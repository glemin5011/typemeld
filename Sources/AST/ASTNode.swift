// //
// //  ASTNode.swift
// //  typemeld
// //
// //  Created by Matej Páleník on 22.08.2024.
// //
// import Foundation

// // Base protocol for AST Nodes
// protocol ASTNode {
//   var nodeType: String { get }
// }

// // Primitive Type Node
// // struct TypeNode: ASTNode {
// //   let nodeType = "Type"
// //   let name: String
// //   var genericType: TypeNode?  // Used for arrays or other generic types
// //   var fields: [StructFieldNode]?
// // }
// class TypeNode: ASTNode {
//   var nodeType: String {
//     return "Type"
//   }

//   let name: String
//   var genericType: TypeNode?  // This is safe because classes are reference types
//   var fields: [StructFieldNode]?

//   init(name: String, genericType: TypeNode? = nil, fields: [StructFieldNode]? = nil) {
//     self.name = name
//     self.genericType = genericType
//     self.fields = fields
//   }
// }

// // Struct Field Node
// struct StructFieldNode {
//   let name: String
//   let type: String
//   let optional: Bool
// }

// // Struct Node
// struct StructNode: ASTNode {
//   let nodeType = "Struct"
//   let name: String
//   let fields: [StructFieldNode]
//   let implements: [String]?
//   let methods: [InterfaceMethodNode]
//   let extends: String?
// }

// // Interface Method Node
// struct InterfaceMethodNode {
//   let name: String
//   let parameters: [StructFieldNode]
//   let returnType: String
// }

// // Interface Node
// struct InterfaceNode: ASTNode {
//   let nodeType = "Interface"
//   let name: String
//   let methods: [InterfaceMethodNode]
//   let extends: String?

// }

// // Function Signature Node
// struct FunctionSignatureNode: ASTNode {
//   let nodeType = "FunctionSignature"
//   let name: String
//   let parameters: [StructFieldNode]
//   let returnType: String
// }

// // Enum to hold all types of AST nodes
// enum DSLNode {
//   case typeNode(TypeNode)
//   case structNode(StructNode)
//   case interfaceNode(InterfaceNode)
//   case functionSignatureNode(FunctionSignatureNode)
// }

import Foundation

// Base protocol for AST Nodes
protocol ASTNode {
  var nodeType: String { get }
}

// Type Node Class to represent primitive, array, and record types
class TypeNode: ASTNode {
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
  }
}

// Struct Field Node now uses TypeNode for its type
struct StructFieldNode {
  let name: String
  let type: TypeNode  // Updated to use TypeNode instead of String
  let optional: Bool
}

// Struct Node representing a data structure with fields
struct StructNode: ASTNode {
  let nodeType = "Struct"
  let name: String
  let fields: [StructFieldNode]
  let implements: [String]?  // Interfaces this struct implements
  let methods: [InterfaceMethodNode]  // Methods defined in this struct
  let extends: String?  // Parent struct (if this struct extends another struct)
}

// Interface Method Node representing a method signature in an interface
struct InterfaceMethodNode {
  let name: String
  let parameters: [StructFieldNode]  // Parameters for the method, using TypeNode
  let returnType: TypeNode  // Return type of the method, using TypeNode
}

// Interface Node representing a contract that can be implemented by structs
struct InterfaceNode: ASTNode {
  let nodeType = "Interface"
  let name: String
  let methods: [InterfaceMethodNode]
  let extends: String?  // Parent interface (if this interface extends another interface)
}

// Function Signature Node representing a standalone function signature
struct FunctionSignatureNode: ASTNode {
  let nodeType = "FunctionSignature"
  let name: String
  let parameters: [StructFieldNode]  // Parameters for the function
  let returnType: TypeNode  // Return type of the function, using TypeNode
}

// Enum to hold all types of AST nodes
enum DSLNode {
  case typeNode(TypeNode)
  case structNode(StructNode)
  case interfaceNode(InterfaceNode)
  case functionSignatureNode(FunctionSignatureNode)
}
