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

/// A test case supports the use of `checkXCAssertionFailure` in tests.
open class CheckXCAssertionFailureTestCase: XCTestCase {
  /// State of an active check for an `XCTAssert` failure
  private struct AssertionFailureCheck {
    /// A substring of the failure message of matching assertions.
    let messageExcerpt: String

    /// True iff the check is satisfied
    var isSatisfied: Bool = false
    
    /// The file and line on which to report a failure if the check is not satisfied.
    let sourceLocation: (file: StaticString, line: UInt)
  }
  
  /// When non-`nil`, the assertion failure currently being checked for.
  private var activeAssertionFailureCheck: AssertionFailureCheck?
  
  /// When looking for an assertion failure message, the failures that didn't match.
  private var nonMatchingFailures: [(file: String, line: Int, message: String)] = []

#if os(macOS) && compiler(>=5.3)
  // recordFailure has been deprecated, so use record instead. Test the older code on mac by
  // replacing with #if false.

  /// Records the occurrence of `issue` in the execution of the test.
 open override func record(_ issue: XCTIssue) {
   if let activeCheck = activeAssertionFailureCheck, issue.type == .assertionFailure {
     if activeCheck.isSatisfied { return }
     let failureMessage = issue.compactDescription + (issue.detailedDescription ?? "")
     if failureMessage.firstOccurrence(ofElements: activeCheck.messageExcerpt) != nil {
       activeAssertionFailureCheck!.isSatisfied = true
     }
     else {
       let l = issue.sourceCodeContext.location
       nonMatchingFailures.append((l?.fileURL.path ?? "", l?.lineNumber ?? 0, failureMessage))
     }
   }
   else {
     super.record(issue)
   }
 }

#else
 
  /// Records a failure during test execution.
  ///
  /// - Parameters:
  ///   - failureMessage: The description of the failure.
  ///   - file: The path to the source file where the failure occurred or `nil` if unknown.
  ///   - line: The line in the source file where the failure occurred.
  ///   - isAssertionFailure: `true` if the failure was the result of a failed assertion, `false` if
  ///     it was the result of an uncaught exception.
  open override func recordFailure(
    withDescription failureMessage: String, inFile file: String, atLine line: Int,
    expected isAssertionFailure: Bool
  ) {
    if let activeCheck = activeAssertionFailureCheck, isAssertionFailure {
      if activeCheck.isSatisfied { return }
      if failureMessage.firstOccurrence(ofElements: activeCheck.messageExcerpt) != nil {
        activeAssertionFailureCheck!.isSatisfied = true
      }
      else {
        nonMatchingFailures.append(file, line, failureMessage)
      }
    }
    else {
      super.recordFailure(
        withDescription: failureMessage, inFile: file, atLine: line, expected: isAssertionFailure)
    }
  }
  
#endif

#if compiler(>=5.3)
  /// `XCTAssert`'s that `trigger`, when evaluated, causes an `XCAssert` function to fail, with
  /// `messageExcerpt` as a substring of the failure message.
  public func checkXCAssertionFailure<T>(
    _ trigger: @autoclosure () -> T, messageExcerpt: String = "",
    file: StaticString = #filePath, line: UInt = #line
  ) {
    checkFailure(trigger, messageExcerpt: messageExcerpt, file: file, line: line)
  }
#else
  /// `XCTAssert`'s that `trigger`, when evaluated, causes an `XCAssert` function to fail, with
  /// `messageExcerpt` as a substring of the failure message.
  public func checkXCAssertionFailure<T>(
    _ trigger: @autoclosure () -> T,
    messageExcerpt: String = "",
    file: StaticString = #file, line: UInt = #line
  ) {
    checkFailure(trigger, messageExcerpt: messageExcerpt, file: file, line: line)
  }
#endif


  /// `XCTAssert`'s that `trigger()`, when evaluated, causes an `XCAssert` function to fail, with
  /// `messageExcerpt` as a substring of the failure message.
  private func checkFailure<T>(
    _ trigger: () -> T,
    messageExcerpt: String = "",
    file: StaticString = #file, line: UInt = #line
  ) {
    self.activeAssertionFailureCheck = AssertionFailureCheck(
      messageExcerpt: messageExcerpt, sourceLocation: (file: file, line: line))
  
    _ = trigger() // try to do the thing that's expected to fail.
  
    let c = activeAssertionFailureCheck!
    activeAssertionFailureCheck = nil
    
    if !c.isSatisfied {
      let aboutExcerpt = c.messageExcerpt.isEmpty ? ""
        : " with message containing \(String(reflecting: c.messageExcerpt))"

      let lines = ["Required assertion failure\(aboutExcerpt) not found"]
        + nonMatchingFailures.lazy.map {
          "\($0.file):\($0.line): note: failure  detected \(String(reflecting: $0.message)))"
        }
      
      XCTFail(
        lines.joined(separator: "\n"),
        file: c.sourceLocation.file, line: c.sourceLocation.line)
    }
  }
}

// TODO: factor into separate loft library.
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


// Local Variables:
// fill-column: 100
// End:
