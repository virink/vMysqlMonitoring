//
//  ViewController.swift
//  vMysqlMonitoring
//
//  Created by Virink on 2017/3/7.
//  Copyright © 2017年 Virink. All rights reserved.
//

import Cocoa

let __VERSION__ = "Ver 1.1.1 Beta"

class ViewController: NSViewController {
    
    @IBOutlet weak var TableView: NSTableView!
    @IBOutlet weak var mainMenu: NSMenu!
    @IBOutlet weak var filterTextField: NSTextField!
    @IBOutlet weak var previewTextField: NSTextField!
    
    @IBOutlet weak var dbHost: NSTextField!
    @IBOutlet weak var dbPort: NSTextField!
    @IBOutlet weak var dbUser: NSTextField!
    @IBOutlet weak var dbPass: NSTextField!
    
    // the data for the table
    dynamic var listData = [NSDictionary]()
    dynamic var original_filter = [NSDictionary]()
    
    dynamic var aboutWin: NSWindow! = nil
    dynamic var sessionCode : NSApplication.ModalSession? = nil
    
    // DBManager
    var dbc = PreferenceData.sharedInstance
    var filter:String = ""
    var db:DBManager = DBManager.shared()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.closeAbout(_:)),  name: NSNotification.Name.NSWindowWillClose, object: nil)
        
        NSApp.mainMenu = mainMenu
//        self.view.window?.makeFirstResponder(self)
        
        self.connectDB()
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
        VLog(msg:"\(sender)")
        if let sessionCode = self.sessionCode {
            NSApplication.shared().endModalSession(sessionCode)
            self.sessionCode = nil
            VLog(msg:"closeAbout")
        }
        if let win = (sender as AnyObject).object {
            if win as! NSObject == self.view.window! {
                VLog(msg:"close App")
                NSApp.terminate(self)
            }
        }
    }
    
    @IBAction func setOpenLog(_ sender: Any) {
        self.db.clearLog()
    }
    
    @IBAction func setTimeNow(_ sender: Any) {
        self.db.getTime()
    }
    
    @IBAction func GetQuerySQL(_ sender: Any) {
        var originalData = [NSDictionary]()
        self.listData.removeAll()
        self.original_filter.removeAll()
        let rows = self.db.getAllSqls() as NSMutableArray
        if (rows.count > 0 && (rows[0] as! NSMutableArray).count > 0){
            for row in rows {
                VLog(msg: row)
                let _r = row as! NSMutableArray
                let t:Array = (_r[0] as! String).components(separatedBy: ".")
                originalData.append(["vtime":t[0],"vsql":_r[1]])
            }
            self.original_filter = originalData
            self.listData = originalData
            self.TableView.reloadData()
        }
    }
    
    @IBAction func Filter(_ sender: Any) {
        self.view.window?.makeFirstResponder(self.filterTextField)
    }
    
    @IBAction func showInPreview(_ sender:Any){
        let row = self.TableView.selectedRow
        if row<0 {
            return
        }
        let msg = self.listData[row].value(forKey: "vsql")
        self.previewTextField.stringValue = msg as! String
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
        VLog(msg:"\(self.listData[row].value(forKey: "vsql") as! String)")
        // 弹出用户通知 user notification
        let notification = NSUserNotification()
        notification.title = "Set \"\(String(describing: msg))\" to Pasteboard Success!"
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func connectDB() {
        if (self.db.connect(dbc.host,connectUser: dbc.user,connectPassword: dbc.pass,connectName: dbc.name,connectPort: UInt32(dbc.port))){
            self.db.getTime()
        }
    }
    
    var p_host:String{
        get{ return PreferenceData.sharedInstance.host }
        set{ PreferenceData.sharedInstance.host = newValue
            PreferenceData.sharedInstance.save()
            self.connectDB()
        }
    }
    
    var p_port:Int{
        get{ return PreferenceData.sharedInstance.port }
        set{ PreferenceData.sharedInstance.port = newValue
            PreferenceData.sharedInstance.save()
            self.connectDB()
        }
    }
    
    var p_user:String{
        get{ return PreferenceData.sharedInstance.user }
        set{ PreferenceData.sharedInstance.user = newValue
            PreferenceData.sharedInstance.save()
            self.connectDB()
        }
    }
    
    var p_pass:String{
        get{ return PreferenceData.sharedInstance.pass }
        set{ PreferenceData.sharedInstance.pass = newValue
            PreferenceData.sharedInstance.save()
            self.connectDB()
        }
    }
    
    func filter(f:String){
        self.listData.removeAll()
        if f != "" {
            for xxx in self.original_filter {
                let str:String = xxx["vsql"] as! String
                if str.lowercased().contains(f.lowercased())  {
                    self.listData.append(xxx)
                }
            }
        }else{
            self.listData = self.original_filter
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
                VLog(msg: "filterTextField : \(text)")
            }
        }
    }
}

