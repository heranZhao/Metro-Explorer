//
//  LandMarkDetailViewController.swift
//  Metro Explorer
//
//  Created by heran zhao on 11/22/18.
//  Copyright © 2018 heran zhao. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreLocation
import Contacts

class LandMarkDetailViewController: UIViewController {
    
    
    var landmark : Businesses?
    var imgData : Data?
    var reviewList = [Reviews]()
    var isFavorite = false
    
    @IBOutlet weak var landmarkImg: UIImageView!
    
    @IBOutlet weak var landmarkAddress: UILabel!
    @IBOutlet weak var landmarkPhone: UILabel!
    @IBOutlet weak var landmarkName: UILabel!
    
    @IBOutlet weak var detailTableView: UITableView!
    
    let TAG = "LandMarkDetailViewController"

    @IBOutlet weak var favoriteBtn: UIBarButtonItem!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Detail"
        
        
        guard let landmark = landmark else
        {
            return
        }
        
        landmarkName.text = landmark.name
        landmarkPhone.text = landmark.phone
        landmarkAddress.text = landmark.location.display_address.joined(separator: " ")
        
        if let data = imgData
        {
            landmarkImg.image = UIImage(data: data)
        }
        
        let loadingNotification = MBProgressHUD.showAdded(to: detailTableView, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        loadingNotification.isUserInteractionEnabled = false
        
        LandmarksAPIManager.shared.reviewDelegate = self
        LandmarksAPIManager.shared.fetchReviews(landmark.id)
        
        detailTableView.dataSource = self
        
        let flag = PersistenceManager.sharedInstance.checkIsFavorite(business: landmark)
        if(flag == true)
        {
            favoriteBtn.image = UIImage(named: "favorite")
            isFavorite = true
        }
        else
        {
            favoriteBtn.image = UIImage(named: "favorite_outline")
        }
        
        detailTableView.tableFooterView = UIView()
    }
    
    @IBAction func mapBtnPressed(_ sender: Any) {
        guard let landmark = landmark else
        {
            return
        }
        let geocoder = CLGeocoder()
        
        let locationString = landmark.location.display_address.joined(separator: " ")
        
        geocoder.geocodeAddressString(locationString) { (placemarks, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let location = placemarks?.first?.location {
                    
                    let mapItem = MKMapItem.forCurrentLocation()
                    
                    let coords2 = CLLocationCoordinate2D(latitude: location.coordinate.latitude,longitude: location.coordinate.longitude)
                    let addressDict2 =
                        [CNPostalAddressStreetKey: landmark.location.address1,
                         CNPostalAddressCityKey: landmark.location.city,
                         CNPostalAddressStateKey: landmark.location.state,
                         CNPostalAddressPostalCodeKey: landmark.location.zip_code]
                    //item2
                    let place2 = MKPlacemark(coordinate: coords2,
                                             addressDictionary: addressDict2)
                    let mapItem2 = MKMapItem(placemark: place2)
                    
                    //-----
                    //launch it
                    let options = [MKLaunchOptionsDirectionsModeKey:
                        MKLaunchOptionsDirectionsModeDriving]
                    
                    //for 1 only.
                    //mapItem.openInMaps(launchOptions: options)
                    //for 1 or N items
                    let mapItems = [mapItem, mapItem2] //src to destination
                    MKMapItem.openMaps(with:mapItems, launchOptions: options)
                    
                }
            }
        }
    }
    @IBAction func favoriteBtnPressed(_ sender: Any)
    {
        guard let landmark = landmark else
        {
            return
        }
        if(isFavorite)
        {
            isFavorite = false
            PersistenceManager.sharedInstance.unCheckFavorite(business: landmark)
            favoriteBtn.image = UIImage(named: "favorite_outline")
        }
        else
        {
            isFavorite = true
            PersistenceManager.sharedInstance.saveWorkout(business: landmark)
            favoriteBtn.image = UIImage(named: "favorite")
        }
    }
    
    @IBAction func shareBtnPressed(_ sender: Any) {
        let shareText = "Check out this place: \(landmark?.name ?? "")!!!"
        
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        present(activityViewController, animated: true, completion: nil)
    }

}


extension LandMarkDetailViewController : UITableViewDataSource
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "DetailTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DetailTableViewCell  else {
            fatalError("")
        }
        
        let review = reviewList[indexPath.row]
        
        cell.desLabel.text = review.text
        cell.namelabel.text = review.user.name
        
        return cell
    }
    
}

extension LandMarkDetailViewController : FetchReviewDelegate
{
    func reviewFound() {
        reviewList = LandmarksAPIManager.shared.reviewList
        DispatchQueue.main.async {
            self.detailTableView.reloadData()
            MBProgressHUD.hide(for: self.detailTableView, animated: true)
            
            if(self.reviewList.count == 0)
            {
                let message = "No Reviews Found."
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                self.present(alert, animated: true)
                let duration: Double = 1.5
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                    alert.dismiss(animated: true)
                }
            }
        }
    }
    
    func reviewNotFound() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.detailTableView, animated: true)
            let message = "Network Error, please try again later."
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            self.present(alert, animated: true)
            let duration: Double = 1.5
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                alert.dismiss(animated: true)
            }
        }
    }
    
}
