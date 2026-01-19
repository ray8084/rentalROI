//
//  Property.swift
//  RentalROI
//
//  Created on $(date).
//

import Foundation

struct Property: Codable {
    let id: UUID
    var name: String
    var initialInvestment: Double
    var appreciation: Double
    var totalRentalIncome: Double
    var expensePercentage: Double?
    var purchaseYear: Int?
    var remodelingExpenses: Double?
    var landPercentage: Double?
    var taxRate: Double?
    
    // Computed properties with defaults for backward compatibility
    var expensePercentageValue: Double {
        return expensePercentage ?? 50.0
    }
    
    var purchaseYearValue: Int {
        return purchaseYear ?? Calendar.current.component(.year, from: Date())
    }
    
    var remodelingExpensesValue: Double {
        return remodelingExpenses ?? 0.0
    }
    
    var landPercentageValue: Double {
        return landPercentage ?? 20.0
    }
    
    var taxRateValue: Double {
        return taxRate ?? 25.0
    }
    
    // Calculate total expenses (operating expenses minus tax savings from depreciation)
    var totalExpenses: Double {
        // Operating expenses = rental income × expense percentage
        let operatingExpenses = totalRentalIncome * (expensePercentageValue / 100)
        
        // Calculate depreciation tax benefit
        let propertyValue = initialInvestment + remodelingExpensesValue
        let landValue = propertyValue * (landPercentageValue / 100)
        let depreciableValue = propertyValue - landValue
        let annualDepreciation = depreciableValue / 27.5
        let taxSavings = annualDepreciation * (taxRateValue / 100)
        
        // Net expenses = operating expenses - tax savings from depreciation
        return operatingExpenses - taxSavings
    }
    
    var roi: Double {
        // Total investment includes initial investment and remodeling expenses
        let totalInvestment = initialInvestment + remodelingExpensesValue
        
        guard totalInvestment > 0 else { return 0 }
        
        // Subtract expenses from rental income
        let netRentalIncome = totalRentalIncome * (1 - expensePercentageValue / 100)
        
        // Calculate depreciation tax benefit
        // Property value = Initial Investment + Remodeling Expenses
        let propertyValue = initialInvestment + remodelingExpensesValue
        
        // Land value = Property value × Land percentage
        let landValue = propertyValue * (landPercentageValue / 100)
        
        // Depreciable value = Property value - Land value
        let depreciableValue = propertyValue - landValue
        
        // Annual depreciation = Depreciable value / 27.5 years (residential)
        let annualDepreciation = depreciableValue / 27.5
        
        // Tax savings = Annual depreciation × Tax rate
        let taxSavings = annualDepreciation * (taxRateValue / 100)
        
        // Calculate total ROI including tax savings from depreciation
        let totalROI = ((netRentalIncome + appreciation + taxSavings) / totalInvestment) * 100
        
        // Calculate years since purchase (minimum 1 year)
        let currentYear = Calendar.current.component(.year, from: Date())
        let years = max(1, currentYear - purchaseYearValue)
        
        // Return average annual ROI
        return totalROI / Double(years)
    }
    
    init(id: UUID = UUID(), name: String, initialInvestment: Double, appreciation: Double, totalRentalIncome: Double, expensePercentage: Double? = 50.0, purchaseYear: Int? = nil, remodelingExpenses: Double? = 0.0, landPercentage: Double? = 20.0, taxRate: Double? = 25.0) {
        self.id = id
        self.name = name
        self.initialInvestment = initialInvestment
        self.appreciation = appreciation
        self.totalRentalIncome = totalRentalIncome
        self.expensePercentage = expensePercentage
        // Default purchase year to current year if not provided
        self.purchaseYear = purchaseYear ?? Calendar.current.component(.year, from: Date())
        self.remodelingExpenses = remodelingExpenses
        self.landPercentage = landPercentage
        self.taxRate = taxRate
    }
}
