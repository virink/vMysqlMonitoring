//
//  FilterController.swift
//  vMysqlMonitoring
//
//  Created by Virink on 2017/3/12.
//  Copyright © 2017年 Virink. All rights reserved.
//

import Cocoa

class FilterController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    var f_text:String{
        get{
//            return MysqlAction.sharedInstance.filter
            return ""
        }
        set{
            return MysqlAction.sharedInstance.filter = newValue
//            ViewController.queryAll(<#T##ViewController#>)
        }
    }
    
}
