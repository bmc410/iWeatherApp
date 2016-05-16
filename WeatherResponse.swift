//
//  WeatherResponse.swift
//  WeatherApp
//
//  Created by Bill McCoy on 5/11/16.
//  Copyright © 2016 WellSpan Health. All rights reserved.
//

import ObjectMapper
import Alamofire
import AlamofireObjectMapper

public class WeatherResponse: Mappable {
    var fiveDayForecast: [Forecast]?
    
    required public init?(_ map: Map){
        
    }
    
    public func mapping(map: Map) {
        fiveDayForecast <- map["list"]
    }
}

public class Forecast: Mappable {
    var timestamp: Int?
    var weather: [Weather]?
    var temp: Float?
    var dtText: String?
    
    public required init?(_ map: Map){
        
    }
    
    public func mapping(map: Map) {
        timestamp <- map["dt"]
        weather <- map["weather"]
        temp <- map["main.temp"]
        dtText <- map["dt_txt"]
    }
}

public class Weather: Mappable {
    var main: String?
    var description: String?
    var icon: String?
    
    required public init?(_ map: Map){
        
    }
    
    public func mapping(map: Map) {
        main <- map["main"]
        description <- map["description"]
        icon <- map["icon"]
    }
}