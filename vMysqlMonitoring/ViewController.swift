//
//  ViewController.swift
//  vMysqlMonitoring
//
//  Created by Virink on 2017/3/7.
//  Copyright © 2017年 Virink. All rights reserved.
//

import Cocoa

let __VERSION__ = "Ver 1.0 Beta"

class ViewController: NSViewController {
    
    @IBOutlet weak var TableView: NSTableView!
    @IBOutlet weak var mainMenu: NSMenu!
    @IBOutlet weak var filterTextField: NSTextField!
    
    @IBOutlet weak var dbHost: NSTextField!
    @IBOutlet weak var dbPort: NSTextField!
    @IBOutlet weak var dbUser: NSTextField!
    @IBOutlet weak var dbPass: NSTextField!
    
    // the data for the table
    dynamic var listData = [NSDictionary]()
    dynamic var original_filter = [NSDictionary]()
    
    dynamic var aboutWin: NSWindow! = nil
    dynamic var sessionCode : NSApplication.ModalSession? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.closeAbout(_:)),  name: NSNotification.Name.NSWindowWillClose, object: nil)
        
        NSApp.mainMenu = mainMenu
        self.view.window?.makeFirstResponder(self)
        
    }
    
    override var representedObject: Any? {
        didSet {
            self.aboutWin.isReleasedWhenClosed = true
            self.aboutWin.close()
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    @IBAction func openAbout(_ sender: Any){
        if self.sessionCode == nil {
            if (self.aboutWin == nil) {
                let frame = CGRect(x: 0, y: 0, width: 400, height: 500)
                let style : NSWindow.StyleMask = [NSWindow.StyleMask.titled,NSWindow.StyleMask.closable]
                self.aboutWin = NSWindow(contentRect:frame, styleMask:style, backing:.buffered, defer:false)
                self.aboutWin.title = "About vMysqlMonitoring"
                self.aboutWin.contentViewController = AboutController()
                self.aboutWin.isReleasedWhenClosed = false
            }
            self.sessionCode = NSApplication.shared().beginModalSession(for: self.aboutWin)
            self.aboutWin.center()
        }
    }
    
    func closeAbout(_ sender: Any){
        NSLog("\(sender)")
        if let sessionCode = self.sessionCode {
            NSApplication.shared().endModalSession(sessionCode)
            self.sessionCode = nil
            NSLog("closeAbout")
        }
        if let win = (sender as AnyObject).object {
            if win as! NSObject == self.view.window! {
                NSLog("close App")
                NSApp.terminate(self)
            }
        }
    }
    
    @IBAction func setOpenLog(_ sender: Any) {
        MysqlAction.sharedInstance.openlog()
    }
    
    @IBAction func setTimeNow(_ sender: Any) {
        MysqlAction.sharedInstance.getseconds()
    }
    
    @IBAction func GetQuerySQL(_ sender: Any) {
        self.queryAll()
    }
    
    @IBAction func Filter(_ sender: Any) {
        self.view.window?.makeFirstResponder(self.filterTextField)
    }
    
    @IBAction func copyTableData(_ sender: Any){
        let row = self.TableView.selectedRow
        if row<0 {
            return
        }
        let msg = self.listData[row].value(forKey: "vsql")
        let pb = NSPasteboard.general()
        pb.clearContents()
        pb.writeObjects([msg as! NSString])
        NSLog("\(self.listData[row].value(forKey: "vsql") as! String)")
        // 弹出用户通知 user notification
        let notification = NSUserNotification()
        notification.title = "Set \"\(String(describing: msg))\" to Pasteboard Success!"
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    var p_host:String{
        get{ return PreferenceData.sharedInstance.v_host }
        set{ PreferenceData.sharedInstance.v_host = newValue
             PreferenceData.sharedInstance.save() }
    }
    
    var p_port:Int{
        get{ return PreferenceData.sharedInstance.v_port }
        set{ PreferenceData.sharedInstance.v_port = newValue
             PreferenceData.sharedInstance.save() }
    }
    
    var p_user:String{
        get{ return PreferenceData.sharedInstance.v_user }
        set{ PreferenceData.sharedInstance.v_user = newValue
             PreferenceData.sharedInstance.save() }
    }
    
    var p_pass:String{
        get{ return PreferenceData.sharedInstance.v_pass }
        set{ PreferenceData.sharedInstance.v_pass = newValue
             PreferenceData.sharedInstance.save() }
    }
    
    func queryAll(){
        var originalData = [NSDictionary]()
        self.listData.removeAll()
        do {
            let rows = try MysqlAction.sharedInstance.query()
            for row in rows! {
                if !row.isEmpty {
                    let data = NSMutableDictionary()
                    data["vtime"] = self.Date2String(t: row["vtime"] as! Date)
                    data["vsql"] = row["vsql"]
                    originalData.append(data)
                }
            }
            self.listData = originalData
            self.TableView.reloadData()
        }
        catch(let e){
            NSLog("Error : queryAll \(e)")
        }
    }
    
    func Date2String(t:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: t)
    }
    
    func filter(f:String){
        var originalData = [NSDictionary]()
        if self.original_filter.isEmpty {
            originalData = self.listData
            self.original_filter = originalData
        }else{
            originalData = self.original_filter
        }
        self.listData.removeAll()
        if f != "" {
            for xxx in originalData {
                let str:String = xxx["vsql"] as! String
                if str.contains(f)  {
                    self.listData.append(xxx)
                }
            }
        }else{
            self.listData = originalData
        }
        self.TableView.reloadData()
    }
    
}

extension ViewController:NSTextFieldDelegate{
    
    override func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            let text = textField.stringValue
            if(textField == self.filterTextField){
                self.filter(f: text)
                NSLog("filterTextField : \(text)")
            }
        }
    }
}
