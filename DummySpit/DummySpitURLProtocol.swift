//
//  DummySpitURLProtocol.swift
//  DummySpit
//
//  Created by Matthew Delves on 16/08/2014.
//  Copyright (c) 2014 Matthew Delves. All rights reserved.
//

//
//  Initial work by DBlechoc
//

import Foundation

public struct DummySpitServiceResponse
{
  public let body: NSData?
  public let header: NSDictionary
  public let urlComponent: String?
  public let statusCode: Int
  public let error: NSError?
  public let url: NSURL?
  
  public init (body: AnyObject, header: NSDictionary, urlComponentToMatch urlComponent: String? = nil, statusCode: Int = 200, error: NSError? = nil)
  {
    if let jsonData = NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions(), error: nil) {
      self.body = jsonData
    }

    self.header = header
    self.urlComponent = urlComponent
    self.statusCode = statusCode
    self.error = error
  }

  public init (filePath: String, header: NSDictionary, url: NSURL? = nil, statusCode: Int = 200, error: NSError? = nil)
  {
    let result: NSString = NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: nil)!
    var jsonResult: AnyObject! = nil
    if let resultData = result.dataUsingEncoding(NSUTF8StringEncoding) {
      self.body = resultData
    }

    self.header = header
    self.url = url
    self.statusCode = statusCode
    self.error = error
  }

  public init (filePath: String, header: NSDictionary, urlComponentToMatch urlComponent: String? = nil, statusCode: Int = 200, error: NSError? = nil)
  {
    let result:NSString = NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: nil)!
    var jsonResult: AnyObject! = nil
    if let resultData = result.dataUsingEncoding(NSUTF8StringEncoding) {
      self.body = resultData
    }
    self.header = header
    self.urlComponent = urlComponent
    self.statusCode = statusCode
    self.error = error
  }

  public init (data: NSData, header: NSDictionary, url: NSURL? = nil, statusCode: Int = 200, error: NSError? = nil)
  {
    self.body = data
    self.header = header
    self.url = url
    self.statusCode = statusCode
    self.error = error
  }

  public init (data: NSData, header: NSDictionary, urlComponentToMatch urlComponent: String? = nil, statusCode: Int = 200, error: NSError? = nil)
  {
    self.body = data
    self.header = header
    self.urlComponent = urlComponent
    self.statusCode = statusCode
    self.error = error
  }

}

var storage: [DummySpitServiceResponse]?
var fullURLstorage: [DummySpitServiceResponse]?

public class DummySpitURLProtocol: NSURLProtocol
{
  public class func cannedResponses(responses: [DummySpitServiceResponse]?)
  {
    storage = responses
  }
  
  public class func cannedResponse(response: DummySpitServiceResponse?)
  {
    if let aResponse = response
    {
      storage = [aResponse]
    }
    else
    {
      storage = nil
    }
  }

  public class func cannedFullURLResponses(responses: [DummySpitServiceResponse]?)
  {
    fullURLstorage = responses
  }

  public class func cannedFullURLResponse(response: DummySpitServiceResponse?)
  {
    if let aResponse = response
    {
      fullURLstorage = [aResponse]
    }
    else
    {
      fullURLstorage = nil
    }
  }

  public class func responsesForURL(URL: NSURL) -> [DummySpitServiceResponse]?
  {
    if let tmpResponses = storage
    {
      var responses = (tmpResponses as [DummySpitServiceResponse]).filter{
        cannedResponse -> Bool in

        return (cannedResponse.urlComponent != nil) ? contains(URL.pathComponents as [String], cannedResponse.urlComponent!) : true
      }
      
      // give priority to responses that have a urlComponent
      responses.sort {
        (response1: DummySpitServiceResponse, response2: DummySpitServiceResponse) -> Bool in
        return response1.urlComponent > response1.urlComponent
      }
      
      return responses
    }
    
    return nil
  }

  public class func responseMatchingURL(request: NSURL) -> DummySpitServiceResponse? {
    if let tmpResponses = fullURLstorage {
      for response : DummySpitServiceResponse in tmpResponses {
        if let responseURL = response.url {
          if responseURL.isEqual(request) {
            return response
          }
        }
      }
    }
    return nil
  }

  override public class func canInitWithRequest(request: NSURLRequest) -> Bool
  {
    let schemeIsMock = request.URL.scheme == "mock"
    var fullUrlMatched = responseMatchingURL(request.URL) != nil
    var urlMatched = responsesForURL(request.URL)?.count > 0
    
    return (schemeIsMock && (urlMatched || fullUrlMatched))
  }

  override public class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest
  {
    return request
  }

  override public class func requestIsCacheEquivalent(a: NSURLRequest, toRequest b: NSURLRequest) -> Bool
  {
    return a.URL == b.URL
  }

  override public func startLoading()
  {
    let request = self.request
    let client: NSURLProtocolClient = self.client!
    
    // Test for full URLs
    if let cannedResponse = self.dynamicType.responseMatchingURL(request.URL) {
      let response = NSHTTPURLResponse(URL: request.URL, statusCode: cannedResponse.statusCode, HTTPVersion: "HTTP/1.1", headerFields: cannedResponse.header)
      client.URLProtocol(self, didReceiveResponse: response!, cacheStoragePolicy: NSURLCacheStoragePolicy.NotAllowed)

      if let body = cannedResponse.body {
        client.URLProtocol(self, didLoadData: body)
      }

      client.URLProtocolDidFinishLoading(self)

    } else if let cannedResponses = self.dynamicType.responsesForURL(request.URL) {
      let cannedResponse: DummySpitServiceResponse = cannedResponses[0]
      if let error = cannedResponse.error
      {
        client.URLProtocol(self, didFailWithError: error)
      }
      else
      {
        let response = NSHTTPURLResponse(URL: request.URL, statusCode: cannedResponse.statusCode, HTTPVersion: "HTTP/1.1", headerFields: cannedResponse.header)
        client.URLProtocol(self, didReceiveResponse: response!, cacheStoragePolicy: NSURLCacheStoragePolicy.NotAllowed)
        
        if let body = cannedResponse.body {
          client.URLProtocol(self, didLoadData: body)
        }
        
        client.URLProtocolDidFinishLoading(self)
      }

    }

  }

  override public func stopLoading()
  {

  }
}