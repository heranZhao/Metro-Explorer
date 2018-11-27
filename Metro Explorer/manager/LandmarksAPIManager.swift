//
//  LandmarksAPIManager.swift
//  Metro Explorer
//
//  Created by heran zhao on 11/21/18.
//  Copyright © 2018 heran zhao. All rights reserved.
//

import Foundation

protocol FetchLandmarksDelegate {
    func landmarksFound()
    func landmarksNotFound()
}

protocol FetchReviewDelegate {
    func reviewFound()
    func reviewNotFound()
}

class LandmarksAPIManager
{
    static var shared = LandmarksAPIManager()
    var landmarkList = [Businesses]()
    var reviewList = [Reviews]()
    
    var delegate: FetchLandmarksDelegate?
    var reviewDelegate : FetchReviewDelegate?
    
    let key = "O6gR3nENQ_oKgJC95koDDXfIF1M9IGL5IoblFYiDAyc7tqtKsAzL5JSbkEfbeXq8h1U8h0YA0UcH9jbcKnI1VRTffV1gJDub4NZHdpeuiBA0a436s_eyqSp6yrT1W3Yx"
    
    func fetchLandmarks(_ lat : Double, _ lon : Double)
    {
        
        var urlComponents = URLComponents(string: "https://api.yelp.com/v3/businesses/search")!
        
        urlComponents.queryItems = [
            URLQueryItem(name: "term", value: "landmark"),
            URLQueryItem(name: "latitude", value: "\(lat)"),
            URLQueryItem(name: "longitude", value: "\(lon)"),
            URLQueryItem(name: "sort_by", value: "rating"),
            URLQueryItem(name: "limit", value: "10")
        ]
        
        let url = urlComponents.url!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //PUT CODE HERE TO RUN UPON COMPLETION
            //print("request complete")
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("response is nil or 200")
                self.delegate?.landmarksNotFound()
                return
            }
            
            //HERE - response is NOT nil
            guard let data = data else {
                print("data is nil")
                self.delegate?.landmarksNotFound()
                return
            }
            
            //HERE - data is NOT nil
            
            let decoder = JSONDecoder()
            
            do {
                let landmarkListResponse = try decoder.decode(LandmarksListResponse.self, from: data)
                self.landmarkList = landmarkListResponse.businesses
                self.delegate?.landmarksFound()
            } catch let error {
                
                print("codable failed - bad data format")
                print(error.localizedDescription)
                
                self.delegate?.landmarksNotFound()
            }
        }
        //print("execute request")
        task.resume()
    }
    
    func fetchReviews(_ id : String)
    {
        
        let urlComponents = URLComponents(string: "https://api.yelp.com/v3/businesses/\(id)/reviews")!
        
        let url = urlComponents.url!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("response is nil or 200")
                self.reviewDelegate?.reviewNotFound()
                return
            }
            
            guard let data = data else {
                print("data is nil")
                self.reviewDelegate?.reviewNotFound()
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let reviewListResponse = try decoder.decode(ReviewListResponse.self, from: data)
                
                self.reviewList = reviewListResponse.reviews
                self.reviewDelegate?.reviewFound()
            } catch let error {
                
                print("codable failed - bad data format")
                print(error.localizedDescription)
                self.reviewList = [Reviews]()
                self.reviewDelegate?.reviewFound()
            }
        }
        task.resume()
    }
}
