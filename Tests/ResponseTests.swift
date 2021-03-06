// ResponseTests.swift
//
// Copyright (c) 2014–2015 Alamofire Software Foundation (http://alamofire.org/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import Alamofire
import XCTest

class AlamofireJSONResponseTestCase: XCTestCase {
    func testGETRequestJSONResponse() {
        let URL = "http://httpbin.org/get"
        let expectation = expectationWithDescription("\(URL)")

        Alamofire.request(.GET, URL, parameters: ["foo": "bar"])
                 .responseJSON { (request, response, JSON, error) in
                    XCTAssertNotNil(request, "request should not be nil")
                    XCTAssertNotNil(response, "response should not be nil")
                    XCTAssertNotNil(JSON, "JSON should not be nil")
                    XCTAssertNil(error, "error should be nil")

                    XCTAssertEqual(JSON!["args"] as! NSObject, ["foo": "bar"], "args should be equal")

                    expectation.fulfill()
        }

        waitForExpectationsWithTimeout(10) { (error) in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testPOSTRequestJSONResponse() {
        let URL = "http://httpbin.org/post"
        let expectation = expectationWithDescription("\(URL)")

        Alamofire.request(.POST, URL, parameters: ["foo": "bar"])
            .responseJSON { (request, response, JSON, error) in
                XCTAssertNotNil(request, "request should not be nil")
                XCTAssertNotNil(response, "response should not be nil")
                XCTAssertNotNil(JSON, "JSON should not be nil")
                XCTAssertNil(error, "error should be nil")

                XCTAssertEqual(JSON!["form"] as! NSObject, ["foo": "bar"], "args should be equal")

                expectation.fulfill()
        }

        waitForExpectationsWithTimeout(10) { (error) in
            XCTAssertNil(error, "\(error)")
        }
    }
}

class AlamofireRedirectResponseTestCase: XCTestCase {
    func testGETRequestRedirectResponse() {
        let URL = "http://google.com"
        let expectation = expectationWithDescription("\(URL)")

        let delegate: Alamofire.Manager.SessionDelegate = Alamofire.Manager.sharedInstance.delegate

        delegate.taskWillPerformHTTPRedirection = { session, task, response, request in
            // Accept the redirect by returning the updated request.
            return request
        }

        Alamofire.request(.GET, URL)
            .response { (request, response, data, error) in
                XCTAssertNotNil(request, "request should not be nil")
                XCTAssertNotNil(response, "response should not be nil")
                XCTAssertNotNil(data, "data should not be nil")
                XCTAssertNil(error, "error should be nil")

                XCTAssertEqual(response!.URL!, NSURL(string: "http://www.google.com/")!, "request should have followed a redirect")

                expectation.fulfill()
        }

        waitForExpectationsWithTimeout(10) { (error) in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testGETRequestDisallowRedirectResponse() {
        let URL = "http://google.com/"
        let expectation = expectationWithDescription("\(URL)")

        let delegate: Alamofire.Manager.SessionDelegate = Alamofire.Manager.sharedInstance.delegate
        delegate.taskWillPerformHTTPRedirection = { session, task, response, request in
            // Disallow redirects by returning nil.
            // TODO: NSURLSessionDelegate's URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:
            // suggests that returning nil should refuse the redirect, but this causes a deadlock/timeout

            return NSURLRequest(URL: NSURL(string: URL)!)
        }

        Alamofire.request(.GET, URL)
            .response { request, response, data, error in
                XCTAssertNotNil(request, "request should not be nil")
                XCTAssertNotNil(response, "response should not be nil")
                XCTAssertNotNil(data, "data should not be nil")
                XCTAssertNil(error, "error should be nil")

                XCTAssertEqual(response!.URL!, NSURL(string: URL)!, "request should not have followed a redirect")

                expectation.fulfill()
        }

        waitForExpectationsWithTimeout(10) { (error) in
            XCTAssertNil(error, "\(error)")
        }
    }
}
