//
//  WeatherViewController.swift
//  TestWorkWeather
//
//  Created by Дмитрий Жучков on 20.11.2020.
//

import UIKit
import SwiftyJSON
import Alamofire
import MapKit
struct Weather {
    var date:String?
    var Weather:Double?
    
}
struct DailyWeather{
    var date:String?
    var minWeather:Double?
    var maxWeather:Double?
    var description:String?
}
class WeatherViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var DateTomorLabel: UILabel!
    @IBOutlet weak var WeatherTod: UICollectionView!
    @IBOutlet weak var WeatherTomor: UICollectionView!
    @IBOutlet weak var WeatherDaily: UICollectionView!
    var temperaturetoday = [Weather]()
    var temperaturetomorrow = [Weather]()
    var weather = [DailyWeather]()
    var coordinate: CLLocationCoordinate2D?
    var Name:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        cityLabel.text = Name
        let WEATHER_TOKEN = "ad74cede7c673cd26fe7450f02c1a530"
        self.WeatherTod.register(WeatherCollectionViewCell.self, forCellWithReuseIdentifier: WeatherCollectionViewCell.reuseId)
        self.WeatherTod.delegate = self
        self.WeatherTod.dataSource = self
        self.WeatherTomor.register(WeatherCollectionViewCellTomor.self, forCellWithReuseIdentifier: WeatherCollectionViewCellTomor.reuseId)
        self.WeatherTomor.delegate = self
        self.WeatherTomor.dataSource = self
        self.WeatherDaily.register(DailyWeatherCell.self, forCellWithReuseIdentifier: DailyWeatherCell.reuseId)
        self.WeatherDaily.delegate = self
        self.WeatherDaily.dataSource = self
        AF.request("https://api.openweathermap.org/data/2.5/onecall?lat=\((coordinate?.latitude)!)&lon=\((coordinate?.longitude)!)&exclude=alerts&appid=\(WEATHER_TOKEN)&units=metric&lang=ru").responseJSON {
        response in
            let json = JSON(response.value!)
            let currentdate = json["current"]["dt"].double
            let date = Date(timeIntervalSince1970: currentdate!)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.none //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.short
            dateFormatter.timeZone = .current
            let current = dateFormatter.string(from: date)
            for n in 0...23 {
                let timeResult = json["hourly"][n]["dt"].double
                let date = Date(timeIntervalSince1970: timeResult!)
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = DateFormatter.Style.none //Set time style
                dateFormatter.dateStyle = DateFormatter.Style.short
                dateFormatter.timeZone = .current
                let localDate = dateFormatter.string(from: date)
                if current.compare(localDate) == .orderedSame {
                    self.DateLabel.text = "Погода на сегодня (\(localDate))"
                    let tempToday = json["hourly"][n]["temp"].double
                    let timeResult1 = json["hourly"][n]["dt"].double
                    let date = Date(timeIntervalSince1970: timeResult1!)
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
                    dateFormatter.dateStyle = DateFormatter.Style.none
                    dateFormatter.timeZone = .current
                    let localDate1 = dateFormatter.string(from: date)
                    let temmp = Weather(date: localDate1, Weather: tempToday!)
                    self.temperaturetoday.append(temmp)
                } else if current.compare(localDate) == .orderedAscending {
                    self.DateTomorLabel.text = "Погода на завтра (\(localDate))"
                    let tempTomorrow = json["hourly"][n]["temp"].double
                    let timeResult1 = json["hourly"][n]["dt"].double
                    let date = Date(timeIntervalSince1970: timeResult1!)
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
                    dateFormatter.dateStyle = DateFormatter.Style.none
                    dateFormatter.timeZone = .current
                    let localDate1 = dateFormatter.string(from: date)
                    let temmp1 = Weather(date: localDate1, Weather: tempTomorrow!)
                    self.temperaturetomorrow.append(temmp1)
                    
                }
            
        }
            for n in 0...7 {
                let dateDaily = json["daily"][n]["dt"].double
                let tempMin = json["daily"][n]["temp"]["min"].double
                let tempMax = json["daily"][n]["temp"]["max"].double
                let descrip = json["daily"][n]["weather"][0]["description"].string
                let date = Date(timeIntervalSince1970: dateDaily!)
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = DateFormatter.Style.none //Set time style
                dateFormatter.dateStyle = DateFormatter.Style.short
                dateFormatter.timeZone = .current
                let Day = dateFormatter.string(from: date)
                let info = DailyWeather(date: Day, minWeather: tempMin!, maxWeather: tempMax!, description: descrip!)
                self.weather.append(info)
                
            }
            OperationQueue.main.addOperation({
                self.WeatherTod.reloadData()
                self.WeatherTomor.reloadData()
                self.WeatherDaily.reloadData()
            })
        }.resume()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.WeatherTod {
        return temperaturetoday.count
        } else if collectionView == self.WeatherTomor {
            return temperaturetomorrow.count
        } else {
            return weather.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.WeatherTod {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCollectionViewCell", for: indexPath) as! WeatherCollectionViewCell
        cell.smallDescriptionLabel.text = temperaturetoday[indexPath.row].date
        cell.nameLabel.text = String(temperaturetoday[indexPath.row].Weather!)
        return cell
        } else if collectionView == self.WeatherTomor {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCollectionViewCellTomor", for: indexPath) as! WeatherCollectionViewCellTomor
            cell.smallDescriptionLabel.text = temperaturetomorrow[indexPath.row].date
            cell.nameLabel.text = String(temperaturetomorrow[indexPath.row].Weather!)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCollectionViewCellDaily", for: indexPath) as! DailyWeatherCell
            cell.nameLabel.text = weather[indexPath.row].date
            cell.smallDescriptionLabel.text = "Мин: \((weather[indexPath.row].minWeather)!),\nМакс: \((weather[indexPath.row].minWeather)!)\n \((weather[indexPath.row].description)!)"
            return cell
        }
    }
}

