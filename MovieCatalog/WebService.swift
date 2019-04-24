//
//  WebService.swift
//  MovieCatalog
//
//  Created by Afaq on 20/04/2019.
//  Copyright © 2019 Afaq. All rights reserved.
//

import Foundation
import Alamofire
import SVProgressHUD


class WebService {
    let apiKey = "?api_key=9c9c5e03126ed509f08869c00f0a6e6a"
    let baseURL = "https://api.themoviedb.org/3/movie/"
    
    func callWebService(methodName: String, parameters: [String: Any]?, message: String?, completion: @escaping (_ result: [String: Any]?, _ error: Error?) -> Void){
        
        //checking for internet reachability
        if GeneralElements.shared.internetConnectivity == .none {
            GeneralElements.showAlertWithMessage("No Internet Connection", sender: nil)
            return
        }
        
        //Display loader with message to let user know what is happening
        if let message = message{
            SVProgressHUD.show(withStatus: message)
        }
        
        //Adding headers to the request
        let headers : HTTPHeaders = ["Accept":"application/json"]
        
        
        AF.request(baseURL + methodName + apiKey, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            GeneralElements.dismissHUD()
            
            switch response.result{
            case .success(let result):
                completion(result as? [String: Any], nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
