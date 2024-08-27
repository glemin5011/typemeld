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
        print("typenode in switch: ", Serializer.serialize(typeNode) ?? "")
        if typeNode.name == "Record" {
          let fields =
            typeNode.fields?.map { "\($0.name): \(convertTypeToSwift($0.type))" }.joined(
              separator: ", ") ?? ""
          lines.append("struct \(typeNode.name) { \(fields) }")
        } else if let fields = typeNode.fields {
          let typeDefinition = fields.map { "var \($0.name): \(convertTypeToSwift($0.type))" }
            .joined(separator: "\n  ")
          lines.append("struct \(typeNode.name) {\n  \(typeDefinition)\n}")
        } else if let keyType = typeNode.keyType,
          let valueType = typeNode.valueType
        {
          lines.append("typealias \(typeNode.name) = [\(keyType): \(valueType)]")
        } else {
          lines.append("typealias \(typeNode.name) = \(convertTypeToSwift(typeNode))")
        }

      }
    }

    return lines.joined(separator: "\n")
  }

  private func convertTypeToSwift(_ type: TypeNode) -> String {
    switch type.name {
    case "Int8":
      return "Int8"
    case "Int16":
      return "Int16"
    case "Int32":
      return "Int32"
    case "Int64":
      return "Int64"
    case "UInt8":
      return "UInt8"
    case "UInt16":
      return "UInt16"
    case "UInt32":
      return "UInt32"
    case "UInt64":
      return "UInt64"
    case "Float32":
      return "Float"
    case "Float64":
      return "Double"
    case "Float":  // Legacy or shorthand support
      return "Float"  // Assuming `Float` as shorthand for `Float32`
    case "Double":  // Legacy or shorthand support
      return "Double"  // Assuming `Double` as shorthand for `Float64`
    case "String":
      return "String"
    case "Char":
      return "Character"
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
        return
          "[\(convertTypeToSwift(TypeNode(name: keyType))): \(convertTypeToSwift(TypeNode(name: valueType)))]"
      } else {
        // Default fallback if no key/value is specified
        return "[String: Any]"
      }
    default:
      return type.name  // Custom types or unrecognized types are returned as-is
    }
  }

}
