//
//  AppDelegate.swift
//  RealmPerf
//
//  Created by floorish on 11/09/2020.
//  Copyright © 2020 floorish. All rights reserved.
//

import Cocoa
import RealmSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var listCount: NSTextField!
    @IBOutlet weak var resultsCount: NSTextField!
    
    var allNotifier: Notifier?
    var resultsNotifier: Notifier?
    var listNotifier: Notifier?
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Logger.print("Launch")
    }

    @IBAction func seed(_ sender: Any) {
        Logger.print("Clicked seed")
        
        do {
            let seeder = Seeder()
            try seeder.run()
        } catch {
            Logger.print("Could not seed", error)
        }
        
    }
    
    @IBAction func clear(_ sender: Any) {
        Logger.print("Clicked clear")
        
        do {
            let seeder = Seeder()
            try seeder.clear()
        } catch {
            Logger.print("Could not clear", error)
        }
    }
    
    @IBAction func write(_ sender: Any) {
        Logger.print("Clicked write")
        self.write(queue: nil)
    }
    
    @IBAction func writeQueue(_ sender: Any) {
        Logger.print("Clicked write queue")
        self.write(queue: Repository.queue)
    }

    @IBAction func load(_ sender: Any) {
        Logger.print("Clicked load")
        self.load(queue: nil)
    }
    
    @IBAction func loadQueue(_ sender: Any) {
        Logger.print("Clicked load queue")
        self.load(queue: Notifier.queue)
    }
    
    
    private func write(queue: DispatchQueue?) {
        do {
            
            let repo = Repository()
            let col = try repo.get(collection: "Collection 1")
            repo.changeGroup(collection: col, queue: queue)
            
        } catch {
            Logger.print("Could not write item", error)
        }
    }
    
    private func load(queue: DispatchQueue?) {
        
        do {
            
            let repo = Repository()
            
            // observe Realm changes
            self.allNotifier = Notifier()
            try self.allNotifier?.listenRealm {
                // do nothing
            }
            
            // single list
            let collection = try repo.get(collection: "Collection 1")
            self.listNotifier = Notifier()
            self.listNotifier?.listen(list: collection.items, queue: queue) { [weak self] in
                
                DispatchQueue.main.async {
                    self?.listCount.stringValue = "List count: \(collection.items.count)"
                }
                
            }
            
            
            // all items
            let items = try repo.getItems(grouped: false)
            self.resultsNotifier = Notifier()
            self.resultsNotifier?.listen(results: items, queue: queue) { [weak self] in
                
                DispatchQueue.main.async {
                    self?.resultsCount.stringValue = "Result count: \(items.count)"
                }
                
            }
            
        } catch {
            Logger.print("Could not start notifier")
        }
        
    }
    
    
}

