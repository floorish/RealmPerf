//
//  Repository.swift
//  RealmPerf
//
//  Created by floorish on 16/09/2020.
//  Copyright © 2020 floorish. All rights reserved.
//

import Foundation
import RealmSwift

class Repository {
    
    static var queue = DispatchQueue(label: "repository", qos: .userInitiated, attributes: [], autoreleaseFrequency: .inherit, target: nil)

    enum Err: Error {
        case couldNotGetCollection
    }
    
    /// Get the collection with the given name
    func get(collection: String) throws -> ManagedCollection {
        
        let r = try Realm()
        
        let c = r.objects(ManagedCollection.self)
            .filter("name = %@", collection)
            .first
        
        guard let col = c else {
            throw Err.couldNotGetCollection
        }
        
        return col
        
    }

    /// Get items sorted by group name
    /// - Parameters:
    ///   - filter: only get items for the given collection name, all items if nil
    ///   - grouped: get a single item for each group, or all items if false
    func getItems(filter: String? = nil, grouped: Bool = false) throws -> Results<ManagedItem> {
        let realm = try Realm()
        var results = realm.objects(ManagedItem.self)

        if let filter = filter {
            let predicate = NSPredicate(format: "ANY collections.name = %@ or ANY collections.name BEGINSWITH %@", filter, "\(filter)/")
            results = results.filter(predicate)
        }
        
        
        let sorts: [SortDescriptor] = [
            SortDescriptor(keyPath: "group.name"),
            SortDescriptor(keyPath: "a"),
            SortDescriptor(keyPath: "b"),
            SortDescriptor(keyPath: "c"),
        ]
        
        results = results.sorted(by: sorts)
        
        if grouped {
            results = results.distinct(by: ["group.name"])
        }
        
        return results
        
    }
    
    
    
    /// Adds the given (or random if nil) Collection to a random Group of Items
    func changeGroup(collection: ManagedCollection? = nil, queue: DispatchQueue? = nil) {

        let ref = collection.map { ThreadSafeReference(to: $0) }
        
        if let queue = queue {
            queue.async {
                self.changeGroup(ref: ref)
            }
        } else {
            self.changeGroup(ref: ref)
        }
        
    }
    
    private func changeGroup(ref: ThreadSafeReference<ManagedCollection>?) {
        
        do {
            let realm = try Realm()
            
            guard let collection = ref.flatMap({ realm.resolve($0) }) ?? realm.objects(ManagedCollection.self).randomElement() else {
                Logger.print("Could not get collection")
                return
            }
            
            guard let group = realm.objects(ManagedGroup.self).randomElement() else {
                Logger.print("Could not get group")
                return
            }
            
            Logger.print("Writing... ", group.items.count)
            try realm.write {
                for item in group.items {
                    item.collections.append(collection)
                }
            }
            
            Logger.print("Writing done")
        } catch {
            Logger.print("Could not write change")
        }
    }
    
    
}
