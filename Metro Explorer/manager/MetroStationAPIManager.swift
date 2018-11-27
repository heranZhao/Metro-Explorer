//
//  MetroStationManager.swift
//  Metro Explorer
//
//  Created by heran zhao on 11/20/18.
//  Copyright © 2018 heran zhao. All rights reserved.
//

import Foundation

protocol FetchStationsDelegate {
    func stationFound()
    func stationNotFound()
}

class MetroStationAPIManager
{
    
    static let shared = MetroStationAPIManager()
    
    var stationList : [Station]
    var selectedStation : Station?
    
    private init()
    {
        stationList = [Station]()
    }
    
    var delegate: FetchStationsDelegate?
    
    func fetchStations() {
        
//        if(self.stationList.count > 0)
//        {
//            self.delegate?.stationFound()
//            return
//        }

        var urlComponents = URLComponents(string: "https://api.wmata.com/Rail.svc/json/jStations")!
        
        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: "58249f718b774fbfbcee8988b13495f3")
        ]
        
        let url = urlComponents.url!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //PUT CODE HERE TO RUN UPON COMPLETION
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("response is nil or 200")
                self.delegate?.stationNotFound()
                return
            }
            
            //HERE - response is NOT nil
            guard let data = data else {
                print("data is nil")
                
                self.delegate?.stationNotFound()
                return
            }
            
            //HERE - data is NOT nil
            
            let decoder = JSONDecoder()
            
            do {
                let metroStationListResponse = try decoder.decode(MetroStationListResponse.self, from: data)
                
                self.stationList = metroStationListResponse.Stations
                
                self.delegate?.stationFound()
                
            } catch let error {
                
                print("codable failed - bad data format")
                print(error.localizedDescription)
                
                self.delegate?.stationNotFound()
            }
        }
        
        task.resume()
    }
    
    func distance(_ lat1 : Double, _ lon1 : Double, _ lat2 : Double, _ lon2 : Double) -> Double
    {
        let p = 0.017453292519943295
        let a = 0.5 - cos((lat2 - lat1) * p)/2 +
            cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p))/2
        return 12742 * asin(sqrt(a))
    }
    
    func setNearestStation(_ lat1 : Double, _ lon1 : Double)
    {
        var dis = 99999999999.0;
        for station in MetroStationAPIManager.shared.stationList
        {
            let curDis = distance(lat1, lon1, station.Lat, station.Lon)
            if(curDis <= dis)
            {
                dis = curDis
                self.selectedStation = station
            }
        }
    }
    
}
