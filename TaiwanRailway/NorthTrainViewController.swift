//
//  NorthTrainViewController.swift
//  TaiwanRailway
//
//  Created by anny on 2020/10/28.
//  Copyright © 2020 anny. All rights reserved.
//

import UIKit
import AudioToolbox

class NorthTrainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var station: Station?
    var train = [StationDetail]()
    var stationID = ""
    var isDownloading = false
    let stationDetail = StationDetailViewController()
    
    @IBOutlet weak var mytableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let station = station{
            stationID = station.StationID
            print("北上ID: \(stationID) 車站:\(station.StationName.Zh_tw)------------")
        }
        downloadData()
    }
    
    func reload() {
        if isDownloading == false{
            downloadData()
        }else{
            stationDetail.showAlert(title: "資料還在跑喔～～～")
        }
    }
    
    func downloadData(){
        let url = URL(string: "https://ptx.transportdata.tw/MOTC/v2/Rail/TRA/LiveBoard/Station/\(stationID)?$format=JSON")!
        var request = URLRequest(url: url)
        request.setValue(xdate, forHTTPHeaderField: "x-date")
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil{
                let errorCode = (error! as NSError).code
                if errorCode == -1009{
                    DispatchQueue.main.async {
                        self.stationDetail.showAlert(title: "目前沒有連結網路")
                    }
                }else{
                    DispatchQueue.main.async {
                        self.stationDetail.showAlert(title: "發生錯誤！！！")
                    }
                }
                self.isDownloading = false
                return
            }
            if let loadedData = data {
                do{
                    print("北上 ---- downloadData------------")
                    let stationData = try JSONDecoder().decode([StationDetail].self, from: loadedData)
                    // 判斷北上
                    for station in stationData{
                        if station.Direction == 0{
                            self.train.append(station)
                        }
                    }
                    DispatchQueue.main.async {
                        self.mytableView.reloadData()
                        AudioServicesPlayAlertSound(1000)
                    }
                }catch{
                    DispatchQueue.main.async {
                        self.stationDetail.showAlert(title: "發生錯誤！！！")
                    }
                    self.isDownloading = false
                }
            }else{
                DispatchQueue.main.async {
                    self.stationDetail.showAlert(title: "發生錯誤！！！")
                }
                self.isDownloading = false
            }
        }.resume()
        isDownloading = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return train.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StationDetailTableViewCell
        
        let timeString = train[indexPath.row].ScheduledDepartureTime
        let time = String(timeString.prefix(5))
        let attributedString = NSMutableAttributedString(string: time)
        attributedString.setAttributes([.foregroundColor: UIColor.systemBlue, .font:UIFont(name: "Chalkduster", size: 25.0)!], range: NSMakeRange(0, attributedString.length))
        cell.textLabel?.attributedText = attributedString
        
        let trainType = train[indexPath.row].TrainTypeName.Zh_tw.split(separator: "(")[0]
        cell.trainType_N.text = String(trainType)
        cell.endStation_N.text = train[indexPath.row].EndingStationName.Zh_tw
        
        let delay = train[indexPath.row].DelayTime
        cell.delay_N.layer.masksToBounds = true
        cell.delay_N.layer.cornerRadius = 10
        
        if delay > 0{
            cell.delay_N.backgroundColor = .systemPink
            cell.delay_N.text = "晚\(delay)分"
        }else{
            cell.delay_N.text = "準點"
        }
    
        return cell
    }
}
