//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation;
import Alamofire;
import SwiftyJSON;

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "8d698604111c99185da01412f3a6d102"
    
    let locationManager = CLLocationManager();
    let weatherDataModel = WeatherDataModel();
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //this 'self' keyword here means this class
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();

        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    func getWeatherData(url: String, parameters: [String:String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if (response.result.isSuccess) {
                print("Successfully got weather data");
                
                let weatherJSON : JSON = JSON(response.result.value!);
                
                print(weatherJSON);
                
                self.updateWeatherData(json: weatherJSON);
            }
            else {
                self.cityLabel.text = "Error occurred";
            }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    func updateWeatherData(json: JSON) {
        
        if let tempResult = json["main"]["temp"].double {
        
            weatherDataModel.temperature = Int((tempResult - 273.15) * 9/5 + 32);
            weatherDataModel.city = json["name"].stringValue;
            weatherDataModel.condition = json["weather"][0]["id"].intValue;
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition);
            
            updateUIWithWeatherData();
        }
        else {
            cityLabel.text = "Weather Unavailable";
        }
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    func updateUIWithWeatherData() {
        
        temperatureLabel.text = "\(weatherDataModel.temperature)°";
        cityLabel.text = weatherDataModel.city;
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName);
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    //didupdate method here
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1];
        if (location.horizontalAccuracy > 0) {
            locationManager.stopUpdatingLocation();

            //this is prevents the class from receiving messages from the location manager in the process of being stopped
            locationManager.delegate = nil;

            print("latitude = \(location.coordinate.latitude), longitude = \(location.coordinate.longitude)");

            let latitude = String(location.coordinate.latitude);
            let longitude = String(location.coordinate.longitude);

            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID];

            getWeatherData(url: WEATHER_URL, parameters: params);
        }
    }
    

    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error);
        cityLabel.text = "Location Unavailable";
    }



    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredANewCityName(city: String) {
        
        let params : [String : String] = ["q" : city, "appid" : APP_ID];
        getWeatherData(url: WEATHER_URL, parameters: params);
        
    }

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "changeCityName") {
            
            let destinationVC = segue.destination as! ChangeCityViewController;
            
            destinationVC.delegate = self;
        }
    }
    
    
    
}


