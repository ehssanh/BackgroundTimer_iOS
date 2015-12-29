//
//  ViewController.swift
//  PresentationTimer
//
//  Created by Ehssan Hoorvash on 28/12/15.
//  Copyright © 2015 E. Hoorvash. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var progress: KDCircularProgress!
    var button: UIButton!
    var timer: NSTimer!
    var delay: Double!
    
    let START_TAG = 1120
    let STOP_TAG = 1123
    
    @IBOutlet weak var slider: UISlider!    
    @IBOutlet weak var minutesLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Setup the progress bar
        setupProgress();
        
        // Setup the button
        setupButton();
        
        // Slider setup
        setupSlider();


        
    }
    
    //MARK:
    //MARK: Privates
    private func setupProgress()
    {
        progress = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        progress.startAngle = -90
        progress.progressThickness = 0.2
        progress.trackThickness = 0.7
        progress.clockwise = true
        progress.center = view.center
        progress.gradientRotateSpeed = 2
        progress.roundedCorners = true
        progress.glowMode = .Forward
        progress.setColors(UIColor.greenColor() ,UIColor.yellowColor(), UIColor.redColor())
        view.addSubview(progress)
    }
    
    private func setupButton()
    {
        button = UIButton(type:.System);
        button.frame = CGRect(x: 0, y: 0, width: 120, height: 120);
        button.center = view.center;
        button.tag = START_TAG;
        
        button.showsTouchWhenHighlighted = true;
        button.setTitleColor(UIColor.blackColor(), forState: .Normal);
        button.setTitleColor(UIColor.lightGrayColor(), forState: .Selected);
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(20.0);
        
        button.setTitle("Start", forState: .Normal);
        
        button.addTarget(self, action: "onButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside);
        view.addSubview(button);
    }
    
    private func setupSlider()
    {
        slider.minimumValue = 1.0;
        slider.maximumValue = 120.0;
        slider.addTarget(self, action: "onSliderValueChanged:", forControlEvents: UIControlEvents.ValueChanged);
        slider.value = 20;
        minutesLabel.text = String(20);
    }
    
    //MARK:
    //MARK: Actions

    func onSliderValueChanged(slider:UISlider!)
    {
        minutesLabel.text = String((NSInteger)(slider.value));
    }
    
    func onButtonClicked(sender:AnyObject!)
    {
        let theButton = sender as! UIButton;
        if(theButton.tag == START_TAG)
        {
            theButton.setTitle("Stop", forState: .Normal);
            theButton.tag = STOP_TAG;
            
            //Every 10 sec check again 
            //TODO: make it variable based on selected time.
            delay = 10
            timer = NSTimer.scheduledTimerWithTimeInterval(delay, target:self, selector: Selector("onTimerTick:"), userInfo: nil, repeats: true);

            progress.angle = 0;
            slider.enabled = false;
            slider.userInteractionEnabled = false;
        }
        else if (theButton.tag==STOP_TAG)
        {
            theButton.setTitle("Start", forState: .Normal);
            theButton.tag = START_TAG;
            timer.invalidate();
            timer = nil;
            
            progress.animateFromAngle(progress.angle, toAngle: 360, duration: 0.6 , completion: { (completed) -> Void in
                
                if(completed)
                {
                    self.progress.angle = 0;
                }
            });
            slider.enabled = true;
            slider.userInteractionEnabled = true;
        }
    }
    
    func onTimerTick(timer:NSTimer!)
    {
        if(progress.angle>=0 && progress.angle <= 360)
        {
            let degreePerMin = floor (360 / slider.value);
            let increment = Float(delay) * degreePerMin / 60;
            
            //timer tick in progress, a second each
            progress.angle! += NSInteger(increment);
            
        }else{
            progress.angle = 0;
        }
        
    }
}
