# Localized

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange?logo=swift)](https://swift.org)
[![SPM](https://img.shields.io/badge/SPM-Compatible-brightgreen?logo=hackthebox)](https://swift.org/package-manager)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2013+%20|%20macOS%2010.15+%20|%20tvOS%2013+%20|%20watchOS%206+-blue?logo=apple)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-purple?logo=bitwarden)](LICENSE)

A Swift macro that automatically generates localized string properties for enums, making internationalization in Swift projects more type-safe and maintainable.

## Features

- **Type-safe localization**: Convert enum cases to localization keys automatically
- **Multiple key formats**: Support for upper snake case, lower snake case, camel case, and Pascal case
- **String formatting**: Automatic handling of associated values for string interpolation
- **Bundle support**: Custom bundle support for modular apps
- **Compile-time validation**: Detect key conflicts and invalid usage at compile time
- **Zero runtime overhead**: All code is generated at compile time

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/EyalKatz24/Localized.git", from: "1.0.0")
]
```

Or add it to your Xcode project:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select the version you want to use

## Usage

### Basic Usage

Simply add the `@Localized` macro to any enum:

```swift
@Localized
enum Localization {
    case ok
    case cancel
    case welcome
    case goodbye
}
```

This generates:
- A `localized` property that returns the localized string
- A `localizedKey` property that returns the localization key
- A private `localized(_:)` function for internal use

### With Associated Values

The macro automatically handles associated values for string formatting:

```swift
@Localized
enum Localization {
    case welcome(name: String)
    case totalCost(amount: Double, currency: String)
    case items(count: Int, itemName: String)
}
```

### Key Format Options

You can customize how enum cases are converted to localization keys:

```swift
// Upper snake case (default): HELLO_WORLD
@Localized
enum Localization {
    case helloWorld
}

// Lower snake case: hello_world
@Localized(keyFormat: .lowerSnakeCase)
enum Localization {
    case helloWorld
}

// Camel case: helloWorld
@Localized(keyFormat: .camelCase)
enum Localization {
    case helloWorld
}

// Pascal case: HelloWorld
@Localized(keyFormat: .pascalCase)
enum Localization {
    case helloWorld
}
```

### Custom Bundle Support

For modular apps or frameworks, you can specify a custom bundle:

```swift
@Localized(bundleId: "com.myapp.core")
enum CoreLocalization {
    case welcome
    case error
}

// Or with both key format and bundle
@Localized(keyFormat: .camelCase, bundleId: "com.myapp.features")
enum FeatureLocalization {
    case newFeature
    case settings
}
```

### Using with Bundle.module

When using in a Swift Package, you can use `Bundle.module`:

```swift
@Localized(bundleId: "\(Bundle.module.bundleIdentifier!)")
enum PackageLocalization {
    case packageSpecific
}
```

## Generated Code

The macro generates the following code for each enum:

```swift
@Localized
enum Localization {
    case welcome(name: String)
    case goodbye
    
    // Generated properties and methods
    public var localized: String {
        switch self {
        case let .welcome(value0):
            String(format: localized("WELCOME"), value0)
        case .goodbye:
            localized("GOODBYE")
        }
    }
    
    public var localizedKey: String {
        switch self {
        case .welcome:
            "WELCOME"
        case .goodbye:
            "GOODBYE"
        }
    }
    
    private func localized(_ string: String) -> String {
        NSLocalizedString(string, comment: "")
    }
}
```

## Localization Files

Create your `.strings` files with the generated keys:

**Localizable.strings (English)**
```
"OK" = "OK";
"CANCEL" = "Cancel";
"WELCOME" = "Welcome, %@!";
"TOTAL_COST" = "Total: %@ %@";
"ITEMS" = "%d %@";
```

**Localizable.strings (Spanish)**
```
"OK" = "Aceptar";
"CANCEL" = "Cancelar";
"WELCOME" = "¡Bienvenido, %@!";
"TOTAL_COST" = "Total: %@ %@";
"ITEMS" = "%d %@";
```

## Best Practices

### 1. Organize by Feature

Instead of one large localization enum, consider organizing by feature:

```swift
@Localized
enum AuthLocalization {
    case login
    case logout
    case invalidCredentials
}

@Localized
enum ProfileLocalization {
    case editProfile
    case saveChanges
    case profileUpdated
}
```

### 2. Use Descriptive Case Names

Make your enum cases descriptive and self-documenting:

```swift
// Good
case welcomeMessage(userName: String)
case paymentFailed(reason: String)

// Avoid
case wm(name: String)
case pf(reason: String)
```

### 3. Handle Special Characters

The macro automatically handles special characters and reserved words:

```swift
@Localized
enum Localization {
    case `class` // Becomes "CLASS"
    case `struct` // Becomes "STRUCT"
    case `enum` // Becomes "ENUM"
    case hello_world // Becomes "HELLO_WORLD"
}
```

## Error Handling

The macro provides compile-time validation for common issues:

### Key Conflicts

```swift
@Localized(keyFormat: .pascalCase)
enum Localization {
    case duplicate // Error: Key conflict with 'Duplicate'
    case Duplicate
}
```

### Invalid Usage

```swift
@Localized // Error: Can only be attached to enums
struct Localization {
    // ...
}
```

## Requirements

- Swift 6.0+
- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+ / macCatalyst 13.0+

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
