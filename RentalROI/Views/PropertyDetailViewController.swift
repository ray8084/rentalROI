//
//  PropertyDetailViewController.swift
//  RentalROI
//
//  Created on $(date).
//

import UIKit

class PropertyDetailViewController: UIViewController {
    var completionHandler: (() -> Void)?
    private var property: Property?
    private var isEditingMode: Bool {
        return property != nil
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Property Name/Address"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let initialInvestmentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Initial Investment"
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let appreciationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Appreciation"
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let rentalIncomeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Total Rental Income"
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let roiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.text = "ROI: 0.0%"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    init(property: Property? = nil) {
        self.property = property
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFields()
        updateROI()
    }
    
    private func setupUI() {
        title = isEditingMode ? "Edit Property" : "Add Property"
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(initialInvestmentTextField)
        stackView.addArrangedSubview(appreciationTextField)
        stackView.addArrangedSubview(rentalIncomeTextField)
        stackView.addArrangedSubview(roiLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20)
        ])
        
        if let property = property {
            nameTextField.text = property.name
            initialInvestmentTextField.text = String(format: "%.2f", property.initialInvestment)
            appreciationTextField.text = String(format: "%.2f", property.appreciation)
            rentalIncomeTextField.text = String(format: "%.2f", property.totalRentalIncome)
        }
    }
    
    private func setupTextFields() {
        [initialInvestmentTextField, appreciationTextField, rentalIncomeTextField].forEach { textField in
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
    }
    
    @objc private func textFieldDidChange() {
        updateROI()
    }
    
    private func updateROI() {
        let initialInvestment = Double(initialInvestmentTextField.text ?? "0") ?? 0
        let appreciation = Double(appreciationTextField.text ?? "0") ?? 0
        let rentalIncome = Double(rentalIncomeTextField.text ?? "0") ?? 0
        
        let roi: Double
        if initialInvestment > 0 {
            roi = ((rentalIncome + appreciation) / initialInvestment) * 100
        } else {
            roi = 0
        }
        
        roiLabel.text = String(format: "ROI: %.1f%%", roi)
        roiLabel.textColor = roi >= 0 ? .systemGreen : .systemRed
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let initialInvestmentText = initialInvestmentTextField.text,
              let initialInvestment = Double(initialInvestmentText),
              let appreciationText = appreciationTextField.text,
              let appreciation = Double(appreciationText),
              let rentalIncomeText = rentalIncomeTextField.text,
              let rentalIncome = Double(rentalIncomeText) else {
            showError(message: "Please fill in all fields with valid numbers")
            return
        }
        
        if isEditingMode, let existingProperty = property {
            let updatedProperty = Property(
                id: existingProperty.id,
                name: name,
                initialInvestment: initialInvestment,
                appreciation: appreciation,
                totalRentalIncome: rentalIncome
            )
            PropertyDataManager.shared.updateProperty(updatedProperty)
        } else {
            let newProperty = Property(
                name: name,
                initialInvestment: initialInvestment,
                appreciation: appreciation,
                totalRentalIncome: rentalIncome
            )
            PropertyDataManager.shared.addProperty(newProperty)
        }
        
        completionHandler?()
        dismiss(animated: true)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
