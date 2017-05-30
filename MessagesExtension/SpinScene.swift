//
//  SpinScene.swift
//  FidgetSpinner
//
//  Created by Developer on 5/29/17.
//  Copyright © 2017 JwitApps. All rights reserved.
//

import UIKit
import SpriteKit

class SpinScene: SKScene {

    var spinner: SKNode!
    
    var rotation: CGFloat = 0
    
    var spinCount = 0 {
        didSet {
            spinCountLabel.text = String(spinCount)
        }
    }
    
    lazy var spinCountLabel: SKLabelNode = {
        let label = SKLabelNode(text: "0")
        return label
    }()

    override func didMove(to view: SKView) {
        spinCountLabel.position = CGPoint(x: 0, y: view.frame.height/4)
        addChild(spinCountLabel)
        
        spinner = setupSpinner()
        
        addChild(spinner)
    }
    
    func setupSpinner() -> SKNode {
        let spinner = SKNode()
        
        for i in 0..<3 {
            let texture = SKTexture(imageNamed: "blade")
            let blade = SKSpriteNode(texture: texture, size: CGSize(width: 100, height: 40))
            
            blade.anchorPoint = CGPoint(x: 0, y: 0.5)
            blade.zRotation = CGFloat(2/3.0 * .pi * Double(i))
            
            spinner.addChild(blade)
        }
        
        let physics = SKPhysicsBody(circleOfRadius: 100)
        physics.pinned = true
        
        spinner.physicsBody = physics
        return spinner
    }
    
    override func didEvaluateActions() {
        // just before calculating physics
        
        rotation = spinner.zRotation + .pi
    }
    
    override func didSimulatePhysics() {
        if rotation > spinner.zRotation + .pi {
            spinCount += 1
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        spinner.physicsBody?.applyTorque(3)
    }
    
}
