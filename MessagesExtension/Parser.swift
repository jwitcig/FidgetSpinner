//
//  Parser.swift
//  MessagesExtension
//
//  Created by Developer on 6/5/17.
//  Copyright © 2017 JwitApps. All rights reserved.
//

import PocketSVG
import SWXMLHash

import SpriteKit

class Parser {
    let url: URL
    let data: Data
    let xml: XMLIndexer
    
    let bodyStyle: Int
    
    lazy var size: CGSize = {
        let svg: XMLIndexer = self.xml["svg"]
        let width = try! (svg.value(ofAttribute: "width") as String).int!
        let height = try! (svg.value(ofAttribute: "height") as String).int!
        return CGSize(width: width, height: height)
    }()
    
    init(bodyStyle: Int) {
        self.bodyStyle = bodyStyle
        
        let fileName = "body\(bodyStyle)"
        let bundle = Bundle(for: Parser.self)
        self.url = bundle.url(forResource: fileName, withExtension: "svg")!
        self.data = try! Data(contentsOf: url)
        self.xml = SWXMLHash.parse(data)
    }
    
    lazy var bearingLocations: [CGPoint] = {
        return self.allIn(indexer: self.xml, soundsLike: "rect").map {
            let x = CGFloat((try! $0.value(ofAttribute: "x") as String).double!)
            let y = CGFloat((try! $0.value(ofAttribute: "y") as String).double!)
//            return CGPoint(x: x-200/2+20, y: -(y-200/2+5))
            return CGPoint(x: x-360/2, y: -(y-328/2-35))

        }
    }()
    
    func allIn(indexer: XMLIndexer, soundsLike name: String? = nil) -> [XMLIndexer] {
        var indexers: [XMLIndexer] = indexer.children
        
        for child in indexer.children {
            indexers.append(contentsOf: allIn(indexer: child, withName: name))
        }
        
        if let name = name {
            return indexers.filter {
                ($0.element?.name.contains(name)) == true
            }
        }
        return indexers
    }
    
    func allIn(indexer: XMLIndexer, withName name: String? = nil) -> [XMLIndexer] {
        var indexers: [XMLIndexer] = indexer.children
        
        for child in indexer.children {
            indexers.append(contentsOf: allIn(indexer: child, withName: name))
        }
        
        if let name = name {
            return indexers.filter {
                ($0.element?.name == name) == true
            }
        }
        return indexers
    }
}
