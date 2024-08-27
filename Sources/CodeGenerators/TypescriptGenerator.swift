import Foundation

class TypeScriptGenerator {
  func generate(_ ast: [DSLNode]) -> String {
    var lines: [String] = []

    for node in ast {
      switch node {
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

      case .functionSignatureNode(_):
        print(
          "Typescript does not support defining function signatures without implementation. Skipping..."
        )
      // let params = functionNode.parameters.map {
      //   "\($0.name): \(convertTypeToTypeScript($0.type))"
      // }
      // .joined(separator: ", ")
      // lines.append(
      //   "function \(functionNode.name)(\(params)): \(convertTypeToTypeScript(functionNode.returnType));"
      // )

      case .typeNode(let typeNode):
        if typeNode.name == "Record" {
          if let keyType = typeNode.keyType, let valueType = typeNode.valueType {
            lines.append(
              "type \(typeNode.name) = Record<\(convertTypeToTypeScript(TypeNode(name: keyType))), \(convertTypeToTypeScript(TypeNode(name: valueType)))>;"
            )
          } else if let fields = typeNode.fields {
            let fieldDefinitions = fields.map { "\($0.name): \(convertTypeToTypeScript($0.type))" }
              .joined(separator: "; ")
            lines.append("type \(typeNode.name) = { \(fieldDefinitions) };")
          } else {
            lines.append("type \(typeNode.name) = Record<string, any>;")
          }
        } else if let fields = typeNode.fields {
          let typeDefinition = fields.map { "\($0.name): \(convertTypeToTypeScript($0.type))" }
            .joined(separator: "; ")
          lines.append("type \(typeNode.name) = { \(typeDefinition) };")
        } else {
          if typeNode.keyType != nil && typeNode.valueType != nil {
            let tsType = convertTypeToTypeScript(typeNode)
            print("TS type", tsType)
            lines.append("type \(typeNode.name) = \(tsType);")
          } else {
            lines.append("type \(typeNode.name) = \(convertTypeToTypeScript(typeNode));")
          }
        }

      }
    }

    return lines.joined(separator: "\n")
  }

  private func convertTypeToTypeScript(_ type: TypeNode) -> String {
    switch type.name {
    case "Int8", "Int16", "Int32", "Int64", "UInt8", "UInt16", "UInt32", "UInt64", "Float",
      "Double":
      return "number"
    case "Float32", "Float64":
      return "number"  // Typescript treats all floating-point numbers as 'number'
    case "Char":
      return "string"  // TypeScript does not have a 'char' type, so it's represented as 'string'
    case "String":
      return "string"
    case "Boolean":
      return "boolean"
    case "Void":
      return "void"
    case "Array":
      if let elementType = type.genericType {
        return "\(convertTypeToTypeScript(elementType))[]"
      } else {
        return "any[]"  // Fallback if generic type is not specified
      }
    case "Record":
      if let keyType = type.keyType, let valueType = type.valueType {
        // Handle Record with specific key and value types
        return
          "Record<\(convertTypeToTypeScript(TypeNode(name: keyType))), \(convertTypeToTypeScript(TypeNode(name: valueType)))>"
      } else if let fields = type.fields {
        let fieldDefinitions = fields.map { "\($0.name): \(convertTypeToTypeScript($0.type))" }
          .joined(separator: "; ")
        return "{ \(fieldDefinitions) }"
      }
      return "Record<string, any>"  // Default case if we have no fields or key/value
    case "Optional":
      if let genericType = type.genericType {
        return "\(convertTypeToTypeScript(genericType)) | undefined"
      } else {
        return "any | undefined"
      }
    default:
      if let keyType = type.keyType, let valueType = type.valueType {
        return
          "Record<\(convertTypeToTypeScript(TypeNode(name: keyType))), \(convertTypeToTypeScript(TypeNode(name: valueType)))>"
      }
      print("TYPE: ", Serializer.serialize(type) ?? "")
      return type.name  // Custom types or unrecognized types are returned as-is
    }
  }

}
