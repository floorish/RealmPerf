//
//  Notifier.swift
//  RealmPerf
//
//  Created by floorish on 11/09/2020.
//  Copyright © 2020 floorish. All rights reserved.
//

import Foundation
import RealmSwift


class Notifier {
    var token: NotificationToken?

    static var queue = DispatchQueue(label: "notifier", qos: .userInitiated, attributes: [], autoreleaseFrequency: .inherit, target: nil)

    deinit {
        self.token?.invalidate()
    }
    
    func listenRealm(callback: @escaping () -> ()) throws {
        self.token?.invalidate()
        let r = try Realm()
        self.token = r.observe { notification, _ in
            Logger.print("Realm notification", "main", notification)
            callback()
        }
    }
    
    func listen(results: Results<ManagedItem>, queue: DispatchQueue? = Notifier.queue, callback: @escaping () -> ()) {
        self.token?.invalidate()
        
        self.token = results.observe(on: queue) { changes in
            
            switch changes {
            case .initial:
                Logger.print("Results notification", (queue == nil ? "main" : "queue"), "initial")
            case .update(_, let deletions, let insertions, let modifications):
                Logger.print("Results notification", (queue == nil ? "main" : "queue"), "update", deletions.count, insertions.count, modifications.count)
            case .error:
                Logger.print("Results notification", (queue == nil ? "main" : "queue"), "error")
            }
            
            callback()
        }
        
    }
    
    func listen(list: LinkingObjects<ManagedItem>, queue: DispatchQueue? = Notifier.queue, callback: @escaping () -> ()) {
        self.token?.invalidate()
        
        self.token = list.observe(on: queue) { changes in
            
            switch changes {
            case .initial:
                Logger.print("List notification", (queue == nil ? "main" : "queue"), "initial")
            case .update(_, let deletions, let insertions, let modifications):
                Logger.print("List notification", (queue == nil ? "main" : "queue"), "update", deletions.count, insertions.count, modifications.count)
            case .error:
                Logger.print("List notification", (queue == nil ? "main" : "queue"), "error")
            }
            
            callback()
            
        }
        
    }
    
}

