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
    
    let collectionView: UICollectionView
    
    var onSelection: ((Spinner)->())!
    
    init(onSelection: @escaping (Spinner)->()) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 130, height: 130)
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: CGRect(origin: .zero, size: CGSize(width: 1, height: 1)), collectionViewLayout: layout)
        collectionView.register(CustomSpinnerCell.self, forCellWithReuseIdentifier: "CustomSpinnerCell")
        collectionView.register(NewCustomSpinnerCell.self, forCellWithReuseIdentifier: "NewCustomSpinnerCell")
        
        self.onSelection = onSelection
        
        super.init(nibName: nil, bundle: nil)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        constrain(collectionView, view) {
            $0.size == $1.size
            $0.center == $1.center
        }
        
        let database = FIRDatabase.database().reference()
        database.child("spinners").observe(.value, with: {
            
            print($0.children.allObjects)
            
            guard let spinnersData = $0.children.allObjects as? [FIRDataSnapshot] else { return }
            
            let sortedSpinnersData = spinnersData.sorted { $0.key > $1.key }
            
            self.spinners = sortedSpinnersData.map {
                var value = $0.value! as! [String : Any]
                value["name"] = $0.key
                return Spinner(dictionary: value)!
            }
            
            self.collectionView.reloadData()
        })
    }
}

extension MySpinnersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard indexPath.row > 0 else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewCustomSpinnerCell", for: indexPath) as! NewCustomSpinnerCell
            
            let database = FIRDatabase.database().reference()
            let name = database.child("spinners").childByAutoId().key
            cell.spinner = Spinner(name: name)
            cell.onSelection = onSelection
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomSpinnerCell", for: indexPath) as! CustomSpinnerCell
        
        cell.spinner = spinners[indexPath.row-1]
        
        cell.onSelection = onSelection
        return cell
    }
}

extension MySpinnersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spinners.count + 1
    }
}

extension MySpinnersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(20, 20, 20, 20)
    }
}

class NewCustomSpinnerCell: UICollectionViewCell {
    var spinner: Spinner!
    var onSelection: ((Spinner)->())!

    override func draw(_ rect: CGRect) {
        UserInterfaceStyleKit.drawCreateNewSpinner(frame: rect, resizing: .aspectFit)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        onSelection(spinner)
    }
}

class CustomSpinnerCell: UICollectionViewCell {
    var spinner: Spinner! {
        didSet {
            spinnerImage = spinner.imageOfSpinner().scaled(to: CGSize(width: 145, height: 145))
        }
    }
    private var spinnerImage: UIImage!
    
    var onSelection: ((Spinner)->())!
    
    override func draw(_ rect: CGRect) {
        UserInterfaceStyleKit.drawSavedSpinner(frame: rect, resizing: .aspectFit, savedSpinnerImage: spinnerImage, customSpinnerImageSize: spinnerImage.size)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        onSelection(spinner)
    }
}
