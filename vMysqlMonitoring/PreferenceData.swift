//
//  PreferenceData.swift
//  vMysqlMonitoring
//
//  Created by Virink on 2017/3/8.
//  Copyright © 2017年 Virink. All rights reserved.
//

import Cocoa

let DATA_DIRECTORY = "\(NSHomeDirectory())/Library/Application Support/\(Bundle.main.bundleIdentifier!)"
let DATA_PATH = "\(DATA_DIRECTORY)/Preference.dat"

class PreferenceData:NSObject {
    
    static let sharedInstance = PreferenceData()
    static let default_data = "127.0.0.1:3306:root::mysql"
    
    var host:String! = nil
    var port:Int! = nil
    var user:String! = nil
    var pass:String! = nil
    var name:String! = nil
    
    override init()
    {
        if !FileManager.default.fileExists(atPath: DATA_DIRECTORY, isDirectory: nil) {
            do{
                try FileManager.default.createDirectory(atPath: DATA_DIRECTORY, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
            }
        }
        if !FileManager.default.fileExists(atPath: DATA_PATH) {
            do{
                try PreferenceData.default_data.write(toFile: DATA_PATH, atomically: false, encoding: String.Encoding.utf8)
            }
            catch {
            }
        }
        super.init()
        read()
    }
    
    func read(){
        let conf = try! NSString(contentsOfFile: DATA_PATH, encoding: String.Encoding.utf8.rawValue) as String
        let data = conf.components(separatedBy: ":")
        if (data.count != 5){
            VLog(msg: "mysql config error")
            try! PreferenceData.default_data.write(toFile: DATA_PATH, atomically: false, encoding: String.Encoding.utf8)
            read()
        } else{
            self.host = data[0]
            self.port = (data[1] as NSString).integerValue
            self.user = data[2]
            self.pass = data[3]
            self.name = data[4]
            VLog(msg: "mysql config : \(data)")
        }
    }
    
    func save()
    {
        let data:String
        data = self.host+":\(String(self.port)):"+self.user+":"+self.pass+":"+self.name
        try! data.write(toFile: DATA_PATH, atomically: false, encoding: String.Encoding.utf8)
        VLog(msg:"save mysql config : \(data)")
    }
}

