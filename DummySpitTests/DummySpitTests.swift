//
//  DummySpitTests.swift
//  DummySpitTests
//
//  Created by Matthew Delves on 16/08/2014.
//  Copyright (c) 2014 Matthew Delves. All rights reserved.
//

//
//  Based upon the work of Dblechoc.
//

import Quick
import Nimble
import DummySpit

class DummySpitURLProtocolSpec: QuickSpec {
  override func spec() {
    describe("DummySpitServiceResponse") {
      var response: DummySpitServiceResponse!
      var error: NSError!
      
      describe("Init with body") {
        beforeEach {
          error = NSError(domain: "au.com.test.domain", code: 150, userInfo: nil)
          response = DummySpitServiceResponse(body: ["test": "blah"], header: ["Content-Type": "application/json; charset=utf-8"], statusCode: 404, error: error)
        }
        
        it("should have a body") {
          expect(response.body as? NSDictionary).to(equal(["test": "blah"]))
        }
        
        it("should have an header") {
          expect(response.header).to(equal(["Content-Type": "application/json; charset=utf-8"]))
        }
        
        it("should have a statusCode") {
          expect(response.statusCode).to(equal(404))
        }
        
        it("should have an error") {
          expect(response.error).to(equal(error))
        }
      }
      
      describe("Init with filePath") {
        beforeEach {
          let filePath = NSBundle(forClass: DummySpitURLProtocolSpec.self).pathForResource("dummy", ofType: "json")
          response = DummySpitServiceResponse(filePath: filePath!, header: ["Content-Type": "application/json; charset=utf-8"])
        }
        
        it("should have a body") {
          expect(response.body as? NSDictionary).to(equal(["foo": "bar"]))
        }
      }
    }
    
    describe("DummySpitURLProtocol") {
      beforeEach {
        let response = DummySpitServiceResponse(body: ["test": "blah"], header: ["Content-Type": "application/json; charset=utf-8"])
        DummySpitURLProtocol.cannedResponse(response)
      }
      
      afterEach {
        DummySpitURLProtocol.cannedResponse(nil)
      }
      
      
      describe("canInitWithRequest") {
        context("without a url component to match") {
          context("when using mock scheme") {
            it("should be able to init a request") {
              let request = NSURLRequest(URL: NSURL(string: "mock://www.apple.com"))
              expect(DummySpitURLProtocol.canInitWithRequest(request)).to(beTruthy())
            }
          }
          
          context("when using http scheme") {
            it("should not be able to init a request") {
              let request = NSURLRequest(URL: NSURL(string: "http://www.apple.com"))
              expect(DummySpitURLProtocol.canInitWithRequest(request)).to(beFalsy())
            }
          }
        }
        
        context("with a url component to match") {
          beforeEach {
            let response = DummySpitServiceResponse(body: ["test": "blah"], header: ["Content-Type": "application/json; charset=utf-8"], urlComponentToMatch:"GetStopsByRouteAndDirection.ashx")
            let responseNoComponent = DummySpitServiceResponse(body: ["test2": "blah"], header: ["Content-Type": "application/json; charset=utf-8"])
            DummySpitURLProtocol.cannedResponses([response, responseNoComponent])
          }
          
          it("should be able to init a request") {
            let request = NSURLRequest(URL: NSURL(string: "mock://www.apple.com/Controllers/GetStopsByRouteAndDirection.ashx?r=123&u=true"))
            expect(DummySpitURLProtocol.canInitWithRequest(request)).to(beTruthy())
          }
        }
      }
      
      describe("canonicalRequestForRequest") {
        it("should return the same request") {
          let request = NSURLRequest(URL: NSURL(string: "mock://www.apple.com"))
          expect(DummySpitURLProtocol.canonicalRequestForRequest(request)).to(equal(request))
        }
      }
      
      describe("requestIsCacheEquivalent") {
        context("when given requests are equal") {
          it("should be equivalent with the same request is given twice") {
            let requestA = NSURLRequest(URL: NSURL(string: "mock://www.apple.com"))
            let requestB = NSURLRequest(URL: NSURL(string: "mock://www.apple.com"))
            expect(DummySpitURLProtocol.requestIsCacheEquivalent(requestA, toRequest: requestB )).to(beTruthy())
          }
        }
        
        context("when given requests aren't equal") {
          it("should be equivalent with the same request is given twice") {
            let requestA = NSURLRequest(URL: NSURL(string: "mock://www.apple.com"))
            let requestB = NSURLRequest(URL: NSURL(string: "http://www.apple.com"))
            expect(DummySpitURLProtocol.requestIsCacheEquivalent(requestA, toRequest: requestB )).to(beFalsy())
          }
        }
      }
      
      // startLoading is tested inside NetworkServiceSpec
    }
  }
}
