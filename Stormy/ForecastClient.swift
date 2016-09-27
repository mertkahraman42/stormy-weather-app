//
//  ForecastClient.swift
//  Stormy
//
//  Created by Mert Kahraman on 27/09/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import Foundation

struct Coordinate {
    let latitude: Double
    let longitude: Double
}

enum Forecast: Endpoint {
    case Current(token: String, coordinate: Coordinate)
    // case Daily
    // case Weekly
    //etc.
    
    var baseURL: NSURL {
        return NSURL(string:"https://api.forecast.io")!
    }
    
    var path: String {
        switch self {
        case .Current(let token, let coordinate):
            return "/forecast/\(token)/\(coordinate.latitude),\(coordinate.longitude)"
        }
    }
    
    var request: NSURLRequest {
        let url = NSURL(string: path, relativeToURL: baseURL)!
        return NSURLRequest(URL: url)
    }
}

final class ForecastAPIClient: APIClient { // We don't want it to be overriden or subclassed
    
    let configuration: NSURLSessionConfiguration
    lazy var session: NSURLSession = { // This is a closure that creates an instance of NSURLSession using the above configuration property and returns it.
        return NSURLSession(configuration: self.configuration)
    }() // We did this trick because we needed to customize this object before initializing it
    
    private let token: String

    init(config: NSURLSessionConfiguration, APIKey: String) {
        self.configuration = config
        self.token = APIKey
    }
    
    convenience init(APIKey: String) {
        self.init(config: NSURLSessionConfiguration.defaultSessionConfiguration(), APIKey: APIKey)
    }
    
    func fetchCurrentWeather(coordinate: Coordinate, completion: APIResult<CurrentWeather> -> Void) {// Anywhere T is used is replaced with CurrentWeather
        let request = Forecast.Current(token: self.token, coordinate: coordinate).request
        
        fetch(request, parse: { json -> CurrentWeather? in
            // Parse from JSON Response to CurrentWeather
            
            if let currentWeatherDictionary = json["currently"] as? [String: AnyObject] {
                return CurrentWeather(JSON: currentWeatherDictionary)
            } else { // If we cannot return to the T type
                return nil
            }
            }, completion: completion)
    }
    
}



















