//
//  ASTNode.swift
//  typemeld
//
//  Created by Matej Páleník on 22.08.2024.
//
import Foundation

// Base protocol for AST Nodes
protocol ASTNode {
  var nodeType: String { get }
}

// Type Node Class to represent primitive, array, and record types
class TypeNode: ASTNode, Encodable {
  var nodeType: String {
    return "Type"
  }

  let name: String
  var genericType: TypeNode?  // Used for arrays or other generic types
  var fields: [StructFieldNode]?  // Used for record types
  var keyType: String? = nil  // For Record<K, V>
  var valueType: String? = nil  // For Record<K, V>

  init(
    name: String, genericType: TypeNode? = nil, fields: [StructFieldNode]? = nil,
    keyType: String? = nil,
    valueType: String? = nil
  ) {
    self.name = name
    self.genericType = genericType
    self.fields = fields
    self.keyType = keyType
    self.valueType = valueType
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    // Encode basic properties
    try container.encode(name, forKey: .name)

    // Use encodeIfPresent for optional properties
    try container.encodeIfPresent(genericType, forKey: .genericType)
    try container.encodeIfPresent(fields, forKey: .fields)
    try container.encodeIfPresent(keyType, forKey: .keyType)
    try container.encodeIfPresent(valueType, forKey: .valueType)
  }

  private enum CodingKeys: String, CodingKey {
    case name
    case genericType
    case fields
    case keyType
    case valueType
  }
}

// Struct Field Node now uses TypeNode for its type
struct StructFieldNode: Encodable {
  let name: String
  let type: TypeNode  // Updated to use TypeNode instead of String
  let optional: Bool
}

// Struct Node representing a data structure with fields
struct StructNode: ASTNode, Encodable {
  let nodeType = "Struct"
  let name: String
  let fields: [StructFieldNode]
  let implements: [String]?  // Interfaces this struct implements
  let methods: [InterfaceMethodNode]  // Methods defined in this struct
  let extends: String?  // Parent struct (if this struct extends another struct)
}

// Interface Method Node representing a method signature in an interface
struct InterfaceMethodNode: Encodable {
  let name: String
  let parameters: [StructFieldNode]  // Parameters for the method, using TypeNode
  let returnType: TypeNode  // Return type of the method, using TypeNode
}

// Interface Node representing a contract that can be implemented by structs
struct InterfaceNode: ASTNode, Encodable {
  let nodeType = "Interface"
  let name: String
  let methods: [InterfaceMethodNode]
  let extends: String?  // Parent interface (if this interface extends another interface)
}

// Function Signature Node representing a standalone function signature
struct FunctionSignatureNode: ASTNode, Encodable {
  let nodeType = "FunctionSignature"
  let name: String
  let parameters: [StructFieldNode]  // Parameters for the function
  let returnType: TypeNode  // Return type of the function, using TypeNode
}

// Enum to hold all types of AST nodes
enum DSLNode: Encodable {
  case typeNode(TypeNode)
  case structNode(StructNode)
  case interfaceNode(InterfaceNode)
  case functionSignatureNode(FunctionSignatureNode)
}
