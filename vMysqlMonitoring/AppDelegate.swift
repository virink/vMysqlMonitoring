//
//  AppDelegate.swift
//  vMysqlMonitoring
//
//  Created by Virink on 2017/3/7.
//  Copyright © 2017年 Virink. All rights reserved.
//

import Cocoa

func VLog<T>(msg: T,
              fileName: String = #file,
              methodName: String = #function,
              lineNumber: Int = #line){
    #if DEBUG
        print("[\((fileName as NSString).pathComponents.last!):\(lineNumber)] [\(methodName)]:\n\(msg)\n-------------------------------------------\n")
    #endif
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

