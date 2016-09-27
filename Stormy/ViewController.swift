//
//  ViewController.swift
//  Stormy
//
//  Created by Pasan Premaratne on 4/9/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import UIKit

extension CurrentWeather {
    var temperatureString: String {
        return "\(Int(temperature))°"
    }
    
    var humidityString: String {
        let percentageValue = Int(humidity * 100)
        return "\(percentageValue)%"
    }
    
    var precipitationProbabilityString: String {
        let percentageValue = Int(precipitationProbability * 100)
        return "\(percentageValue)%"
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    @IBOutlet weak var currentHumidityLabel: UILabel!
    @IBOutlet weak var currentPrecipitationLabel: UILabel!
    @IBOutlet weak var currentWeatherIcon: UIImageView!
    @IBOutlet weak var currentSummaryLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let forecastAPIKey = "d03b85c42749b58fea3034bbfb9ec2de" // We cant read this property elsewhere in the app
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let icon = WeatherIcon.PartlyCloudyDay.image
        let currentWeather = CurrentWeather(temperature: 56.0, humidity: 1.0, precipitationProbability: 1.0, summary: "Wet and rainy", icon: icon)
        
        display(currentWeather)
        
        
        dataTask.resume() // Task is only activated if we fire this code!
        // Our dataTask is carried on a background thread
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func display(weather: CurrentWeather) {
        currentTemperatureLabel.text = weather.temperatureString
        currentPrecipitationLabel.text = weather.precipitationProbabilityString
        currentHumidityLabel.text = weather.humidityString
        currentSummaryLabel.text = weather.summary
        currentWeatherIcon.image = weather.icon
    }
}




























