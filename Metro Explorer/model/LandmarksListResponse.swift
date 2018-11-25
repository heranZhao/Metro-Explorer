//
//  LandmarksListResponse.swift
//  Metro Explorer
//
//  Created by heran zhao on 11/21/18.
//  Copyright © 2018 heran zhao. All rights reserved.
//

import Foundation

struct LandmarksListResponse: Codable {
    
    let businesses: [Businesses]
    let total: Int
    let region: Region
    
}

struct Businesses: Codable {
    
    let id: String
    let alias: String
    let name: String
    let image_url: String
    let is_closed: Bool
    let url: String
    //let categories: [Categories]
    let rating: Double
    //let coordinates: Coordinates
    let location: Location
    let phone: String
    //let display_phone: String
    let distance: Double
}

struct Categories: Codable {
    
    let alias: String
    let title: String
    
}

struct Coordinates: Codable {
    
    let latitude: Double
    let longitude: Double
    
}

struct Location: Codable {
    
    let address1: String?
    let address2: String?
    let address3: String?
    let city: String?
    let zip_code: String?
    let country: String?
    let state: String?
    let display_address: [String]
}

struct Region: Codable {
    
    let center: Center
    
}

struct Center: Codable {
    
    let longitude: Double
    let latitude: Double
    
}

