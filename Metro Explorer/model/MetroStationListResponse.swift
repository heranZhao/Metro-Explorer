//
//  MetroStationListResponse.swift
//  Metro Explorer
//
//  Created by heran zhao on 11/20/18.
//  Copyright © 2018 heran zhao. All rights reserved.
//

import Foundation

struct MetroStationListResponse: Codable {
    
    let Stations: [Station]
    
}

struct Station: Codable {
    
    let Code: String
    let Name: String
    let LineCode1: String
    let LineCode2: String?
    let LineCode3: String?
    let Lat: Double
    let Lon: Double
    let Address: Address
    
}

struct Address: Codable {
    
    let Street: String
    let City: String
    let State: String
    let Zip: String
    
}
