//
//  MysqlAction.swift
//  vMysqlMonitoring
//
//  Created by Virink on 2017/3/8.
//  Copyright © 2017年 Virink. All rights reserved.
//

import Cocoa
//import Foundation

class MysqlAction {
    
    static let sharedInstance = MysqlAction()
    var filter:String = ""
    var con = MySQL.Connection()
    var datatime:String = ""
    var seconds:Double = 0.0
    
    init(){
    }
    
    func connect() {
        if !self.con.isConnected {
            do{
                try self.con.open(
                    PreferenceData.sharedInstance.v_host,
                    port: PreferenceData.sharedInstance.v_port,
                    user: PreferenceData.sharedInstance.v_user,
                    passwd: PreferenceData.sharedInstance.v_pass)
            }
            catch (let e) {
                print(e)
            }
        }
    }
    
    func openlog(){
        do {
            try self.con.exec("use mysql;")
            try self.con.exec("truncate table general_log;") // clear log
            try self.con.exec("set global general_log=on;")
            try self.con.exec("SET GLOBAL log_output='table';")
        }
        catch(let e){
            print(e)
        }
    }
    
    func getseconds(){
        if self.con.isConnected {
            do {
                let stmt = try self.con.prepare("select unix_timestamp() as 'stime' from dual where 9 > ?;")
                let res = try stmt.query([1])
                let temp2:Double = Double(NSDate().timeIntervalSince1970)
                let rows = try res.readAllRows()
                var temp1:Double = 0.0
                if ((rows?.count)! > 0 && (rows?[0].count)! > 0 && (rows?[0][0].count)! > 0){
                    let temp = rows?[0][0]["stime"] as! Int64
                    temp1 = Double(temp)
                }
                self.seconds = Double(temp1) - 1.0 - Double(temp2)
            }
            catch(let e)
            {
                print(e)
            }
        }
    }
    
    func query() throws -> [MySQL.Row]?
    {
        do{
            let stmt = try self.con.prepare("select event_time as 'vtime', argument as 'vsql' from mysql.general_log where command_type='Query' and argument not like '%general\\_log%' and argument not like '%log\\_output%' and unix_timestamp(event_time) > ?;")
            let res = try stmt.query(["\(self.datatime)"])
            let rows = try res.readAllRows()
            self.getdatetimenow()
            if ((rows?.count)! > 0 && (rows?[0].count)! > 0){
                return rows?[0]
            }else{
                return [[:]]
            }
        }
        catch(let e){
            print(e)
            return [[:]]
        }
    }
    
    func getdatetimenow() {
        let tmp = NSDate().timeIntervalSince1970 + self.seconds
        self.datatime = "\(tmp)"
    }
}
