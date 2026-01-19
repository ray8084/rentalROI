# Rental ROI iOS App

An iOS application built with UIKit to track rental property investments and calculate ROI.

## Features

- List of rental properties displayed in a collection view
- Each property shows:
  - Initial investment
  - Appreciation value
  - Total rental income
  - Auto-calculated ROI percentage
- Add, edit, and delete properties
- Data persistence using UserDefaults

## Getting Started

The Xcode project is already set up and ready to use!

### To Run the App

1. Clone the repository:
   ```bash
   git clone https://github.com/ray8084/rentalROI.git
   cd rentalROI
   ```

2. Open the project in Xcode:
   ```bash
   open RentalROI.xcodeproj
   ```

3. Select a simulator or device from the scheme menu

4. Click Run (⌘R) or press the Play button

The app will build and launch with all features ready to use!

## Project Structure

```
RentalROI/
├── AppDelegate.swift
├── SceneDelegate.swift
├── Models/
│   └── Property.swift
├── Managers/
│   └── PropertyDataManager.swift
└── Views/
    ├── PropertyListViewController.swift
    ├── PropertyCollectionViewCell.swift
    └── PropertyDetailViewController.swift
```

## Requirements

- iOS 13.0+
- Xcode 12.0+
- Swift 5.0+

## ROI Calculation

ROI is automatically calculated as:
```
ROI = ((Total Rental Income + Appreciation) / Initial Investment) × 100
```

The ROI is displayed with color coding:
- Green for positive ROI
- Red for negative ROI
