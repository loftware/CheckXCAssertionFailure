# LoftTest_CheckXCAssertionFailure

Test your testing code! Allows you to write an `XCTest` that checks that a given
expression causes some `XCAssert` function call to fail.

Say you have written:

```swift
import XCTest

/// `XCTAssert`'s that `s` is a palindrome, with the given failure message.
func XCTAssertIsPalindrome(
  _ s: String, _ failureMessage: String = "Not a palindrome!",
  file: StaticString = #filePath, line: UInt = #line
) {
  // Not the most efficient way to check for palindrome-ness!
  XCTAssert(s.elementsEqual(s.reversed(), failureMessage, file: file, line: line)
}
```

Then, derive your test case from `CheckXCAssertionFailureTestCase` and use
`checkXCAssertionFailure` as shown to verify that your test function actually
fails when it should:


```swift
import XCTest
import LoftTest_CheckXCAssertionFailure

final class MyXCTAssertionTests: CheckXCAssertionFailureTestCase {
  func testXCTAsssertIsPalindrome() {
    XCTAssertIsPalindrome("gohangasalamiimalasagnahog")
  }
  
  func testXCTAsssertIsPalindromeFails() {
    checkXCAssertionFailure(XCTAssertIsPalindrome("aploughmanpanama"))
  }
}
```
