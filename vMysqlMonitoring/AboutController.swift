//
//  AboutController.swift
//  vMysqlMonitoring
//
//  Created by Virink on 2017-12-12.
//  Copyright © 2017 Virink. All rights reserved.
//

import Cocoa

class AboutController: NSViewController {
    
    @IBOutlet weak var version: NSTextField!
    
    var le:Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.version.stringValue = __VERSION__
    }
    
}

