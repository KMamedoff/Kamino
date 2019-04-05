//
//  ResidentInfoViewController.swift
//  Kamino
//
//  Created by Kenan Mamedoff on 02/04/2019.
//  Copyright © 2019 Kenan Mamedoff. All rights reserved.
//

import UIKit
import Kingfisher

struct Resident: Decodable {
    let name: String
    let height: String
    let mass: String
    let hairColor: String
    let skinColor: String
    let eyeColor: String
    let birthYear: String
    let gender: String
    let homeworld: URL
    let imageUrl: URL
}

class ResidentInfoViewController: UIViewController {
    
    @IBOutlet weak var residentInfoProfileImageViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var residentInfoProfileImageView: UIImageView!
    @IBOutlet weak var residentInfoTextView: UITextView!
    
    var residentUrl: String?
    var homeworldName: String?
    var homeFeedResident: Resident?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let residentUrlString = residentUrl else { return }
        Service.shared.getRequest(urlString: residentUrlString) { (feed: Resident) in
            self.homeFeedResident = feed
            
            guard let residentName = self.homeFeedResident?.name else { return }
            guard let residentHeight = self.homeFeedResident?.height else { return }
            guard let residentHairColor = self.homeFeedResident?.hairColor else { return }
            guard let residentSkinColor = self.homeFeedResident?.skinColor else { return }
            guard let residentEyeColor = self.homeFeedResident?.eyeColor else { return }
            guard let residentBirthYear = self.homeFeedResident?.birthYear else { return }
            guard let residentGender = self.homeFeedResident?.gender else { return }
            guard let residentImageUrl = self.homeFeedResident?.imageUrl else { return }
            guard let planetName = self.homeworldName else { return }
            
            self.residentInfoProfileImageView.kf.indicatorType = .activity
            self.residentInfoProfileImageView.kf.setImage(with: residentImageUrl) { result in
                switch result {
                case .success(let value):
                    print(value.image)
                    
                    let imageViewSize = CGSize(width: self.residentInfoProfileImageView.frame.width, height: self.residentInfoProfileImageView.frame.height)
                    let imageAspectRatio = value.image.size.height / value.image.size.width
                    
                    self.residentInfoProfileImageViewConstraint.constant = imageViewSize.width * imageAspectRatio
                    UIView.animate(withDuration: 0.3) {
                        self.view.layoutIfNeeded()
                    }
                case .failure(let error):
                    print(error)
                    
                    self.residentInfoProfileImageView.image = UIImage(named: "No Image")
                }
            }
            
            self.title = residentName
            self.residentInfoTextView.text = """
            Height: \(residentHeight)
            Hair color: \(residentHairColor)
            Skin color: \(residentSkinColor)
            Eye color: \(residentEyeColor)
            Birth year: \(residentBirthYear)
            Gender: \(residentGender)
            Homeworld: \(planetName)
            """
        }
        
    }
    
}
