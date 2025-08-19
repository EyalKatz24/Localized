/// A Swift macro that automatically generates localized string properties for enums.
///
/// This macro converts enum cases to localization keys and generates:
/// - A `localized` property that returns the localized string
/// - A `localizedKey` property that returns the localization key
/// - A private `localized(_:)` function for internal use
///
/// ## Key Features
/// - **Type-safe localization**: Convert enum cases to localization keys automatically
/// - **Multiple key formats**: Support for upper snake case, lower snake case, camel case, and Pascal case
/// - **String formatting**: Automatic handling of associated values for string interpolation
/// - **Bundle support**: Custom bundle support for modular apps
/// - **Compile-time validation**: Detect key conflicts and invalid usage at compile time
///
/// ## Parameters
/// - `keyFormat`: The localization key format used in your localizable files. The default value is `.upperSnakeCase`.
/// - `bundleId`: An optional bundle identifier where your localizable files are located. If not supplied or failed to read the bundle with the given value, the `.main` bundle will be used.
///
/// ## Usage Examples
///
/// ### Basic Usage
/// ```swift
/// @Localized
/// enum Localization {
///     case ok
///     case cancel
///     case welcome
///     case goodbye
/// }
/// ```
///
/// ### With Associated Values
/// ```swift
/// @Localized
/// enum Localization {
///     case welcome(name: String)
///     case totalCost(amount: Double, currency: String)
///     case items(count: Int, itemName: String)
/// }
/// ```
///
/// ### Custom Key Format
/// ```swift
/// @Localized(keyFormat: .camelCase)
/// enum Localization {
///     case helloWorld // Becomes "helloWorld"
///     case welcomeMessage // Becomes "welcomeMessage"
/// }
/// ```
///
/// ### Custom Bundle
/// ```swift
/// @Localized(bundleId: "com.myapp.core")
/// enum CoreLocalization {
///     case welcome
///     case error
/// }
/// ```
///
/// ### Swift Package with Bundle.module
/// ```swift
/// @Localized(bundleId: "\(Bundle.module.bundleIdentifier!)")
/// enum PackageLocalization {
///     case packageSpecific
/// }
/// ```
///
/// ## Generated Code
/// The macro generates the following code for each enum:
/// ```swift
/// @Localized
/// enum Localization {
///     case welcome(name: String)
///     case goodbye
///     
///     public var localized: String {
///         switch self {
///         case let .welcome(value0):
///             String(format: localized("WELCOME"), value0)
///         case .goodbye:
///             localized("GOODBYE")
///         }
///     }
///     
///     public var localizedKey: String {
///         switch self {
///         case .welcome:
///             "WELCOME"
///         case .goodbye:
///             "GOODBYE"
///         }
///     }
///     
///     private func localized(_ string: String) -> String {
///         NSLocalizedString(string, comment: "")
///     }
/// }
/// ```
///
/// ## Best Practices
/// - Use descriptive enum case names that clearly represent the localization key
/// - Organize localizations by feature rather than having one large enum
/// - Use associated values for dynamic content that needs string formatting
/// - Handle special characters and reserved words with backticks when necessary
///
/// ## Error Handling
/// The macro provides compile-time validation for:
/// - Key conflicts when different cases produce the same localization key
/// - Invalid usage on non-enum types
/// - Bundle identifier validation
@attached(member, names: arbitrary)
public macro Localized(keyFormat: LocalizationKeyFormat = .upperSnakeCase, bundleId: String? = nil) = #externalMacro(module: "LocalizedMacros", type: "LocalizedMacro")

/// The key format used for converting enum cases to localization keys.
///
/// This enum defines the different formatting options available for generating
/// localization keys from enum case names.
public enum LocalizationKeyFormat {
    
    /// Converts enum cases to `lower_snake_cased` localization keys.
    /// 
    /// Example: `helloWorld` → `"hello_world"`
    case lowerSnakeCase
    
    /// Converts enum cases to `UPPER_SNAKE_CASED` localization keys.
    /// 
    /// This is the default format.
    /// Example: `helloWorld` → `"HELLO_WORLD"`
    case upperSnakeCase
    
    /// Converts enum cases to `camelCased` localization keys.
    /// 
    /// Example: `hello_world` → `"helloWorld"`
    case camelCase
    
    /// Converts enum cases to `PascalCased` localization keys.
    /// 
    /// Example: `hello_world` → `"HelloWorld"`
    case pascalCase
}
