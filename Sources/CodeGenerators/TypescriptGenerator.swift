//
//  TypescriptGenerator.swift
//  typemeld
//
//  Created by Matej Páleník on 24.08.2024.
//

import Foundation

class TypeScriptGenerator {
  func generate(_ ast: [DSLNode]) -> String {
    var lines: [String] = []

    for node in ast {
      switch node {
      case .typeNode(let typeNode):
        // Primitive types don't need explicit definition in TypeScript
        break

      case .structNode(let structNode):
        // Handle extends for structs
        if let parentStruct = structNode.extends {
          lines.append("interface \(structNode.name) extends \(parentStruct) {")
        } else {
          lines.append("interface \(structNode.name) {")
        }

        for field in structNode.fields {
          let optionalMark = field.optional ? " | undefined" : ""
          lines.append("  \(field.name): \(convertTypeToTypeScript(field.type))\(optionalMark);")
        }
        lines.append("}")

      case .interfaceNode(let interfaceNode):
        // Handle extends for interfaces
        if let parentInterface = interfaceNode.extends {
          lines.append("interface \(interfaceNode.name) extends \(parentInterface) {")
        } else {
          lines.append("interface \(interfaceNode.name) {")
        }

        for method in interfaceNode.methods {
          let params = method.parameters.map { "\($0.name): \(convertTypeToTypeScript($0.type))" }
            .joined(separator: ", ")
          lines.append(
            "  \(method.name)(\(params)): \(convertTypeToTypeScript(method.returnType));")
        }
        lines.append("}")

      case .functionSignatureNode:
        print(
          "Function signatures cannot be defined without implementation in TypeScript. Skipping...")
      }
    }

    return lines.joined(separator: "\n")
  }

  private func convertTypeToTypeScript(_ type: String) -> String {
    switch type {
    case "Int8", "Int16", "Int32", "Int64", "UInt8", "UInt16", "UInt32", "UInt64", "Float",
      "Double":
      return "number"
    case "Char", "String":
      return "string"
    case "Boolean":
      return "boolean"
    case "Void":
      return "void"
    default:
      return type  // Custom types or unrecognized types are returned as-is
    }
  }
}
