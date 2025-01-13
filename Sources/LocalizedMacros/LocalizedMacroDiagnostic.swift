//
//  File.swift
//  
//
//  Created by Eyal Katz on 15/12/2024.
//

import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxMacros

enum LocalizedMacroDiagnostic {
    case notAnEnum
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
            return "'Localized' macro can only be attached to enums"
        }
    }
}

extension MacroExpansionContext {
    func diagnose(_ diagnostic: LocalizedMacroDiagnostic, with declaration: some DeclGroupSyntax) {
        diagnose(diagnostic.diagnose(at: declaration))
    }
}
