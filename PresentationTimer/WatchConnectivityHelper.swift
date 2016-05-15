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
            self.session = WCSession.defaultSession();
            self.session.delegate = self;
            
            self.session.activateSession()
        }
    }
    
    func sendMessage(message: [String : AnyObject])
    {
        if (WCSession.defaultSession().reachable){
                self.session.sendMessage(message, replyHandler: nil, errorHandler: nil);
        }
    }
    

    
    
    func saveData(data: String, key: String)
    {
        let userDefaults = NSUserDefaults(suiteName: "group.com.ozkobet.presentationtimer");
        userDefaults?.setObject(data, forKey:key);
    }
    
    
    //MARK: Connectivity to Watch
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject])
    {
        print("Message received from watch : ", message);
    }
    
    func sessionWatchStateDidChange(session: WCSession) {
        
        print("iPhone received message");
        
        if #available(iOS 9.3, *) {
            print("Session stste ", session.activationState)
        } else {
            // Fallback on earlier versions
        };
    }
    
}

