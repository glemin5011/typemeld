//
//  DSLParser.swift
//  typemeld
//
//  Created by Matej Páleník on 22.08.2024.
//

import Foundation

final class DSLParser {
  func parse(_ dsl: String) -> [DSLNode] {
    // Split the DSL script into lines, trim whitespace, and remove empty lines or comments
    let lines = dsl.split(separator: "\n").map {
      $0.trimmingCharacters(in: .whitespacesAndNewlines)
    }.filter { !$0.isEmpty && !$0.hasPrefix("//") }
    // Ensure 'lines' remains as [Substring]
    let substrLines = lines.map { Substring($0) }  // This line ensures we work with [Substring] explicitly
    var ast: [DSLNode] = []

    var index = 0
    while index < substrLines.count {
      let line = substrLines[index]

      if line.hasPrefix("type ") {
        ast.append(.typeNode(parseType(String(line))))
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

    return ast
  }

  private func parseType(_ line: String) -> TypeNode {
    let name = line.split(separator: " ")[1]
    return TypeNode(name: String(name))
  }

  //   /// Parses a struct into an AST Node. Currently supports extending other structs.
  //   /// - Parameters:
  //   ///   - lines:
  //   ///   - startIndex:
  //   /// - Returns:
  //   private func parseStruct(_ lines: [Substring], _ startIndex: Int) -> (StructNode, Int) {
  //     let structDeclaration = lines[startIndex].split(separator: " ")
  //     print(structDeclaration)
  //     let structName = structDeclaration[1]
  //     var fields: [StructFieldNode] = []
  //     var extendsStruct: String? = nil

  //     // Identify whether the struct extends anything else
  //     if structDeclaration.contains("extends") {
  //       if let extendsIndex = structDeclaration.firstIndex(of: "extends") {
  //         extendsStruct = String(structDeclaration[extendsIndex + 1])
  //       }
  //     }

  //     var index = startIndex + 1
  //     while index < lines.count && !lines[index].starts(with: "}") {
  //       let line = lines[index]
  //       let parts = line.replacingOccurrences(of: ",", with: "").split(separator: ":").map {
  //         $0.trimmingCharacters(in: .whitespaces)
  //       }

  //       guard parts.count == 2 else {
  //         print("Warning: Skipping malformed line in struct definition: \(line)")
  //         index += 1
  //         continue
  //       }

  //       let fieldName = parts[0]
  //       let fieldType = parts[1]
  //       let optional = fieldType.hasSuffix("?")

  //       fields.append(
  //         StructFieldNode(
  //           name: String(fieldName), type: String(fieldType).replacingOccurrences(of: "?", with: ""),
  //           optional: optional))
  //     }

  //     let structNode = StructNode(
  //       name: String(structName), fields: fields, implements: nil, methods: [], extends: extendsStruct
  //     )

  //     return (structNode, index)
  //   }

  //   private func parseInterface(_ lines: [Substring], _ startIndex: Int) -> (InterfaceNode, Int) {
  //     let interfaceDeclaration = lines[startIndex].split(separator: " ")
  //     let interfaceName = interfaceDeclaration[1]
  //     var methods: [InterfaceMethodNode] = []
  //     var extendsInterface: String? = nil

  //     if interfaceDeclaration.contains("extends") {
  //       if let extendsIndex = interfaceDeclaration.firstIndex(of: "extends") {
  //         extendsInterface = String(interfaceDeclaration[extendsIndex + 1])
  //       }
  //     }

  //     var index = startIndex + 1
  //     while index < lines.count && !lines[index].starts(with: "}") {
  //       let line = lines[index]

  //       // Convert Substring to String for regex matching
  //       let lineString = String(line)

  //       // Split the method signature using regex to handle spaces correctly
  //       let pattern = #"(\w+)\((.*?)\)\s*:\s*(\w+)"#

  //       guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
  //         print("Error: Could not create regex pattern.")
  //         index += 1
  //         continue
  //       }

  //       guard
  //         let match = regex.firstMatch(
  //           in: lineString, options: [], range: NSRange(lineString.startIndex..., in: lineString))
  //       else {
  //         print("Warning: Skipping malformed method signature: \(lineString)")
  //         index += 1
  //         continue
  //       }

  //       // Extract method name
  //       let methodNameRange = Range(match.range(at: 1), in: lineString)
  //       let methodName = methodNameRange.flatMap { String(lineString[$0]) } ?? ""

  //       // Extract parameter string and split by commas
  //       let paramsRange = Range(match.range(at: 2), in: lineString)
  //       let paramsString = paramsRange.flatMap { String(lineString[$0]) } ?? ""

  //       let parameters: [StructFieldNode] =
  //         paramsString.isEmpty
  //         ? []
  //         : paramsString.split(separator: ",").compactMap { param in
  //           let paramParts = param.trimmingCharacters(in: CharacterSet.whitespaces).split(
  //             separator: ":"
  //           ).map {
  //             $0.trimmingCharacters(in: CharacterSet.whitespaces)
  //           }

  //           guard paramParts.count == 2 else {
  //             print("Warning: Skipping malformed parameter in method definition: \(param)")
  //             return nil
  //           }

  //           return StructFieldNode(
  //             name: String(paramParts[0]), type: String(paramParts[1]), optional: false)
  //         }

  //       let returnTypeRange = Range(match.range(at: 3), in: lineString)
  //       let returnType = returnTypeRange.flatMap { String(lineString[$0]) } ?? "Void"

  //       methods.append(
  //         InterfaceMethodNode(name: methodName, parameters: parameters, returnType: returnType))

  //       index += 1
  //     }

  //     let interfaceNode = InterfaceNode(name: String(interfaceName), methods: methods)
  //     return (interfaceNode, index)
  //   }

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
      let fieldType = parts[1]
      let optional = fieldType.hasSuffix("?")
      fields.append(
        StructFieldNode(
          name: String(fieldName),
          type: String(fieldType).replacingOccurrences(of: "?", with: ""), optional: optional))
      index += 1
    }

    let structNode = StructNode(
      name: String(structName),
      fields: fields,
      implements: nil,
      methods: [],
      extends: extendsStruct
    )
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
      print("LINE: ", line)

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
          print("PARAM PARTS:", paramParts)
          guard paramParts.count == 2 else {
            print("Warning: Skipping malformed parameter in method definition: \(param)")
            return nil
          }
          print("NAME: ", paramParts[0], "TYPE:", paramParts[1])
          return StructFieldNode(
            name: String(paramParts[0]), type: String(paramParts[1]), optional: false)
        }

      // Extract return type
      let returnTypeRange = Range(match.range(at: 3), in: lineString)
      let returnType = returnTypeRange.flatMap { String(lineString[$0]) } ?? "Void"

      methods.append(
        InterfaceMethodNode(name: methodName, parameters: parameters, returnType: returnType))
      index += 1
    }

    let interfaceNode = InterfaceNode(
      name: String(interfaceName), methods: methods, extends: extendsInterface)
    return (interfaceNode, index)
  }

  public func parseFunctionSignature(_ line: String) -> FunctionSignatureNode {
    // Define a regular expression pattern to capture function signature
    let pattern = #"fn\s+(\w+)\(([^)]*)\)\s*:\s*(\w+)"#

    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
      print("Error: Could not create regex pattern.")
      return FunctionSignatureNode(name: "", parameters: [], returnType: "Void")
    }

    guard
      let match = regex.firstMatch(
        in: line, options: [], range: NSRange(line.startIndex..., in: line))
    else {
      print("Warning: No match found for function signature: \(line)")
      return FunctionSignatureNode(name: "", parameters: [], returnType: "Void")
    }

    // Extract function name
    let fnNameRange = Range(match.range(at: 1), in: line)
    let fnName = fnNameRange.flatMap { String(line[$0]) } ?? ""

    // Extract parameter string and split by commas
    let paramsRange = Range(match.range(at: 2), in: line)
    let paramsString = paramsRange.flatMap { String(line[$0]) } ?? ""
    let params: [StructFieldNode] =
      paramsString.isEmpty
      ? []
      : paramsString.split(separator: ",").compactMap { param in
        let paramParts = param.trimmingCharacters(in: .whitespaces).split(separator: ":").map {
          $0.trimmingCharacters(in: .whitespaces)
        }
        print("PARAM PARTS:", paramParts)
        guard paramParts.count == 2 else {
          print("Warning: Skipping malformed parameter in function signature: \(param)")
          return nil
        }
        print("NAME: ", paramParts[0], "TYPE:", paramParts[1])
        return StructFieldNode(
          name: String(paramParts[0]), type: String(paramParts[1]), optional: false)
      }

    // Extract return type
    let returnTypeRange = Range(match.range(at: 3), in: line)
    let returnType = returnTypeRange.flatMap { String(line[$0]) } ?? "Void"

    return FunctionSignatureNode(name: fnName, parameters: params, returnType: returnType)
  }
}
