//
//  ViewController.swift
//  vMysqlMonitoring
//
//  Created by Virink on 2017/3/7.
//  Copyright © 2017年 Virink. All rights reserved.
//

import Cocoa
//import Foundation


class ViewController: NSViewController, NSTableViewDataSource {
    
    @IBOutlet weak var TableView: NSTableView!
    @IBOutlet var arrayController: NSArrayController!
    
    // the data for the table
    dynamic var listData:[NSObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MysqlAction.sharedInstance.getseconds()
    }
    
    @IBAction func toClip(_ sender: Any) {
    }
    
    override var representedObject: Any? {
        didSet {
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return listData[row]
    }
    
    func queryAll(){
        self.listData.removeAll()
        do {
            let rows = try MysqlAction.sharedInstance.query()
            for row in rows! {
                print(row)
                if !row.isEmpty {
                    var data = row
                    data["vtime"] = dts(t: data["vtime"] as! Date)
                    listData.append(data as NSObject)
                }
            }
            self.TableView.reloadData()
        }
        catch(let e){
            print(e)
        }
    }
    
    func dts(t:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: t)

    }
    
    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(.command) {
            switch event.keyCode {
            // Cmd + R
            case 15:
                self.queryAll()
//                self.TableView.scrollRowToVisible(self.listData.count - 1)
                break
            // Cmd + F
            case 3:
                break
            // Cmd + D
            case 2:
                MysqlAction.sharedInstance.getseconds()
                break
            default:
                print(event.keyCode)
            }
        }
    }
}
