//
//  RestAPI.swift
//  WaitCounts
//
//  Created by Bill McCoy on 5/2/16.
//  Copyright © 2016 WellSpan Health. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public class RestAPI{

    func CallAPI(apiCall: String, completion: (JSON) -> ()) {
        Alamofire.request(
            .GET,apiCall
            )
           .responseJSON {
                response in
                    switch response.result {
                        case .Success(let data):
                            let jsonData = JSON(data)
                            completion(jsonData)
                        case .Failure:
                            break
                        //completion(String(NSData()))
            }
        }
    }
}