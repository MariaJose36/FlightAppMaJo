//
//  FavoriteFlight+CoreDataProperties.swift
//  CodeChallengeFlightApp
//
//  Created by Cincinnati Ai on 7/30/25.
//
//

import Foundation
import CoreData


extension FavoriteFlight {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteFlight> {
        return NSFetchRequest<FavoriteFlight>(entityName: "FavoriteFlight")
    }

    @NSManaged public var flightNumber: String?

}

extension FavoriteFlight : Identifiable {

}
