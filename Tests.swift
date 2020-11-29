import XCTest
import LoftTest_CheckXCAssertionFailure

func XCTAssertIsPalindrome(
  _ s: String, _ failureMessage: String = "Not a palindrome!",
  file: StaticString = #filePath, line: UInt = #line
) {
  // Not the most efficient way to check for palindrome-ness!
  XCTAssert( s.elementsEqual(s.reversed()), failureMessage, file: file, line: line)
}

final class CheckXCAssertionFailureTests: CheckXCAssertionFailureTestCase {
  func testNoAssertion() {
    XCTAssert(true)
  }

  func testAssertion() {
    checkXCAssertionFailure(XCTAssert(false))
    XCTAssert(true)
  }

  func testAssertionMessage() {
    checkXCAssertionFailure(XCTAssert(false, "la la la bamba la"), "bamba")
    XCTAssert(true)
  }

  func testAssertionMessage1stFailure() {
    checkXCAssertionFailure(
      {
        XCTAssert(false, "la la la bamba la")
        XCTAssert(false)
      }(),
      "bamba")
    XCTAssert(true)
  }
  
  func testAssertionMessage2ndFailure() {
    checkXCAssertionFailure(
      {
        XCTAssert(false)
        XCTAssert(false, "la la la bamba la")
      }(),
      "bamba")
    XCTAssert(true)
  }

  func testXCTAsssertIsPalindrome() {
    XCTAssertIsPalindrome("gohangasalamiimalasagnahog")
    checkXCAssertionFailure(XCTAssertIsPalindrome("aploughmanpanama"))
  }

  /* Not actually expected to work.
     
  func testNestedFailureExpectation() {
    checkXCAssertionFailure(
      checkXCAssertionFailure(XCTAssert(true)))
  }
   */
}
