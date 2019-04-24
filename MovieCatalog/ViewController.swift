//
//  ViewController.swift
//  MovieCatalog
//
//  Created by Afaq on 20/04/2019.
//  Copyright © 2019 Afaq. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    let imageUrlPath = "http://image.tmdb.org/t/p/w342/"
    
    let identifier = "movieCell"
    var movies : [MovieModel] = []
    var filteredMovies : [MovieModel] = []
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //adding refresh control to the tableView
        refreshControl.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)
        self.tableView.refreshControl = refreshControl
        self.loadCachedData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.fetchPopularMovies()
        }
        
        self.addKeyboardObserver()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "Movie Catalog"
    }
    
    
    func addKeyboardObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let begginingFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let endFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = endFrame.origin.y - begginingFrame.origin.y
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
            self.searchBar.frame.origin.y += deltaY
        }, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


//MARK:- Table view datasource
extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! movieCell
        
        let movie = filteredMovies[indexPath.row]
        
        cell.movieTitle.text = movie.title
        
        
        let imageUrl = URL(string: self.imageUrlPath + movie.backdropPath)
        
        cell.thumbnail.kf.indicatorType = .activity
        cell.thumbnail.kf.setImage(with: imageUrl)
        
        return cell;
    }
}


//MARK:- table view delegate
extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.view.endEditing(true)
        
        if let movieDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetail") as? MovieDetailViewController{
            movieDetailVC.movieBasicInfo = self.filteredMovies[indexPath.row]
            self.navigationController?.pushViewController(movieDetailVC, animated: true)
        }
    }
    
    //display refresh control with current time
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        let refreshControlString = "Updating: " + dateFormatter.string(from: Date())
        
        refreshControl.attributedTitle = NSAttributedString(string: refreshControlString)
    }
    
    //call webservice to updata transactions
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refreshControl.isRefreshing{
            self.loadCachedData()
            fetchPopularMovies()
        }
    }
}



//MARK:- Search bar delegate
extension ViewController: UISearchBarDelegate{
    
    //Filtering movies locally
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = movies.filter{$0.title.lowercased().contains(searchText.lowercased())}
        
        if searchText == ""{
            filteredMovies = movies
        }
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}



//MARK:- Web Service
extension ViewController{
    
    //calling webservice to fetch list of popular movies
    func fetchPopularMovies(){
        let methodName = "popular"
        let parameters : Dictionary<String, Any>? = nil
        
        let webService = WebService()
        webService.callWebService(methodName: methodName, parameters: parameters, message: "Fetching Movies"){ response, error in
            
            GeneralElements.dismissHUD()
            
            if let _ = error{
                GeneralElements.showAlertWithMessage("Can't connect to server. Please! try again", sender: self)
            }
            
            guard let dataDict = response else{
                return
            }
            self.parseData(data: dataDict)
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
            self.saveCachedData()
        }
    }
    
    func parseData(data: Dictionary<String, Any>){
        let results = data["results"] as! [Dictionary<String, Any>]
        
        movies = []
        
        for result in results{
            var movie = MovieModel()
            movie.adult = result["adult"] as? Bool
            movie.backdropPath = result["backdrop_path"] as? String
            movie.genreIds = result["genre_ids"] as? [Int]
            movie.id = result["id"] as? Int
            movie.originalLanguage = result["original_language"] as? String
            movie.originalTitle = result["original_title"] as? String
            movie.overview = result["overview"] as? String
            movie.popularity = result["popularity"] as? Float
            movie.posterPath = result["poster_path"] as? String
            movie.releaseDate = result["release_date"] as? String
            movie.title = result["title"] as? String
            movie.video = result["video"] as? Bool
            movie.voteAverage = result["vote_average"] as? Float
            movie.voteCount = result["vote_count"] as? Int
            
            self.movies.append(movie)
        }
        filteredMovies = movies
    }
}


//MARK:- Caching data in plist file
extension ViewController{
    
    func getPlistUrl() -> URL{
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths.object(at: 0) as! NSString
        let path = documentsDirectory.appendingPathComponent("CachedData.plist")
        return URL(fileURLWithPath: path)
    }
    
    //loading cached data from plist
    func loadCachedData() {
        let pilstURL = getPlistUrl()
        
        do{
            let plistDecoder = PropertyListDecoder()
            let data = try Data.init(contentsOf: pilstURL)
            let value = try plistDecoder.decode([MovieModel].self, from: data)
            
            self.movies = value as [MovieModel]
            self.filteredMovies = movies
            self.tableView.reloadData()
        }
        catch {
            print(error)
        }
    }
    
    //caching data to plist
    func saveCachedData() {
        
       let pilstURL = getPlistUrl()
        
        do {
            let plistEncoder = PropertyListEncoder()
            plistEncoder.outputFormat = .xml
            let plistData = try plistEncoder.encode(movies)
            try plistData.write(to: pilstURL)
            
        } catch {
            print(error)
        }
    }
}

