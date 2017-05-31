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

    var isDecelerating = false
    
    var isStopped = false
    
    var spinner: SKNode!
    
    var previousFrameRotation: CGFloat = 0
    
    var spinCount = 0 {
        didSet {
            spinCountLabel.text = String(spinCount)
        }
    }
    
    var spinStartTime: Date?
    
    lazy var spinTimeLabel: SKLabelNode = {
        let label = SKLabelNode(text: "0")
        return label
    }()
    
    lazy var spinCountLabel: SKLabelNode = {
        let label = SKLabelNode(text: "0")
        return label
    }()
    
    var game: SpinGame!

    override func didMove(to view: SKView) {
        view.showsPhysics = true
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.scaleMode = .resizeFill
//        self.size = view.frame.size
        
        spinCountLabel.position = CGPoint(x: 0, y: view.frame.height/4)
        addChild(spinCountLabel)
        
        spinner = setupSpinner()
        
        addChild(spinner)
    }
    
    func setupSpinner() -> SKNode {
        let spinner = SKNode()

        let texture = SKTexture(image: BodyStyleStyleKit.imageOfBody1)
        let body = SKSpriteNode(texture: texture)
        
        body.position = CGPoint(x: 0, y: 35)

        spinner.addChild(body)

        for i in 0..<3 {
//            let texture = SKTexture(imageNamed: "blade")
//            let blade = SKSpriteNode(texture: texture, size: CGSize(width: 100, height: 40))
//            
//            blade.anchorPoint = CGPoint(x: 0, y: 0.5)
//            blade.zRotation = CGFloat(2/3.0 * .pi * Double(i))
//            
//            spinner.addChild(blade)
        }
        
        let physics = SKPhysicsBody(circleOfRadius: 100, center: CGPoint(x: 0, y: -35))
        physics.pinned = true
        physics.friction = 1.0
        physics.angularDamping = 1.0
        
        spinner.physicsBody = physics
        return spinner
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let startTime = spinStartTime {
            spinTimeLabel.text = "\(currentTime - startTime.timeIntervalSince1970) sec"
        }
    }
    
    override func didEvaluateActions() {
        // just before calculating physics
        
        previousFrameRotation = spinner.zRotation + .pi
    }
    
    override func didSimulatePhysics() {
        let currentFrameRotation = spinner.zRotation + .pi
        
        if previousFrameRotation > currentFrameRotation {
            spinCount += 1
        }
        
        if isDecelerating {
            if spinner.physicsBody!.angularVelocity < 0.5 {
                stopSpinner()
            }
        }
    }
    
    func startSpinner() {
        spinner.physicsBody?.angularVelocity = 100
        
        spinStartTime = Date()
    }
    
    func stopSpinner() {
        guard !isStopped else { return }
        
        isStopped = true
        
        spinner.physicsBody?.allowsRotation = false
        
        game.finish()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        startSpinner()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDecelerating = true
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDecelerating = true
    }
    
}
