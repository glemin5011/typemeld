import Foundation

class SwiftGenerator {
  func generate(_ ast: [DSLNode]) -> String {
    var lines: [String] = []

    // Map to keep track of all structs for inheritance
    var structMap: [String: StructNode] = [:]
    for node in ast {
      if case let .structNode(structNode) = node {
        structMap[structNode.name] = structNode
      }
    }

    for node in ast {
      switch node {
      // case .typeNode:
      //   // Primitive types don't need explicit definition in Swift
      //   break

      case .structNode(let structNode):
        lines.append("struct \(structNode.name) {")

        // Gather fields including inherited ones
        var allFields = structNode.fields

        // If the struct extends another, copy over fields from the parent
        if let parentStructName = structNode.extends {
          if let parentStruct = structMap[parentStructName] {
            allFields = parentStruct.fields + structNode.fields
          } else {
            print(
              "Warning: Parent struct \(parentStructName) not found for struct \(structNode.name)")
          }
        }

        for field in allFields {
          let optionalMark = field.optional ? "?" : ""
          lines.append("  var \(field.name): \(convertTypeToSwift(field.type))\(optionalMark)")
        }
        lines.append("}")

      case .interfaceNode(let interfaceNode):
        // Handle protocol inheritance
        if let parentInterface = interfaceNode.extends {
          lines.append("protocol \(interfaceNode.name): \(parentInterface) {")
        } else {
          lines.append("protocol \(interfaceNode.name) {")
        }

        for method in interfaceNode.methods {
          let params = method.parameters.map { "\($0.name): \(convertTypeToSwift($0.type))" }
            .joined(separator: ", ")
          lines.append(
            "  func \(method.name)(\(params)) -> \(convertTypeToSwift(method.returnType))")
        }
        lines.append("}")

      case .functionSignatureNode(let functionNode):
        let params = functionNode.parameters.map { "\($0.name): \(convertTypeToSwift($0.type))" }
          .joined(separator: ", ")
        lines.append(
          "func \(functionNode.name)(\(params)) -> \(convertTypeToSwift(functionNode.returnType))")

      case .typeNode(let typeNode):
        if typeNode.name == "Record" {
          let fields =
            typeNode.fields?.map { "\($0.name): \(convertTypeToSwift($0.type))" }.joined(
              separator: ", ") ?? ""
          lines.append("struct \(typeNode.name) { \(fields) }")
        } else if let fields = typeNode.fields {
          let typeDefinition = fields.map { "var \($0.name): \(convertTypeToSwift($0.type))" }
            .joined(separator: "\n  ")
          lines.append("struct \(typeNode.name) {\n  \(typeDefinition)\n}")
        } else {
          lines.append("typealias \(typeNode.name) = \(convertTypeToSwift(typeNode))")
        }

      }
    }

    return lines.joined(separator: "\n")
  }

  // private func convertTypeToSwift(_ type: TypeNode) -> String {
  //   switch type.name {
  //   case "Int8", "Int16", "Int32", "Int64", "UInt8", "UInt16", "UInt32", "UInt64":
  //     return "Int"
  //   case "Float":
  //     return "Float"
  //   case "Double":
  //     return "Double"
  //   case "String":
  //     return "String"
  //   case "Boolean":
  //     return "Bool"
  //   case "Void":
  //     return "Void"
  //   case "Array":
  //     if let elementType = type.genericType {
  //       return "[\(convertTypeToSwift(elementType))]"
  //     } else {
  //       return "[Any]"
  //     }
  //   case "Record":
  //     let fields =
  //       type.fields?.map { "\($0.name): \(convertTypeToSwift(TypeNode(name: $0.type.nodeType)))" }
  //       .joined(separator: ", ") ?? ""
  //     return "[String: Any]"  // Simplified representation for Records in Swift
  //   default:
  //     return type.name  // Custom types or unrecognized types are returned as-is
  //   }
  // }

  private func convertTypeToSwift(_ type: TypeNode) -> String {
    switch type.name {
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
    case "Array":
      if let elementType = type.genericType {
        return "[\(convertTypeToSwift(elementType))]"
      } else {
        return "[Any]"
      }
    case "Record":
      if let keyType = type.keyType, let valueType = type.valueType {
        // Handle Record with specific key and value types
        if keyType == "String" && valueType == "String" {
          return "[String: String]"  // Specific case for Record<String, String>
        } else {
          return
            "[\(convertTypeToSwift(TypeNode(name: keyType))): \(convertTypeToSwift(TypeNode(name: valueType)))]"
        }
      } else {
        return "[String: Any]"  // Default case
      }
    default:
      return type.name  // Custom types or unrecognized types are returned as-is
    }
  }

}
