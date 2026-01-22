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
    private let dataManager: PropertyList
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
        textField.placeholder = "Average Monthly Rent"
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let expensePercentageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Expense Percentage (default: 50%)"
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let purchaseYearTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Purchase Year"
        textField.keyboardType = .numberPad
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let remodelingExpensesTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Remodeling Expenses"
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let landPercentageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Land Percentage"
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let taxRateTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Tax Rate"
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
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete Property", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return button
    }()
    
    // Helper function to create field labels
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        return label
    }
    
    // Helper function to create a horizontal row with label and text field
    private func createFieldRow(labelText: String, textField: UITextField) -> UIStackView {
        let label = createLabel(text: labelText)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let rowStack = UIStackView(arrangedSubviews: [label, textField])
        rowStack.axis = .horizontal
        rowStack.spacing = 12
        rowStack.alignment = .center
        rowStack.distribution = .fill
        
        // Set label width constraint for alignment
        label.widthAnchor.constraint(equalToConstant: 180).isActive = true
        
        return rowStack
    }
    
    // Helper function to format numbers with commas
    private func formatNumber(_ value: Double, decimalPlaces: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = decimalPlaces
        formatter.minimumFractionDigits = decimalPlaces
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.\(decimalPlaces)f", value)
    }
    
    // Helper function to parse numbers, removing commas
    private func parseNumber(_ text: String) -> Double? {
        let cleanedText = text.replacingOccurrences(of: ",", with: "")
        return Double(cleanedText)
    }
    
    // Helper function to parse integers, removing commas
    private func parseInteger(_ text: String) -> Int? {
        let cleanedText = text.replacingOccurrences(of: ",", with: "")
        return Int(cleanedText)
    }
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    init(property: Property? = nil, dataManager: PropertyList) {
        self.property = property
        self.dataManager = dataManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFields()
        setupKeyboardObservers()
        updateROI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    deinit {
        removeKeyboardObservers()
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
        
        // Add labels and fields in horizontal rows
        stackView.addArrangedSubview(createFieldRow(labelText: "Property Name/Address", textField: nameTextField))
        
        stackView.addArrangedSubview(createFieldRow(labelText: "Initial Investment", textField: initialInvestmentTextField))
        
        stackView.addArrangedSubview(createFieldRow(labelText: "Appreciation", textField: appreciationTextField))
        
        stackView.addArrangedSubview(createFieldRow(labelText: "Average Monthly Rent", textField: rentalIncomeTextField))
        
        stackView.addArrangedSubview(createFieldRow(labelText: "Operating Expense %", textField: expensePercentageTextField))
        
        stackView.addArrangedSubview(createFieldRow(labelText: "Purchase Year", textField: purchaseYearTextField))
        
        stackView.addArrangedSubview(createFieldRow(labelText: "Remodeling Expenses", textField: remodelingExpensesTextField))
        
        stackView.addArrangedSubview(createFieldRow(labelText: "Land Percentage %", textField: landPercentageTextField))
        
        stackView.addArrangedSubview(createFieldRow(labelText: "Tax Rate %", textField: taxRateTextField))
        
        stackView.addArrangedSubview(roiLabel)
        
        // Add delete button only when editing an existing property
        if isEditingMode {
            stackView.addArrangedSubview(deleteButton)
            NSLayoutConstraint.activate([
                deleteButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        
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
            initialInvestmentTextField.text = formatNumber(property.initialInvestment)
            appreciationTextField.text = formatNumber(property.appreciation)
            // Convert annual income to monthly rent for display
            rentalIncomeTextField.text = formatNumber(property.totalRentalIncome / 12)
            expensePercentageTextField.text = formatNumber(property.expensePercentageValue, decimalPlaces: 1)
            purchaseYearTextField.text = String(property.purchaseYearValue)
            remodelingExpensesTextField.text = formatNumber(property.remodelingExpensesValue)
            landPercentageTextField.text = formatNumber(property.landPercentageValue, decimalPlaces: 1)
            taxRateTextField.text = formatNumber(property.taxRateValue, decimalPlaces: 1)
        } else {
            // Set defaults for new property
            expensePercentageTextField.text = "50.0"
            let currentYear = Calendar.current.component(.year, from: Date())
            purchaseYearTextField.text = String(currentYear)
            remodelingExpensesTextField.text = "0.0"
            landPercentageTextField.text = "20.0"
            taxRateTextField.text = "25.0"
            rentalIncomeTextField.text = "0.0"
        }
    }
    
    private func setupTextFields() {
        [initialInvestmentTextField, appreciationTextField, rentalIncomeTextField, expensePercentageTextField, purchaseYearTextField, remodelingExpensesTextField, landPercentageTextField, taxRateTextField].forEach { textField in
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            textField.delegate = self
        }
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        
        UIView.animate(withDuration: animationDuration) {
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        }
        
        // Scroll to active text field if needed
        if let activeTextField = findFirstResponder() {
            scrollToTextField(activeTextField)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: animationDuration) {
            self.scrollView.contentInset = .zero
            self.scrollView.scrollIndicatorInsets = .zero
        }
    }
    
    private func findFirstResponder() -> UITextField? {
        let textFields = [nameTextField, initialInvestmentTextField, appreciationTextField, rentalIncomeTextField, expensePercentageTextField, purchaseYearTextField, remodelingExpensesTextField, landPercentageTextField, taxRateTextField]
        return textFields.first { $0.isFirstResponder }
    }
    
    private func scrollToTextField(_ textField: UITextField) {
        let textFieldFrame = textField.convert(textField.bounds, to: scrollView)
        let scrollViewFrame = scrollView.bounds
        let adjustedFrame = CGRect(
            x: textFieldFrame.origin.x,
            y: textFieldFrame.origin.y - 20,
            width: textFieldFrame.width,
            height: textFieldFrame.height + 40
        )
        
        if !scrollViewFrame.contains(adjustedFrame) {
            scrollView.scrollRectToVisible(adjustedFrame, animated: true)
        }
    }
    
    @objc private func textFieldDidChange() {
        updateROI()
    }
    
    private func updateROI() {
        let initialInvestment = parseNumber(initialInvestmentTextField.text ?? "0") ?? 0
        let appreciation = parseNumber(appreciationTextField.text ?? "0") ?? 0
        let monthlyRent = parseNumber(rentalIncomeTextField.text ?? "0") ?? 0
        // Convert monthly rent to annual income
        let rentalIncome = monthlyRent * 12
        let expensePercentage = parseNumber(expensePercentageTextField.text ?? "50") ?? 50.0
        let purchaseYear = parseInteger(purchaseYearTextField.text ?? "") ?? Calendar.current.component(.year, from: Date())
        let remodelingExpenses = parseNumber(remodelingExpensesTextField.text ?? "0") ?? 0.0
        let landPercentage = parseNumber(landPercentageTextField.text ?? "20") ?? 20.0
        let taxRate = parseNumber(taxRateTextField.text ?? "25") ?? 25.0
        
        // Total investment includes initial investment and remodeling expenses
        let totalInvestment = initialInvestment + remodelingExpenses
        
        let roi: Double
        if totalInvestment > 0 {
            // Subtract expenses from rental income
            let netRentalIncome = rentalIncome * (1 - expensePercentage / 100)
            
            // Calculate depreciation tax benefit
            // Property value = Initial Investment + Remodeling Expenses
            let propertyValue = initialInvestment + remodelingExpenses
            
            // Land value = Property value × Land percentage
            let landValue = propertyValue * (landPercentage / 100)
            
            // Depreciable value = Property value - Land value
            let depreciableValue = propertyValue - landValue
            
            // Annual depreciation = Depreciable value / 27.5 years (residential)
            let annualDepreciation = depreciableValue / 27.5
            
            // Tax savings = Annual depreciation × Tax rate
            let taxSavings = annualDepreciation * (taxRate / 100)
            
            // Calculate total ROI including tax savings from depreciation
            let totalROI = ((netRentalIncome + appreciation + taxSavings) / totalInvestment) * 100
            
            // Calculate years since purchase (minimum 1 year)
            let currentYear = Calendar.current.component(.year, from: Date())
            let years = max(1, currentYear - purchaseYear)
            
            // Calculate average annual ROI
            roi = totalROI / Double(years)
        } else {
            roi = 0
        }
        
        roiLabel.text = String(format: "Annual ROI: %.1f%%", roi)
        roiLabel.textColor = roi >= 0 ? .systemGreen : .systemRed
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let initialInvestmentText = initialInvestmentTextField.text,
              let initialInvestment = parseNumber(initialInvestmentText),
              let appreciationText = appreciationTextField.text,
              let appreciation = parseNumber(appreciationText),
              let monthlyRentText = rentalIncomeTextField.text,
              let monthlyRent = parseNumber(monthlyRentText),
              let purchaseYearText = purchaseYearTextField.text,
              let purchaseYear = parseInteger(purchaseYearText) else {
            showError(message: "Please fill in all fields with valid numbers")
            return
        }
        
        // Convert monthly rent to annual income for storage
        let rentalIncome = monthlyRent * 12
        
        let expensePercentage = parseNumber(expensePercentageTextField.text ?? "50") ?? 50.0
        let remodelingExpenses = parseNumber(remodelingExpensesTextField.text ?? "0") ?? 0.0
        let landPercentage = parseNumber(landPercentageTextField.text ?? "20") ?? 20.0
        let taxRate = parseNumber(taxRateTextField.text ?? "25") ?? 25.0
        
        if isEditingMode, let existingProperty = property {
            var updatedProperty = Property(
                id: existingProperty.id,
                name: name,
                initialInvestment: initialInvestment,
                appreciation: appreciation,
                totalRentalIncome: rentalIncome,
                expensePercentage: expensePercentage,
                purchaseYear: purchaseYear,
                remodelingExpenses: remodelingExpenses,
                landPercentage: landPercentage,
                taxRate: taxRate
            )
            dataManager.updateProperty(updatedProperty)
        } else {
            let newProperty = Property(
                name: name,
                initialInvestment: initialInvestment,
                appreciation: appreciation,
                totalRentalIncome: rentalIncome,
                expensePercentage: expensePercentage,
                purchaseYear: purchaseYear,
                remodelingExpenses: remodelingExpenses,
                landPercentage: landPercentage,
                taxRate: taxRate
            )
            dataManager.addProperty(newProperty)
        }
        
        completionHandler?()
        dismiss(animated: true)
    }
    
    @objc private func deleteTapped() {
        guard let property = property else { return }
        
        let alert = UIAlertController(
            title: "Delete Property",
            message: "Are you sure you want to delete \(property.name)? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self, let property = self.property else { return }
            self.dataManager.deleteProperty(withId: property.id)
            self.completionHandler?()
            self.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension PropertyDetailViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollToTextField(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Format numbers with commas when editing ends
        if textField == initialInvestmentTextField || 
           textField == appreciationTextField || 
           textField == rentalIncomeTextField || 
           textField == remodelingExpensesTextField {
            if let text = textField.text, let value = parseNumber(text) {
                textField.text = formatNumber(value)
            }
        } else if textField == expensePercentageTextField || 
                  textField == landPercentageTextField || 
                  textField == taxRateTextField {
            if let text = textField.text, let value = parseNumber(text) {
                textField.text = formatNumber(value, decimalPlaces: 1)
            }
        }
        updateROI()
    }
}
