//
//  main.swift
//  typemeld
//
//  Created by Matej Páleník on 24.08.2024.
//

import Foundation

let dslScript = """
  interface Worker {
    work(hours: Int32): Void
    report(): String
  }

  interface AdvancedWorker extends Worker {
    lead(teamSize: Int32): Void
  }

  struct Engineer extends Person {
    specialty: String
    isWorking: Boolean
  }

  function hire(person: Person, position: String): Boolean

  struct Person {
    id: Int32
    name: String
    tags: String[]
  }

  type KeyValue = { key: String, value: Int32 }

  function addTags(person: Person, newTags: String[]): Person

  """

let parser = DSLParser()
let ast = parser.parse(dslScript)

let tsGenerator = TypeScriptGenerator()
let swiftGenerator = SwiftGenerator()
let rustGenerator = RustGenerator()

// Generate outputs
let tsOutput = tsGenerator.generate(ast)
let swiftOutput = swiftGenerator.generate(ast)
let rustOutput = rustGenerator.generate(ast)

// Determine output directory based on app needs
let fileManager = FileManager.default
let currentPath = fileManager.currentDirectoryPath
let distPath = currentPath + "/dist"

// Create the 'dist' directory if it doesn't exist
do {
  if !fileManager.fileExists(atPath: distPath) {
    try fileManager.createDirectory(
      atPath: distPath, withIntermediateDirectories: true, attributes: nil)
  }
} catch {
  print("Error creating dist directory: \(error)")
}

// Function to write content to a file
func writeToFile(fileName: String, content: String) {
  let filePath = "\(distPath)/\(fileName)"
  print(filePath)
  do {
    try content.write(toFile: filePath, atomically: true, encoding: .utf8)
    print("Successfully wrote to \(filePath)")
  } catch {
    print("Error writing to file \(filePath): \(error)")
  }
}

// Write outputs to respective files
writeToFile(fileName: "output.ts", content: tsOutput)
writeToFile(fileName: "output.swift", content: swiftOutput)
writeToFile(fileName: "output.rs", content: rustOutput)

print("TypeScript Output written to dist/output.ts")
print("Swift Output written to dist/output.swift")
print("Rust Output written to dist/output.rs")
