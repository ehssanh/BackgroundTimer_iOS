//
//  DataTransferHelper.swift
//  PresentationTimer
//
//  Created by Ehssan Hoorvash on 12/05/16.
//  Copyright © 2016 E. Hoorvash. All rights reserved.
//

import Foundation
import WatchConnectivity


@available(iOS 9.0, *)
class WatchConnectivityHelper: NSObject, WCSessionDelegate
{
    var session : WCSession!
    
    func startWatchSession()
    {
        if (WCSession.isSupported()){
            session = WCSession.defaultSession();
            session.delegate = self;
            session.activateSession();
        }
    }
    
    func sendMessage(message: [String : AnyObject])
    {
        session.sendMessage(message, replyHandler: nil, errorHandler: nil);
    }
    
    func stopWatchSession()
    {
        session = nil;
    }
    
    
    func saveData(data: String, key: String)
    {
        let userDefaults = NSUserDefaults(suiteName: "group.com.ozkobet.presentationtimer");
        userDefaults?.setObject(data, forKey:key);
    }
    
    
}

