//
//  ViewController.swift
//  TestWorkWeather
//
//  Created by Дмитрий Жучков on 20.11.2020.
//

import UIKit
import MapKit
import RealmSwift
struct CityList {
    var Name: String?
    var coord: CLLocationCoordinate2D
}
class ViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var cityList: UITableView!
    var cityStorage = [CityList]()
    let realm = try! Realm()
    override func viewDidLoad() {
        super.viewDidLoad()
        cityList.delegate = self
        cityList.dataSource = self
        cityList.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        let date = realm.objects(City.self)
        if (date.count != 0) {
        for n in 0...(date.count - 1) {
            print(date[n].Lati)
            print(date[n].Long)
            let data = CityList(Name: date[n].Name, coord: CLLocationCoordinate2D(latitude: date[n].Lati, longitude: date[n].Long))
            print(data)
            cityStorage.append(data)
        }
        }
        if cityStorage.isEmpty {
            let firstCityAlert = UIAlertController(title: "", message: "Выберите первый город", preferredStyle: .alert)
            let decide = UIAlertAction(title: "Выбрать", style: .default, handler: AutoComplete(_:))
            firstCityAlert.addAction(decide)
            present(firstCityAlert, animated: true) {}
        }
    
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityStorage.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(identifier: "Weather") as? WeatherViewController else { return }
              vc.navigationItem.largeTitleDisplayMode = .never
        vc.coordinate = cityStorage[indexPath.row].coord
        vc.Name = cityStorage[indexPath.row].Name
              navigationController?.pushViewController(vc, animated: true)
        self.cityList.reloadData()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell") as UITableViewCell
        if cityStorage.isEmpty != true  {
            cell.textLabel?.text = cityStorage[indexPath.row].Name
        }
        return cell
    }
    @IBAction func AutoComplete(_ sender: Any) {
        let popoverContent = storyboard?.instantiateViewController(withIdentifier: "Complete") as! AutoCompleteViewController
        popoverContent.popoverPresentationController?.delegate = self
        popoverContent.delegate = self
        present(popoverContent, animated: true, completion: nil)
    }
    
}
extension ViewController: AutoCompleteViewControllerDelegate {
    func addInfo(Data: CityList) {
        self.dismiss(animated: true) {
            self.cityStorage.append(Data)
            self.cityList.reloadData()
        }
    }
}
