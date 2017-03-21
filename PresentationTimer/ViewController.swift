//
//  ViewController.swift
//  PresentationTimer
//
//  Created by Ehssan Hoorvash on 28/12/15.
//  Copyright © 2015 E. Hoorvash. All rights reserved.
//

import UIKit
import GoogleMobileAds

enum UIUserInterfaceIdiom : Int
{
    case unspecified
    case phone
    case pad
}

struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}


@available(iOS 9.0, *)
class ViewController: UIViewController, UIAlertViewDelegate, GADBannerViewDelegate
{

    var progress: KDCircularProgress!
    var timer: Timer!
    var delay: Double!
    var startTime: TimeInterval!
    var alarms: Array<Bool>!

    let START_TAG = 1120
    let STOP_TAG = 1123
    
    let ALARM_BUTTON_COEFFICIENT = 12000
    let ALARM_PROGRESS_COEFFICIENT = 11000
    
    let PLUS_BUTTON_TAG = 331
    let MINUS_BUTTON_TAG = 332
    
    let MINUTES_CONST_LABEL_TAG = 7788
    let bannerView = GADBannerView(adSize:kGADAdSizeSmartBannerPortrait,origin: CGPoint(x: 0.0, y: 24.0))

    
    var currentMin : NSInteger!
    
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var minutesLabel: UILabel!

    @IBOutlet weak var elapsedTimeLabel: UILabel!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        self.setNeedsStatusBarAppearanceUpdate();
    
        
        // Setup the progress bar
        setupMainProgress();
        progress.animate(fromAngle: progress.angle, toAngle: 360, duration: 0.6, completion: {
            (completed) -> Void in

            if (completed) {
                self.progress.angle = 0;
            }
        });

        // Setup the button
        setupStartStopButton();

        // Slider setup
        setupSlider();
        
        alarms = [Bool](repeating: true, count: 4);
        setupAlarmIndicators();
        
        createAndLoadInterstitial();
        showBannerAd();
    }
    
    

    @IBAction func onPlusClick(_ sender: AnyObject)
    {
        slider.value += 1;
        onSliderValueChanged(slider);
    }

    @IBAction func onMinusClick(_ sender: AnyObject)
    {
        slider.value -= 1;
        onSliderValueChanged(slider);
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle
    {
        return UIStatusBarStyle.lightContent;
    }


    fileprivate func setupAlarmIndicators()
    {
        let screenWidth = Float(UIScreen.main.bounds.size.width);
        let numberOfIndicators = 4;
        var origin_y = 100;
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPAD {
             origin_y = 100
        }
        
        
        let origin_x = (Float(screenWidth) / Float(numberOfIndicators)) / 2.0;
        for i in 1 ... numberOfIndicators
        {
            let indicator_x = origin_x + Float(i-1) * (screenWidth/Float(numberOfIndicators));
            let indicator = KDCircularProgress(frame: CGRect(x:0 , y: 0, width: 50, height: 50));
            indicator.center = CGPoint(x: NSInteger(indicator_x), y: origin_y);
            indicator.startAngle = -90;
            indicator.progressThickness = 0.3
            indicator.trackThickness = 0.6
            indicator.set(colors: UIColor.green, UIColor.green, UIColor.green);
            indicator.tag = ALARM_PROGRESS_COEFFICIENT + i;
            view.addSubview(indicator);
            
            let alarmButton = UIButton(type: .system);
            alarmButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50);
            alarmButton.center = indicator.center;
            alarmButton.tag = 10000 + i ;
            alarmButton.showsTouchWhenHighlighted = true;
            alarmButton.tag = ALARM_BUTTON_COEFFICIENT + i;
            alarmButton.setTitleColor(UIColor.white, for: UIControlState());
            alarmButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12.0);
            alarmButton.titleLabel?.textColor = UIColor.white;
            alarmButton.setTitle("50", for: UIControlState());
            alarmButton.setTitleColor(UIColor.white, for: UIControlState());
            alarmButton.addTarget(self, action: #selector(ViewController.onAlarmButtonClicked(_:)), for: UIControlEvents.touchUpInside);
            view.addSubview(alarmButton);
        }
        
        
        (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 1) as! KDCircularProgress).angle = Double(360 * 50 / 100) ;
        (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 2) as! KDCircularProgress).angle = Double(360 * 75 / 100) ;
        (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 2) as! KDCircularProgress).set(colors: UIColor.yellow, UIColor.yellow, UIColor.yellow)
        (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 3) as! KDCircularProgress).angle = Double(360 * 90 / 100) ;
        (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 3) as! KDCircularProgress).set(colors: UIColor.orange, UIColor.orange, UIColor.orange)
        (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 4) as! KDCircularProgress).angle = Double(360 * 98 / 100) ;
        (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 4) as! KDCircularProgress).set(colors: UIColor.red, UIColor.red, UIColor.red)
    
        (view.viewWithTag(ALARM_BUTTON_COEFFICIENT + 1) as! UIButton).setTitle("50%", for: UIControlState());
        (view.viewWithTag(ALARM_BUTTON_COEFFICIENT + 2) as! UIButton).setTitle("75%", for: UIControlState());
        (view.viewWithTag(ALARM_BUTTON_COEFFICIENT + 3) as! UIButton).setTitle("90%", for: UIControlState());
        (view.viewWithTag(ALARM_BUTTON_COEFFICIENT + 4) as! UIButton).setTitle("95%", for: UIControlState());
    }


    //MARK:
    //MARK: Privates
    fileprivate func setupMainProgress()
    {
        progress = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: 280, height: 280))
        progress.startAngle = -90
        progress.progressThickness = 0.2
        progress.trackThickness = 0.2
        progress.trackColor = UIColor.gray;
        progress.clockwise = true
        progress.center = view.center
        progress.gradientRotateSpeed = 2
        progress.roundedCorners = true
        progress.glowMode = .forward
        progress.set(colors: UIColor.green, UIColor.green, UIColor.green)
        view.addSubview(progress)
    }

    fileprivate func setupStartStopButton()
    {
        //button = UIButton(type: .System);
        //button.frame = CGRect(x: 0, y: 0, width: 120, height: 120);
        //button.center = view.center;
        button.tag = START_TAG;

        button.showsTouchWhenHighlighted = true;
        button.setTitleColor(UIColor.black, for: UIControlState());
        button.setTitleColor(UIColor.lightGray, for: .selected);
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0);
        button.titleLabel?.textColor = UIColor.white;

        button.setTitle("Start", for: UIControlState());
        button.setTitleColor(UIColor.white, for: UIControlState());

        button.addTarget(self, action: #selector(ViewController.onButtonClicked(_:)), for: UIControlEvents.touchUpInside);
        view.addSubview(button);
    }
    


    fileprivate func setupSlider()
    {
        slider.minimumValue = 1.0;
        slider.maximumValue = 120.0;
        slider.addTarget(self, action: #selector(ViewController.onSliderValueChanged(_:)), for: UIControlEvents.valueChanged);
        slider.value = 20;
        minutesLabel.text = String(20);
    }

    //MARK:
    //MARK: Actions

    func onSliderValueChanged(_ slider: UISlider!)
    {
        minutesLabel.text = String((NSInteger)(slider.value));
    }
    
    func onAlarmButtonClicked(_ sender: AnyObject!)
    {
        switch sender.tag
        {
        case (ALARM_BUTTON_COEFFICIENT + 1):
            let c = alarms[0] ? UIColor.gray : UIColor.green ;
            (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 1) as! KDCircularProgress).set(colors: c,c,c)
            alarms[0] = !alarms[0];
            break;
        case ALARM_BUTTON_COEFFICIENT + 2:
            let c = alarms[1]  ? UIColor.gray : UIColor.yellow ;
            (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 2) as! KDCircularProgress).set(colors:c,c,c)
            alarms[1] = !alarms[1];
            break;
        case ALARM_BUTTON_COEFFICIENT + 3:
            let c = alarms[2]  ? UIColor.gray : UIColor.orange ;
            (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 3) as! KDCircularProgress).set(colors:c,c,c)
            alarms[2] = !alarms[2];
            break;
        case ALARM_BUTTON_COEFFICIENT+4:
            let c = alarms[3]  ? UIColor.gray : UIColor.red ;
            (view.viewWithTag(ALARM_PROGRESS_COEFFICIENT + 4) as! KDCircularProgress).set(colors:c,c,c)
            alarms[3] = !alarms[3];
            break;
        default:
            break;
        }
        
        print(alarms);
    }

    
    func onButtonClicked(_ sender: AnyObject!)
    {
        let theButton = sender as! UIButton;
    
        if (theButton.tag == START_TAG)
        {
            
            theButton.setTitle("Stop", for: UIControlState());
            theButton.tag = STOP_TAG;

            //TODO: make it variable based on selected time.
            delay = floor(Double(slider.value) / 6) + 1
            ;
            
            timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(ViewController.onTimerTick(_:)), userInfo: nil, repeats: true);

            startTime = Date.timeIntervalSinceReferenceDate;
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.updateElapsedTimeLabel), userInfo: nil, repeats: false);

            progress.angle = 0;
            slider.isEnabled = false;
            slider.isUserInteractionEnabled = false;
            (self.view.viewWithTag(PLUS_BUTTON_TAG) as! UIButton).isUserInteractionEnabled = false;
            (self.view.viewWithTag(PLUS_BUTTON_TAG) as! UIButton).setTitleColor(UIColor.gray, for: UIControlState());
            (self.view.viewWithTag(MINUS_BUTTON_TAG) as! UIButton).isUserInteractionEnabled = false;
            (self.view.viewWithTag(MINUS_BUTTON_TAG) as! UIButton).setTitleColor(UIColor.gray, for: UIControlState());
            minutesLabel.textColor = UIColor.gray;
            (self.view.viewWithTag(MINUTES_CONST_LABEL_TAG) as! UILabel).textColor = UIColor.gray;
            
            currentMin = NSInteger(slider.value);

            
        } else if (theButton.tag == STOP_TAG){
            
            
            theButton.setTitle("Start", for: UIControlState());
            theButton.tag = START_TAG;
            resetTimers();

            progress.animate(fromAngle: progress.angle, toAngle: 360, duration: 0.6, completion: {
                (completed) -> Void in

                if (completed) {
                    self.progress.angle = 0;
                }
            });
            slider.isEnabled = true;
            slider.isUserInteractionEnabled = true;
            
            (self.view.viewWithTag(PLUS_BUTTON_TAG) as! UIButton).isUserInteractionEnabled = true;
            (self.view.viewWithTag(PLUS_BUTTON_TAG) as! UIButton).setTitleColor(UIColor.white, for: UIControlState());
            (self.view.viewWithTag(MINUS_BUTTON_TAG) as! UIButton).isUserInteractionEnabled = true;
            (self.view.viewWithTag(MINUS_BUTTON_TAG) as! UIButton).setTitleColor(UIColor.white, for: UIControlState());
            (self.view.viewWithTag(MINUTES_CONST_LABEL_TAG) as! UILabel).textColor = UIColor.white;
            minutesLabel.textColor = UIColor.white;
        }
    }

    
    func onTimerTick(_ timer: Timer!)
    {
        let degreePerMin = Double(360 / NSInteger(slider.value));
        let increment = Double( Double(delay) * degreePerMin / 60) ;

        //print("Increment is  ", NSInteger(increment));
        //print("Degree Per min  ", degreePerMin);

        checkForNotifications(Double( Double(progress.angle) + increment) / Double(360.0));

        progress.angle += Double(increment);

        if (progress.angle >= 0 && progress.angle <= 360) {
            //TODO: adjust colors

        } else {
            //Time up. Stop the timer.
            resetTimers();
        }

    }

    func updateElapsedTimeLabel()
    {
        let currentTime = Date.timeIntervalSinceReferenceDate;
        var elapsedTime: TimeInterval = currentTime - startTime;

        let minutes = NSInteger(elapsedTime / 60.0);

        elapsedTime -= (TimeInterval(minutes) * 60);
        let seconds = NSInteger(elapsedTime);

        elapsedTime -= TimeInterval(seconds);
        //let fraction = NSInteger(elapsedTime * 100);

        let strMinutes = String(format: "%02d", minutes);
        let strSeconds = String(format: "%02d", seconds);
        let strFraction = "00";
        
        if (currentMin != (NSInteger(slider.value) - minutes))
        {
            currentMin = (NSInteger(slider.value) - minutes);
        }

        elapsedTimeLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)";

        if (timer != nil && minutes < NSInteger(slider.value)) {
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.updateElapsedTimeLabel), userInfo: nil, repeats: false);
        } else {
            elapsedTimeLabel.text = "00:00:00";
        }
    }

    
    fileprivate func resetTimers()
    {
        print("Time's up");
        progress.angle = 0;
        timer.invalidate();
        timer = nil;

        elapsedTimeLabel.text = "00:00:00";
    }
    
    fileprivate func checkForNotifications(_ percent: Double)
    {
        if (alarms[0] && percent >= 0.95 )
        {
            showLocalNotification("95%% of your time passed. Wrap it up!");
            alarms[0] = false;
            return;
        }
        
        if (alarms[1] && percent >= 0.90 )
        {
            showLocalNotification("90%% of your time passed. Almost finished!");
            alarms[1] = false;
            return;
        }
        
        if (alarms[2] && percent >= 0.75 )
        {
            showLocalNotification("75%% of your time has passed.");
            alarms[2] = false;
            return;
        }
        
        if (alarms[3] && percent >= 0.50)
        {
            showLocalNotification("Half of your presentation time has passed.");
            alarms[3] = false;
            return;
        }
    
    }
    
    fileprivate func showLocalNotification(_ message: String)
    {
        let localNotification = UILocalNotification();
        localNotification.fireDate = Date(timeIntervalSinceNow: 0);
        localNotification.alertBody = message;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }
    
    fileprivate func createAndLoadInterstitial()
    {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-1774127394132080/1318777855")
        let request = GADRequest()
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made.
        request.testDevices = [kGADSimulatorID, "5927d0ad369776b75b817969d61bbc3f" ]
        interstitial.load(request)
        
        presentInterstitial(interstitial);
        
    }
    
    fileprivate func presentInterstitial(_ ad: GADInterstitial)
    {
        let delay = 2.0 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            ad.present(fromRootViewController: self)
        }
    }
    
    fileprivate func showBannerAd()
    {
        bannerView.delegate = self;
        bannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView.adUnitID = "ca-app-pub-1774127394132080/2935111857"
        bannerView.load(request)
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView)
    {
        self.view.addSubview(bannerView);
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError)
    {
        print();
    }

    
   }
