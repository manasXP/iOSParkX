//
//  ParkingXViewController.swift
//  ParkingX
//
//  Created by Manas Pradhan on 26/09/18.
//  Copyright © 2018 kfxlabs. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ParkingXViewController: UITableViewController {
  
  private let model = ParkingModel.sharedInstance
  
  private var listener = Firestore.firestore().collection("ParkingSpaces").whereField("spaceId", isEqualTo: ParkingModel.sharedInstance.currentParkingSpaceId!)
    .addSnapshotListener { querySnapshot, error in
  }
  
  @IBAction func parkingSelectorTouched(_ sender: UIBarButtonItem!) {
    let alertController = UIAlertController(title: "Parking Spaces", message: "Of \(model.parkingSpaces.count) Parking Spaces in your city", preferredStyle: .actionSheet)
    
    for (spaceId,space) in model.parkingSpaces {
      let action = UIAlertAction(title: space, style: .default) { (action:UIAlertAction) in
        if let currentSpaceId = self.model.currentParkingSpaceId {
          if currentSpaceId != spaceId {
            UserDefaults.standard.set(spaceId, forKey: "CurrentParkingSpaceKey")
            self.listener.remove()
            self.listener = Firestore.firestore().collection("ParkingSpaces").whereField("spaceId", isEqualTo: currentSpaceId)
              .addSnapshotListener { querySnapshot, error in
                self.model.fetchAsyncParkingModelFromFireStore()
            }
          }
        } else {
          //TODO: Later use GPS to assign a closest distance default value
          UserDefaults.standard.set("PhoenixMallBangalore", forKey: "CurrentParkingSpaceKey")
        }
      }
      alertController.addAction(action)
    }

    let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
    }
    alertController.addAction(cancel)

    self.present(alertController, animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(parkingStatsBecameKnown), name: Notification.Name("ParkingSpaceStatsBecameKnown"), object: nil)

    model.fetchAsyncParkingModelFromFireStore()
    navigationController?.navigationBar.prefersLargeTitles = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Attach listener
    if let currentSpaceId = model.currentParkingSpaceId {
      listener.remove()
      listener = Firestore.firestore().collection("ParkingSpaces").whereField("spaceId", isEqualTo: currentSpaceId)
        .addSnapshotListener { querySnapshot, error in
          self.model.fetchAsyncParkingModelFromFireStore()
      }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    listener.remove()
  }
  
  @objc func parkingStatsBecameKnown() {
    title = model.title
    self.tableView.reloadData()
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "\(model.available4WSlots) of \(model.total4WSlots) Parking Available"
  }

  public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 60.0
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = UIView()
    headerView.backgroundColor = UIColor.lightGray
    
    let headerLabel = UILabel(frame: CGRect(x: 30, y: 10, width:
      tableView.bounds.size.width, height: tableView.bounds.size.height))
    headerLabel.font = UIFont(name: "Verdana", size: 24)
    headerLabel.textColor = UIColor.white
    headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
    headerLabel.sizeToFit()
    headerView.addSubview(headerLabel)
    
    return headerView
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return model.parkingLevelsCount()
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingSummaryCell", for: indexPath)
    cell.textLabel!.text = model.parkingLevelName(forIndexPath: indexPath)
    
    let availableSlots = model.parkingLevelAvailable4WSlotsCount(forIndexPath: indexPath)
    let totalSlots = model.parkingLevelTotalSlots4WCount(forIndexPath: indexPath)
    if availableSlots > 0 {
      cell.detailTextLabel!.textColor = UIColor.black
      cell.detailTextLabel!.text = "\(availableSlots) of \(totalSlots) Available"
    } else {
      cell.detailTextLabel!.textColor = UIColor.red
      cell.detailTextLabel!.text = "Parking Full"
    }
    
    return cell
  }
  
}
