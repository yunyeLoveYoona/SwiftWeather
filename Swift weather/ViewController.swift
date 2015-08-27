//
//  ViewController.swift
//  Swift weather
//
//  Created by 叶云 on 15/8/13.
//  Copyright (c) 2015年 叶云. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate{
    @IBOutlet weak var loadingImage: UIActivityIndicatorView!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var lodingText: UILabel!
    @IBOutlet weak var locationText: UILabel!
    @IBOutlet weak var weatherInfo: UILabel!
    let locationManager : CLLocationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        if(ios8()){
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        var today:NSDate = NSDate()
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM"
        var mouth : Int = dateFormatter.stringFromDate(today).toInt()!
        if(mouth >= 5 && mouth<=8){
            self.view.backgroundColor = UIColor(patternImage: UIImage(named : "background_summer")!)

        }else{
            self.view.backgroundColor = UIColor(patternImage: UIImage(named : "background")!)

        }
        loadingImage.startAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func ios8() -> Bool{
        return (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8
        
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        var location : CLLocation = locations[locations.count-1] as! CLLocation
        if(location.horizontalAccuracy > 0){
            self.updateWeatherInfo(location.coordinate.latitude, longitude: location.coordinate.longitude)
            locationManager.stopUpdatingLocation()
        }
    }
    func updateWeatherInfo(latitude :CLLocationDegrees,longitude:CLLocationDegrees){
        let manager = AFHTTPRequestOperationManager()
        let url = "http://api.openweathermap.org/data/2.5/weather"
        let params = ["lat" : latitude,"lon" : longitude,"cnt" : 0]
        manager.GET(url, parameters: params, success: {(operation:AFHTTPRequestOperation, responseObject:AnyObject!) -> Void in
            self.updateUiSuccess(responseObject as! NSDictionary)
            },
            failure : { (operation,error: NSError!) -> Void in
              println("Json:"+error.description)
        })
      
    }
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        lodingText.text = "地理位置信息不可用"
    }
    func updateUiSuccess(jsonResult: NSDictionary){
        loadingImage.hidden = true
        loadingImage.stopAnimating()
        lodingText.text = nil
        if let tempResult = jsonResult["main"]?["temp"] as? Double{
            var temperature :Double
            if (jsonResult["sys"]?["country"] as? String == "US"){
                temperature = round(((tempResult - 273.15)*1.8)+32)
            }else{
                temperature = round(tempResult - 273.15)
            }
            self.weatherInfo.text = "\(temperature)°C"
            var name = jsonResult["name"] as! String
            locationText.text = "\(name)"
            var condition = (jsonResult["weather"] as! NSArray)[0]["id"] as? Int
            var sunrise = jsonResult["sys"]?["sunrise"] as? Double
            var sunset = jsonResult["sys"]?["sunset"] as? Double
            var night = false
            var now = NSDate().timeIntervalSince1970
            if(now < sunrise || now > sunset){
                night = true
            }
            self.updateWeatherImage(night, condition : condition!)
        }else{
            lodingText.text = "获取不到天气信息"
        }
       
    }
    func updateWeatherImage(night : Bool,condition : Int){
        if(condition < 300){
            if night{
                weatherImage.image = UIImage(named: "tstorm1_night.png")
            }else{
                weatherImage.image = UIImage(named: "tstorm1")
            }
        }else if(condition < 500){
            weatherImage.image = UIImage(named: "light_rain")
        }else if(condition < 600){
            weatherImage.image = UIImage(named: "shower3")
        }else if(condition < 700){
            weatherImage.image = UIImage(named: "snow4")
        }else if(condition < 771){
            if night{
                weatherImage.image = UIImage(named: "fog_night")
            }else{
                weatherImage.image = UIImage(named: "fog")
            }

        }else if(condition == 800){
            if night{
                weatherImage.image = UIImage(named: "sunny_night")
            }else{
                weatherImage.image = UIImage(named: "sunny")
            }
        }else if(condition < 804){
            if night{
                weatherImage.image = UIImage(named: "cloudy2_night")
            }else{
                weatherImage.image = UIImage(named: "cloudy2")
            }
        }else if(condition == 804){
             weatherImage.image = UIImage(named: "overcast")
        }else if((condition >= 900 && condition < 903) || (condition > 904 && condition < 1000)){
            weatherImage.image = UIImage(named: "tstorm3")
        }else if(condition == 903){
            weatherImage.image = UIImage(named: "snow5")
        }else if(condition == 904){
            weatherImage.image = UIImage(named: "sunny")
        }else{
            weatherImage.image = UIImage(named: "dunno  ")
        }

    }

}

