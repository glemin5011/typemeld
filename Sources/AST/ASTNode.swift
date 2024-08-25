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

// Primitive Type Node
struct TypeNode: ASTNode {
    let nodeType = "Type"
    let name: String
}

// Struct Field Node
struct StructFieldNode {
    let name: String
    let type: String
    let optional: Bool
}

// Struct Node
struct StructNode: ASTNode {
    let nodeType = "Struct"
    let name: String
    let fields: [StructFieldNode]
    let implements: [String]?
}

// Interface Method Node
struct InterfaceMethodNode {
    let name: String
    let parameters: [StructFieldNode]
    let returnType: String
}

// Interface Node
struct InterfaceNode: ASTNode {
    let nodeType = "Interface"
    let name: String
    let methods: [InterfaceMethodNode]
}

// Function Signature Node
struct FunctionSignatureNode: ASTNode {
    let nodeType = "FunctionSignature"
    let name: String
    let parameters: [StructFieldNode]
    let returnType: String
}

// Enum to hold all types of AST nodes
enum DSLNode {
    case typeNode(TypeNode)
    case structNode(StructNode)
    case interfaceNode(InterfaceNode)
    case functionSignatureNode(FunctionSignatureNode)
}