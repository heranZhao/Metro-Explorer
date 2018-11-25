//
//  NearestTableViewController.swift
//  Metro Explorer
//
//  Created by heran zhao on 11/20/18.
//  Copyright © 2018 heran zhao. All rights reserved.
//

import UIKit
import CoreLocation

class LandmarksViewController: UITableViewController {

    let TAG = "LandmarksViewController"

    private var curStation : Station?
    private var limit = 15
    private var offset = 0
    private var landmarkList : [Businesses] = []
    //let refreshControl = UIRefreshControl()
    
    private var selectLandmark : Businesses?
    private var selectLandmarkImgData : Data?
    
    enum LandmarkViewType: Int {
        case Nearest = 0, Selected, Favorite
    }
    
    var type = LandmarkViewType.Nearest
//    enum SourceType{
//        Nearest = 0,
//        
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        if(type == .Favorite && selectLandmark != nil)
        {
            let flag = PersistenceManager.sharedInstance.checkIsFavorite(business: selectLandmark!)
            if(!flag)
            {
                if let index = landmarkList.index(where: { $0.id == selectLandmark!.id })
                {
                    landmarkList.remove(at: index)
                    self.tableView.reloadData()
                }
            }
        }
        
        selectLandmark = nil
        selectLandmarkImgData = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        curStation = MetroStationAPIManager.shared.selectedStation
        switch type
        {
        case .Nearest:
            self.navigationItem.title = curStation?.Name
            fetchData()
        case .Selected:
            self.navigationItem.title = curStation?.Name
            fetchData()
        case .Favorite:
            self.navigationItem.title = "Favorite Landmarks"
            landmarkList = PersistenceManager.sharedInstance.fetchFavoriteBusinesses()
            self.tableView.reloadData()
        }
        
    }

    func fetchData()
    {
        LandmarksAPIManager.shared.delegate = self
        LandmarksAPIManager.shared.fetchLandmarks(curStation!.Lat, curStation!.Lon, limit, offset)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return landmarkList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "LandmarkTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? LandmarkTableViewCell  else {
            fatalError("")
        }
        
        let business = landmarkList[indexPath.row]
        
        cell.landmarkName.text = business.name
        cell.landmarkAddress.text = business.location.display_address.joined(separator: " ")
        cell.setURL(business.image_url)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! LandmarkTableViewCell
        selectLandmark = landmarkList[indexPath.row]
        selectLandmarkImgData = cell.data
        performSegue(withIdentifier: "detailSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue"{
            let vc = segue.destination as! LandMarkDetailViewController
            
            vc.landmark = selectLandmark
            vc.imgData = selectLandmarkImgData
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (endScrolling >= scrollView.contentSize.height)
        {
            if( type == LandmarkViewType.Nearest || type == LandmarkViewType.Selected)
            {
                fetchData()
            }
        }
    }

}


extension LandmarksViewController : FetchLandmarksDelegate
{
    func landmarksFound() {

        let newSize = LandmarksAPIManager.shared.landmarkList.count - 1
        var indexPath = [IndexPath]()
        let count : Int = Int(landmarkList.count)
        for row in 0...newSize
        {
            indexPath.append(IndexPath(row: count + row, section: 0))
        }
        
        landmarkList = landmarkList + LandmarksAPIManager.shared.landmarkList
        offset = offset  + limit
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: indexPath, with: .none)
            self.tableView.endUpdates()
        }
    }
    
    func landmarksNotFound() {
        
    }

}
