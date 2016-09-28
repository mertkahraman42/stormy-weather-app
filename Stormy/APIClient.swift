//
//  APIClient.swift
//  Stormy
//
//  Created by Mert Kahraman on 27/09/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import Foundation

public let TRENetworkingErrorDomain = "com.treehouse.Stormy.NetworkingError"
public let MissingHTTPResponseError: Int = 10
public let UnexpectedResponseError: Int = 20


typealias JSON = [String: AnyObject]
typealias JSONTaskCompletion = (JSON?, NSHTTPURLResponse?,NSError?) -> Void
typealias JSONTask = NSURLSessionDataTask

enum APIResult<T> {
    case Success(T)
    case Failure(ErrorType)
}

protocol JSONDecodable {
    init?(JSON: [String: AnyObject])
}

protocol Endpoint {
    var baseURL: NSURL { get }
    var path: String { get }
    var request: NSURLRequest { get }
}

protocol APIClient {
    var configuration: NSURLSessionConfiguration { get }
    var session: NSURLSession { get }
    
    init(config: NSURLSessionConfiguration, APIKey: String)
    
    func JSONTaskWithRequest(request: NSURLRequest, completion: JSONTaskCompletion) -> JSONTask  // This method creates a data task attempting to convert the data to a JSON object.
    func fetch<T: JSONDecodable>(request: NSURLRequest, parse: JSON -> T?, completion: APIResult<T> -> Void)
    
}
extension APIClient {
    func JSONTaskWithRequest(request: NSURLRequest, completion: JSONTaskCompletion) -> JSONTask {
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard let HTTPResponse = response as? NSHTTPURLResponse else { // When we experience an error on the networking
                let userInfo = [ NSLocalizedDescriptionKey: NSLocalizedString("Missing HTTP Response", comment: "") ] // Using an NSError object, here we convey additional information about an error aside from the code and domain
                
                let error = NSError(domain: TRENetworkingErrorDomain, code: MissingHTTPResponseError, userInfo: userInfo)
                completion(nil, nil, error) // If we didn't even get the response, then everything must fail, we return void and leave the func
                return
            }
            if data == nil { // We get a response from HTTP server with an error, and without any data. For example HTTP Error 500 (error on server side)
                if let error = error {
                    completion(nil, HTTPResponse,error)
                }
            } else { // We get a response from HTTP server and a valid data. We then switch on the status code
                switch HTTPResponse.statusCode {
                case 200: // We ONLY attempt to convert the data to JSON if the request was successful with a status code of 200
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String: AnyObject] // Even though the data was received, it may not be converted to a JSON with [String: AnyObject] collection type. It can be of array style. So we try the method.
                        // Note: in as? operator we used ! because we ensured data can't be nil
                        completion(json, HTTPResponse, nil) // If conversion was successful, we got the json and the response with no error
                    } catch let error as NSError {
                        completion(nil,HTTPResponse,error) // If conversion was unsuccessful, we obviously don't have the json, but have the response and the error
                    }
                default: print("Received HTTP Response: \(HTTPResponse.statusCode) - not handled")
                }
            }
        } // We're creating a data task using the request, and using the closure expression, we provide an implementation to convert the resulting data from the task into a JSON response and returning the task.
        
        return task
    }
    
    func fetch<T>(request: NSURLRequest, parse: JSON -> T?, completion: APIResult<T> -> Void) { // In this func, we want to use the request to get a JSON object, parse it, and provide an instance of the model.
        
            let task = JSONTaskWithRequest(request) { json, response, error in
                
                dispatch_async(dispatch_get_main_queue()) {

                guard let json = json else { // We parse the json that JSONTaskWithRequest method returns
                    if let error = error {
                        completion(.Failure(error))
                    } else { // json is nil and error is nil
                        // TODO: Implement Error Handling
                    }
                    return
                }
                
                if let value = parse(json) { // We feed that json into the parse function to see if it succeeded
                    completion(.Success(value)) // If it succeeded
                } else {
                    let error = NSError(domain: TRENetworkingErrorDomain, code: UnexpectedResponseError, userInfo: nil)
                    completion(.Failure(error)) // If it failed
                }
            }
        }
        task.resume()
        
    }
}

























