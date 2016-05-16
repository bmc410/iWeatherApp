//
//  ViewController.swift
//  WeatherApp
//
//  Created by Bill McCoy on 5/11/16.
//  Copyright © 2016 WellSpan Health. All rights reserved.
//

import UIKit
import CoreLocation
import ObjectMapper




class ViewController: UITableViewController, CLLocationManagerDelegate {

    let gradientLayer = CAGradientLayer()
    
    @IBOutlet var WeatherTable: UITableView!
    @IBOutlet weak var Navbar: UINavigationItem!
    
    
    var city: String?
    let locationManager = CLLocationManager()
    var weatherResp: WeatherResponse?
    var fiveDayForecast: [Forecast]?
    var latitude: String = ""
    var longitude: String = ""
    var openWeatherMapAPIKey: String = "8c43f472feacb1178fe9eacb75a36878"
    var today: NSDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FindLocation()
        tableView.backgroundView = UIImageView(image: UIImage(named: "white"))
        self.refreshControl?.addTarget(self, action: #selector(ViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        //greyGradient()
        //self.view.backgroundColor = UIColor.yellowColor()
        self.WeatherTable.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        //Navbar.title = "Weather for Dallastown, PA"
        //setTableViewBackgroundGradient(self, UIColor.redColor(), UIColor.darkGrayColor())
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        getWeather()
        refreshControl.endRefreshing()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func FindLocation(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func getDayNameBy(stringDate: String) -> String
    {
        let df  = NSDateFormatter()
        df.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let date = df.dateFromString(stringDate)!
        df.dateFormat = "EEEE"
        return df.stringFromDate(date);
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if fiveDayForecast != nil{
            count = (fiveDayForecast!.count)
        }
        return count
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //cell.backgroundColor = UIColor(white: 1, alpha: 0.5)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        // get an instance of your cell
        
        
        
        var cell = tableView.dequeueReusableCellWithIdentifier("WeatherTableViewCell", forIndexPath: indexPath) as? WeatherTableViewCell
        
        if cell == nil {
            cell = WeatherTableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "WeatherTableViewCell")
        }
        
        let singleday = fiveDayForecast![indexPath.row]
        var dayName: String?
        
        let df  = NSDateFormatter()
        df.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let rowDate = df.dateFromString(singleday.dtText!)!
        
        let today = NSDate()
        let tomorrow = today.dateByAddingTimeInterval(24 * 60 * 60)
        
        if compareDate(rowDate, toDate: today, toUnitGranularity: .Day) == NSComparisonResult.OrderedSame{
            dayName = "Today"
        } else if compareDate(rowDate, toDate: tomorrow, toUnitGranularity: .Day) == NSComparisonResult.OrderedSame{
            dayName = "Tomorrow"
        } else {
            dayName = getDayNameBy(singleday.dtText!)
        }
        
        //let dayName = getDayNameBy(singleday.dtText!)
        let iconURL = "http://openweathermap.org/img/w/" + singleday.weather![0].icon! + ".png"
        cell!.WeatherImage.imageFromUrl(iconURL)
        cell!.MainCellTitle.text = dayName
        cell!.Description.text = singleday.weather![0].description!
        let iTemp = (Int) (singleday.temp!)
        cell!.Temp.text = (String) (iTemp) + "\u{00B0}"
        cell?.backgroundColor = UIColor.clearColor()
        return cell!
    
    }
    
    func compareDate(date1: NSDate, toDate date2: NSDate, toUnitGranularity unit: NSCalendarUnit) -> NSComparisonResult{
//        let now = NSDate()
//        // "Sep 23, 2015, 10:26 AM"
//        let olderDate = NSDate(timeIntervalSinceNow: -10000)
//        // "Sep 23, 2015, 7:40 AM"
//        
//        var order = NSCalendar.currentCalendar().compareDate(now, toDate: olderDate,
//                                                             toUnitGranularity: .Hour)
//        
//        switch order {
//        case .OrderedDescending:
//            print("DESCENDING")
//        case .OrderedAscending:
//            print("ASCENDING")
//        case .OrderedSame:
//            print("SAME")
//        }
        
        // Compare to hour: SAME
        
        let order = NSCalendar.currentCalendar().compareDate(date1, toDate: date2,
                                                         toUnitGranularity: .Day)
        
        switch order {
        case .OrderedDescending:
            return NSComparisonResult.OrderedDescending
        case .OrderedAscending:
            return NSComparisonResult.OrderedAscending
        case .OrderedSame:
            return NSComparisonResult.OrderedSame
        }
        
        // Compare to day: DESCENDING
        
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func getWeather() {
        let apiCall = "http://api.openweathermap.org/data/2.5/forecast?lat=" + self.latitude
            + "&lon=" + self.longitude + "&units=imperial&mode=json&appid=" + self.openWeatherMapAPIKey
        NSLog("getWeather called with api request: \(apiCall)")
        let obj = RestAPI()
        obj.CallAPI(apiCall) { response in
            self.weatherResp = Mapper<WeatherResponse>().map((String) (response))
            self.fiveDayForecast = self.weatherResp!.fiveDayForecast?.lazy.filter{c in c.dtText!.lowercaseString.rangeOfString("00:00:00") != nil}
            self.getTodayWeather()
        }

    }
    
    func getTodayWeather(){
        let apiCall = "http://api.openweathermap.org/data/2.5/weather?lat=" + self.latitude
            + "&lon=" + self.longitude + "&units=imperial&mode=json&appid=" + self.openWeatherMapAPIKey
        let obj = RestAPI()
        obj.CallAPI(apiCall) { response in
            let f = Mapper<Forecast>().map((String) (response))
            let df  = NSDateFormatter()
            df.dateFormat = "YYYY-MM-dd HH:mm:ss"
            f?.dtText = df.stringFromDate(NSDate())
            self.fiveDayForecast?.insert(f!, atIndex: 0)
            self.WeatherTable.reloadData()
        }
    }

    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            self.locationManager.stopUpdatingLocation()
            manager.stopUpdatingLocation()
            for item: AnyObject in locations {
                if let location = item as? CLLocation {
                    if location.horizontalAccuracy < 1000 {
                        if placemarks!.count > 0 {
                            let pm = placemarks![0] as CLPlacemark
                            self.displayLocationInfo(pm)
                        } else {
                            print("Problem with the data received from geocoder")
                        }
                        manager.stopUpdatingLocation()
                        self.latitude = String(location.coordinate.latitude)
                        self.longitude = String(location.coordinate.longitude)
                        self.getWeather()
                        
                    }
                }
            }
            
            
            
        })
    }
    
    func displayLocationInfo(placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            city = locality
            let postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            _ = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
            
            Navbar.title = "Weather for " + locality! + ", " + administrativeArea! +  " " + postalCode!
            
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }



}

