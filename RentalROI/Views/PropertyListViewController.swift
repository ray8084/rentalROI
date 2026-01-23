//
//  PropertyListViewController.swift
//  RentalROI
//
//  Created on $(date).
//

import UIKit

class PropertyListViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var properties: [Property] = []
    private let dataManager = PropertyList()
    
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
        
        // Setup navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addPropertyTapped)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareProperties)
        )
        
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
}

extension PropertyListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return properties.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PropertyCollectionViewCell.identifier, for: indexPath) as! PropertyCollectionViewCell
        cell.configure(with: properties[indexPath.item])
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
        return CGSize(width: itemWidth, height: 140)
    }
}
