//
//  SpinnerViewController.swift
//  FidgetSpinner
//
//  Created by Developer on 5/30/17.
//  Copyright © 2017 JwitApps. All rights reserved.
//

import Messages
import SpriteKit
import UIKit

import Cartography

import iMessageTools
import JWSwiftTools

class SpinnerViewController: UIViewController {
    
    var skView: SKView {
        return view as! SKView
    }
    
    var scene = SpinScene()
    
    var game: SpinGame!
    
    var messageSender: MessageSender?
    var orientationManager: OrientationManager?
    
    init(previousSession: SpinSession?, messageSender: MessageSender, orientationManager: OrientationManager) {
        self.messageSender = messageSender
        self.orientationManager = orientationManager
      
        super.init(nibName: nil, bundle: nil)
        
        configureScene(previousSession: previousSession)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        self.view = SKView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createColorPickers()
    }
    
    private func configureScene(previousSession: SpinSession?) {
        let lifeCycle = LifeCycle(started: nil, finished: self.finished)
        
        self.game = SpinGame(previousSession: previousSession, cycle: lifeCycle)
        scene.game = self.game
        
        skView.presentScene(scene)
    }
    
    func createColorPickers() {
        let label = UILabel()
        label.text = "hey"
        let componentsStack = UIStackView(arrangedSubviews: [label])
        
        let frameColorPicker = ColorPicker(selected: .white) { selected in
            self.scene.backgroundColor = selected
        }
        
        let scrollView = UIScrollView()

        scrollView.translatesAutoresizingMaskIntoConstraints = false

        frameColorPicker.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(frameColorPicker)
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        constrain(frameColorPicker, scrollView) {
            $0.leading == $1.leading
            $0.trailing == $1.trailing
            $0.top == $1.top
            $0.bottom == $1.bottom
        }
        
        let colorPickersStack = UIStackView(arrangedSubviews: [componentsStack, scrollView])
        colorPickersStack.axis = .vertical
        colorPickersStack.alignment = .fill
        colorPickersStack.distribution = .fillEqually
        
        view.addSubview(colorPickersStack)
        
        constrain(colorPickersStack, view) {
            $0.centerX == $1.centerX
            $0.top == $1.top
            
            $0.width == $1.width
            $0.height == 88
        }
    }
    
    func finished() {
        let initial = SpinSession.InitialData()
        let instance = SpinSession.InstanceData(time: 10, spins: 10)
        
        let selectedMessage = (messageSender as? MSMessagesAppViewController)?.activeConversation?.selectedMessage
        let session = SpinSession(instance: instance, initial: initial, ended: false, message: selectedMessage)
        
        let spinnerImage = UIImage(cgImage: skView.texture(from: scene.spinner)!.cgImage())
        
        let layout = SpinMessageLayoutBuilder(spinnerImage: spinnerImage, time: 10, spins: scene.spinCount).generateLayout()
        
        let writer = SpinMessageWriter(data: session.dictionary, session: selectedMessage?.session)

        guard let newMessage = writer?.message else { return }
        
        messageSender?.send(message: newMessage,
                             layout: layout,
                  completionHandler: nil)
    }
}

class ColorView: UIView {
    
    var onTouch: (UIColor)->()
    
    init(color: UIColor, onTouch: @escaping (UIColor)->()) {
        self.onTouch = onTouch
        
        super.init(frame: .zero)
        
        backgroundColor = color
    
        addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        onTouch(backgroundColor!)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "bounds" {
            layer.cornerRadius = frame.size.height/2
        }
    }
}

class ColorPicker: UIStackView {
    static var allColors = [ColorPickerStyleKit.color,
                            ColorPickerStyleKit.color0,
                            ColorPickerStyleKit.color1,
                            ColorPickerStyleKit.color2,
                            ColorPickerStyleKit.color3,
                            ColorPickerStyleKit.color4,
                            ColorPickerStyleKit.color5,
                            ColorPickerStyleKit.color6,
                            ColorPickerStyleKit.color7,
                            ColorPickerStyleKit.color8,
                            ColorPickerStyleKit.color9,
                            ColorPickerStyleKit.color10,
                            ColorPickerStyleKit.color11,
                            ColorPickerStyleKit.color12,
                            ColorPickerStyleKit.color13,
                            ColorPickerStyleKit.color14,
                            ColorPickerStyleKit.color15,
                            ColorPickerStyleKit.color16,
                            ColorPickerStyleKit.color17,
                            ColorPickerStyleKit.color18,
                            ColorPickerStyleKit.color19,
                            ColorPickerStyleKit.color20,
                            ColorPickerStyleKit.color21]
    
    var selected: UIColor
    var onSelection: (UIColor)->()
    
    init(selected: UIColor, onSelection: @escaping (UIColor)->()) {
        self.selected = selected
        self.onSelection = { _ in }
        
        super.init(frame: .zero)
        
        self.onSelection = {
            self.selected = $0
            onSelection($0)
        }

        axis = .horizontal
        alignment = .center
        distribution = .equalSpacing
        spacing = 10
    
        ColorPicker.allColors.forEach {
            let colorView = ColorView(color: $0, onTouch: onSelection)
            addArrangedSubview(colorView)
            
            constrain(colorView) {
                $0.width == $0.height
                $0.height == 44
            }
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
