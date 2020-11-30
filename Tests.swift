import XCTest
import LoftTest_CheckXCAssertionFailure

#if compiler(>=5.3)

func myXCTAssertIsPalindrome(
  _ s: String, _ failureMessage: String = "Not a palindrome!",
  file: StaticString = #filePath, line: UInt = #line
) {
  // Not the most efficient way to check for palindrome-ness!
  XCTAssert( s.elementsEqual(s.reversed()), failureMessage, file: file, line: line)
}

#else

func myXCTAssertIsPalindrome(
  _ s: String, _ failureMessage: String = "Not a palindrome!",
  file: StaticString = #file, line: UInt = #line
) {
  // Not the most efficient way to check for palindrome-ness!
  XCTAssert( s.elementsEqual(s.reversed()), failureMessage, file: file, line: line)
}

#endif

// Note: in order to truly prove that checkXCAssertionFailure works, you need to alter these tests
// one by one, to force them to fail in different places.  Of course, that is the problem this
// package is intended to solve for other packages.
final class CheckXCAssertionFailureTests: CheckXCAssertionFailureTestCase {
  func testNoAssertion() {
    XCTAssert(true)
  }

  func testAssertion() {
    checkXCAssertionFailure(XCTAssert(false))
    XCTAssert(true)
  }

  func testAssertionMessage() {
    checkXCAssertionFailure(XCTAssert(false, "la la la bamba la"), messageExcerpt: "bamba")
    XCTAssert(true)
  }

  func testAssertionMessage1stFailure() {
    checkXCAssertionFailure(
      {
        XCTAssert(false, "la la la bamba la")
        XCTAssert(false)
      }(),
      messageExcerpt: "bamba")
    XCTAssert(true)
  }
  
  func testAssertionMessage2ndFailure() {
    checkXCAssertionFailure(
      {
        XCTAssert(false)
        XCTAssert(false, "la la la bamba la")
      }(),
      messageExcerpt: "bamba")
    XCTAssert(true)
  }

  func testInterleaved() {
    XCTAssert(true)
    checkXCAssertionFailure(XCTAssert(false))
    XCTAssert(true)
    checkXCAssertionFailure(XCTAssert(false))
    XCTAssert(true)
  }

  func testXCTAsssertIsPalindrome() {
    myXCTAssertIsPalindrome("gohangasalamiimalasagnahog")
    checkXCAssertionFailure(myXCTAssertIsPalindrome("aploughmanpanama"))
  }

  /* Not actually expected to work.
     
  func testNestedFailureExpectation() {
    checkXCAssertionFailure(
      checkXCAssertionFailure(XCTAssert(true)))
  }
   */
}

// Local Variables:
// fill-column: 100
// End:
