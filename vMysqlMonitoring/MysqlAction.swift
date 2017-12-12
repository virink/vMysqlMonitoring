//
//  MysqlAction.swift
//  vMysqlMonitoring
//
//  Created by Virink on 2017/3/8.
//  Copyright © 2017年 Virink. All rights reserved.
//

import Cocoa
import MySqlSwiftNative

class MysqlAction {
    
    static let sharedInstance = MysqlAction()
    var filter:String = ""
    var con = MySQL.Connection()
    var datatime:String = ""
    var seconds:Double = 0.0
    
    init(){
    }
    
    func connect() -> Bool {
        if !self.con.isConnected {
            do{
                try self.con.open(
                    PreferenceData.sharedInstance.v_host,
                    port: PreferenceData.sharedInstance.v_port,
                    user: PreferenceData.sharedInstance.v_user,
                    passwd: PreferenceData.sharedInstance.v_pass)
                return true
            }
            catch (let e) {
                NSLog("Connect Error : \(e)")
                self.msg_alert(msg: "\(e)")
            }
        }
        return false
    }
    
    func openlog(){
        if(connect()){
            do {
                try self.con.exec("use mysql;")
                try self.con.exec("set global general_log=off;")
                try self.con.exec("truncate table general_log;") // clear log
                try self.con.exec("SET GLOBAL log_output='table';")
                try self.con.exec("set global general_log=on;")
            }
            catch(let e){
                NSLog("Error : \(e)")
            }
        }
    }
    
    func getseconds(){
        if self.con.isConnected {
            do {
                let stmt = try self.con.prepare("select unix_timestamp() as 'stime_virink' from dual where 9 > ?;")
                let res = try stmt.query([1])
                let rows = try res.readAllRows()
                if ((rows?.count)! > 0 && (rows?[0].count)! > 0 && (rows?[0][0].count)! > 0){
                    let temp = rows?[0][0]["stime_virink"] as! Int64
                    self.seconds = Double(temp)
                }else{
                    self.seconds = Double(0.0)
                }
                NSLog("Set seconds = \(self.seconds)")
            }
            catch(let e)
            {
                NSLog("Error : \(e)")
            }
        }else if(connect()){
            getseconds()
        }
    }
    
    func query() throws -> [MySQL.Row]?
    {
        if self.seconds == Double(0.0){
            NSLog("Error : Please set seconds")
        }else if self.con.isConnected {
            do{
                let stmt = try self.con.prepare("SELECT event_time as vtime, argument as vsql FROM mysql.general_log WHERE (command_type = 'Query' OR command_type = 'Execute') AND unix_timestamp(event_time) > ? AND argument NOT LIKE '%general_log%' AND argument NOT LIKE '%select event_time,argument from%' AND argument NOT LIKE '%SHOW%' AND argument NOT LIKE '%SELECT STATE%' AND argument NOT LIKE '%SET NAMES%' AND argument NOT LIKE '%SET PROFILING%' AND argument NOT LIKE '%stime_virink%' AND argument NOT LIKE '%SELECT QUERY_ID%' order by event_time desc;")
                let res = try stmt.query(["\(self.seconds)"])
                let rows = try res.readAllRows()
                if ((rows?.count)! > 0 && (rows?[0].count)! > 0){
                    return rows?[0]
                }else{
                    return [[:]]
                }
            }
            catch(let e){
                NSLog("Error : \(e)")
                return [[:]]
            }
        }else if(connect()){
            return try query()
        }
        return [[:]]
    }
    
    func msg_alert(msg:String){
        let alert:NSAlert = NSAlert()
        alert.messageText = msg
        alert.runModal()
    }
    
}
