//
//  PreferenceData.swift
//  vMysqlMonitoring
//
//  Created by Virink on 2017/3/8.
//  Copyright © 2017年 Virink. All rights reserved.
//

import Cocoa
//import Foundation

let DATA_DIRECTORY = "\(NSHomeDirectory())/Library/Application Support/\(Bundle.main.bundleIdentifier!)"
let DATA_PATH = "\(DATA_DIRECTORY)/Preference.dat"

class PreferenceData:NSObject {
    
    static let sharedInstance = PreferenceData()
    
    var v_host:String
    var v_port:Int
    var v_user:String
    var v_pass:String
    
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
                let data = "127.0.0.1:3306:root:root"
                try data.write(toFile: DATA_PATH, atomically: false, encoding: String.Encoding.utf8)
            }
            catch {
            }
        }
        
        let conf = try! NSString(contentsOfFile: DATA_PATH, encoding: String.Encoding.utf8.rawValue) as String
        let data = conf.components(separatedBy: ":")
        self.v_host = data[0]
        self.v_port = (data[1] as NSString).integerValue
        self.v_user = data[2]
        self.v_pass = data[3]
        
        super.init()
        
    }
    
    func save()
    {
        let data:String
        data = self.v_host+":\(self.v_port):"+self.v_user+":"+self.v_pass
        try! data.write(toFile: DATA_PATH, atomically: false, encoding: String.Encoding.utf8)
    }
}

