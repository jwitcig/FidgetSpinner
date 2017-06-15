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
import FirebaseDatabase
//import GoogleMobileAds

import iMessageTools
import JWSwiftTools

class SpinnerViewController: UIViewController {
    
    var skView: SKView {
        return view as! SKView
    }
    
//    var adView: GADBannerView!
    
    var scene = SpinScene()
    
    var game: SpinGame!
    
    var messageSender: MessageSender?
    var orientationManager: OrientationManager?
    
    var designOptionsButtons: [UIView] = []
    
    var colorPicker: ColorPicker!
    
    var editButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(SpinnerViewController.toggleEditMode(sender:)), for: .touchUpInside)
        return button
    }()
    
    var editDrawer: UIView?
    var editDrawerHiddenConstraint: ConstraintGroup?
    var editDrawerVisibleConstraint: ConstraintGroup?
    
    var spinnerSlot = ""
    var customizerSelection = 0
    
    var bodyColor: UIColor = ColorPicker.allColors[0]
    var bearingColor: UIColor = ColorPicker.allColors[0]
    var capColor: UIColor = ColorPicker.allColors[0]
    var bodyStyle = 0
    var bearingStyle = 0
    var capStyle = 0
    
    var bodyStylePicker: BodyStylePicker!
    var bearingStylePicker: BearingStylePicker!
    var capStylePicker: CapStylePicker!
    
    var bodyStylePickerConstraints: ConstraintGroup!
    var bearingStylePickerConstraints: ConstraintGroup!
    var capStylePickerConstraints: ConstraintGroup!
    
    var previousSession: SpinSession?
    
    lazy var scoreboard: PaintCodeView = {
        PaintCodeView {
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 1
            
            let formattedTime = formatter.string(from: NSNumber(value: self.game.time.float!))!
            
            UserInterfaceStyleKit.drawScore(frame: $0, resizing: .aspectFit, scoreTimeText: formattedTime, scoreSpinsCount: self.game.spins.string!)
        }
    }()
    
    init(previousSession: SpinSession?, messageSender: MessageSender, orientationManager: OrientationManager, spinner: Spinner) {
        self.messageSender = messageSender
        self.orientationManager = orientationManager
        
        self.previousSession = previousSession
        
        self.spinnerSlot = spinner.name
        
        super.init(nibName: nil, bundle: nil)
        
        configureScene(previousSession: previousSession, spinner: spinner)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        self.view = SKView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orientationManager?.requestPresentationStyle(.expanded)
        
        view.addSubview(scoreboard)
        
        constrain(scoreboard, view) {
            $0.leading == $1.leading
            $0.trailing == $1.trailing
            
            $0.bottom == $1.bottom
            
            $0.width == $0.height * 375/69.0
        }
        
        createColorPickers()
        
//        adView = GADBannerView(adSize: kGADAdSizeFullBanner)
//        self.view.addSubview(adView)
//        
//        adView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
//        adView.rootViewController = self
//        let request = GADRequest()
//        request.testDevices = [kGADSimulatorID]
//        adView.load(request)
    }
    
    private func configureScene(previousSession: SpinSession?, spinner: Spinner) {
        let lifeCycle = LifeCycle(started: nil, finished: self.finished)
        
        self.game = SpinGame(previousSession: previousSession, cycle: lifeCycle)
        scene.game = self.game
        
        scene.scoreboard = scoreboard
        
        scene.updateScoreboard = {
            self.game.time = $0
            self.game.spins = $1
            
            self.scoreboard.setNeedsDisplay()
        }
        
        skView.presentScene(scene)
        
        scene.createSpinner(bodyColor: spinner.bodyColor, bearingColor: spinner.bearingColor, capColor: spinner.capColor, bodyStyle: spinner.bodyStyle, bearingStyle: spinner.bearingStyle, capStyle: spinner.capStyle)
    }
    
    func createColorPickers() {
        
        let bodyButton = PaintCodeView { rect in
            UserInterfaceStyleKit.drawSpinnerBodyTypeButton(frame: rect, resizing: .aspectFit, buttonSelected: self.customizerSelection == 0)
        }
        
        let bearingButton = PaintCodeView { rect in
            UserInterfaceStyleKit.drawSpinnerBearingTypeButton(frame: rect, resizing: .aspectFit, buttonSelected: self.customizerSelection == 1)
        }
        
        let capButton = PaintCodeView { rect in
            UserInterfaceStyleKit.drawSpinnerCapTypeButton(frame: rect, resizing: .aspectFit, buttonSelected: self.customizerSelection == 2)
        }
        
        designOptionsButtons = [bodyButton, bearingButton, capButton]
        
        for button in designOptionsButtons {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SpinnerViewController.designButtonPressed(recognizer:)))

            button.addGestureRecognizer(tapRecognizer)
        }
        
        let componentsStack = UIStackView(arrangedSubviews: designOptionsButtons)
        componentsStack.alignment = .fill
        componentsStack.distribution = .fillEqually
        
        colorPicker = ColorPicker(selected: .white) { selected in
            switch self.customizerSelection {
            case 0:
                self.bodyColor = selected
            case 1:
                self.bearingColor = selected
            case 2:
                self.capColor = selected
            default: break
            }
            
            self.scene.createSpinner(bodyColor: self.bodyColor,
                                  bearingColor: self.bearingColor,
                                      capColor: self.capColor,
                                     bodyStyle: self.bodyStyle,
                                  bearingStyle: self.bearingStyle,
                                      capStyle: self.capStyle)
        }
        
        let colorScrollView = UIScrollView()

        colorScrollView.translatesAutoresizingMaskIntoConstraints = false

        colorPicker.translatesAutoresizingMaskIntoConstraints = false
        
        colorScrollView.addSubview(colorPicker)
        
        colorScrollView.showsHorizontalScrollIndicator = false
        colorScrollView.showsVerticalScrollIndicator = false
        
        constrain(colorPicker, colorScrollView) {
            $0.leading == $1.leading
            $0.trailing == $1.trailing
            $0.top == $1.top
            $0.bottom == $1.bottom
        }
        
        
        
        
        
        bodyStylePicker = BodyStylePicker(selected: 0) { selected in
            self.bodyStyle = selected
            
            self.scene.createSpinner(bodyColor: self.bodyColor,
                                     bearingColor: self.bearingColor,
                                     capColor: self.capColor,
                                     bodyStyle: self.bodyStyle,
                                     bearingStyle: self.bearingStyle,
                                     capStyle: self.capStyle)
        }
        
        let styleScrollView = UIScrollView()
        
        styleScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        styleScrollView.addSubview(bodyStylePicker)
        
        bodyStylePickerConstraints = constrain(bodyStylePicker, styleScrollView) {
            $0.leading == $1.leading
            $0.trailing == $1.trailing
            $0.top == $1.top
            $0.bottom == $1.bottom
        }
        
        
        
        
        
        
        
        
        
        
        bearingStylePicker = BearingStylePicker(selected: 0) { selected in
            self.bearingStyle = selected
            
            self.scene.createSpinner(bodyColor: self.bodyColor,
                                     bearingColor: self.bearingColor,
                                     capColor: self.capColor,
                                     bodyStyle: self.bodyStyle,
                                     bearingStyle: self.bearingStyle,
                                     capStyle: self.capStyle)
        }
        
        
        bearingStylePicker.translatesAutoresizingMaskIntoConstraints = false
        
        styleScrollView.addSubview(bearingStylePicker)
        
        bearingStylePickerConstraints = constrain(bearingStylePicker, styleScrollView) {
            $0.leading == $1.leading
            $0.trailing == $1.trailing
            $0.top == $1.top
            $0.bottom == $1.bottom
        }

        
        
        
        
        
        
        
        
        capStylePicker = CapStylePicker(selected: 0) { selected in
            self.capStyle = selected

            self.scene.createSpinner(bodyColor: self.bodyColor,
                                     bearingColor: self.bearingColor,
                                     capColor: self.capColor,
                                     bodyStyle: self.bodyStyle,
                                     bearingStyle: self.bearingStyle,
                                     capStyle: self.capStyle)
        }
    
        capStylePicker.translatesAutoresizingMaskIntoConstraints = false
        
        styleScrollView.addSubview(capStylePicker)
        
        capStylePickerConstraints = constrain(capStylePicker, styleScrollView) {
            $0.leading == $1.leading
            $0.trailing == $1.trailing
            $0.top == $1.top
            $0.bottom == $1.bottom
        }
        

        
        
        
        
        
        let customizerStack = UIStackView(arrangedSubviews: [componentsStack, styleScrollView, colorScrollView])
        customizerStack.axis = .vertical
        customizerStack.alignment = .fill
        customizerStack.distribution = .fillProportionally
        
        view.addSubview(customizerStack)
        
        constrain(customizerStack, view) {
            $0.centerX == $1.centerX
            
            $0.width == $1.width
            
            $0.height == 50 * 3 // color picker is 10 shorter
        }
        
        editDrawerVisibleConstraint = constrain(customizerStack, view) {
            $0.top == $1.top
        }
        editDrawerVisibleConstraint?.active = false
        
        editDrawerHiddenConstraint = constrain(customizerStack, view) {
            $0.bottom == $1.top
        }
        
        editDrawer = customizerStack
        
        let drawerBackground = PaintCodeView {
            UserInterfaceStyleKit.drawEditDrawer(frame: $0, editDrawerButton: #imageLiteral(resourceName: "EditButton"))
        }
        
        customizerStack.insertSubview(drawerBackground, belowSubview: customizerStack.subviews[0])
        constrain(drawerBackground, customizerStack) {
            $0.leading == $1.leading
            $0.trailing == $1.trailing
            $0.top == $1.top
            $0.bottom == $1.bottom + 44
        }
        
        view.addSubview(editButton)
        
        constrain(editButton, drawerBackground) {
            $0.centerX == $1.centerX
            $0.bottom == $1.bottom
        }
        
        selectDesignButton(bodyButton)
    }
    
    func toggleEditMode(sender: Any) {
        guard !scene.isDecelerating else { return }
        
        guard let hidden = editDrawerHiddenConstraint,
              let visible = editDrawerVisibleConstraint else { return }
        
        let database = Database.database().reference()
        let spinners = database.child("spinners")
        
        if hidden.active {
            scene.changeBackground(to: .edit)
            
            scene.isEditing = true
            
            hidden.active = false
            visible.active = true
            
            spinners.child(spinnerSlot).observe(.value, with: {
                guard let value = $0.value as? [String : Any] else { return }
                
                self.bodyColor = UIColor(ciColor: CIColor(string: value["bodyColor"]! as! String))
                self.bearingColor = UIColor(ciColor: CIColor(string: value["bearingColor"]! as! String))
                self.capColor = UIColor(ciColor: CIColor(string: value["capColor"]! as! String))
                self.bodyStyle = value["bodyStyle"]! as! Int
                self.bearingStyle = value["bearingStyle"]! as! Int
                self.capStyle = value["capStyle"]! as! Int
                
                self.scene.createSpinner(bodyColor: self.bodyColor,
                                         bearingColor: self.bearingColor,
                                         capColor: self.capColor,
                                         bodyStyle: self.bodyStyle,
                                         bearingStyle: self.bearingStyle,
                                         capStyle: self.capStyle)
            })

            UIView.animate(withDuration: 0.5, animations: view.layoutIfNeeded)
            
        } else {
            scene.changeBackground(to: .play)
            
            scene.isEditing = false
            
            visible.active = false
            hidden.active = true
        
            spinners.child(spinnerSlot).setValue([
                "bodyColor" : CIColor(cgColor: self.bodyColor.cgColor).stringRepresentation,
                "bearingColor" : CIColor(cgColor: self.bearingColor.cgColor).stringRepresentation,
                "capColor" : CIColor(cgColor: self.capColor.cgColor).stringRepresentation,
                "bodyStyle" : self.bodyStyle,
                "bearingStyle" : self.bearingStyle,
                "capStyle" : self.capStyle,
                ], withCompletionBlock: { (error, ref) in
                    print(error)
                    print(ref)
            })
//            
//            spinners.child(spinnerSlot).setValue([
//                "bodyColor" : CIColor(cgColor: self.bodyColor.cgColor).stringRepresentation,
//                "bearingColor" : CIColor(cgColor: self.bearingColor.cgColor).stringRepresentation,
//                "capColor" : CIColor(cgColor: self.capColor.cgColor).stringRepresentation,
//                "bodyStyle" : self.bodyStyle,
//                "bearingStyle" : self.bearingStyle,
//                "capStyle" : self.capStyle,
//                ])
            
            UIView.animate(withDuration: 0.5, animations: view.layoutIfNeeded)
        }
    }
    
    func finished() {
        let exactTime = game.time
        let time = Double(round(10*exactTime)/10).cgFloat!
        
        let spins = scene.spinCount
        
        let initial = SpinSession.InitialData()
        let instance = SpinSession.InstanceData(time: time, spins: spins)
        
        let selectedMessage = (messageSender as? MSMessagesAppViewController)?.activeConversation?.selectedMessage
        let session = SpinSession(instance: instance, initial: initial, ended: false, message: selectedMessage)
        
        let spinnerImage = UIImage(cgImage: skView.texture(from: scene.spinner)!.cgImage()).scaled(to: CGSize(width: 200, height: 200))
        
        let messageImage = UserInterfaceStyleKit.imageOfInsertedSpinnerMessage(savedSpinnerImage: spinnerImage)
        
        let layout = SpinMessageLayoutBuilder(spinnerImage: messageImage,
                                                      time: time,
                                                     spins: spins).generateLayout()
        
        let writer = SpinMessageWriter(data: session.dictionary,
                                    session: selectedMessage?.session)

        guard let newMessage = writer?.message else { return }
        
        messageSender?.send(message: newMessage,
                             layout: layout,
                  completionHandler: nil)
        
        orientationManager?.requestPresentationStyle(.compact)
    }
    
    func designButtonPressed(recognizer: UIGestureRecognizer) {
        guard let button = recognizer.view else { return }
        selectDesignButton(button)
    }
    
    func selectDesignButton(_ button: UIView) {
        for button in designOptionsButtons {
            button.setNeedsDisplay()
        }
        
        let buttonIndex = designOptionsButtons.index(of: button)!
        self.customizerSelection = buttonIndex
        switch buttonIndex  {
        case 0:
            bodyStylePicker.isHidden = false
            bearingStylePicker.isHidden = true
            capStylePicker.isHidden = true
            
            bearingStylePickerConstraints.active = false
            capStylePickerConstraints.active = false
            bodyStylePickerConstraints.active = true
        case 1:
            bodyStylePicker.isHidden = true
            bearingStylePicker.isHidden = false
            capStylePicker.isHidden = true
            
            bodyStylePickerConstraints.active = true
            capStylePickerConstraints.active = false
            bearingStylePickerConstraints.active = true
        case 2:
            bodyStylePicker.isHidden = true
            bearingStylePicker.isHidden = true
            capStylePicker.isHidden = false
            
            bearingStylePickerConstraints.active = false
            bodyStylePickerConstraints.active = false
            capStylePickerConstraints.active = true
        default:
            break
        }
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

class BodyStyleView: UIView {
    let style: Int
    let onTouch: (Int)->()
    
    lazy var bearingImage: UIImage = {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }()
    
    init(style: Int, onTouch: @escaping (Int)->()) {
        self.style = style
        self.onTouch = onTouch
        
        super.init(frame: .zero)
        
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        BodyStyles.draw(body: style, rect: rect, resizing: .aspectFit, bodyColor: .gray, image: bearingImage)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        onTouch(style)
    }
}

class BearingStyleView: UIView {
    let style: Int
    let onTouch: (Int)->()
    
    init(style: Int, onTouch: @escaping (Int)->()) {
        self.style = style
        self.onTouch = onTouch
        
        super.init(frame: .zero)
        
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        BearingStyles.draw(body: style, rect: rect, resizing: .aspectFit, bodyColor: .gray)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        onTouch(style)
    }
}

class CapStyleView: UIView {
    let style: Int
    let onTouch: (Int)->()
    
    init(style: Int, onTouch: @escaping (Int)->()) {
        self.style = style
        self.onTouch = onTouch
        
        super.init(frame: .zero)
        
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        CapStyles.draw(body: style, rect: rect, resizing: .aspectFit, bodyColor: .gray)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        onTouch(style)
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
                $0.height == 40
            }
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BodyStylePicker: UIStackView {
    var selected: Int
    var onSelection: (Int)->()
    
    static let stylesCount = 13
    
    init(selected: Int, onSelection: @escaping (Int)->()) {
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
        
        (0..<BodyStylePicker.stylesCount).forEach {
            let colorView = BodyStyleView(style: $0, onTouch: onSelection)
            addArrangedSubview(colorView)
            
            constrain(colorView) {
                $0.width == $0.height
                $0.height == 50
            }
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BearingStylePicker: UIStackView {
    var selected: Int
    var onSelection: (Int)->()
    
    static let stylesCount = 13
    
    init(selected: Int, onSelection: @escaping (Int)->()) {
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
        
        (0..<BearingStylePicker.stylesCount).forEach {
            let colorView = BearingStyleView(style: $0, onTouch: onSelection)
            addArrangedSubview(colorView)
            
            constrain(colorView) {
                $0.width == $0.height
                $0.height == 50
            }
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CapStylePicker: UIStackView {
    var selected: Int
    var onSelection: (Int)->()
    
    static let stylesCount = 5
    
    init(selected: Int, onSelection: @escaping (Int)->()) {
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
        
        (0..<CapStylePicker.stylesCount).forEach {
            let colorView = CapStyleView(style: $0, onTouch: onSelection)
            addArrangedSubview(colorView)
            
            constrain(colorView) {
                $0.width == $0.height
                $0.height == 50
            }
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PaintCodeView: UIView {
    var drawRect: ((CGRect) -> Void)?
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    convenience init(drawRect: @escaping (CGRect)->Void) {
        self.init(frame: .zero)
        self.drawRect = drawRect
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        drawRect?(rect)
    }
}

extension UIImage {
    public func scaled(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
