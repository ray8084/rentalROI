//
//  ImportProgressViewController.swift
//  RentalROI
//
//  Created on $(date).
//

import UIKit

class ImportProgressViewController: UIViewController {
    enum ImportStage {
        case downloading
        case copying
        case reading
        case validating
        case importing
        case complete
        case error(String)
    }
    
    var onCancel: (() -> Void)?
    private var currentStage: ImportStage = .downloading
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Importing Properties"
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let fileNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        return indicator
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .systemGreen
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(fileNameLabel)
        containerView.addSubview(progressIndicator)
        containerView.addSubview(checkmarkImageView)
        containerView.addSubview(statusLabel)
        containerView.addSubview(cancelButton)
        
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            fileNameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            fileNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            fileNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            progressIndicator.topAnchor.constraint(equalTo: fileNameLabel.bottomAnchor, constant: 24),
            progressIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            checkmarkImageView.topAnchor.constraint(equalTo: fileNameLabel.bottomAnchor, constant: 24),
            checkmarkImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 60),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 60),
            
            statusLabel.topAnchor.constraint(equalTo: progressIndicator.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            cancelButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 24),
            cancelButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),
            cancelButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func setFileName(_ fileName: String) {
        fileNameLabel.text = fileName
    }
    
    func updateStage(_ stage: ImportStage) {
        currentStage = stage
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch stage {
            case .downloading:
                self.statusLabel.text = "Downloading from iCloud..."
                self.progressIndicator.isHidden = false
                self.checkmarkImageView.isHidden = true
                self.cancelButton.isHidden = false
                
            case .copying:
                self.statusLabel.text = "Copying file..."
                self.progressIndicator.isHidden = false
                self.checkmarkImageView.isHidden = true
                self.cancelButton.isHidden = false
                
            case .reading:
                self.statusLabel.text = "Reading file..."
                self.progressIndicator.isHidden = false
                self.checkmarkImageView.isHidden = true
                self.cancelButton.isHidden = false
                
            case .validating:
                self.statusLabel.text = "Validating data..."
                self.progressIndicator.isHidden = false
                self.checkmarkImageView.isHidden = true
                self.cancelButton.isHidden = false
                
            case .importing:
                self.statusLabel.text = "Importing properties..."
                self.progressIndicator.isHidden = false
                self.checkmarkImageView.isHidden = true
                self.cancelButton.isHidden = false
                
            case .complete:
                self.statusLabel.text = "Import complete!"
                self.progressIndicator.isHidden = true
                self.checkmarkImageView.isHidden = false
                self.cancelButton.setTitle("Done", for: .normal)
                
            case .error(let message):
                self.statusLabel.text = "Error: \(message)"
                self.statusLabel.textColor = .systemRed
                self.progressIndicator.isHidden = true
                self.checkmarkImageView.isHidden = true
                self.cancelButton.setTitle("Close", for: .normal)
            }
        }
    }
    
    @objc private func cancelTapped() {
        if case .complete = currentStage {
            dismiss(animated: true)
        } else if case .error = currentStage {
            dismiss(animated: true)
        } else {
            onCancel?()
        }
    }
}
