//
//  ParkingModel.swift
//  ParkingX
//
//  Created by Manas Pradhan on 26/09/18.
//  Copyright © 2018 kfxlabs. All rights reserved.
//

import Foundation
import Firebase


class ParkingModel {
  
  public static let sharedInstance = ParkingModel()
  
  public var title = ""
  public var city = "Bangalore"
  public var parkingSpaces = [String:String]()
  public var total4WSlots = 0
  public var available4WSlots = 0
  public var total4WLevelSlots = [String:Int]()
  public var available4WLevelSlots = [String:Int]()
  public var reserved4WLevelSlots = [String:Int]()
  public var levelNames = [String:String]()

  
  private init() {
    print("Parking Model fetch from Firestore db")
  }
  
  public func fetchAsyncParkingModelFromFireStore() {
    let spacesRef = Firestore.firestore().collection("ParkingSpaces")
    spacesRef.getDocuments() { (querySnapshot, err) in
      if let err = err {
        print("Error getting documents: \(err)")
      } else {
        for document in querySnapshot!.documents {
          if document.data()["city"] as! String != self.city {
            return
          }
          
          self.parkingSpaces[document.documentID] = document.data()["name"] as? String
          if ParkingXViewController.currentSpaceId! != document.documentID {
            return
          }
          
          self.title = document.data()["name"] as! String
          self.total4WSlots = document.data()["total4WSlots"] as! Int
          self.available4WSlots = document.data()["available4WSlots"] as! Int
         
          let levelRef = spacesRef.document(document.documentID).collection("ParkingLevels")
          levelRef.getDocuments() { (querySnapshot2, err2) in
            if let err = err2 {
              print("Error getting documents: \(err)")
            } else {
              for document2 in querySnapshot2!.documents {
                print("\(document2.documentID) => \(document2.data())")
                self.total4WLevelSlots[document2.documentID] = document2.data()["total4WSlots"] as? Int
                self.available4WLevelSlots[document2.documentID] = document2.data()["available4WSlots"] as? Int
                self.reserved4WLevelSlots[document2.documentID] = document2.data()["reserved4WSlots"] as? Int
                self.levelNames[document2.documentID] = document2.data()["name"] as? String
              }
              NotificationCenter.default.post(name: Notification.Name("ParkingSpaceStatsBecameKnown"), object: nil)
            }
          }
        }
      }
    }
  }
  
  public func parkingLevelsCount() -> Int {
    return total4WLevelSlots.keys.count
  }
  
  public func parkingLevelTotalSlots4WCount(forIndexPath indexPath:IndexPath) -> Int {
    var index = 0
    for (_,value) in total4WLevelSlots {
      if index == indexPath.row {
        return value
      }
      index += 1
    }
    return 0
  }

  public func parkingLevelAvailable4WSlotsCount(forIndexPath indexPath:IndexPath) -> Int {
    var index = 0
    for (_,value) in available4WLevelSlots {
      if index == indexPath.row {
        return value
      }
      index += 1
    }
    return 0
  }

  public func parkingLevelReserved4WSlotsCount(forIndexPath indexPath:IndexPath) -> Int {
    var index = 0
    for (_,value) in reserved4WLevelSlots {
      if index == indexPath.row {
        return value
      }
      index += 1
    }
    return 0
  }

  public func parkingLevelName(forIndexPath indexPath:IndexPath) -> String {
    var index = 0
    for (_,value) in levelNames {
      if index == indexPath.row {
        return value
      }
      index += 1
    }
    return ""
  }
  
}
