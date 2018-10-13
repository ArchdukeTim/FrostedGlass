//
//  Attribute.swift
//  FrostedGlass
//
//  Created by Tim Winters on 10/10/18.
//  Copyright © 2018 Tim Winters. All rights reserved.
//

import UIKit
import os.log

class Attribute: NSObject, NSCoding {
    
    //Mark: Properties
    
    var label: String
    var value: Float
    var min: Float
    var max: Float
    var callback: (Float) -> Void
    
    struct PropertyKey {
        static let label = "name"
        static let value = "value"
        static let max = "max"
        static let min = "min"
        static let callback = "callback"
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("attributes")
    
    static func genAttr(label: String, value: Float, min: Float, max: Float, callback: @escaping (Float) -> Void) -> Attribute{
        return Attribute(label: label, value: value, min: min, max: max, callback: callback)!
    }
    
    init?(label: String, value: Float, min: Float, max: Float, callback: @escaping (Float) -> Void) {
        // Initialization should fail if there is no name or if the rating is negative.
        guard !label.isEmpty else {
            return nil
        }
        
        
        self.label = label
        self.value = value
        self.min = min
        self.max = max
        self.callback = callback
    }
    
    @objc func onUpdate(sender: UISlider){
        self.callback(sender.value)
    }
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(label, forKey: PropertyKey.label)
        aCoder.encode(value, forKey: PropertyKey.value)
        aCoder.encode(min, forKey: PropertyKey.min)
        aCoder.encode(max, forKey: PropertyKey.max)
        aCoder.encode(callback, forKey: PropertyKey.callback)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let label = aDecoder.decodeObject(forKey: PropertyKey.label) as? String else {
            os_log("Unable to decode the label for an Attribute object", log: OSLog.default, type: .debug)
            return nil
        }
        let value = aDecoder.decodeObject(forKey: PropertyKey.value) as! Float
        let min = aDecoder.decodeObject(forKey: PropertyKey.min) as! Float
        let max = aDecoder.decodeObject(forKey: PropertyKey.max) as! Float
        let callback = aDecoder.decodeObject(forKey: PropertyKey.callback) as! (Float) -> Void
        
        
        self.init(label: label, value: value, min: min, max: max, callback: callback)
    }
}
