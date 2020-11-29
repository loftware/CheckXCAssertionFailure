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

// https://medium.com/@matthew_healy/cuteasserts-dev-blog-1-wait-how-do-you-test-that-a-test-failed-37419eb33b49
// for the basic technique.
public func requireAssertionFailure<T>(
  _ expectedToAssert: @autoclosure () -> T,
  _ expectedMessageSubstring: String = "",
  file: StaticString = #filePath, line: UInt = #line
) {
  XCTFail(magicFailurePrefix + expectedMessageSubstring, file: file, line: line)
  _ = expectedToAssert()
}

private struct CaptureMissingAssertionIssue: Error {}

private let magicFailurePrefix = ":MaGiCfAiLuRePrEfIx:"
private let magicFailurePrefixLength = magicFailurePrefix.utf8.count

extension Collection where Element: Equatable {
  func firstOccurrenceOf<E: Collection>(excerpt: E) -> SubSequence?
    where E.Element == Element
  {
    var remainder = self[...]
    var tail = self.dropFirst(excerpt.count)
    repeat {
      let sample = remainder[..<tail.startIndex]
      if sample.elementsEqual(excerpt) {
        return sample
      }
      remainder.popFirst()
    }
    while tail.popFirst() != nil
    return nil
  }
}

open class XCAssertTestCase: XCTestCase {
  fileprivate var stopped = false
    
  final class Run: XCTestCaseRun {
    fileprivate var expectedAssertionFailure: (descriptionExcerpt: Substring, file: String, line: Int)?
    fileprivate weak var testCase: XCAssertTestCase?
    
    /*
     override func record(_ issue: XCTIssue) {
     if issue.type == .thrownError {
     print("capturing", issue)
     missingAssertionIssue = issue
     }
     else if issue.type == .assertionFailure {
     requiredAssertionFailureDetected = true
     print("required failure detected:", issue)
     }
     else {
     print("delegating", issue)
     super.record(issue)
     }
     }
     */
    
    override func stop() {
      if let (excerpt, file, line) = expectedAssertionFailure {
        testCase!.stopped = true
        testCase!.recordFailure(
          withDescription: """
            Required assertion failure did not occur\
            \(excerpt.isEmpty ? "": ": " + String(describing: excerpt))
            """,
          inFile: file,
          atLine: line,
          expected: true)
      }
      super.stop()
    }
  }

  open override func recordFailure(
    withDescription description: String, inFile file: String, atLine line: Int,
    expected isAssertionFailure: Bool
  ) {
    let run = unsafeDowncast(self.testRun.unsafelyUnwrapped, to: Run.self)
    
    if !stopped && isAssertionFailure {
      if let (excerpt, _, _) = run.expectedAssertionFailure {
        if description.firstOccurrenceOf(excerpt: excerpt) != nil {
          run.expectedAssertionFailure = nil // fulfilled
        }
        return
      }
      else if let magic = description.utf8.firstOccurrenceOf(excerpt: magicFailurePrefix.utf8) {
        run.expectedAssertionFailure = (Substring(description.utf8[magic.endIndex...]), file, line)
        run.testCase = self
        return
      }
    }
    super.recordFailure(
      withDescription: description, inFile: file, atLine: line, expected: isAssertionFailure)
  }
  
  public override var testRunClass: AnyClass? {
    return Run.self
  }
}
