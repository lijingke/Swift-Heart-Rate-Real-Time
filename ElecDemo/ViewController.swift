//
//  ViewController.swift
//  ElecDemo
//
//  Created by NhatHM on 8/9/19.
//  Copyright © 2019 GST.PID. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private var dataSource: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(receivedHeartRateNoti(noti: )), name: NSNotification.Name("ReceivedHeartRate"), object: nil)
        heartRateLabel.text = "Heart Rate"
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        WorkoutTracking.shared.authorizeHealthKit()
        WorkoutTracking.shared.observerHeartRateSamples()
        WatchKitConnection.shared.delegate = self
    }
    
    private func setupUI() {
        view.addSubview(heartRateLabel)
        view.addSubview(historyLabel)
        view.addSubview(tableView)
        heartRateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.left.right.equalToSuperview()
        }
        historyLabel.snp.makeConstraints { make in
            make.top.equalTo(heartRateLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(historyLabel.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private var timeStamp: Int = 0
    
    lazy var heartRateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var historyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "历史记录时间"
        return label
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    @objc func receivedHeartRateNoti(noti: Notification ) {
        print(noti)
        DispatchQueue.main.async {
            guard let heartRate = noti.object as? Double else { return }
            let info = "当前心率为：\(heartRate)\n获取时间：\(SXDateTool.getCurrentTime(timeFormat: .YYYYMMDDHHMMSSsss))"
            self.heartRateLabel.text = info
            let historyInfo = "\(SXDateTool.getCurrentTime(timeFormat: .YYYYMMDDHHMMSSsss)) 心率：\(heartRate)"
            self.dataSource.insert(historyInfo, at: 0)
            self.tableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let info = dataSource[indexPath.row]
        cell.textLabel?.text = info
        return cell
    }
    
    
}

extension ViewController: UITableViewDelegate {
    
}

extension ViewController: WatchKitConnectionDelegate {
    func didFinishedActiveSession() {
        WatchKitConnection.shared.sendMessage(message: ["username" : "nhathm" as AnyObject])
    }
}
