import XCTest

import JRPCSwiftNioTests

var tests = [XCTestCaseEntry]()
tests += JRPCSwiftNioTests.allTests()
XCTMain(tests)