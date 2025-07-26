# AppetizerDetailsView Components

This folder contains reusable components extracted from `AppetizerDetailsView` for better code organization and reusability.

## Components

### 1. `NutritionInfoView.swift`
Displays nutritional information (Calories, Carbs, Protein) in a consistent format.

```swift
NutritionInfoView(title: "Calories", value: appetizer.calories)
NutritionInfoView(title: "Carbs", value: appetizer.carbs)
NutritionInfoView(title: "Protein", value: appetizer.protein)
```

### 2. `CloseButtonView.swift`
A reusable close button with the same styling as the original.

```swift
CloseButtonView {
    isShowingDetails = false
}
```

### 3. `AddToOrderButton.swift`
A styled button for adding items to orders with price display.

```swift
AddToOrderButton(price: appetizer.price) {
    // Add to order functionality
}
```

### 4. `AppetizerImageComponent.swift`
A wrapper around `AppetizerRemoteImage` with configurable dimensions.

```swift
AppetizerImageComponent(urlString: appetizer.imageURL)
// or with custom size:
AppetizerImageComponent(urlString: appetizer.imageURL, width: 250, height: 180)
```

## Benefits

- ✅ **Reusable**: Components can be used in other parts of the app
- ✅ **Maintainable**: Changes to styling only need to be made in one place
- ✅ **Testable**: Each component can be tested independently
- ✅ **Organized**: Better file structure and separation of concerns
- ✅ **Consistent**: Same styling across the app when reusing components

## Usage in AppetizerDetailsView

The main `AppetizerDetailsView` now uses these components while maintaining exactly the same appearance and behavior as before. 