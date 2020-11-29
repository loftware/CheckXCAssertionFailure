// swift-tools-version:5.1
import PackageDescription

let auxilliaryFiles = ["README.md", "LICENSE"]
let package = Package(
  name: "LoftTest_CheckXCAssertionFailure",
  products: [
    .library(
      name: "LoftTest_CheckXCAssertionFailure",
      targets: ["LoftTest_CheckXCAssertionFailure"]),
  ],
  targets: [
    .target(
      name: "LoftTest_CheckXCAssertionFailure",
      path: ".",
      exclude: auxilliaryFiles + ["Tests.swift"],
      sources: ["CheckXCAssertionFailure.swift"]),
    .testTarget(
      name: "Test",
      dependencies: ["LoftTest_CheckXCAssertionFailure"],
      path: ".",
      exclude: auxilliaryFiles + ["CheckXCAssertionFailure.swift"],
      sources: ["Tests.swift"]
    ),
  ]
)
