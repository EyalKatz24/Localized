import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(LocalizedMacros)
import LocalizedMacros

let testMacros: [String: Macro.Type] = [
    "Localized": LocalizedMacro.self
]
#endif

final class LocalizedTests: XCTestCase {
    
    func testNotAnEnumDiagnostic() {
        #if canImport(LocalizedMacros)
        assertMacroExpansion(
            """
            @Localized
            struct Localization {
            }
            """,
            expandedSource:
            """
            struct Localization {
            }
            """,
            diagnostics: [
                .init(message: "'Localized' macro can only be attached to enums", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #endif
    }
    
    func testEmptyEnum() {
        #if canImport(LocalizedMacros)
        assertMacroExpansion(
                """
                @Localized
                enum Localization {
                }
                """,
                expandedSource:
                """
                enum Localization {
                
                    public var localized: String {
                        switch self {
                        }
                    }
                
                    private func localized(_ string: String) -> String {
                        NSLocalizedString(string, comment: "")
                    }
                }
                """,
                macros: testMacros
        )
        #endif
    }
    
    func testConsecutiveCapitalLetters() {
        #if canImport(LocalizedMacros)
        assertMacroExpansion(
            """
            @Localized
            enum Localization {
                case a
                case A
                case Aa
                case ok
                case url
                case URl
                case URL
                case noIRegretted
            }
            """,
            expandedSource:
            """
            enum Localization {
                case a
                case A
                case Aa
                case ok
                case url
                case URl
                case URL
                case noIRegretted
            
                public var localized: String {
                    switch self {
                    case .a:
                        localized("A")
                    case .A:
                        localized("A")
                    case .Aa:
                        localized("AA")
                    case .ok:
                        localized("OK")
                    case .url:
                        localized("URL")
                    case .URl:
                        localized("U_RL")
                    case .URL:
                        localized("U_R_L")
                    case .noIRegretted:
                        localized("NO_I_REGRETTED")
                    }
                }
            
                private func localized(_ string: String) -> String {
                    NSLocalizedString(string, comment: "")
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testLocalizedWithAssociatedValues() {
        #if canImport(LocalizedMacros)
        assertMacroExpansion(
            """
            @Localized
            enum Localization {
                case noValues
                case singleString(stringValue: String)
                case singleInt(intValue: Int)
                case singleFloat(floatValue: Float)
                case singleDouble(doubleValue: Double)
                case twoValues(first: String, second: String)
                case twoValues2(first: Double, second: Float)
                case twoValues3(first: Int, second: Int)
                case threeValues(first: String, second: Int, third: String)
                case threeValues2(first: Int, second: String, third: Double)
                case threeValues3(first: Float, second: Float, third: Int)
                case fourValues(first: String, second: Float, third: String, fourth: Double)
                case fourValues2(first: Int, second: Int, third: String, fourth: Int)
                case fourValues3(first: Float, second: Float, third: Double, fourth: Double)
            }
            """,
            expandedSource:
            """
            enum Localization {
                case noValues
                case singleString(stringValue: String)
                case singleInt(intValue: Int)
                case singleFloat(floatValue: Float)
                case singleDouble(doubleValue: Double)
                case twoValues(first: String, second: String)
                case twoValues2(first: Double, second: Float)
                case twoValues3(first: Int, second: Int)
                case threeValues(first: String, second: Int, third: String)
                case threeValues2(first: Int, second: String, third: Double)
                case threeValues3(first: Float, second: Float, third: Int)
                case fourValues(first: String, second: Float, third: String, fourth: Double)
                case fourValues2(first: Int, second: Int, third: String, fourth: Int)
                case fourValues3(first: Float, second: Float, third: Double, fourth: Double)
            
                public var localized: String {
                    switch self {
                    case .noValues:
                        localized("NO_VALUES")
                    case let .singleString(value0):
                        String(format: localized("SINGLE_STRING"), value0)
                    case let .singleInt(value0):
                        String(format: localized("SINGLE_INT"), value0)
                    case let .singleFloat(value0):
                        String(format: localized("SINGLE_FLOAT"), value0)
                    case let .singleDouble(value0):
                        String(format: localized("SINGLE_DOUBLE"), value0)
                    case let .twoValues(value0, value1):
                        String(format: localized("TWO_VALUES"), value0, value1)
                    case let .twoValues2(value0, value1):
                        String(format: localized("TWO_VALUES2"), value0, value1)
                    case let .twoValues3(value0, value1):
                        String(format: localized("TWO_VALUES3"), value0, value1)
                    case let .threeValues(value0, value1, value2):
                        String(format: localized("THREE_VALUES"), value0, value1, value2)
                    case let .threeValues2(value0, value1, value2):
                        String(format: localized("THREE_VALUES2"), value0, value1, value2)
                    case let .threeValues3(value0, value1, value2):
                        String(format: localized("THREE_VALUES3"), value0, value1, value2)
                    case let .fourValues(value0, value1, value2, value3):
                        String(format: localized("FOUR_VALUES"), value0, value1, value2, value3)
                    case let .fourValues2(value0, value1, value2, value3):
                        String(format: localized("FOUR_VALUES2"), value0, value1, value2, value3)
                    case let .fourValues3(value0, value1, value2, value3):
                        String(format: localized("FOUR_VALUES3"), value0, value1, value2, value3)
                    }
                }
            
                private func localized(_ string: String) -> String {
                    NSLocalizedString(string, comment: "")
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }
    
    func testCasesWithNumbers() {
        #if canImport(LocalizedMacros)
        assertMacroExpansion(
            """
            @Localized
            enum Localization {
                case a
                case a1
                case a2345
                case ab8th9
                case c0cDdd4d
                case ABC6
            }
            """,
            expandedSource:
            """
            enum Localization {
                case a
                case a1
                case a2345
                case ab8th9
                case c0cDdd4d
                case ABC6
            
                public var localized: String {
                    switch self {
                    case .a:
                        localized("A")
                    case .a1:
                        localized("A1")
                    case .a2345:
                        localized("A2345")
                    case .ab8th9:
                        localized("AB8TH9")
                    case .c0cDdd4d:
                        localized("C0C_DDD4D")
                    case .ABC6:
                        localized("A_B_C6")
                    }
                }
            
                private func localized(_ string: String) -> String {
                    NSLocalizedString(string, comment: "")
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }
    
    func testKeywordsCasesWithBackticks() {
        #if canImport(LocalizedMacros)
        assertMacroExpansion(
            """
            @Localized
            enum Localization {
                case `case`
                case `continue`
                case `if`
                case `is`
                case `for`(stringValue: String)
                case `while`
            }
            """,
            expandedSource:
            """
            enum Localization {
                case `case`
                case `continue`
                case `if`
                case `is`
                case `for`(stringValue: String)
                case `while`
            
                public var localized: String {
                    switch self {
                    case .`case`:
                        localized("CASE")
                    case .`continue`:
                        localized("CONTINUE")
                    case .`if`:
                        localized("IF")
                    case .`is`:
                        localized("IS")
                    case let .`for`(value0):
                        String(format: localized("FOR"), value0)
                    case .`while`:
                        localized("WHILE")
                    }
                }
            
                private func localized(_ string: String) -> String {
                    NSLocalizedString(string, comment: "")
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }
    
    func testCamelCaseParameter() {
        #if canImport(LocalizedMacros)
        assertMacroExpansion(
            """
            @Localized(keyFormat: .camelCase)
            enum Localization {
                case a
                case A
                case Aa
                case url
                case URl
                case URL
                case no_i_regretted
            }
            """,
            expandedSource:
            """
            enum Localization {
                case a
                case A
                case Aa
                case url
                case URl
                case URL
                case no_i_regretted
            
                public var localized: String {
                    switch self {
                    case .a:
                        localized("a")
                    case .A:
                        localized("a")
                    case .Aa:
                        localized("aa")
                    case .url:
                        localized("url")
                    case .URl:
                        localized("uRl")
                    case .URL:
                        localized("uRL")
                    case .no_i_regretted:
                        localized("noIRegretted")
                    }
                }
            
                private func localized(_ string: String) -> String {
                    NSLocalizedString(string, comment: "")
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }
    
    func testPascalCaseParameter() {
        #if canImport(LocalizedMacros)
        assertMacroExpansion(
            """
            @Localized(keyFormat: .pascalCase)
            enum Localization {
                case a
                case A
                case Aa
                case url
                case URl
                case URL
                case no_i_regretted
            }
            """,
            expandedSource:
            """
            enum Localization {
                case a
                case A
                case Aa
                case url
                case URl
                case URL
                case no_i_regretted
            
                public var localized: String {
                    switch self {
                    case .a:
                        localized("A")
                    case .A:
                        localized("A")
                    case .Aa:
                        localized("Aa")
                    case .url:
                        localized("Url")
                    case .URl:
                        localized("URl")
                    case .URL:
                        localized("URL")
                    case .no_i_regretted:
                        localized("NoIRegretted")
                    }
                }
            
                private func localized(_ string: String) -> String {
                    NSLocalizedString(string, comment: "")
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }
    
    func testLowerSnakeCaseParameter() {
        #if canImport(LocalizedMacros)
        assertMacroExpansion(
            """
            @Localized(keyFormat: .lowerSnakeCase)
            enum Localization {
                case a
                case a1
                case a2345
                case ab8th9
                case c0cDdd4d
                case ABC6
            }
            """,
            expandedSource:
            """
            enum Localization {
                case a
                case a1
                case a2345
                case ab8th9
                case c0cDdd4d
                case ABC6
            
                public var localized: String {
                    switch self {
                    case .a:
                        localized("a")
                    case .a1:
                        localized("a1")
                    case .a2345:
                        localized("a2345")
                    case .ab8th9:
                        localized("ab8th9")
                    case .c0cDdd4d:
                        localized("c0c_ddd4d")
                    case .ABC6:
                        localized("a_b_c6")
                    }
                }
            
                private func localized(_ string: String) -> String {
                    NSLocalizedString(string, comment: "")
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }
    
    func testBundleParameter() {
        #if canImport(LocalizedMacros)
        assertMacroExpansion(
            """
            @Localized(bundleId: "core.Core.resources")
            enum Localization {
                case hello
                case loveYou
            }
            """,
            expandedSource:
            """
            enum Localization {
                case hello
                case loveYou
            
                public var localized: String {
                    switch self {
                    case .hello:
                        localized("HELLO")
                    case .loveYou:
                        localized("LOVE_YOU")
                    }
                }
            
                private func localized(_ string: String) -> String {
                    let bundle = Bundle(identifier: "core.Core.resources") ?? .main
                    return NSLocalizedString(string, bundle: bundle, comment: "")
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }
    
    func testLowerSnakeCaseAndBundleParameters() {
        #if canImport(LocalizedMacros)
        assertMacroExpansion(
            """
            @Localized(keyFormat: .lowerSnakeCase, bundleId: "core.Core.resources")
            enum Localization {
                case hello
                case loveYou
            }
            """,
            expandedSource:
            """
            enum Localization {
                case hello
                case loveYou
            
                public var localized: String {
                    switch self {
                    case .hello:
                        localized("hello")
                    case .loveYou:
                        localized("love_you")
                    }
                }
            
                private func localized(_ string: String) -> String {
                    let bundle = Bundle(identifier: "core.Core.resources") ?? .main
                    return NSLocalizedString(string, bundle: bundle, comment: "")
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }
}
