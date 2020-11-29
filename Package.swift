// swift-tools-version:5.3
import PackageDescription

let auxilliaryFiles = ["README.md", "LICENSE"]
let package = Package(
  name: "LoftTest_XCAssertTestCase",
  products: [
    .library(
      name: "LoftTest_XCAssertTestCase",
      targets: ["LoftTest_XCAssertTestCase"]),
  ],
  targets: [
    .target(
      name: "LoftTest_XCAssertTestCase",
      path: ".",
      exclude: auxilliaryFiles + ["Tests.swift"],
      sources: ["XCAssertTestCase.swift"]),
    .testTarget(
      name: "Test",
      dependencies: ["LoftTest_XCAssertTestCase"],
      path: ".",
      exclude: auxilliaryFiles + ["XCAssertTestCase.swift"],
      sources: ["Tests.swift"]
    ),
  ]
)
