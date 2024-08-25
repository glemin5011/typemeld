// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "typemeld",
  products: [
    // Define the product as an executable
    .executable(name: "typemeld", targets: ["typemeld"])
  ],
  dependencies: [
    // List any external dependencies here
  ],
  targets: [
    .executableTarget(
      name: "typemeld",
      resources: [
        .process("LanguageDefinition/Primitives.typemeld")  // Declare the file as a resource
      ]
    )
  ]
)
