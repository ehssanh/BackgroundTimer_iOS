//
//  InterfaceController.swift
//  PresentationTimerWatch Extension
//
//  Created by Ehssan Hoorvash on 10/05/16.
//  Copyright © 2016 E. Hoorvash. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


enum ButtonState {
    case Pause
    case Resume
}

class InterfaceController: WKInterfaceController, WCSessionDelegate
{

    @IBOutlet var button: WKInterfaceButton!
    @IBOutlet var minutesLabel: WKInterfaceLabel!
    
    var buttonState: ButtonState!
    
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        buttonState = .Pause;
        
    }

    override func willActivate()
    {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate()
    {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func onButtonClick()
    {
        updateButtonTitle();
    }
    
    
    
  
    //MARK:
    
    func updateUI(minutes:Int)
    {
        
    }
    
    func updateButtonTitle()
    {
        if(buttonState == .Pause){
            button.setTitle("Resume");
            buttonState = .Resume;
        }else{
            button.setTitle("Pause");
            buttonState = .Pause;
        }
    }
    
}
