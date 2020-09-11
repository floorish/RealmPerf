//
//  Item.swift
//  RealmPerf
//
//  Created by floorish on 11/09/2020.
//  Copyright © 2020 floorish. All rights reserved.
//

import Foundation
import RealmSwift


// Item connected to a single Group
// Item connected to multiple Collections

class ManagedItem: Object {

    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""

    @objc dynamic var group: ManagedGroup? = nil
    let collections = List<ManagedCollection>()
    
    // some properties
    @objc dynamic var a: Double = 0
    @objc dynamic var b: Double = 0
    @objc dynamic var c: Double = 0

    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["name"]
    }
    

}

class ManagedCollection: Object {

    @objc dynamic var name: String = ""
    let items = LinkingObjects(fromType: ManagedItem.self, property: "collections")


    override static func indexedProperties() -> [String] {
        return ["name"]
    }
    
}

class ManagedGroup: Object {
    
    @objc dynamic var name: String = ""
    let items = LinkingObjects(fromType: ManagedItem.self, property: "group")
    
    override static func indexedProperties() -> [String] {
        return ["name"]
    }
    
}

