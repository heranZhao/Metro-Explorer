//
//  ReviewListResponse.swift
//  Metro Explorer
//
//  Created by heran zhao on 11/23/18.
//  Copyright © 2018 heran zhao. All rights reserved.
//

import Foundation

struct ReviewListResponse: Codable {
    
    let reviews: [Reviews]
    let total: Int
    let possible_languages: [String]
}

struct Reviews: Codable {
    
    let id: String
    let url: URL
    let text: String
    let rating: Int
    let time_created: String
    let user: User
}

struct User: Codable {
    
    let id: String
    let profile_url: URL
    let image_url: URL
    let name: String
}

