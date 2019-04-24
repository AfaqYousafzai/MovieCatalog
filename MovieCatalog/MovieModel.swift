//
//  MovieModel.swift
//  MovieCatalog
//
//  Created by Afaq on 20/04/2019.
//  Copyright © 2019 Afaq. All rights reserved.
//

import Foundation

public struct MovieModel: Codable {
    
    public var adult : Bool!
    public var backdropPath : String!
    public var genreIds : [Int]!
    public var id : Int!
    public var originalLanguage : String!
    public var originalTitle : String!
    public var overview : String!
    public var popularity : Float!
    public var posterPath : String!
    public var releaseDate : String!
    public var title : String!
    public var video : Bool!
    public var voteAverage : Float!
    public var voteCount : Int!
}
