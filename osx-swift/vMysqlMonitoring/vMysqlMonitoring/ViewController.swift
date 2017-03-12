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
    
    // the data for the table
    dynamic var originalData:[NSDictionary] = []
    dynamic var listData:[NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MysqlAction.sharedInstance.getseconds()
    }
    
    @IBAction func Clip(_ sender: Any) {
        
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
//                print(row)
                if !row.isEmpty {
                    var data = row
                    data["vtime"] = dts(t: data["vtime"] as! Date)
                    originalData.append(data as NSDictionary)
                }
            }
            listData = originalData
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
    
//    func alertFilter() {
//        let fv:FilterController = FilterController()
//        addChildViewController(fv)
////        let accessory:NSTextView = NSTextView(frame:NSMakeRect(0,0,200,15))
////        let alert:NSAlert = NSAlert()
////        alert.messageText = "Filter:"
//////        alert.delegate = 
////        alert.accessoryView = accessory
////        alert.runModal()
//    }
    
    func filter(f:String){
        listData.removeAll()
        if f == "" {
            listData = originalData
        }else{
            for xxx in originalData {
                let str:String = xxx["vsql"] as! String //xxx["vsql"]
                if str.contains(f)  {
                    listData.append(xxx)
                }
            }
        }
        TableView.reloadData()
    }
    
    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(.command) {
            switch event.keyCode {
            // Cmd + R
            case 15:
                self.queryAll()
                MysqlAction.sharedInstance.getseconds()
//                self.TableView.scrollRowToVisible(self.listData.count - 1)
                break
            // Cmd + F
            case 3:
//                alertFilter()
//                filter(f: "utf")
                break
            // Cmd + D
            case 2:
                MysqlAction.sharedInstance.getseconds()
                break
            // Cmd + V
            case 9:
                let alert:NSAlert = NSAlert()
                alert.messageText = "Virink"
                var info:String = "Blog : https://www.virzz.com\n"
                info += "GitHub : https://github.com/virink\n"
                info += "E-mail : virink@outlook.com"
                alert.informativeText = info
                alert.runModal()
                break
            default:
                print(event.keyCode)
            }
        }
    }
}
