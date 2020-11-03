//
//  StationDetailViewController.swift
//  TaiwanRailway
//
//  Created by anny on 2020/10/28.
//  Copyright © 2020 anny. All rights reserved.
//

import UIKit

class StationDetailViewController: UIViewController {

    var station: Station?
    var stationID = ""
    var stationName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let station = station{
            stationName = station.StationName.Zh_tw
            stationID = station.StationID
            navigationItem.title = stationName + "車站"
        }
    }
    
    @IBAction func reloadData(_ sender: UIBarButtonItem) {
        let reloadNorth = NorthTrainViewController()
        let reloadSouth = SouthTrainViewController()
        reloadNorth.stationID = stationID
        reloadSouth.stationID = stationID
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          // 取消 cell 的選取狀態
          tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let north = segue.destination as? NorthTrainViewController, let stationData = station{
            north.station = stationData
        }
        
        if let south = segue.destination as? SouthTrainViewController, let stationData = station{
            south.station = stationData
        }
    }
    
    // 發生錯誤警視窗
    func showAlert(title:String){
        let alert = UIAlertController(title: title, message: "請稍後再試！", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


