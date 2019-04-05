//
//  ViewController.swift
//  Kamino
//
//  Created by Kenan Mamedoff on 02/04/2019.
//  Copyright © 2019 Kenan Mamedoff. All rights reserved.
//

import UIKit
import Kingfisher
import Lightbox

struct Planet: Decodable {
    let name: String
    let rotationPeriod: String
    let orbitalPeriod: String
    let diameter: String
    let climate: String
    let gravity: String
    let terrain: String
    let surfaceWater: String
    let population: String
    let residents: [String]
    let imageUrl: URL
    let likes: Int
}

struct PostLikes : Decodable {
    var planetId: Int
    var likes: Int
    
    private enum CodingKeys : String, CodingKey {
        case planetId = "planet_id", likes = "likes " // Did this because there is a typo in API. Instead of "likes" it has been entered as "likes ".
    }
}

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var planetProfileImageView: UIImageView!
    @IBOutlet weak var planetInfoTextView: UITextView!
    @IBOutlet weak var planetInfoView: UIView!
    @IBOutlet weak var planetLikeButtonOutlet: UIButton!
    @IBOutlet weak var residentsTableView: UITableView!

    var homeFeedPlanet: Planet?
    var residentNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mytapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapAction))
        mytapGestureRecognizer.numberOfTapsRequired = 1
        planetProfileImageView.addGestureRecognizer(mytapGestureRecognizer)
        
        let planetUrlString = "https://private-bef1e9-starwars2.apiary-mock.com/planets/10"
        Service.shared.getRequest(urlString: planetUrlString) { (feed: Planet) in
            self.homeFeedPlanet = feed
            
            guard let planetName = self.homeFeedPlanet?.name else { return }
            guard let planetImageUrl = self.homeFeedPlanet?.imageUrl else { return }
            guard let planetLikes = self.homeFeedPlanet?.likes else { return }
            guard let planetRotationPeriod = self.homeFeedPlanet?.rotationPeriod else { return }
            guard let planetOrbitalPeriod = self.homeFeedPlanet?.orbitalPeriod else { return }
            guard let planetDiameter = self.homeFeedPlanet?.diameter else { return }
            guard let planetClimate = self.homeFeedPlanet?.climate else { return }
            guard let planetGravity = self.homeFeedPlanet?.gravity else { return }
            guard let planetTerrain = self.homeFeedPlanet?.terrain else { return }
            guard let planetSurfaceWater = self.homeFeedPlanet?.surfaceWater else { return }
            guard let planetPopulation = self.homeFeedPlanet?.population else { return }
            
            self.planetProfileImageView.kf.indicatorType = .activity
            self.planetProfileImageView.kf.setImage(with: planetImageUrl) { result in
                switch result {
                case .success(let value):
                    print(value)
                case .failure(let error):
                    print(error)
                    self.planetProfileImageView.image = UIImage(named: "No Image")
                }
            }
            
            self.title = "\(planetName) - Planet"
            self.planetLikeButtonOutlet.isEnabled = true
            self.planetLikeButtonOutlet.setTitle("👍🏻 Like (\(planetLikes))", for: .normal)
            self.planetInfoTextView.text = """
            Rotation period: \(planetRotationPeriod)
            Orbital period: \(planetOrbitalPeriod)
            diameter: \(planetDiameter)
            Climate: \(planetClimate)
            Gravity: \(planetGravity)
            Terrain: \(planetTerrain)
            Surface Water: \(planetSurfaceWater)
            Population: \(planetPopulation)
            """
            
            /*
            // NOT POSSIBLE TO GET RESIDENT NAMES WITHOUT TOO MUCH API REQUESTS AT ONCE
            self.homeFeedPlanet?.residents.forEach {
                Service.shared.getRequest(urlString: $0) { (feed: Resident) in
                    self.residentNames.append(feed.name)
                }
            }
            */
            
            let contentSize = self.planetInfoTextView.sizeThatFits(self.planetInfoTextView.bounds.size)
            self.headerHeightConstraint.constant = contentSize.height + 16
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            
            UIView.transition(with: self.residentsTableView, duration: 0.35, options: .transitionCrossDissolve, animations: {
                self.residentsTableView.reloadData()
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Resident Info Segue" {
            let nextScene = segue.destination as? ResidentInfoViewController
            let indexPath = self.residentsTableView.indexPathForSelectedRow
            nextScene?.homeworldName = homeFeedPlanet?.name
            nextScene?.residentUrl = homeFeedPlanet?.residents[indexPath?.row ?? 0]
        }
    }
    
    @IBAction func planetLikeButtonAction(_ sender: UIButton) {
        let likeUrlString = "https://private-bef1e9-starwars2.apiary-mock.com/planets/10/like"
        Service.shared.postRequest(urlString: likeUrlString, body: "{\n  \"planet_id\": 10\n}", value: [["application/json", "Content-Type"]]) { (feed: PostLikes) in
            
            if let buttonTitle = self.planetLikeButtonOutlet.titleLabel?.text {
                if buttonTitle.contains(String(feed.likes)) {
                    self.planetLikeButtonOutlet.setTitle("👍🏻 Like (\(feed.likes + 1))", for: .normal)
                    self.planetLikeButtonOutlet.setTitleColor(UIColor.blue, for: .normal)
                } else {
                    self.planetLikeButtonOutlet.setTitle("👍🏻 Like (\(feed.likes))", for: .normal)
                    self.planetLikeButtonOutlet.setTitleColor(UIColor.darkGray, for: .normal)
                }
            }
        }
    }
    
    @objc func imageTapAction(recognizer: UITapGestureRecognizer) {
        guard let planetName = self.homeFeedPlanet?.name else { return }
        let images = [LightboxImage(image: self.planetProfileImageView.image!, text: planetName)]
        
        let controller = LightboxController(images: images)
        controller.dynamicBackground = true
        self.present(controller, animated: true, completion: nil)
    }
    
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeFeedPlanet?.residents.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView( _ tableView : UITableView,  titleForHeaderInSection section: Int) -> String? {
        return "Residents"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Resident Info Segue", sender: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Residents Cell", for: indexPath) as! ResidentsTableViewCell
        
        cell.residentInfoLabel.text = "Resident №\(indexPath.row + 1)"
        
        return cell
    }
}
