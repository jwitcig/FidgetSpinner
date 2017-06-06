//
//  SpinScene.swift
//  FidgetSpinner
//
//  Created by Developer on 5/29/17.
//  Copyright © 2017 JwitApps. All rights reserved.
//

import UIKit
import SpriteKit

import JWSwiftTools

struct TimedLocation {
    let location: CGPoint
    let time: Date
}

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
    
    var spinStart: TimedLocation?
    
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
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.scaleMode = .resizeFill
//        self.size = view.frame.size
        
        physicsWorld.gravity = .zero
        
        spinCountLabel.position = CGPoint(x: 0, y: view.frame.height/4)
        addChild(spinCountLabel)
        
        createSpinner(bodyColor: .blue, bearingColor: .clear, capColor: .clear, bodyStyle: 0, bearingStyle: 0, capStyle: 0)
    }
    
    func createSpinner(bodyColor: UIColor, bearingColor: UIColor, capColor: UIColor, bodyStyle: Int, bearingStyle: Int, capStyle: Int) {
        if let spinner = self.spinner {
            if spinner.parent != nil {
                spinner.removeFromParent()
            }
        }
        
        
        let imageSize = CGSize(width: 104, height: 104)
        var image: UIImage?
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        BearingStyles.draw(body: bearingStyle,
                           rect: CGRect(origin: .zero, size: imageSize),
                       resizing: .aspectFit,
                      bodyColor: bearingColor)

        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        CapStyles.draw(body: capStyle,
                       rect: CGRect(origin: .zero, size: imageSize),
                   resizing: .aspectFit,
                  bodyColor: capColor)
    
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        
        let spinnerSize = CGSize(width: 360, height: 328)
        
        UIGraphicsBeginImageContextWithOptions(spinnerSize, false, 0)
        BodyStyles.draw(body: bodyStyle,
                        rect: CGRect(origin: .zero, size: spinnerSize),
                    resizing: .aspectFit,
                   bodyColor: bodyColor,
                       image: image ?? UIImage())
        
        let spinnerImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        let texture = SKTexture(image: spinnerImage)
        let spinner = SKSpriteNode(texture: texture)
        
        spinner.position = CGPoint(x: 0, y: 35)
        
        let physics = SKPhysicsBody(circleOfRadius: 100, center: CGPoint(x: 0, y: -35))
        physics.pinned = true
        physics.friction = 0.2
        physics.angularDamping = 0.05
        
        spinner.physicsBody = physics
        
        self.spinner = spinner
        addChild(spinner)
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
        guard isDecelerating else { return }
        
        let currentFrameRotation = spinner.zRotation + .pi
        
        if spinner.physicsBody!.angularVelocity > 0 {
            if previousFrameRotation > currentFrameRotation {
                spinCount += 1
            }
        } else {
            if previousFrameRotation < currentFrameRotation {
                spinCount += 1
            }
        }
        
        if isDecelerating {
            if abs(spinner.physicsBody!.angularVelocity) < 0.5 {
                stopSpinner()
            }
        }
    }
    
    func startSpinner(velocity: CGFloat) {
        spinner.constraints = []
        spinner.physicsBody?.angularVelocity = velocity
        
        spinStartTime = Date()
        
        isDecelerating = true
    }
    
    func stopSpinner() {
        guard !isStopped else { return }
        
        isStopped = true
        
        spinner.physicsBody?.allowsRotation = false
        
        game.finish()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            guard !isDecelerating else { return }
            
            let location = touch.location(in: self)
            
            spinStart = TimedLocation(location: location, time: Date())
            
            let orient = SKConstraint.orient(to: location, in: self, offset: SKRange(constantValue: 0))
            spinner.constraints = [orient]
            
            print(spinner.physicsBody?.angularVelocity)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            guard !isDecelerating else { return }
            guard let start = spinStart else { return }
            
            let end = TimedLocation(location: touch.location(in: self), time: Date())
            
            let distance = end.location.distance(toPoint: start.location)
            let time = end.time.timeIntervalSince(start.time)
            
            let direction = spinner.physicsBody!.angularVelocity > 0 ? 1 : -1
            
            let velocity = distance / CGFloat(time) * CGFloat(direction)
            
            startSpinner(velocity: velocity)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
}

struct BodyStyles {
    static func draw(body: Int, rect: CGRect, resizing: BodyStyleStyleKit.ResizingBehavior, bodyColor: UIColor, image: UIImage) {
        switch body {
        case 0:
            BodyStyleStyleKit.drawBody(frame: rect, resizing: resizing, bodyColor: bodyColor, bearing: image)
        case 1:
            BodyStyleStyleKit.drawBody1(frame: rect, resizing: resizing, bodyColor: bodyColor, bearing: image)
        case 2:
            BodyStyleStyleKit.drawBody2(frame: rect, resizing: resizing, bodyColor: bodyColor, bearing: image)
        case 3:
            BodyStyleStyleKit.drawBody3(frame: rect, resizing: resizing, bodyColor: bodyColor, bearing: image)
        case 4:
            BodyStyleStyleKit.drawBody4(frame: rect, resizing: resizing, bodyColor: bodyColor, bearing: image)
        case 5:
            BodyStyleStyleKit.drawBody5(frame: rect, resizing: resizing, bodyColor: bodyColor, bearing: image)
        case 6:
            BodyStyleStyleKit.drawBody6(frame: rect, resizing: resizing, bodyColor: bodyColor, bearing: image)
        case 7:
            BodyStyleStyleKit.drawBody7(frame: rect, resizing: resizing, bodyColor: bodyColor, bearing: image)
        case 8:
            BodyStyleStyleKit.drawBody8(frame: rect, resizing: resizing, bodyColor: bodyColor, bearing: image)
        case 9:
            BodyStyleStyleKit.drawBody9(frame: rect, resizing: resizing, bodyColor: bodyColor, bearing: image)
        case 10:
            BodyStyleStyleKit.drawBody10(frame: rect, resizing: resizing, bodyColor: bodyColor, bearing: image)
        case 11:
            BodyStyleStyleKit.drawBody11(frame: rect, resizing: resizing, bodyColor: bodyColor, bearing: image)
        case 12:
            BodyStyleStyleKit.drawBody12(frame: rect, resizing: resizing, bodyColor: bodyColor, bearing: image)
        default:
            break
        }
    }
}

struct BearingStyles {
    static func draw(body: Int, rect: CGRect, resizing: BearingStyleStyleKit.ResizingBehavior, bodyColor: UIColor) {
        switch body {
        case 0:
            BearingStyleStyleKit.drawBearing1(frame: rect, resizing: resizing, bearingColorParam: bodyColor)
        case 1:
            BearingStyleStyleKit.drawBearing2(frame: rect, resizing: resizing, bearingColorParam: bodyColor)
        case 2:
            BearingStyleStyleKit.drawBearing3(frame: rect, resizing: resizing)
        case 3:
            BearingStyleStyleKit.drawBearing4(frame: rect, resizing: resizing, bearingColorParam: bodyColor)
        case 4:
            BearingStyleStyleKit.drawBearing5(frame: rect, resizing: resizing, bearingColorParam: bodyColor)
        case 5:
            BearingStyleStyleKit.drawBearing6(frame: rect, resizing: resizing)
        default:
            break
        }
    }
}

struct CapStyles {
    static func draw(body: Int, rect: CGRect, resizing: CapStyleStyleKit.ResizingBehavior, bodyColor: UIColor) {
        switch body {
        case 0:
            CapStyleStyleKit.drawCap1(frame: rect, resizing: resizing, capColor: bodyColor)
        case 1:
            CapStyleStyleKit.drawCap2(frame: rect, resizing: resizing, capColor: bodyColor)
        case 2:
            CapStyleStyleKit.drawCap3(frame: rect, resizing: resizing, capColor: bodyColor)
        case 3:
            CapStyleStyleKit.drawCap4(frame: rect, resizing: resizing, capColor: bodyColor)
        case 4:
            CapStyleStyleKit.drawCap5(frame: rect, resizing: resizing, capColor: bodyColor)
        default:
            break
        }
    }
}
