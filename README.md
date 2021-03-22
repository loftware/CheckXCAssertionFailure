# LoftTest_CheckXCAssertionFailure

XCTest-compatible components that can verify that a given test fails as
expected.

## Basic Usage

If you have written an `XCAssert`-style checking function like this one

```swift
import XCTest

/// `XCTAssert`'s that `s` is a palindrome, with the given failure message.
func myXCTAssertIsPalindrome(
  _ s: String, file: StaticString = #filePath, line: UInt = #line)
{
  // Not the most efficient way to check for palindrome-ness!
  XCTAssert(s.elementsEqual(s.reversed(), failureMessage, file: file, line: line)
}
```

and you want to test it, checking that it works when the test passes is easy:

```swift
  func testXCTAsssertIsPalindromePassesOnPalindrome() {
    myXCTAssertIsPalindrome("MadamInEdEnImadaM"))
  }
```

But to test that it works when the test fails, you need to somehow trigger the
failure condition without causing any tests to actually fail.

To do that, derive you test case from `CheckXCAssertionFailureTestCase`:


```swift
import XCTest
import LoftTest_CheckXCAssertionFailure

final class MyXCTAssertionTests: CheckXCAssertionFailureTestCase {
    ...
}
```

and then, in the testing function, wrap the failing check in
`checkXCAssertionFailure`:

```swift
  func testXCTAsssertIsPalindromeFailsOnNonPalindrome() {
    checkXCAssertionFailure( // <===== HERE
      myXCTAssertIsPalindrome("this is not a palindrome"))
  }
```

That test passes if, and only if, the `XCTAssert` in `myXCTAssertIsPalindrome`
fails when passed the non-palindrome string.

## Checking for a particular failure message 

Testing `myXCTAssertIsPalindrome` is trivial, and one could make a case that
it's not worth a dependency on this package. As reusable testing functions
become [more
complex](https://github.com/loftware/StandardLibraryProtocolChecks), though, it
becomes harder to determine that they're doing the right things.

One reason is that they often contain many `XCAssert`ions, and then just
confirming that the test failed isn't enough: you need to confirm that it failed
*for the expected reasons*, i.e. that the `XCAssert`ion you expected is the one
that fired.  For a super-trivial example:

```swift
import XCTest

/// `XCTAssert`'s that `s` is a palindrome, with the given failure message.
func myXCTAssertIsNonEmptyPalindrome(
  _ s: String, file: StaticString = #filePath, line: UInt = #line
) {
  XCTAssertFalse(s.isEmpty, "empty string", file: file, line: line)
  XCTAssert(s.elementsEqual(s.reversed(), "not a palindrome", file: file, line: line)
}
```

To accomodate that need, `checkXCAssertionFailure` has an optional
`messageFragment` parameter that makes the test pass only if the fragment is
present in the failure message. In that case you might check for failure this
way:

```swift
  func testXCTAsssertIsPalindromeFailureCases() {
    checkXCAssertionFailure(
      myXCTAssertIsNonEmptyPalindrome("asymmetric text"),
      messageFragment: "not a palindrome") // <==== HERE
      
    checkXCAssertionFailure(
      myXCTAssertIsNonEmptyPalindrome(""),
      messageFragment: "empty") // <==== HERE
  }
```

## Failure to match

When evaluating the first argument to `checkXCAssertionFailure` doesn't produce
a message matching the `messageFragment`, the resulting failure message contains
a list of all the locations where an `XCAssert`ion did fail, along with one
example of any failure message that occurred on that line.  This information can
be useful for diagnosing `messageFragment` mismatches.  Only one example is
printed to avoid overwhelming the programmer in cases where a test fails in a
loop.
