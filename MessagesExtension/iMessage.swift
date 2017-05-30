//
//  iMessage.swift
//  FidgetSpinner
//
//  Created by Developer on 5/29/17.
//  Copyright © 2017 JwitApps. All rights reserved.
//

import Messages

import Game
import iMessageTools
import JWSwiftTools

struct SpinInstanceData: InstanceDataType, StringDictionaryRepresentable {
    typealias Constraint = SpinGame
    
    let time: CGFloat
    let spins: Int
    
    var dictionary: [String: String] {
        return [
            "instance-time" : time.string!,
            "instance-spins" : spins.string!,
        ]
    }
    
    init(time: CGFloat, spins: Int) {
        self.time = time
        self.spins = spins
    }
    
    init?(dictionary: [String : String]) {
        guard let time = dictionary["instance-time"]?.double?.cgFloat else { return nil }
        guard let spins = dictionary["instance-spins"]?.int else { return nil }
        
        self.init(time: time, spins: spins)
    }
}

struct SpinInitialData: InitialDataType, StringDictionaryRepresentable {
    typealias Constraint = SpinGame
    
    var dictionary: [String: String] {
        return [:]
    }
    
    init() { }
    
    init?(dictionary: [String: String]) {
        self.init()
    }
}

struct SpinSession: SessionType, StringDictionaryRepresentable, Messageable {
    typealias Constraint = Spin
    typealias InitialData = SpinInitialData
    typealias InstanceData = SpinInstanceData
    typealias MessageWriterType = SpinMessageWriter
    typealias MessageLayoutBuilderType = SpinMessageLayoutBuilder
    
    let initial: InitialData
    let instance: InstanceData
    
    let ended: Bool
    
    let message: MSMessage?
    var messageSession: MSSession? {
        return message?.session
    }
    
    var dictionary: [String : String] {
        return instance.dictionary.merged(initial.dictionary).merged(["ended" : ended.string!])
    }
    
    public init(instance: InstanceData, initial: InitialData, ended: Bool = false, message: MSMessage? = nil) {
        self.instance = instance
        self.initial = initial

        self.ended = false
        
        self.message = message
    }
    
    public init?(dictionary: [String: String]) {
        guard let instance = InstanceData(dictionary: dictionary) else { return nil }
        guard let initial = InitialData(dictionary: dictionary) else { return nil }
        guard let ended = dictionary["ended"]?.bool else { return nil }
        
        self.instance = instance
        self.initial = initial
        
        self.ended = ended
        
        self.message = nil
    }
}

extension SpinSession {
    var gameData: InstanceData { return instance }
}

struct SpinMessageReader: MessageReader, SessionSpecific {
    typealias SessionConstraint = SpinSession
    
    var message: MSMessage
    var data: [String: String]
    
    var session: SessionConstraint!
    
    init() {
        self.message = MSMessage()
        self.data = [:]
    }
    
    mutating func isValid(data: [String : String]) -> Bool {
        guard let ended = data["ended"]?.bool else { return false }
        guard let instance = SessionConstraint.InstanceData(dictionary: data) else { return false }
        guard let initial = SessionConstraint.InitialData(dictionary: data) else { return false }
        self.session = SpinSession(instance: instance, initial: initial, ended: ended, message: message)
        return true
    }
}

struct SpinMessageWriter: MessageWriter {
    var message: MSMessage
    var data: [String: String]
    
    init() {
        self.message = MSMessage()
        self.data = [:]
    }
    
    func isValid(data: [String : String]) -> Bool {
        guard let _ = data["instance-time"] else { return false }
        guard let _ = data["instance-spins"] else { return false }
        return true
    }
}

protocol Spin: class {
    var lifeCycle: LifeCycle { get }
    
    var time: CGFloat { get set }
    var spins: Int { get set }
}

extension Spin {
    func start() {
        lifeCycle.start()
    }
    
    func finish() {
        lifeCycle.finish()
    }
}

class SpinGame: Spin, Game, TypeConstraint {
    typealias Session = SpinSession
    
    static let GameName = "SpinGame"
    
    let padding: Padding?
    
    let lifeCycle: LifeCycle
    
    let previousSession: Session?
    
    var time: CGFloat = 0
    var spins: Int = 0
    
    init(previousSession: Session?,
         cycle: LifeCycle) {
        
        self.padding = nil
        
        self.lifeCycle = cycle
        
        self.previousSession = previousSession
    }
}

struct SpinMessageLayoutBuilder: MessageLayoutBuilder {
    var spinnerImage: UIImage
    var time: CGFloat
    var spins: Int
    
    init(spinnerImage: UIImage, time: CGFloat, spins: Int) {
        self.spinnerImage = spinnerImage
        self.time = time
        self.spins = spins
    }
    
    func generateLayout() -> MSMessageTemplateLayout {
        let layout = MSMessageTemplateLayout()
        layout.image = spinnerImage
        layout.caption = "\(time) seconds"
        layout.trailingCaption = "\(spins) spins"
        return layout
    }
}
