//
//  SwiftGenerator.swift
//  typemeld
//
//  Created by Matej Páleník on 24.08.2024.
//

import Foundation

class SwiftGenerator {
  func generate(_ ast: [DSLNode]) -> String {
    var lines: [String] = []

    for node in ast {
      switch node {
      case let .typeNode(typeNode):
        // Primitive types don't need explicit definition in Swift
        break
      case let .structNode(structNode):
        lines.append("struct \(structNode.name) {")
        for field in structNode.fields {
          let optionalMark = field.optional ? "?" : ""
          lines.append("  var \(field.name): \(convertTypeToSwift(field.type))\(optionalMark)")
        }
        lines.append("}")
      case let .interfaceNode(interfaceNode):
        lines.append("protocol \(interfaceNode.name) {")
        for method in interfaceNode.methods {
          let params = method.parameters.map { "\($0.name): \(convertTypeToSwift($0.type))" }
            .joined(separator: ", ")
          lines.append(
            "  func \(method.name)(\(params)) -> \(convertTypeToSwift(method.returnType))")
        }
        lines.append("}")
      case let .functionSignatureNode(functionNode):
        let params = functionNode.parameters.map { "\($0.name): \(convertTypeToSwift($0.type))" }
          .joined(separator: ", ")
        lines.append(
          "func \(functionNode.name)(\(params)) -> \(convertTypeToSwift(functionNode.returnType))")
      }
    }

    return lines.joined(separator: "\n")
  }

  private func convertTypeToSwift(_ type: String) -> String {
    switch type {
    case "Int8", "Int16", "Int32", "Int64", "UInt8", "UInt16", "UInt32", "UInt64":
      return "Int"
    case "Float":
      return "Float"
    case "Double":
      return "Double"
    case "String":
      return "String"
    case "Boolean":
      return "Bool"
    case "Void":
      return "Void"
    default:
      return type  // Custom types or unrecognized types are returned as-is
    }
  }
}
