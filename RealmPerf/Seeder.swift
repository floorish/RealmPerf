//
//  Seeder.swift
//  RealmPerf
//
//  Created by floorish on 11/09/2020.
//  Copyright © 2020 floorish. All rights reserved.
//

import Foundation
import RealmSwift


class Seeder {
    
    func clear() throws {
        guard let url = Realm.Configuration.defaultConfiguration.fileURL else {
            return
        }
        
        do {
            try FileManager.default.removeItem(at: url)
            Logger.print("Cleared database, relaunch app and run seeder")
        } catch {
            Logger.print("Could not remove file", url)
        }
        
    }
    
    func run() throws {
        
        let realm = try Realm()

        Logger.print("generating items...")

        let cols = (0..<1000).map {
            return self.createCollection(name: "Collection \($0)")
        }
        
        let groups = (0..<20000).map {
            return self.createGroup(name: "Group \($0)")
        }
        
        let items: [ManagedItem] = (0..<500000).map {
            let item = self.createItem(name: "Item \($0)")
            item.group = groups[$0 % 20000]
            
            let rnd = Int.random(in: 0..<10)
            for _ in 0...rnd {
                if let col = cols.randomElement() {
                    item.collections.append(col)
                }
            }

            return item
        }
        
        Logger.print("storing \(cols.count) collections, \(groups.count) groups, \(items.count) items...")

        try realm.write {
            realm.deleteAll()
            realm.add(items)
        }
        
        Logger.print("storing done")
        
    }
    
    func add(count: Int) throws {
        
        let realm = try Realm()
        
        let cols = realm.objects(ManagedCollection.self)
        let groups = realm.objects(ManagedGroup.self)

        let items: [ManagedItem] = (0..<count).map {
            let item = self.createItem(name: "Item \($0)")
            
            if let grp = groups.randomElement() {
                item.group = grp
            }

            let rnd = Int.random(in: 0..<10)
            
            for _ in 0...rnd {
                if let col = cols.randomElement() {
                    item.collections.append(col)
                }
            }
            
            return item
        }
        
        Logger.print("adding \(count) items...")
        
        try realm.write {
            realm.add(items)
        }
        
        Logger.print("adding done")
    }
    
    private func createItem(name: String) -> ManagedItem {
        
        let m = ManagedItem()
        m.name = name
        m.a = Double.random(in: 0...1)
        m.b = Double.random(in: 0...1)
        m.c = Double.random(in: 0...1)
        
        return m
    }
    
    private func createCollection(name: String) -> ManagedCollection {
        
        let m = ManagedCollection()
        m.name = name

        return m
    }
    
    private func createGroup(name: String) -> ManagedGroup {
        
        let m = ManagedGroup()
        m.name = name
        
        return m
    }
}


