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
    var startTime: NSTimeInterval!
    var alarms: Array<Bool>!

    let START_TAG = 1120
    let STOP_TAG = 1123
    
    let ALARM_BUTTON_COEFFICIENT = 12000
    let ALARM_PROGRESS_COEFFICIENT = 11000
    
    let PLUS_BUTTON_TAG = 331
    let MINUS_BUTTON_TAG = 332
    
    let MINUTES_CONST_LABEL_TAG = 7788
    
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var minutesLabel: UILabel!

    @IBOutlet weak var elapsedTimeLabel: UILabel!
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        self.setNeedsStatusBarAppearanceUpdate();

        // Setup the progress bar
        setupMainProgress();
        progress.animateFromAngle(progress.angle, toAngle: 360, duration: 0.6, completion: {
            (completed) -> Void in

            if (completed) {
                self.progress.angle = 0;
            }
        });

        // Setup the button
        setupStartStopButton();

        // Slider setup
        setupSlider();
        
        alarms = [Bool](count: 4, repeatedValue: true);
        setupAlarmIndicators();
    }
    

    @IBAction func onPlusClick(sender: AnyObject) {
        slider.value += 1;
        onSliderValueChanged(slider);
    }

    @IBAction func onMinusClick(sender: AnyObject) {
        slider.value -= 1;
        onSliderValueChanged(slider);
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }


    private func setupAlarmIndicators()
    {
        let screenWidth = Float(UIScreen.mainScreen().bounds.size.width);
        let numberOfIndicators = 4;
        let origin_y = 100;
        let origin_x = (Float(screenWidth) / Float(numberOfIndicators)) / 2.0;
        for i in 1 ... numberOfIndicators
        {
            let indicator_x = origin_x + Float(i-1) * (screenWidth/Float(numberOfIndicators));
            let indicator = KDCircularProgress(frame: CGRect(x:0 , y: 0, width: 50, height: 50));
            indicator.center = CGPoint(x: NSInteger(indicator_x), y: origin_y);
            indicator.startAngle = -90;
            indicator.progressThickness = 0.3
            indicator.trackThickness = 0.6
            indicator.setColors(UIColor.greenColor(), UIColor.greenColor(), UIColor.greenColor());
            indicator.tag = ALARM_PROGRESS_COEFFICIENT + i;
            view.addSubview(indicator);
            
            let alarmButton = UIButton(type: .System);
            alarmButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50);
            alarmButton.center = indicator.center;
            alarmButton.tag = 10000 + i ;
            alarmButton.showsTouchWhenHighlighted = true;
            alarmButton.tag = ALARM_BUTTON_COEFFICIENT + i;
            alarmButton.setTitleColor(UIColor.whiteColor(), forState: .Normal);
            alarmButton.titleLabel?.font = UIFont.boldSystemFontOfSize(12.0);
            alarmButton.titleLabel?.textColor = UIColor.whiteColor();
            alarmButton.setTitle("50", forState: .Normal);
            alarmButton.setTitleColor(UIColor.whiteColor(), forState: .Normal);
            alarmButton.addTarget(self, action: #selector(ViewController.onAlarmButtonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside);
            view.addSubview(alarmButton);
        }
        
        
        (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 1) as! KDCircularProgress).angle = 360 * 50 / 100 ;
        (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 2) as! KDCircularProgress).angle = 360 * 75 / 100 ;
        (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 2) as! KDCircularProgress).setColors(UIColor.yellowColor(), UIColor.yellowColor(), UIColor.yellowColor())
        (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 3) as! KDCircularProgress).angle = 360 * 90 / 100 ;
        (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 3) as! KDCircularProgress).setColors(UIColor.orangeColor(), UIColor.orangeColor(), UIColor.orangeColor())
        (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 4) as! KDCircularProgress).angle = 360 * 98 / 100 ;
        (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 4) as! KDCircularProgress).setColors(UIColor.redColor(), UIColor.redColor(), UIColor.redColor())
    
        (view.viewWithTag(ALARM_BUTTON_COEFFICIENT + 1) as! UIButton).setTitle("50%", forState: .Normal);
        (view.viewWithTag(ALARM_BUTTON_COEFFICIENT + 2) as! UIButton).setTitle("75%", forState: .Normal);
        (view.viewWithTag(ALARM_BUTTON_COEFFICIENT + 3) as! UIButton).setTitle("90%", forState: .Normal);
        (view.viewWithTag(ALARM_BUTTON_COEFFICIENT + 4) as! UIButton).setTitle("95%", forState: .Normal);
    }


    //MARK:
    //MARK: Privates
    private func setupMainProgress()
    {
        progress = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        progress.startAngle = -90
        progress.progressThickness = 0.2
        progress.trackThickness = 0.2
        progress.trackColor = UIColor.grayColor();
        progress.clockwise = true
        progress.center = view.center
        progress.gradientRotateSpeed = 2
        progress.roundedCorners = true
        progress.glowMode = .Forward
        progress.setColors(UIColor.greenColor(), UIColor.greenColor(), UIColor.greenColor())
        view.addSubview(progress)
    }

    private func setupStartStopButton()
    {
        button = UIButton(type: .System);
        button.frame = CGRect(x: 0, y: 0, width: 120, height: 120);
        button.center = view.center;
        button.tag = START_TAG;

        button.showsTouchWhenHighlighted = true;
        button.setTitleColor(UIColor.blackColor(), forState: .Normal);
        button.setTitleColor(UIColor.lightGrayColor(), forState: .Selected);
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(20.0);
        button.titleLabel?.textColor = UIColor.whiteColor();

        button.setTitle("Start", forState: .Normal);
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal);

        button.addTarget(self, action: #selector(ViewController.onButtonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside);
        view.addSubview(button);
    }
    


    private func setupSlider() {
        slider.minimumValue = 1.0;
        slider.maximumValue = 120.0;
        slider.addTarget(self, action: #selector(ViewController.onSliderValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged);
        slider.value = 20;
        minutesLabel.text = String(20);
    }

    //MARK:
    //MARK: Actions

    func onSliderValueChanged(slider: UISlider!)
    {
        minutesLabel.text = String((NSInteger)(slider.value));
    }
    
    func onAlarmButtonClicked(sender: AnyObject!)
    {
        switch sender.tag
        {
        case (ALARM_BUTTON_COEFFICIENT + 1):
            let c = alarms[0] ? UIColor.grayColor() : UIColor.greenColor() ;
            (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 1) as! KDCircularProgress).setColors(c,c,c)
            alarms[0] = !alarms[0];
            break;
        case ALARM_BUTTON_COEFFICIENT + 2:
            let c = alarms[1]  ? UIColor.grayColor() : UIColor.yellowColor() ;
            (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 2) as! KDCircularProgress).setColors(c,c,c)
            alarms[1] = !alarms[1];
            break;
        case ALARM_BUTTON_COEFFICIENT + 3:
            let c = alarms[2]  ? UIColor.grayColor() : UIColor.orangeColor() ;
            (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 3) as! KDCircularProgress).setColors(c,c,c)
            alarms[2] = !alarms[2];
            break;
        case ALARM_BUTTON_COEFFICIENT+4:
            let c = alarms[3]  ? UIColor.grayColor() : UIColor.redColor() ;
            (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 4) as! KDCircularProgress).setColors(c,c,c)
            alarms[3] = !alarms[3];
            break;
        default:
            break;
        }
        
        print(alarms);
        
    }

    func onButtonClicked(sender: AnyObject!)
    {
        let theButton = sender as! UIButton;
    
        if (theButton.tag == START_TAG)
        {
            theButton.setTitle("Stop", forState: .Normal);
            theButton.tag = STOP_TAG;

            //TODO: make it variable based on selected time.
            delay = 5
            timer = NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: #selector(ViewController.onTimerTick(_:)), userInfo: nil, repeats: true);

            startTime = NSDate.timeIntervalSinceReferenceDate();
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.updateElapsedTimeLabel), userInfo: nil, repeats: false);

            progress.angle = 0;
            slider.enabled = false;
            slider.userInteractionEnabled = false;
            (self.view.viewWithTag(PLUS_BUTTON_TAG) as! UIButton).userInteractionEnabled = false;
            (self.view.viewWithTag(PLUS_BUTTON_TAG) as! UIButton).setTitleColor(UIColor.grayColor(), forState: .Normal);
            (self.view.viewWithTag(MINUS_BUTTON_TAG) as! UIButton).userInteractionEnabled = false;
            (self.view.viewWithTag(MINUS_BUTTON_TAG) as! UIButton).setTitleColor(UIColor.grayColor(), forState: .Normal);
            minutesLabel.textColor = UIColor.grayColor();
            (self.view.viewWithTag(MINUTES_CONST_LABEL_TAG) as! UILabel).textColor = UIColor.grayColor();

            
        } else if (theButton.tag == STOP_TAG){
            
            theButton.setTitle("Start", forState: .Normal);
            theButton.tag = START_TAG;
            resetTimers();

            progress.animateFromAngle(progress.angle, toAngle: 360, duration: 0.6, completion: {
                (completed) -> Void in

                if (completed) {
                    self.progress.angle = 0;
                }
            });
            slider.enabled = true;
            slider.userInteractionEnabled = true;
            
            (self.view.viewWithTag(PLUS_BUTTON_TAG) as! UIButton).userInteractionEnabled = true;
            (self.view.viewWithTag(PLUS_BUTTON_TAG) as! UIButton).setTitleColor(UIColor.whiteColor(), forState: .Normal);
            (self.view.viewWithTag(MINUS_BUTTON_TAG) as! UIButton).userInteractionEnabled = true;
            (self.view.viewWithTag(MINUS_BUTTON_TAG) as! UIButton).setTitleColor(UIColor.whiteColor(), forState: .Normal);
            (self.view.viewWithTag(MINUTES_CONST_LABEL_TAG) as! UILabel).textColor = UIColor.whiteColor();
            minutesLabel.textColor = UIColor.whiteColor();
        }
    }

    func onTimerTick(timer: NSTimer!)
    {
        let degreePerMin = Double(360 / NSInteger(slider.value));
        let increment = Double( Double(delay) * degreePerMin / 60) ;

        print("Increment is  ", NSInteger(increment));
        print("Degree Per min  ", degreePerMin);

        checkForNotifications(Double( Double(progress.angle) + increment) / Double(360.0));

        progress.angle! += NSInteger(increment);

        if (progress.angle >= 0 && progress.angle <= 360) {
            //TODO: adjust colors

        } else {
            //Time up. Stop the timer.
            resetTimers();
        }

    }

    func updateElapsedTimeLabel()
    {
        let currentTime = NSDate.timeIntervalSinceReferenceDate();
        var elapsedTime: NSTimeInterval = currentTime - startTime;
        
        

        let minutes = NSInteger(elapsedTime / 60.0);

        elapsedTime -= (NSTimeInterval(minutes) * 60);
        let seconds = NSInteger(elapsedTime);

        elapsedTime -= NSTimeInterval(seconds);
        //let fraction = NSInteger(elapsedTime * 100);

        let strMinutes = String(format: "%02d", minutes);
        let strSeconds = String(format: "%02d", seconds);
        let strFraction = "00";

        elapsedTimeLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)";

        if (timer != nil && minutes < NSInteger(slider.value)) {
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.updateElapsedTimeLabel), userInfo: nil, repeats: false);
        } else {
            elapsedTimeLabel.text = "00:00:00";
        }
    }

    private func resetTimers()
    {
        print("Time's up");
        progress.angle = 0;
        timer.invalidate();
        timer = nil;

        elapsedTimeLabel.text = "00:00:00";
    }
    
    private func checkForNotifications(percent: Double)
    {
        if (alarms[0] && percent >= 0.95 )
        {
            showLocalNotification("95% passed");
            alarms[0] = false;
            return;
        }
        
        if (alarms[1] && percent >= 0.90 )
        {
            showLocalNotification("90% gone");
            alarms[1] = false;
            return;
        }
        
        if (alarms[2] && percent >= 0.75 )
        {
            showLocalNotification("75% gobe");
            alarms[2] = false;
            return;
        }
        
        if (alarms[3] && percent >= 0.50)
        {
            showLocalNotification("Half time");
            alarms[3] = false;
            return;
        }
    
    }
    
    private func showLocalNotification(message: String)
    {
        let localNotification = UILocalNotification();
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 0);
        localNotification.alertBody = message;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
}
