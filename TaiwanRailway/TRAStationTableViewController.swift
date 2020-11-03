//
//  TRAStationTableViewController.swift
//  TaiwanRailway
//
//  Created by anny on 2020/10/27.
//  Copyright © 2020 anny. All rights reserved.
//

import UIKit

class TRAStationTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var searchController: UISearchController?
    var stations = [Station]()
    var searchStations = [Station]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 讀取Stations
        if let stations = Station.loadFromFile() {
            self.stations = stations
        }

        settingSearchController()
        downloadData()
    }
    
    func downloadData(){
        let url = URL(string: "https://ptx.transportdata.tw/MOTC/v2/Rail/TRA/Station?$select=StationID%2C%20StationName%2C%20StationPosition%2C%20StationClass&$orderby=StationID&$format=JSON")!
        var request = URLRequest(url: url)
        request.setValue(xdate, forHTTPHeaderField: "x-date")
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let loadedData = data {
                do{
                    let stationData = try JSONDecoder().decode([Station].self, from: loadedData)
                    self.stations = stationData
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                    //寫入Stations資料 將清單存到手機中
                    Station.saveToFile(stations: self.stations)
                }catch{
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }

    func settingSearchController(){
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        navigationItem.searchController = searchController
        // 在搜尋列中 按下 table view 可以換頁(預設為true 不能按下 所以要設成false)
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "搜尋火車站"
        searchController?.searchBar.tintColor = .red
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text{
            searchStations = stations.filter { (name) -> Bool in
                return name.StationName.Zh_tw.contains(searchText)
            }
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController?.isActive == true{
            return searchStations.count
        }else{
            return stations.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if searchController?.isActive == true{
            cell.textLabel?.text = searchStations[indexPath.row].StationName.Zh_tw
        }else{
            cell.textLabel?.text = stations[indexPath.row].StationName.Zh_tw
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // 選到的車站傳給下一頁
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StationDetail"{
            if let detail = segue.destination as? StationDetailViewController, let row = tableView.indexPathForSelectedRow?.row{
                if searchController?.isActive == true{
                    detail.station = searchStations[row]
                }else{
                    detail.station = stations[row]
                }
            }
        }
    }
}
