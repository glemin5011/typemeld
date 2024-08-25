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
      case .typeNode:
        // Primitive types don't need explicit definition in Rust
        break

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
      }
    }

    return lines.joined(separator: "\n")
  }

  private func convertTypeToRust(_ type: TypeNode) -> String {
    switch type.name {
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
    case "Array":
      if let elementType = type.genericType {
        return "Vec<\(convertTypeToRust(elementType))>"
      } else {
        return "Vec<()>"
      }
    case "Record":
      // Create a tuple struct for the record
      let fieldDefs =
        type.fields?.map {
          "\(convertTypeToRust(TypeNode(name: $0.type.name))): \(convertTypeToRust(TypeNode(name: $0.type.nodeType)))"
        }
        .joined(separator: ", ") ?? ""
      return "(\(fieldDefs))"
    default:
      return type.name  // Custom types or unrecognized types are returned as-is
    }
  }
}
