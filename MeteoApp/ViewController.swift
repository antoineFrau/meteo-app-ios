//
//  ViewController.swift
//  MeteoApp
//
//  Created by Antoine Frau on 18/04/2019.
//  Copyright © 2019 Antoine Frau. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
class ViewController: UIViewController, CLLocationManagerDelegate {

    var apiUrl = "https://api.openweathermap.org/data/2.5/weather?q=Ajaccio&units=metric&appid=b8c0162f208b810fd4c2e82e370a98a4"
    var myWeather: Weather?
    
    let locationManager = CLLocationManager()
    
    var backgroundColorByTime = [String: Any]()
    
    private var mainConstraints: [NSLayoutConstraint] = []
    private var metrics: [String: CGFloat]?
    private var views = [String: Any]()
    
    private var cityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.font = label.font.withSize(40)
        label.text = "City"
        return label
    }()
    
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.font = label.font.withSize(40)
        label.text = "HH:MM"
        return label
    }()
    
    private var temparatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.font = label.font.withSize(40)
        label.text = "X°"
        return label
    }()
    
    var imageWeather: UIImageView = {
        let img = UIImageView(image: UIImage(named: "Clear"))
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    var imageRefreshWeather: UIImageView = {
        let img = UIImageView(image: UIImage(named: "Refresh"))
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder() // To get shake gesture
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        timeLabel.text = getCurrDateTime()
        self.view.backgroundColor = getBackgroundColorBasedOnTime()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(refreshData(tapGestureRecognizer:)))
        imageRefreshWeather.isUserInteractionEnabled = true
        imageRefreshWeather.addGestureRecognizer(tapGestureRecognizer)
        
        self.views["cityLabel"] = cityLabel
        self.views["imageWeather"] = imageWeather
        self.views["temparatureLabel"] = temparatureLabel
        self.views["timeLabel"] = timeLabel
        self.views["imageRefreshWeather"] = imageRefreshWeather
        
        self.view.addSubview(cityLabel)
        self.view.addSubview(imageWeather)
        self.view.addSubview(temparatureLabel)
        self.view.addSubview(timeLabel)
        self.view.addSubview(imageRefreshWeather)
        
        getDataFromApi()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        self.apiUrl = changeApiUrl(locValue)
        
        self.refreshDataAndUI()
    }
    
    func changeApiUrl(_ locValue: CLLocationCoordinate2D) -> String{
        return "https://api.openweathermap.org/data/2.5/weather?lat=\(locValue.latitude)&lon=\(locValue.longitude)&appid=b8c0162f208b810fd4c2e82e370a98a4"
    }
    
    func changeApiUrl(_ city: String) -> String{
       return "https://api.openweathermap.org/data/2.5/weather?q=\(city.replacingOccurrences(of: " ", with: "%20"))&units=metric&appid=b8c0162f208b810fd4c2e82e370a98a4"
    }
    
    @objc func refreshData(tapGestureRecognizer: UITapGestureRecognizer){
        refreshDataAndUI()
    }
    
    func refreshDataAndUI(){
        getDataFromApi()
        timeLabel.text = getCurrDateTime()
        self.view.backgroundColor = getBackgroundColorBasedOnTime()
    }
    
    func getDataFromApi(){
        let data:NSData = try! NSData(contentsOf: URL(string:apiUrl)!)
        do {
            let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as! [String:Any]
            guard let weather = json["weather"] as? [[String: Any]] else {
                print(json["weather"] as Any)
                return
            }
            
            guard let temp = json["main"] as? [String: NSNumber] else {
                print(json["main"] as Any)
                return
            }
            
            guard let name = json["name"] as? String else {
                print(json["name"] as Any)
                return
            }
            
            myWeather = Weather(city: name, temperature: temp["temp"]!, imgName:weather[0]["main"] as! String)
            temparatureLabel.text = (myWeather?.temperature.stringValue)! + "°"
            imageWeather.image = getImageByName(name: myWeather?.imgName)
            cityLabel.text = myWeather?.city
        } catch let error as NSError {
            print(error)
        }
    }
    
    func genreateConstraintsVerticalOrientation() {
        
        let cityConstraintHorizontal = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-leftMargin-[cityLabel]-rightMargin-|",
            metrics: self.metrics,
            views: self.views)
        self.mainConstraints += cityConstraintHorizontal
        
        let iconWeatherConstraintHorizontal = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-iconWeatherHorizontalMargin-[imageWeather]-iconWeatherHorizontalMargin-|",
            metrics: self.metrics,
            views: self.views)
        self.mainConstraints += iconWeatherConstraintHorizontal
        
        let temperatureConstraintHorizontal = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-leftMargin-[temparatureLabel]-rightMargin-|",
            metrics: self.metrics,
            views: self.views)
        self.mainConstraints += temperatureConstraintHorizontal
        
        let timeConstraintHorizontal = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-leftMargin-[timeLabel]-rightMargin-|",
            metrics: self.metrics,
            views: self.views)
        self.mainConstraints += timeConstraintHorizontal
        
        let iconRefreshConstraintHorizontal = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-iconRefreshHorizontalMargin-[imageRefreshWeather]-iconRefreshHorizontalMargin-|",
            metrics: self.metrics,
            views: self.views)
        self.mainConstraints += iconRefreshConstraintHorizontal
        
        let constraintsVertical = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-topMargin-[cityLabel]-[imageWeather]-[temparatureLabel]-[timeLabel]",
            metrics: self.metrics,
            views: self.views)
        self.mainConstraints += constraintsVertical
        
        let refreshConstraintsVertical = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[timeLabel]-topMargin-[imageRefreshWeather]|",
            metrics: self.metrics,
            views: self.views)
        self.mainConstraints += refreshConstraintsVertical
        
        NSLayoutConstraint.activate(self.mainConstraints)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        if !self.mainConstraints.isEmpty {
            NSLayoutConstraint.deactivate(self.mainConstraints)
            self.mainConstraints.removeAll()
        }
        
        let newInsets = view.safeAreaInsets
        let leftMargin = newInsets.left > 0 ? newInsets.left : Metrics.padding
        let rightMargin = newInsets.right > 0 ? newInsets.right : Metrics.padding
        let topMargin = newInsets.top > 0 ? newInsets.top : Metrics.padding
        let bottomMargin = newInsets.bottom > 0 ? newInsets.bottom : Metrics.padding
        let halfHeigh = self.view.frame.height / 2
        let iconWeatherHorizontalMargin = (self.view.frame.width / 4).rounded()
        let iconRefreshHorizontalMargin = (self.view.frame.width / 3).rounded() + rightMargin + (rightMargin * 0.5)
        
        self.metrics = [
            "horizontalPadding": Metrics.padding,
            "topMargin": topMargin,
            "bottomMargin": bottomMargin,
            "leftMargin": leftMargin,
            "rightMargin": rightMargin,
            "halfHeigh": halfHeigh,
            "iconWeatherHorizontalMargin": iconWeatherHorizontalMargin,
            "iconRefreshHorizontalMargin": iconRefreshHorizontalMargin,
        ]
        self.genreateConstraintsVerticalOrientation()
    }
    
    private enum Metrics {
        static let padding: CGFloat = 30.0
    }
    
    func getBackgroundColorBasedOnTime() -> UIColor {
        let time = getCurrDateTime()
        let hour = Int(time.components(separatedBy: ":")[0])!
        var color = UIColor.black
        if(hour>=23 && hour<5){
            color = UIColor(rgb:0xa3a3a3)
        }
        if(hour>=5 && hour<9){
            color = UIColor(rgb:0x1c93a8)
        }
        if(hour>=9 && hour<15){
            color = UIColor(rgb:0x18af75)
        }
        if(hour>=15 && hour<19){
            color = UIColor(rgb:0xd2db6f)
        }
        if(hour>=19 && hour<23){
            color = UIColor(rgb:0xe5921d)
        }
        return color
    }
    
    func getCurrDateTime() -> String {
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        return df.string(from: Date())
    }
    
    func getImageByName(name: String?) -> UIImage {
        return UIImage(named: name ?? "Clear")!
    }
    
    // We are willing to become first responder to get shake motion
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        refreshDataAndUI()
    }
    
}

