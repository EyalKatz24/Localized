/// An enum-only macro that computes a localized `String` property, using the enum cases as the keys used in our localization files.
///
/// Each enum case is converted to upper-snake-cased petterned string, represents a localization key in the provided `.localizable` files.
/// The use of `enum` associated values simplifies the `String` formatting API, as each of them is used as an argument passed to the `String(format:)` initializer.
///
/// - parameter keyFormat: The localization key format used in your localizable files. The default value is `.upperSnakeCase`.
///
/// - parameter bundleId: An optional bundle identifier where your localizable files are located in. If not supplied or failed to read the bundle with the given value, the `.main` bundle will be used. Make sure to expand the macro to review the implementation. If you use a `Bundle` implicit member such as `.module`, you should provide the unwrapped identifier value for example: `@Localized(keyFormat: .camelCase, bundleId: "\(Bundle.module.bundleIdentifier!)")`
///
/// - NOTE: Use the macro wisely, the best practice would be using a main localization enum,
/// however breaking some localizations into separated enums might be useful in some scenarios,
/// such as localization enum for alerts only.
///
/// Usage example:
///```swift
/// @Localized
/// enum Localization {
///     case ok
///     case myPartnerIs(partnerName: String)
///     case totalCost(firstAmount: Double, secondAmount: Double, cashierName: String)
/// }
///```
/// The macro `Localized` after macro expansion:
///```swift
/// @Localized
/// enum Localization {
///     case ok
///     case myPartnerIs(partnerName: String)
///     case totalCost(firstAmount: Double, secondAmount: Double, cashierName: String)
///
///     public var localized: String {
///         switch self {
///         case .ok:
///             localized("OK")
///         case let .myPartnerInfo(value0):
///             String(format: localized("MY_PARTNER_INFO"), value0)
///         case let .totalCost(value0, value1, value2):
///             String(format: localized("TOTAL_COST"), value0, value1, value2)
///         }
///     }
///
///     private func localized(_ string: String) -> String {
///         NSLocalizedString(string, comment: "")
///     }
/// }
///```
@attached(member, names: arbitrary)
public macro Localized(keyFormat: LocalizationKeyFormat = .upperSnakeCase, bundleId: String? = nil) = #externalMacro(module: "LocalizedMacros", type: "LocalizedMacro")

/// The key format used in the keys in your localization file.
///
/// The default value used is `.upperSnakeCase`.
public enum LocalizationKeyFormat {
    
    /// Converts the `@localized` attached enum into `lower_snake_cased` localization key.
    case lowerSnakeCase
    
    /// Converts the `@localized` attached enum into `UPPER_SNAKE_CASED` localization key.
    case upperSnakeCase
    
    /// Converts the `@localized` attached enum into `camelCased` localization key.
    case camelCase
    
    /// Converts the `@localized` attached enum into `PascalCased` localization key.
    case pascalCase
}
