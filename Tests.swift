import XCTest
@testable import LoftTest_XCAssertTestCase

final class XCAssertTestCaseTests: XCAssertTestCase {
  func testNoAssertion() {
    XCTAssert(true)
  }

  func testAssertion() {
    requireAssertionFailure(XCTAssert(false))
  }

    func testAssertionMessage() {
      requireAssertionFailure(XCTAssert(false, "la la la bomba la"), "bomba")
    }
}
