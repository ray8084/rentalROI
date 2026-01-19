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
    
    var roi: Double {
        guard initialInvestment > 0 else { return 0 }
        return ((totalRentalIncome + appreciation) / initialInvestment) * 100
    }
    
    init(id: UUID = UUID(), name: String, initialInvestment: Double, appreciation: Double, totalRentalIncome: Double) {
        self.id = id
        self.name = name
        self.initialInvestment = initialInvestment
        self.appreciation = appreciation
        self.totalRentalIncome = totalRentalIncome
    }
}
