import Foundation

/// Generator for Rust programming language, which takes in an AST and returns syntactically correct Rust types
class RustGenerator {
  func generate(_ ast: [DSLNode]) -> String {
    var lines: [String] = []

    // Map to keep track of all structs for composition
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

        // Collect all fields including those from parent structs
        var allFields = structNode.fields

        // Handle composition: If the struct extends another, copy fields from the parent
        if let parentStructName = structNode.extends {
          if let parentStruct = structMap[parentStructName] {
            allFields = parentStruct.fields + structNode.fields
          } else {
            print(
              "Warning: Parent struct \(parentStructName) not found for struct \(structNode.name)")
          }
        }

        for field in allFields {
          let rustType =
            field.optional
            ? "Option<\(convertTypeToRust(field.type))>" : convertTypeToRust(field.type)
          lines.append("  \(field.name): \(rustType),")
        }
        lines.append("}")

      case .interfaceNode(let interfaceNode):
        // Handle trait inheritance
        if let parentInterface = interfaceNode.extends {
          lines.append("trait \(interfaceNode.name): \(parentInterface) {")
        } else {
          lines.append("trait \(interfaceNode.name) {")
        }

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

      case .typeNode(let typeNode):
        if let fields = typeNode.fields {
          let structFields = fields.map { "\($0.name): \(convertTypeToRust($0.type))" }.joined(
            separator: ", ")
          lines.append("struct \(typeNode.name) { \(structFields) }")
        } else if let keyType = typeNode.keyType, let valueType = typeNode.valueType {
          let rustType =
            "std::collections::HashMap<\(convertTypeToRust(TypeNode(name: keyType))), \(convertTypeToRust(TypeNode(name: valueType)))>"
          lines.append("type \(typeNode.name) = \(rustType);")
        } else {
          lines.append("type \(typeNode.name) = \(convertTypeToRust(typeNode));")
        }
      }
    }

    return lines.joined(separator: "\n")
  }

  private func convertTypeToRust(_ type: TypeNode) -> String {
    switch type.name {
    case "Int8":
      return "i8"
    case "Int16":
      return "i16"
    case "Int32":
      return "i32"
    case "Int64":
      return "i64"
    case "UInt8":
      return "u8"
    case "UInt16":
      return "u16"
    case "UInt32":
      return "u32"
    case "UInt64":
      return "u64"
    case "Float32":
      return "f32"
    case "Float64":
      return "f64"
    case "Float":  // Legacy or shorthand support
      return "f32"  // Assuming `Float` as shorthand for `f32`
    case "Double":  // Legacy or shorthand support
      return "f64"  // Assuming `Double` as shorthand for `f64`
    case "String":
      return "String"
    case "Char":
      return "char"
    case "Boolean":
      return "bool"
    case "Void":
      return "()"
    case "Array":
      if let elementType = type.genericType {
        return "Vec<\(convertTypeToRust(elementType))>"
      } else {
        return "Vec<()>"
      }
    case "Record":
      if let fields = type.fields {
        let fieldDefinitions = fields.map { "\(convertTypeToRust($0.type)) \($0.name)" }.joined(
          separator: ", ")
        return "struct { \(fieldDefinitions) }"
      } else if let keyType = type.keyType, let valueType = type.valueType {
        return
          "std::collections::HashMap<\(convertTypeToRust(TypeNode(name: keyType))), \(convertTypeToRust(TypeNode(name: valueType)))>"
      } else {
        return "std::collections::HashMap<String, String>"
      }
    default:
      return type.name  // Custom types or unrecognized types are returned as-is
    }
  }
}
