//
//  LocalizedMacroDiagnostic.swift
//
//
//  Created by Eyal Katz on 15/12/2024.
//

import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxMacros

enum LocalizedMacroDiagnostic {
    case notAnEnum
    case keyConflict(firstCase: String, secondCase: String)
}

extension LocalizedMacroDiagnostic: DiagnosticMessage {
    var severity: DiagnosticSeverity { .error }

    var diagnosticID: MessageID {
        MessageID(domain: "Swift", id: "Localized.\(self)")
    }

    func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(node: Syntax(node), message: self)
    }

    var message: String {
        switch self {
        case .notAnEnum:
            "'Localized' macro can only be attached to enums"
        case let .keyConflict(firstCase, secondCase):
            "Localization key conflict: '\(firstCase)' and '\(secondCase)'"
        }
    }
}

extension MacroExpansionContext {
    func diagnose(_ diagnostic: LocalizedMacroDiagnostic, with declaration: some DeclGroupSyntax) {
        diagnose(diagnostic.diagnose(at: declaration))
    }
}
