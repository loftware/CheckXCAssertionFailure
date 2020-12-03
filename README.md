# LoftTest_CheckXCAssertionFailure

Test your testing code! Allows you to write an `XCTest` that checks that a given
expression causes some `XCAssert` function call to fail.

Say you have written this `XCAssert`-style check:

```swift
import XCTest

/// `XCTAssert`'s that `s` is a palindrome, with the given failure message.
func myXCTAssertIsPalindrome(
  _ s: String, _ failureMessage: String = "Not a palindrome!",
  file: StaticString = #filePath, line: UInt = #line
) {
  // Not the most efficient way to check for palindrome-ness!
  XCTAssert(s.elementsEqual(s.reversed(), failureMessage, file: file, line: line)
}
```

You can test it by deriving your test case from `CheckXCAssertionFailureTestCase` 
and using `checkXCAssertionFailure` as shown below:


```swift
import XCTest
import LoftTest_CheckXCAssertionFailure

final class MyXCTAssertionTests: CheckXCAssertionFailureTestCase {
  func testXCTAsssertIsPalindrome() {
    myXCTAssertIsPalindrome("gohangasalamiimalasagnahog")
  }
  
  // This test only passes if the myXCTAssertIsPalindrome call causes an
  // XCAssertion failure.
  func testXCTAsssertIsPalindromeFails() {
    checkXCAssertionFailure(myXCTAssertIsPalindrome("<==== NOT A PALINDROME"))
  }
}
```
