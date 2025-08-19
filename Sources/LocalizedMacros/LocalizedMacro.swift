import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

public struct LocalizedMacro: MemberMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            context.diagnose(.notAnEnum, with: declaration)
            return []
        }
        
        var keyFormat = "upperSnakeCase"
        var bundleId: String?
        
        if case let .argumentList(arguments) = node.arguments {
            if let keyFormatFromArgument = arguments.first(where: { $0.label?.identifier?.name == "keyFormat" })?.expression.as(MemberAccessExprSyntax.self)?.description.removing(".") {
                keyFormat = keyFormatFromArgument
            }
            
            if let bundleIdFromArgument = arguments.first(where: { $0.label?.identifier?.name == "bundleId" })?.expression.as(StringLiteralExprSyntax.self)?.description {
                bundleId = bundleIdFromArgument
            }
        }
        
        let members = enumDecl.memberBlock.members
        let caseDecls = members.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
        let elements = caseDecls.flatMap { $0.elements }
        
        checkForKeyConflicts(elements, keyFormat, context, declaration)
        
        let localizedVar = try localizedVariableDecl(with: elements, keyFormat: keyFormat)
        let localizeFuncDecl = try localizeFuncionDecl(bundleId: bundleId)
        let localizedKeyVar = try localizedKeyVariableDecl(with: elements, keyFormat: keyFormat)
        
        return [
            DeclSyntax(localizedVar),
            DeclSyntax(localizeFuncDecl),
            DeclSyntax(localizedKeyVar)
        ]
    }
    
    private static func checkForKeyConflicts(_ elements: [EnumCaseElementListSyntax.Element], _ keyFormat: String, _ context: some MacroExpansionContext, _ declaration: some DeclGroupSyntax) {
        var dictionary = [String: String]()
        for element in elements {
            let key = element.name.toLocalizedKey(keyFormat)
            if let existingCase = dictionary[key] {
                context.diagnose(.keyConflict(firstCase: existingCase, secondCase: element.name.description), with: declaration)
            } else {
                dictionary[key] = element.name.description
            }
        }
    }
    
    /// This localized function is used instead of explicit initializer, so it can be modified in the future if needed
    private static func localizeFuncionDecl(bundleId: String?) throws -> FunctionDeclSyntax {
        if let bundleId {
            try FunctionDeclSyntax("private func localized(_ string: String) -> String") {
               """
               let bundle = Bundle(identifier: \(raw: bundleId)) ?? .main
                   return NSLocalizedString(string, bundle: bundle, comment: "")
               """
            }
        } else {
            try FunctionDeclSyntax("private func localized(_ string: String) -> String") {
                """
                NSLocalizedString(string, comment: "")
                """
            }
        }
    }
    
    private static func localizedVariableDecl(with elements: [EnumCaseElementListSyntax.Element], keyFormat: String) throws -> VariableDeclSyntax {
        try VariableDeclSyntax("public var localized: String") {
            try SwitchExprSyntax("switch self") {
                for element in elements {
                    caseSyntax(for: element, keyFormat: keyFormat)
                }
            }
        }
    }
    
    private static func localizedKeyVariableDecl(with elements: [EnumCaseElementListSyntax.Element], keyFormat: String) throws -> VariableDeclSyntax {
        try VariableDeclSyntax("public var localizedKey: String") {
            try SwitchExprSyntax("switch self") {
                for element in elements {
                    SwitchCaseSyntax(
                    """
                    case .\(element.name):
                        "\(raw: "\(element.name.toLocalizedKey(keyFormat))")"
                    """
                    )
                }
            }
        }
    }
    
    private static func caseSyntax(for element: EnumCaseElementSyntax, keyFormat: String) -> SwitchCaseSyntax {
        if element.parameterClause != nil {
            return formatLocalized(from: element, keyFormat: keyFormat)
        }
        return localize(element, keyFormat: keyFormat)
    }

    private static func localize(_ element: EnumCaseElementSyntax, keyFormat: String) -> SwitchCaseSyntax {
        SwitchCaseSyntax(
        """
        case .\(element.name):
            localized("\(raw: "\(element.name.toLocalizedKey(keyFormat))")")
        """
        )
    }
    
    private static func formatLocalized(from element: EnumCaseElementSyntax, keyFormat: String) -> SwitchCaseSyntax {
        let parameterList = element.parameterClause?.parameters ?? []
        return SwitchCaseSyntax(
        """
        case let .\(element.name)(\(raw: formatArguments(from: parameterList))):
            String(format: localized("\(raw: "\(element.name.toLocalizedKey(keyFormat))")"),\(raw: formatArguments(from: parameterList)))
        """
        )
    }
    
    private static func formatArguments(from list: EnumCaseParameterListSyntax) -> String {
        list
            .enumerated()
            .map { ($0.offset == 0 ? "" : " ") + "value\($0.offset)" }
            .joined(separator: ",")
    }
}

@main
struct LocalizedPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        LocalizedMacro.self,
    ]
}

fileprivate extension String {
    
    private var words: [String] {
        let pattern = "(?<=\\w)(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: .zero, length: count)
        
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "_")
            .lowercased()
            .components(separatedBy: "_")
            .filter { !$0.isEmpty } ?? [self.lowercased()]
    }
    
    var snakeCased: String {
        let pattern = "(?<=\\w)(?=[A-Z])|(?<=[A-Z])(?=[A-Z])"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: .zero, length: count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1$3_$2$4") ?? self
    }
    
    var pascalCased: String {
        words.map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined()
    }
    
    var camelCased: String {
        guard let firstWord = words.first?.lowercased() else { return "" }
        
        let camelCased = words.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined()
        
        return firstWord + camelCased
    }
    
    var backticksRemoved: String {
        replacingOccurrences(of: "`", with: "")
    }
    
    func removing<Target>(_ target: Target) -> String where Target: StringProtocol {
        replacingOccurrences(of: target, with: "")
    }
}

fileprivate extension TokenSyntax {
    
    func toLocalizedKey(_ keyFormat: String) -> String {
        switch keyFormat {
        case "lowerSnakeCase": "\(self)".snakeCased.lowercased().backticksRemoved
        case "upperSnakeCase": "\(self)".snakeCased.uppercased().backticksRemoved
        case "camelCase": "\(self)".camelCased.backticksRemoved
        case "pascalCase": "\(self)".pascalCased.backticksRemoved
        default: "\(self)".snakeCased.uppercased().backticksRemoved
        }
    }
}
