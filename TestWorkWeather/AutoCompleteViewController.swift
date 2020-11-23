//
//  AutoCompleteViewController.swift
//  TestWorkWeather
//
//  Created by Дмитрий Жучков on 20.11.2020.
//
import UIKit
import MapKit
import RealmSwift
protocol AutoCompleteViewControllerDelegate {
    func addInfo(Data: CityList)
}
class City: Object {
    @objc dynamic var Name: String? = "None"
    @objc dynamic var  Long:Double  = 0.0
    @objc dynamic var  Lati:Double  = 0.0
    
}
class AutoCompleteViewController: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var cityAutoComplete: UISearchBar!
    @IBOutlet weak var notesTableView: UITableView!
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var delegate: AutoCompleteViewControllerDelegate?
    let realm = try! Realm()
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCompleter.delegate = self
        cityAutoComplete.delegate = self
        notesTableView.dataSource = self
        notesTableView.delegate = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  }

extension AutoCompleteViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchCompleter.queryFragment = searchText
    }
}

extension AutoCompleteViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        notesTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}

extension AutoCompleteViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
}
extension AutoCompleteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let completion = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            let coordinate:CLLocationCoordinate2D
            coordinate = (response?.mapItems[0].placemark.coordinate)!
            let info = CityList(Name: searchRequest.naturalLanguageQuery, coord: coordinate)
            let data = City()
            var flag = 0
            let proverka = self.realm.objects(City.self)
            if proverka.count != 0 {
            for n in 0...proverka.count-1 {
                if proverka[n].Name == searchRequest.naturalLanguageQuery {
                    flag = 1
                }
            }
            }
            if flag == 0 {
            data.Name = searchRequest.naturalLanguageQuery
            data.Long = coordinate.longitude
            print(coordinate.longitude)
            data.Lati = coordinate.latitude
            print(coordinate.latitude)
            self.delegate?.addInfo(Data:info)
            try! self.realm.write {
                self.realm.add(data)
            }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        dismiss(animated: true, completion: nil)
}
}
