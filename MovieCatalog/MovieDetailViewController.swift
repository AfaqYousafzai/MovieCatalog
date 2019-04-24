//
//  MovieDetailViewController.swift
//  MovieCatalog
//
//  Created by Afaq on 21/04/2019.
//  Copyright © 2019 Afaq. All rights reserved.
//

import UIKit
import Kingfisher
import XCDYouTubeKit
import AVKit

struct YouTubeVideoQuality {
    static let hd720 = NSNumber(value: XCDYouTubeVideoQuality.HD720.rawValue)
    static let medium360 = NSNumber(value: XCDYouTubeVideoQuality.medium360.rawValue)
    static let small240 = NSNumber(value: XCDYouTubeVideoQuality.small240.rawValue)
}

class MovieDetailViewController: UIViewController {
    
    let imageUrlPath = "http://image.tmdb.org/t/p/w342/"

    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!
    
    @IBOutlet weak var genreActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var watchTrailerIndicator: UIActivityIndicatorView!
    
    var movieBasicInfo: MovieModel!
    
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.titleLabel.text = movieBasicInfo.title
        //self.genresLabel.text = movieBasicInfo.genreIds.first
        self.dateLabel.text = movieBasicInfo.releaseDate
        
        
        //using kingFisher to cache the images
        let imageUrl = URL(string: self.imageUrlPath + movieBasicInfo.posterPath)
        self.posterImage.kf.indicatorType = .activity
        self.posterImage.kf.setImage(with: imageUrl)
        
        self.overviewTextView.text = movieBasicInfo.overview
        
       
        self.watchTrailerIndicator.isHidden = true
        self.genreActivityIndicator.startAnimating()
        self.genresLabel.isHidden = true
        
         self.fetchDetailForMovie(withId: movieBasicInfo.id)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

    //MARK:- Actions
    @IBAction func watchTrailerPressed(_ sender: UIButton){
        self.watchTrailerIndicator.isHidden = false;
        self.watchTrailerIndicator.startAnimating()
        fetchYoutubeIdentifierForMovie(withId: movieBasicInfo.id)
    }
    
    
    func playVideo(videoIdentifier: String?) {
        let playerViewController = AVPlayerViewController()
        self.present(playerViewController, animated: true, completion: nil)
        
        
        XCDYouTubeClient.default().getVideoWithIdentifier(videoIdentifier) { [weak playerViewController] (video: XCDYouTubeVideo?, error: Error?) in
            if let streamURLs = video?.streamURLs, let streamURL = (streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? streamURLs[YouTubeVideoQuality.hd720] ?? streamURLs[YouTubeVideoQuality.medium360] ?? streamURLs[YouTubeVideoQuality.small240]) {
                playerViewController?.player = AVPlayer(url: streamURL)
                NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying),
                                                       name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerViewController?.player?.currentItem)
                playerViewController?.player?.play()
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func playerDidFinishPlaying(_ notification: NSNotification) {
        self.dismiss(animated: true, completion: nil)
        
    }

    
    
}


//MARK:- Web Service
extension MovieDetailViewController{
    
    //calling webservice to fetch list of popular movies
    func fetchDetailForMovie(withId id: Int){
        let methodName = String(id)
        let parameters : Dictionary<String, Any>? = nil
        
        let webService = WebService()
        webService.callWebService(methodName: methodName, parameters: parameters, message: nil){ response, error in
            
            if let _ = error{
                GeneralElements.showAlertWithMessage("Can't connect to server. Please! try again", sender: self)
            }
            
            guard let dataDict = response else{
                return
            }
            self.parseGenresFromData(data: dataDict)
        }
    }
    
    func parseGenresFromData(data: Dictionary<String, Any>){
        if let genres = data["genres"] as? [Dictionary<String, Any>]{
            
            var genresString : String = ""
            
            for i in 0..<genres.count{
                genresString += genres[i]["name"] as! String
                
                //to avoid comma at the end of string
                if i == genres.count - 1{
                    break
                }
                genresString += ", "
            }
            
            self.genresLabel.text = genresString
            self.genreActivityIndicator.stopAnimating()
            self.genreActivityIndicator.removeFromSuperview()
            self.genresLabel.isHidden = false
        }
    }
    
    func fetchYoutubeIdentifierForMovie(withId id: Int){
        let methodName = String(id) + "/videos"
        let parameters : Dictionary<String, Any>? = nil
        
        let webService = WebService()
        webService.callWebService(methodName: methodName, parameters: parameters, message: nil){ response, error in
            
            if let _ = error{
                GeneralElements.showAlertWithMessage("Can't connect to server. Please! try again", sender: self)
            }
            
            guard let dataDict = response else{
                return
            }
            self.parseYoutubeIdentifierFromData(data: dataDict)
        }
    }
    
    func parseYoutubeIdentifierFromData(data: Dictionary<String, Any>){
        if let results = data["results"] as? [Dictionary<String, Any>]{
            for result in results{
                let type = result["type"] as! String
                if type == "Trailer"{
                    let youtubeIdentifier = result["key"] as! String
                    self.playVideo(videoIdentifier: youtubeIdentifier)
                    
                    self.watchTrailerIndicator.stopAnimating()
                    self.watchTrailerIndicator.isHidden = true
                    
                    break;
                }
            }
        }
    }
}
