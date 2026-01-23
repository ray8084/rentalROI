//
//  PropertyListViewController.swift
//  RentalROI
//
//  Created on $(date).
//

import UIKit
import MobileCoreServices

class PropertyListViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var properties: [Property] = []
    private let dataManager = PropertyList()
    private var importProgressVC: ImportProgressViewController?
    private var importBackup: Data?
    private var importCancelled = false
    private var viewMode: ViewMode = .details
    private var segmentedControl: UISegmentedControl!
    
    enum ViewMode {
        case summary
        case details
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadProperties()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProperties()
    }
    
    private func setupUI() {
        title = "Real ROI"
        view.backgroundColor = .systemGroupedBackground
        
        // Setup segmented control for view mode toggle
        segmentedControl = UISegmentedControl(items: ["Summary", "Details"])
        segmentedControl.selectedSegmentIndex = 1 // Default to Details
        segmentedControl.addTarget(self, action: #selector(viewModeChanged), for: .valueChanged)
        navigationItem.titleView = segmentedControl
        
        // Setup navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addPropertyTapped)
        )
        
        updateLeftBarButton()
        
        // Setup collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        // Single column layout for wider cards
        let spacing: CGFloat = 16
        let itemsPerRow: CGFloat = 1
        let totalSpacing = spacing * (itemsPerRow - 1) + (layout.sectionInset.left + layout.sectionInset.right)
        let itemWidth = (view.bounds.width - totalSpacing) / itemsPerRow
        layout.itemSize = CGSize(width: itemWidth, height: 140)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(PropertyCollectionViewCell.self, forCellWithReuseIdentifier: PropertyCollectionViewCell.identifier)
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadProperties() {
        properties = dataManager.loadProperties()
        collectionView.reloadData()
        updateLeftBarButton()
    }
    
    private func updateLeftBarButton() {
        if properties.isEmpty {
            // Show import button when empty
            let importButton = UIBarButtonItem(
                image: UIImage(systemName: "square.and.arrow.down"),
                style: .plain,
                target: self,
                action: #selector(importProperties)
            )
            importButton.accessibilityLabel = "Import Properties"
            navigationItem.leftBarButtonItem = importButton
        } else {
            // Show export button when there are properties
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .action,
                target: self,
                action: #selector(shareProperties)
            )
        }
    }
    
    @objc private func addPropertyTapped() {
        let detailVC = PropertyDetailViewController(dataManager: dataManager)
        detailVC.completionHandler = { [weak self] in
            self?.loadProperties()
        }
        let navController = UINavigationController(rootViewController: detailVC)
        present(navController, animated: true)
    }
    
    @objc private func shareProperties() {
        // Check if there are properties to share
        guard !properties.isEmpty else {
            let alert = UIAlertController(
                title: "No Properties",
                message: "There are no properties to share.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Get JSON data
        guard let jsonData = dataManager.exportPropertiesAsJSON() else {
            let alert = UIAlertController(
                title: "Export Error",
                message: "Failed to export properties data.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Create temporary file
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        let fileName = "rental-properties-\(dateString).json"
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        // Write JSON data to file
        do {
            try jsonData.write(to: fileURL)
        } catch {
            let alert = UIAlertController(
                title: "Export Error",
                message: "Failed to create export file: \(error.localizedDescription)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Create and present share sheet
        let activityViewController = UIActivityViewController(
            activityItems: [fileURL],
            applicationActivities: nil
        )
        
        // For iPad support
        if let popover = activityViewController.popoverPresentationController {
            popover.barButtonItem = navigationItem.leftBarButtonItem
        }
        
        // Clean up temporary file after sharing completes
        activityViewController.completionWithItemsHandler = { _, _, _, _ in
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        present(activityViewController, animated: true)
    }
    
    @objc private func importProperties() {
        // Use kUTTypeJSON for iOS 13.0 compatibility
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeJSON as String], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        
        // For iPad support
        if let popover = documentPicker.popoverPresentationController {
            popover.barButtonItem = navigationItem.leftBarButtonItem
        }
        
        present(documentPicker, animated: true)
    }
    
    @objc private func viewModeChanged() {
        viewMode = segmentedControl.selectedSegmentIndex == 0 ? .summary : .details
        collectionView.reloadData()
    }
}

extension PropertyListViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        
        let fileName = url.lastPathComponent
        
        // 1. Dismiss picker immediately
        controller.dismiss(animated: true)
        
        // 2. Create backup for undo
        importBackup = dataManager.createBackup()
        importCancelled = false
        
        // 3. Show custom progress UI
        let progressVC = ImportProgressViewController()
        progressVC.setFileName(fileName)
        progressVC.modalPresentationStyle = .overFullScreen
        progressVC.onCancel = { [weak self] in
            self?.importCancelled = true
            progressVC.dismiss(animated: true)
        }
        importProgressVC = progressVC
        present(progressVC, animated: true)
        
        // 4. Process import on background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self, !self.importCancelled else { return }
            
            // Request access to the security-scoped resource
            let hasAccess = url.startAccessingSecurityScopedResource()
            defer {
                if hasAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            do {
                // Stage 1: Check if file needs downloading from iCloud
                var resourceValues = try url.resourceValues(forKeys: [.isUbiquitousItemKey, .ubiquitousItemDownloadingStatusKey])
                
                if let isUbiquitous = resourceValues.isUbiquitousItem, isUbiquitous {
                    // Check download status (available in iOS 13.0+)
                    if let downloadStatus = resourceValues.ubiquitousItemDownloadingStatus {
                        // .notDownloaded and .downloading are the enum cases
                        if downloadStatus == URLUbiquitousItemDownloadingStatus.notDownloaded {
                            DispatchQueue.main.async {
                                progressVC.updateStage(.downloading)
                            }
                            
                            // Start downloading from iCloud
                            try FileManager.default.startDownloadingUbiquitousItem(at: url)
                            
                            // Wait for download to complete (with timeout)
                            // Check periodically for up to 15 seconds
                            for _ in 0..<30 {
                                if self.importCancelled { return }
                                
                                do {
                                    resourceValues = try url.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
                                    if let status = resourceValues.ubiquitousItemDownloadingStatus, status == URLUbiquitousItemDownloadingStatus.current {
                                        break
                                    }
                                } catch {
                                    // Continue checking
                                }
                                
                                // Wait 0.5 seconds before next check
                                RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
                            }
                            
                            if self.importCancelled { return }
                        }
                    }
                }
                
                // Stage 2: Copy file to local sandbox
                DispatchQueue.main.async {
                    progressVC.updateStage(.copying)
                }
                
                let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                let importsDir = appSupport.appendingPathComponent("Imports", isDirectory: true)
                try? FileManager.default.createDirectory(at: importsDir, withIntermediateDirectories: true)
                
                let localURL = importsDir.appendingPathComponent(UUID().uuidString + ".json")
                try FileManager.default.copyItem(at: url, to: localURL)
                defer {
                    try? FileManager.default.removeItem(at: localURL)
                }
                
                if self.importCancelled { return }
                
                // Stage 3: Read file
                DispatchQueue.main.async {
                    progressVC.updateStage(.reading)
                }
                
                let fileData = try Data(contentsOf: localURL)
                
                if self.importCancelled { return }
                
                // Stage 4: Validate JSON
                DispatchQueue.main.async {
                    progressVC.updateStage(.validating)
                }
                
                guard let _ = try? JSONDecoder().decode([Property].self, from: fileData) else {
                    throw NSError(domain: "ImportError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format or file structure"])
                }
                
                if self.importCancelled { return }
                
                // Stage 5: Import
                DispatchQueue.main.async {
                    progressVC.updateStage(.importing)
                }
                
                guard self.dataManager.importPropertiesFromJSON(fileData) else {
                    throw NSError(domain: "ImportError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to import properties"])
                }
                
                if self.importCancelled {
                    // Restore backup if cancelled during import
                    if let backup = self.importBackup {
                        _ = self.dataManager.restoreFromBackup(backup)
                    }
                    return
                }
                
                // Stage 6: Complete
                let importedProperties = self.dataManager.loadProperties()
                let propertyCount = importedProperties.count
                
                DispatchQueue.main.async {
                    progressVC.updateStage(.complete)
                    self.loadProperties()
                    
                    // Show toast notification
                    self.showToast(message: "Imported \(propertyCount) propert\(propertyCount == 1 ? "y" : "ies")")
                    
                    // Dismiss progress view after a brief delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        progressVC.dismiss(animated: true)
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    progressVC.updateStage(.error(error.localizedDescription))
                }
            }
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // User cancelled, do nothing
    }
    
    private func showImportError(message: String) {
        let alert = UIAlertController(
            title: "Import Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.font = .systemFont(ofSize: 16, weight: .medium)
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textAlignment = .center
        toastLabel.layer.cornerRadius = 12
        toastLabel.clipsToBounds = true
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.alpha = 0
        
        view.addSubview(toastLabel)
        
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            toastLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            toastLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),
            toastLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        UIView.animate(withDuration: 0.3) {
            toastLabel.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0) {
                toastLabel.alpha = 0
            } completion: { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
    
    private func showImportResults(propertyCount: Int, fileName: String) {
        let alert = UIAlertController(
            title: "Import Complete",
            message: "Successfully imported \(propertyCount) propert\(propertyCount == 1 ? "y" : "ies") from \(fileName).",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func undoLastImport() {
        guard let backup = importBackup else { return }
        
        if dataManager.restoreFromBackup(backup) {
            loadProperties()
            showToast(message: "Import undone")
        } else {
            showImportError(message: "Failed to undo import")
        }
        
        importBackup = nil
    }
}

extension PropertyListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return properties.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PropertyCollectionViewCell.identifier, for: indexPath) as! PropertyCollectionViewCell
        cell.configure(with: properties[indexPath.item], isSummaryMode: viewMode == .summary)
        return cell
    }
}

extension PropertyListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let property = properties[indexPath.item]
        let detailVC = PropertyDetailViewController(property: property, dataManager: dataManager)
        detailVC.completionHandler = { [weak self] in
            self?.loadProperties()
        }
        let navController = UINavigationController(rootViewController: detailVC)
        present(navController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let property = properties[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.deleteProperty(property)
            }
            return UIMenu(title: "", children: [deleteAction])
        }
    }
    
    private func deleteProperty(_ property: Property) {
        let alert = UIAlertController(
            title: "Delete Property",
            message: "Are you sure you want to delete \(property.name)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.dataManager.deleteProperty(withId: property.id)
            self?.loadProperties()
        })
        
        present(alert, animated: true)
    }
}

extension PropertyListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        // Single column layout for wider cards
        let itemsPerRow: CGFloat = 1
        let totalSpacing = layout.minimumInteritemSpacing * (itemsPerRow - 1) + layout.sectionInset.left + layout.sectionInset.right
        let itemWidth = (collectionView.bounds.width - totalSpacing) / itemsPerRow
        // Adjust height based on view mode: summary shows name, investment, total return, and ROI
        // Details view includes: name, investment, purchase year, appreciation, total rent, total expenses, and ROI
        let itemHeight: CGFloat = viewMode == .summary ? 100 : 170
        return CGSize(width: itemWidth, height: itemHeight)
    }
}
