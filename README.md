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

## Setup Instructions

### Option 1: Create Xcode Project (Recommended)

1. Open Xcode
2. Create a new project:
   - File → New → Project
   - Choose "App" under iOS
   - Product Name: `RentalROI`
   - Interface: `Storyboard` (we'll delete it)
   - Language: `Swift`
   - Use Core Data: `No`
   - Include Tests: Optional

3. Delete the default `Main.storyboard` file and remove it from the project

4. Delete the `ViewController.swift` file

5. In the project settings:
   - Go to the project target → General tab
   - Set "Main Interface" to empty (clear the field)
   - Go to Info tab → Custom iOS Target Properties
   - Remove `UISceneStoryboardFile` if present

6. Copy all the files from this repository:
   - `RentalROI/AppDelegate.swift` → Replace the default AppDelegate
   - `RentalROI/SceneDelegate.swift` → Add to project
   - `RentalROI/Models/Property.swift` → Add to project (create Models group if needed)
   - `RentalROI/Managers/PropertyDataManager.swift` → Add to project (create Managers group if needed)
   - `RentalROI/Views/PropertyListViewController.swift` → Add to project (create Views group if needed)
   - `RentalROI/Views/PropertyCollectionViewCell.swift` → Add to project
   - `RentalROI/Views/PropertyDetailViewController.swift` → Add to project
   - `RentalROI/Supporting/Info.plist` → Update or replace your Info.plist

7. Ensure all files are added to the target membership in Xcode

8. Build and run!

### Option 2: Using Project Generator Script

If you have `xcodegen` installed, you can use the project.yml configuration.

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
