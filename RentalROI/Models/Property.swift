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
    
    // Computed properties with defaults for backward compatibility
    var expensePercentageValue: Double {
        return expensePercentage ?? 50.0
    }
    
    var purchaseYearValue: Int {
        return purchaseYear ?? Calendar.current.component(.year, from: Date())
    }
    
    var roi: Double {
        guard initialInvestment > 0 else { return 0 }
        
        // Subtract expenses from rental income
        let netRentalIncome = totalRentalIncome * (1 - expensePercentageValue / 100)
        
        // Calculate total ROI
        let totalROI = ((netRentalIncome + appreciation) / initialInvestment) * 100
        
        // Calculate years since purchase (minimum 1 year)
        let currentYear = Calendar.current.component(.year, from: Date())
        let years = max(1, currentYear - purchaseYearValue)
        
        // Return average annual ROI
        return totalROI / Double(years)
    }
    
    init(id: UUID = UUID(), name: String, initialInvestment: Double, appreciation: Double, totalRentalIncome: Double, expensePercentage: Double? = 50.0, purchaseYear: Int? = nil) {
        self.id = id
        self.name = name
        self.initialInvestment = initialInvestment
        self.appreciation = appreciation
        self.totalRentalIncome = totalRentalIncome
        self.expensePercentage = expensePercentage
        // Default purchase year to current year if not provided
        self.purchaseYear = purchaseYear ?? Calendar.current.component(.year, from: Date())
    }
}
