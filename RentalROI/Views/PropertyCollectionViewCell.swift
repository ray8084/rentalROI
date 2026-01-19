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
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowRadius = 4
        
        // Left column: Property details
        leftColumnStackView.addArrangedSubview(nameLabel)
        leftColumnStackView.addArrangedSubview(initialInvestmentLabel)
        leftColumnStackView.addArrangedSubview(appreciationLabel)
        leftColumnStackView.addArrangedSubview(rentalIncomeLabel)
        
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
    
    func configure(with property: Property) {
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
        appreciationLabel.text = "Appreciation: \(currencyFormatter.string(from: NSNumber(value: property.appreciation)) ?? "$0")"
        rentalIncomeLabel.text = "Rental Income: \(currencyFormatter.string(from: NSNumber(value: property.totalRentalIncome)) ?? "$0")"
        
        let roiValue = property.roi
        roiLabel.text = String(format: "%.1f%%", roiValue)
        roiLabel.textColor = roiValue >= 0 ? .systemGreen : .systemRed
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        initialInvestmentLabel.text = nil
        appreciationLabel.text = nil
        rentalIncomeLabel.text = nil
        roiLabel.text = nil
    }
}
