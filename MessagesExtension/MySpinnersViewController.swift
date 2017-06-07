//
//  MySpinnersViewController.swift
//  FidgetSpinner
//
//  Created by Developer on 6/6/17.
//  Copyright © 2017 JwitApps. All rights reserved.
//

import UIKit

import Cartography
import FirebaseDatabase

class MySpinnersViewController: UIViewController {

    var spinners: [Spinner] = []
    
    var collectionView = UICollectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        constrain(collectionView, view) {
            $0.size == $1.size
            $0.center == $1.center
        }
        
        let database = FIRDatabase.database().reference()
        database.child("spinners").observe(.value, with: {
            guard let spinnersData = $0.children.allObjects as? [[String : Any]] else { return }
            
            self.spinners = spinnersData.map { Spinner(dictionary: $0)! }
        })
    }
}

extension MySpinnersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = UICollectionViewCell()
        return cell
    }
}

extension MySpinnersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spinners.count
    }
}

struct Spinner {
    let bodyStyle: Int
    let bearingStyle: Int
    let capStyle: Int
    let bodyColor: UIColor
    let bearingColor: UIColor
    let capColor: UIColor
    
    init?(dictionary: [String : Any]) {
        self.bodyStyle = dictionary["bodyStyle"]! as! Int
        self.bearingStyle = dictionary["bodyStyle"]! as! Int
        self.capStyle = dictionary["bodyStyle"]! as! Int
        
        self.bodyColor = UIColor(ciColor: CIColor(string: dictionary["bodyColor"]! as! String))
        self.bearingColor = UIColor(ciColor: CIColor(string: dictionary["bearingColor"]! as! String))
        self.capColor = UIColor(ciColor: CIColor(string: dictionary["capColor"]! as! String))
    }
}
