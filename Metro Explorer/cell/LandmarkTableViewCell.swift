//
//  LandmarkTableViewCell.swift
//  Metro Explorer
//
//  Created by heran zhao on 11/22/18.
//  Copyright © 2018 heran zhao. All rights reserved.
//

import UIKit

class LandmarkTableViewCell: UITableViewCell {

    
    @IBOutlet weak var landmarkImg: UIImageView!
    @IBOutlet weak var landmarkAddress: UILabel!
    @IBOutlet weak var landmarkName: UILabel!
    
    var url : URL?
    var data : Data?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setURL(_ url: String)
    {
        self.url = URL(string: url)
        
        landmarkImg.contentMode = .scaleAspectFit
        
        if let u = self.url
        {
            downloadImage(from: u)
        }
    }

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        //print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            //print(self.landmarkName.text)
            //print("Download Finished")
            DispatchQueue.main.async() {
                self.landmarkImg.image = UIImage(data: data)
                self.data = data
            }
        }
    }
}
