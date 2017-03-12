//
//  PreferenceController.swift
//  vMysqlMonitoring
//
//  Created by Virink on 2017/3/8.
//  Copyright © 2017年 Virink. All rights reserved.
//

import Cocoa

class PreferencesController: NSViewController {
    
    
    @IBOutlet weak var pf_host: NSTextField!
    @IBOutlet weak var pf_port: NSTextField!
    @IBOutlet weak var pf_user: NSTextField!
    @IBOutlet weak var pf_pass: NSTextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var p_host:String{
        get{
            return PreferenceData.sharedInstance.v_host
        }
        set{
            PreferenceData.sharedInstance.v_host = newValue
            PreferenceData.sharedInstance.save()
        }
    }
    
    var p_port:Int{
        get{
            return PreferenceData.sharedInstance.v_port
        }
        set{
            PreferenceData.sharedInstance.v_port = newValue
            PreferenceData.sharedInstance.save()
        }
    }
    
    var p_user:String{
        get{
            return PreferenceData.sharedInstance.v_user
        }
        set{
            PreferenceData.sharedInstance.v_user = newValue
            PreferenceData.sharedInstance.save()
        }
    }
    
    var p_pass:String{
        get{
            return PreferenceData.sharedInstance.v_pass
        }
        set{
            PreferenceData.sharedInstance.v_pass = newValue
            PreferenceData.sharedInstance.save()
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if (event.modifierFlags.contains(.command) && event.keyCode == 13) {
            PreferenceData.sharedInstance.save()
//            view
        }
    }
}
