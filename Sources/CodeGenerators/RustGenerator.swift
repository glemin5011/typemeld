//
//  RustGenerator.swift
//  typemeld
//
//  Created by Matej Páleník on 24.08.2024.
//

import Foundation

/// Generator for Rust programming language, which takes in an AST and returns syntactically correct Rust types
/// - Parameter ast: an instance of DSLNode
/// - Returns: A string representing generated types based on the input AST
/// - Throws: An error of type `InternalGeneratorError` in case error generation fails
class RustGenerator {
  func generate(_ ast: [DSLNode]) -> String {
    var lines: [String] = []

    for node in ast {
      switch node {
      case .typeNode(let typeNode):
        // Primitive types don't need explicit definition in Rust
        break
      case .structNode(let structNode):
        lines.append("struct \(structNode.name) {")
        for field in structNode.fields {
          let optionalMark =
            field.optional
            ? "Option<\(convertTypeToRust(field.type))>" : convertTypeToRust(field.type)
          lines.append("  \(field.name): \(optionalMark),")
        }
        lines.append("}")
      case .interfaceNode(let interfaceNode):
        lines.append("trait \(interfaceNode.name) {")
        for method in interfaceNode.methods {
          let params = method.parameters.map { "\($0.name): \(convertTypeToRust($0.type))" }.joined(
            separator: ", ")
          lines.append("  fn \(method.name)(\(params)) -> \(convertTypeToRust(method.returnType));")
        }
        lines.append("}")
      case .functionSignatureNode(let functionNode):
        let params = functionNode.parameters.map { "\($0.name): \(convertTypeToRust($0.type))" }
          .joined(separator: ", ")
        lines.append(
          "fn \(functionNode.name)(\(params)) -> \(convertTypeToRust(functionNode.returnType));")
      }
    }

    return lines.joined(separator: "\n")
  }

  private func convertTypeToRust(_ type: String) -> String {
    switch type {
    case "Int32":
      return "i32"
    case "Float":
      return "f32"
    case "Double":
      return "f64"
    case "String":
      return "String"
    case "Boolean":
      return "bool"
    case "Void":
      return "()"
    default:
      return type  // Custom types or unrecognized types are returned as-is
    }
  }
}
