//
//  DSLParser.swift
//  typemeld
//
//  Created by Matej Páleník on 22.08.2024.
//

import Foundation

final class DSLParser {

  var currentlyEvaluated = ""

  func parse(_ dsl: String) -> [DSLNode] {
    // Split the DSL script into lines, trim whitespace, and remove empty lines or comments
    let lines = dsl.split(separator: "\n").map {
      $0.trimmingCharacters(in: .whitespacesAndNewlines)
    }.filter { !$0.isEmpty && !$0.hasPrefix("//") }
    let substrLines = lines.map { Substring($0) }
    var ast: [DSLNode] = []

    var index = 0
    while index < substrLines.count {
      let line = substrLines[index]

      if line.hasPrefix("type ") {
        let typeNode = parseTypeDefinition(line)  // Use a new function to parse type definition
        print("TypeNode HERE:", Serializer.serialize(typeNode) ?? "")
        ast.append(.typeNode(typeNode))
      } else if line.hasPrefix("struct ") {
        let (structNode, newIndex) = parseStruct(substrLines, index)
        ast.append(.structNode(structNode))
        index = newIndex
      } else if line.hasPrefix("interface ") {
        let (interfaceNode, newIndex) = parseInterface(substrLines, index)
        ast.append(.interfaceNode(interfaceNode))
        index = newIndex
      } else if line.hasPrefix("function ") {
        ast.append(.functionSignatureNode(parseFunctionSignature(String(line))))
      }

      index += 1
    }

    print("Serialized AST: ", Serializer.serialize(ast) ?? "")

    return ast
  }

  private func parseTypeDefinition(_ line: Substring) -> TypeNode {
    let parts = line.split(separator: "=").map { $0.trimmingCharacters(in: .whitespaces) }
    let typeName = parts[0].split(separator: " ")[1]  // Extract "KeyValue" from "type KeyValue"
    let typeDefinition = parts[1]

    let parsedType = parseType(String(typeDefinition))  // Use existing parseType function

    print("Serialized type: ", Serializer.serialize(parsedType) ?? "")
    return TypeNode(
      name: String(typeName), genericType: parsedType.genericType, fields: parsedType.fields,
      keyType: parsedType.keyType, valueType: parsedType.valueType)
  }

  private func parseRecordType(genericTypeName: String) -> TypeNode {
    var types = genericTypeName

    if genericTypeName.lastIndex(of: ">") != nil {
      types = String(genericTypeName.dropLast())
    }

    var keyValueTypes = types.split(separator: ",").map {
      $0.trimmingCharacters(in: .whitespaces)
    }

    // Handle cases where comma might be missing
    if keyValueTypes.count == 1 {
      keyValueTypes = types.split(separator: " ").map {
        $0.trimmingCharacters(in: .whitespaces)
      }
    }

    if keyValueTypes.count == 2 {
      let typeNode = TypeNode(
        name: "Record", keyType: keyValueTypes[0], valueType: keyValueTypes[1])

      print("outgoing typeNode: ", Serializer.serialize(typeNode) ?? "")
      return typeNode
    } else {
      print("Error: Invalid Record type format in DSL: \(genericTypeName)")
      return TypeNode(name: "Record", keyType: "String", valueType: "Any")  // Default fallback
    }
  }

  private func parseType(_ typeString: String) -> TypeNode {
    // Check for generic type (e.g., SomeThing<T> or Record<string, string>)
    if let genericStart = typeString.firstIndex(of: "<"),
      let genericEnd = typeString.lastIndex(of: ">"),
      genericStart < genericEnd
    {

      let baseTypeName = String(typeString[..<genericStart])
      let genericContent = String(typeString[genericStart...].dropFirst().dropLast())  // Extract the inner part of "<...>"

      // Special handling for "Record<K, V>" types
      if baseTypeName == "Record" {
        return parseRecordType(genericTypeName: genericContent)
      }

      // For generic types like SomeThing<T>
      let genericTypeNode = parseType(genericContent)
      return TypeNode(name: baseTypeName, genericType: genericTypeNode)
    }

    // Check for Array type (ending with [])
    if typeString.hasSuffix("[]") {
      let elementType = String(typeString.dropLast(2))  // Remove the "[]" suffix
      return TypeNode(name: "Array", genericType: parseType(elementType))
    }

    // Check for Record type (enclosed in {})
    if typeString.hasPrefix("{") && typeString.hasSuffix("}") {
      let recordContent = typeString.dropFirst().dropLast()

      let fields = recordContent.split(separator: ",").compactMap {
        fieldString -> StructFieldNode? in
        let parts = fieldString.split(separator: ":").map {
          $0.trimmingCharacters(in: .whitespaces)
        }

        guard parts.count == 2 else {
          print("Warning: Malformed record field: \(fieldString)")
          return nil
        }

        return StructFieldNode(
          name: String(parts[0]),
          type: parseType(String(parts[1])),
          optional: false)
      }

      return TypeNode(name: "Record", fields: fields)
    }

    // Handle primitive or custom types
    return TypeNode(name: typeString)
  }

  /// Parses a struct into an AST Node. Currently supports extending other structs.
  /// - Parameters:
  ///   - lines:
  ///   - startIndex:
  /// - Returns:

  private func parseStruct(_ lines: [Substring], _ startIndex: Int) -> (StructNode, Int) {
    let structDeclaration = lines[startIndex].split(separator: " ")
    let structName = structDeclaration[1]
    var fields: [StructFieldNode] = []
    var extendsStruct: String? = nil

    if structDeclaration.contains("extends") {
      if let extendsIndex = structDeclaration.firstIndex(of: "extends") {
        extendsStruct = String(structDeclaration[extendsIndex + 1])
      }
    }

    var index = startIndex + 1
    while index < lines.count && !lines[index].starts(with: "}") {
      let line = lines[index]
      let parts = line.replacingOccurrences(of: ",", with: "").split(separator: ":").map {
        $0.trimmingCharacters(in: .whitespacesAndNewlines)
      }
      guard parts.count == 2 else {
        print("Warning: Skipping malformed line in struct definition: \(line)")
        index += 1
        continue
      }
      let fieldName = parts[0]
      let fieldType = parseType(parts[1])  // Parse the type as TypeNode
      let optional = parts[1].hasSuffix("?")
      fields.append(
        StructFieldNode(
          name: String(fieldName),
          type: fieldType,  // Use TypeNode here
          optional: optional))
      index += 1
    }

    let structNode = StructNode(
      name: String(structName),
      fields: fields,
      implements: nil,
      methods: [],
      extends: extendsStruct
    )
    print("SERIALIZER: ", Serializer.serialize(structNode) ?? "")
    return (structNode, index)
  }

  private func parseInterface(_ lines: [Substring], _ startIndex: Int) -> (InterfaceNode, Int) {
    let interfaceDeclaration = lines[startIndex].split(separator: " ")
    let interfaceName = interfaceDeclaration[1]
    var methods: [InterfaceMethodNode] = []
    var extendsInterface: String? = nil

    if interfaceDeclaration.contains("extends") {
      if let extendsIndex = interfaceDeclaration.firstIndex(of: "extends") {
        extendsInterface = String(interfaceDeclaration[extendsIndex + 1])
      }
    }

    var index = startIndex + 1
    while index < lines.count && !lines[index].starts(with: "}") {
      let line = lines[index]

      // Convert Substring to String for regex matching
      let lineString = String(line)

      // Split the method signature using regex to handle spaces correctly
      let pattern = #"(\w+)\((.*?)\)\s*:\s*(\w+)"#
      guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
        print("Error: Could not create regex pattern.")
        index += 1
        continue
      }

      // Use the converted String for regex matching
      guard
        let match = regex.firstMatch(
          in: lineString, options: [], range: NSRange(lineString.startIndex..., in: lineString))
      else {
        print("Warning: Skipping malformed method signature: \(lineString)")
        index += 1
        continue
      }

      // Extract method name
      let methodNameRange = Range(match.range(at: 1), in: lineString)
      let methodName = methodNameRange.flatMap { String(lineString[$0]) } ?? ""

      // Extract parameter string and split by commas
      let paramsRange = Range(match.range(at: 2), in: lineString)
      let paramsString = paramsRange.flatMap { String(lineString[$0]) } ?? ""
      let parameters: [StructFieldNode] =
        paramsString.isEmpty
        ? []
        : paramsString.split(separator: ",").compactMap { param in
          let paramParts = param.trimmingCharacters(in: CharacterSet.whitespaces).split(
            separator: ":"
          ).map {
            $0.trimmingCharacters(in: CharacterSet.whitespaces)
          }
          guard paramParts.count == 2 else {
            print("Warning: Skipping malformed parameter in method definition: \(param)")
            return nil
          }
          let paramTypeNode = parseType(paramParts[1])  // Use parseType to get TypeNode
          return StructFieldNode(
            name: String(paramParts[0]),
            type: paramTypeNode,  // Use TypeNode here
            optional: false)
        }

      // Extract return type
      let returnTypeRange = Range(match.range(at: 3), in: lineString)
      let returnTypeString = returnTypeRange.flatMap { String(lineString[$0]) } ?? "Void"
      let returnTypeNode = parseType(returnTypeString)  // Use parseType to get TypeNode

      methods.append(
        InterfaceMethodNode(name: methodName, parameters: parameters, returnType: returnTypeNode))
      index += 1
    }

    let interfaceNode = InterfaceNode(
      name: String(interfaceName), methods: methods, extends: extendsInterface)
    return (interfaceNode, index)
  }

  private func parseFunctionSignature(_ line: String) -> FunctionSignatureNode {
    // Updated regular expression to capture generics and complex return types
    let pattern = #"function\s+(\w+)\s*(<\w+>)?\(([^)]*)\)\s*:\s*([<>\w\[\]]+)"#

    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
      print("Error: Could not create regex pattern.")
      return FunctionSignatureNode(name: "", parameters: [], returnType: TypeNode(name: "Void"))
    }

    guard
      let match = regex.firstMatch(
        in: line, options: [], range: NSRange(line.startIndex..., in: line))
    else {
      print("Warning: No match found for function signature: \(line)")
      return FunctionSignatureNode(name: "", parameters: [], returnType: TypeNode(name: "Void"))
    }

    // Extract function name
    let fnNameRange = Range(match.range(at: 1), in: line)
    let fnName = fnNameRange.flatMap { String(line[$0]) } ?? ""

    // Extract parameter string and split by commas
    let paramsRange = Range(match.range(at: 3), in: line)
    let paramsString = paramsRange.flatMap { String(line[$0]) } ?? ""

    let params: [StructFieldNode] =
      paramsString.isEmpty
      ? []
      : paramsString.split(separator: ",").compactMap { param in
        let paramParts = param.trimmingCharacters(in: .whitespaces).split(separator: ":").map {
          $0.trimmingCharacters(in: .whitespaces)
        }

        // Added guard check to prevent "Index out of range" error
        guard paramParts.count == 2 else {
          print("Warning: Skipping malformed parameter in function signature: \(param)")
          return nil
        }

        let paramTypeNode = parseType(paramParts[1])  // Use parseType to get TypeNode
        return StructFieldNode(
          name: String(paramParts[0]), type: paramTypeNode, optional: false)
      }

    // Extract return type
    let returnTypeRange = Range(match.range(at: 4), in: line)
    let returnTypeString = returnTypeRange.flatMap { String(line[$0]) } ?? "Void"
    let returnTypeNode = parseType(returnTypeString)  // Use parseType to get TypeNode

    return FunctionSignatureNode(name: fnName, parameters: params, returnType: returnTypeNode)
  }

}
