//
//  PropertyCollectionViewCell.swift
//  RentalROI
//
//  Created on $(date).
//

import UIKit

class PropertyCollectionViewCell: UICollectionViewCell {
    static let identifier = "PropertyCollectionViewCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    private let initialInvestmentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let appreciationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let rentalIncomeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let totalExpensesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let totalReturnLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let purchaseYearLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let roiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textAlignment = .right
        return label
    }()
    
    private let leftColumnStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        stack.distribution = .fill
        return stack
    }()
    
    private let rightColumnStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .trailing
        stack.distribution = .fill
        return stack
    }()
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .top
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Use systemBackground in light mode, secondarySystemGroupedBackground in dark mode (lighter than main background)
        contentView.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .secondarySystemGroupedBackground : .systemBackground
        }
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowRadius = 4
        
        // Left column: Property details
        leftColumnStackView.addArrangedSubview(nameLabel)
        leftColumnStackView.addArrangedSubview(initialInvestmentLabel)
        leftColumnStackView.addArrangedSubview(totalReturnLabel)
        leftColumnStackView.addArrangedSubview(purchaseYearLabel)
        leftColumnStackView.addArrangedSubview(appreciationLabel)
        leftColumnStackView.addArrangedSubview(rentalIncomeLabel)
        leftColumnStackView.addArrangedSubview(totalExpensesLabel)
        
        // Right column: ROI
        rightColumnStackView.addArrangedSubview(roiLabel)
        
        // Main horizontal stack with two columns
        mainStackView.addArrangedSubview(leftColumnStackView)
        mainStackView.addArrangedSubview(rightColumnStackView)
        
        contentView.addSubview(mainStackView)
        
        // Set column widths - left column flexible, right column fixed size for ROI
        leftColumnStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        rightColumnStackView.setContentHuggingPriority(.required, for: .horizontal)
        rightColumnStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with property: Property, isSummaryMode: Bool) {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 0
        
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        percentageFormatter.maximumFractionDigits = 1
        percentageFormatter.minimumFractionDigits = 1
        percentageFormatter.multiplier = 1
        
        nameLabel.text = property.name
        initialInvestmentLabel.text = "Investment: \(currencyFormatter.string(from: NSNumber(value: property.initialInvestment)) ?? "$0")"
        
        // Calculate total return over entire time frame
        let currentYear = Calendar.current.component(.year, from: Date())
        let years = max(1, currentYear - property.purchaseYearValue)
        let cumulativeRent = property.totalRentalIncome * Double(years)
        let cumulativeExpenses = property.totalExpenses * Double(years)
        let cumulativeNetRentalIncome = cumulativeRent - cumulativeExpenses
        
        // Gains = Appreciation + Net Rental Income
        // Note: Tax savings are already included in totalExpenses (they reduce expenses),
        // so we don't add them separately to avoid double-counting
        let totalReturn = property.appreciation + cumulativeNetRentalIncome
        totalReturnLabel.text = "Gains: \(currencyFormatter.string(from: NSNumber(value: totalReturn)) ?? "$0")"
        
        let roiValue = property.roi
        roiLabel.text = String(format: "%.1f%%", roiValue)
        let appGreen = UIColor(red: 120/255.0, green: 180/255.0, blue: 60/255.0, alpha: 1.0)
        roiLabel.textColor = roiValue >= 0 ? appGreen : .systemRed
        
        // Show/hide labels based on view mode
        if isSummaryMode {
            // Summary view: show name, investment, total return, and ROI
            totalReturnLabel.isHidden = false
            purchaseYearLabel.isHidden = true
            appreciationLabel.isHidden = true
            rentalIncomeLabel.isHidden = true
            totalExpensesLabel.isHidden = true
        } else {
            // Details view: show all information
            totalReturnLabel.isHidden = true
            purchaseYearLabel.isHidden = false
            appreciationLabel.isHidden = false
            rentalIncomeLabel.isHidden = false
            totalExpensesLabel.isHidden = false
            
            purchaseYearLabel.text = "Purchase Year: \(property.purchaseYearValue)"
            appreciationLabel.text = "Appreciation: \(currencyFormatter.string(from: NSNumber(value: property.appreciation)) ?? "$0")"
            
            rentalIncomeLabel.text = "Total Rent: \(currencyFormatter.string(from: NSNumber(value: cumulativeRent)) ?? "$0")"
            totalExpensesLabel.text = "Total Expenses: \(currencyFormatter.string(from: NSNumber(value: cumulativeExpenses)) ?? "$0")"
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        initialInvestmentLabel.text = nil
        totalReturnLabel.text = nil
        purchaseYearLabel.text = nil
        appreciationLabel.text = nil
        rentalIncomeLabel.text = nil
        totalExpensesLabel.text = nil
        roiLabel.text = nil
        // Reset visibility
        totalReturnLabel.isHidden = false
        purchaseYearLabel.isHidden = false
        appreciationLabel.isHidden = false
        rentalIncomeLabel.isHidden = false
        totalExpensesLabel.isHidden = false
    }
}
