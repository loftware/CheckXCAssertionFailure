// Copyright 2020 Dave Abrahams. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import XCTest

/// `XCTAssert`'s that `requiredToFailXCAssertion`, when evaluated, causes an `XCAssert` function to
/// fail, with `requiredMessageExcerpt` as a substring of the failure message.
///
/// - Warning: must be used only from an `CheckXCAssertionFailureTestCase`.
public func checkXCAssertionFailure<T>(
  _ requiredToFailXCAssertion: @autoclosure () -> T,
  _ requiredMessageExcerpt: String = "",
  file: StaticString = #filePath, line: UInt = #line
) {
  // use the magic numbers defined below to shove information into the test case using XCTFail
  XCTFail("\0", file: file, line: UInt(collectRequirements))
  XCTFail(requiredMessageExcerpt, file: file, line: line)
  
  _ = requiredToFailXCAssertion() // try to do the thing that's expected to fail.
  
  XCTFail(file: file, line: UInt(stopRequiringXCAssertion))
}

/// A magic number that, when passed as a line number, tells the test case that the next failure
/// actually transmits information about the expected XCAssertion.
private let collectRequirements = Int.max

/// A magic number that, when passed as a line number, tells the test case that it should revert to
/// normal mode and allow regular tests to work.
private let stopRequiringXCAssertion = Int.max - 1

/// An XCTestCase subclass that supports the use of `checkXCAssertionFailure` in tests.
open class CheckXCAssertionFailureTestCase: XCTestCase {
  /// The state of `self`.
  ///
  /// - See Also: `State`
  private var state = State.normal
  
  /// The state machine representation of the test case.
  private enum State {
    /// Functioning like a normal `XCTestCase`.
    case normal
    
    /// Waiting for a failure that transmits the required XCTAssert failure message, appended to a
    /// “garbage” string having the given number of prefix characters.
    case collectingRequirements(prefixUTF8Count: Int)
    
    /// Waiting for a failure with a message containing `messageExcerpt`; if not found we should
    /// report a failure at the given `file` and `line`.
    case requiringXCAssertionFailure(messageExcerpt: Substring, file: String, line: Int)

    /// The assertion failure we were waiting for was found, but the expression that is being
    /// checked for failure is still running.
    case ignoringXCAssertionFailures
  }

  /// Records a failure during test execution for the test run.
  ///
  /// - Parameters:
  ///   - failureMessage: The description of the failure.
  ///   - file: The file path to the source file where the failure occurred or nil if unknown.
  ///   - line: The line number in the source file at filePath where the failure occurred.
  ///   - isAssertionFailure: true if the failure was the result of a failed assertion, false if it
  ///     was the result of an uncaught exception.
  open override func recordFailure(
    withDescription failureMessage: String, inFile file: String, atLine line: Int,
    expected isAssertionFailure: Bool
  ) {
    if !isAssertionFailure {
      super.recordFailure(
        withDescription: failureMessage, inFile: file, atLine: line, expected: isAssertionFailure)
      return
    }
    
    switch state {
    case .normal:
      assert(line != stopRequiringXCAssertion)
      if line == collectRequirements {
        state = .collectingRequirements(prefixUTF8Count: failureMessage.utf8.count - 1)
      }
      else {
        super.recordFailure(
          withDescription: failureMessage, inFile: file, atLine: line, expected: isAssertionFailure)
      }

    case .collectingRequirements(let prefixUTF8Count):
      assert(line != collectRequirements)
      assert(line != stopRequiringXCAssertion)
      let excerpt = Substring(failureMessage.utf8.dropFirst(prefixUTF8Count))
      state = .requiringXCAssertionFailure(messageExcerpt: excerpt, file: file, line: line)
      
    case .requiringXCAssertionFailure(let messageExcerpt, let file_, let line_):
      assert(line != collectRequirements)
      if line == stopRequiringXCAssertion {
        let aboutExcerpt = messageExcerpt.isEmpty ? ""
          : " with message containing \(String(reflecting: messageExcerpt))"
      
        super.recordFailure(
          withDescription: "Required assertion failure\(aboutExcerpt) not found",
          inFile: file_, atLine: line_, expected: true)
        state = .normal
      }
      else {
        if failureMessage.firstOccurrence(ofElements: messageExcerpt) != nil {
          state = .ignoringXCAssertionFailures
        }
      }
      
    case .ignoringXCAssertionFailures:
      if line == stopRequiringXCAssertion {
        state = .normal
      }
    }
  }
}

private extension Collection where Element: Equatable {
  /// Returns the first `SubSequence` of `self` with elements equal to `excerpt`.
  func firstOccurrence<E: Collection>(ofElements excerpt: E) -> SubSequence?
    where E.Element == Element
  {
    var remainder = self[...]
    var tail = self.dropFirst(excerpt.count)
    repeat {
      let sample = remainder[..<tail.startIndex]
      if sample.elementsEqual(excerpt) {
        return sample
      }
      _ = remainder.popFirst()
    }
    while tail.popFirst() != nil
    return nil
  }
}

