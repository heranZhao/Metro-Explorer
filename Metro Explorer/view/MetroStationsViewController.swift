//
//  MetroStationsViewController.swift
//  Metro Explorer
//
//  Created by heran zhao on 11/21/18.
//  Copyright © 2018 heran zhao. All rights reserved.
//

import UIKit
//import MBProgressHUD

class MetroStationsViewController: UITableViewController {

    let TAG = "MetroStationsViewController"

    var stationList = [Station]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        MetroStationAPIManager.shared.delegate = self
        MetroStationAPIManager.shared.fetchStations()
        //let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        loadingNotification.isUserInteractionEnabled = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    //- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return stationList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MetroStationTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MetroStationTableViewCell  else {
            fatalError("")
        }
        
        let station = stationList[indexPath.row]
        
        cell.stationName.text = station.Name
        cell.stationAddress.text = station.Address.Street
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)

        let station = stationList[indexPath.row]
        MetroStationAPIManager.shared.selectedStation = station
        performSegue(withIdentifier: "landmarkSegue", sender: self)
    }
    
    func setStationList()
    {
        stationList = MetroStationAPIManager.shared.stationList
        DispatchQueue.main.async {
            self.tableView.reloadData()
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
}
extension MetroStationsViewController : FetchStationsDelegate
{
    func stationFound()
    {
        setStationList()
        //MetroStationAPIManager.shared.setNearestStation(curLat, curLon)
        //performSegue(withIdentifier: "stationSegue", sender: self)
    }
    
    func stationNotFound() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
}