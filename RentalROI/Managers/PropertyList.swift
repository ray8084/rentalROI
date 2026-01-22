//
//  PropertyList.swift
//  RentalROI
//
//  Created on $(date).
//

import Foundation

class PropertyList {
    private let propertiesKey = "SavedProperties"
    
    init() {}
    
    func saveProperties(_ properties: [Property]) {
        if let encoded = try? JSONEncoder().encode(properties) {
            UserDefaults.standard.set(encoded, forKey: propertiesKey)
        }
    }
    
    func loadProperties() -> [Property] {
        guard let data = UserDefaults.standard.data(forKey: propertiesKey),
              let properties = try? JSONDecoder().decode([Property].self, from: data) else {
            return []
        }
        return properties
    }
    
    func addProperty(_ property: Property) {
        var properties = loadProperties()
        properties.append(property)
        saveProperties(properties)
    }
    
    func updateProperty(_ property: Property) {
        var properties = loadProperties()
        if let index = properties.firstIndex(where: { $0.id == property.id }) {
            properties[index] = property
            saveProperties(properties)
        }
    }
    
    func deleteProperty(withId id: UUID) {
        var properties = loadProperties()
        properties.removeAll(where: { $0.id == id })
        saveProperties(properties)
    }
}
