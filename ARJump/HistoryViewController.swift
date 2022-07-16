//
//  HistoryViewController.swift
//  ARJump
//
//  Created by 闫润邦 on 2022/7/16.
//

import UIKit
import CoreMedia

class HistoryViewController: UIViewController {
    var storage: Storage!
    var tableView = UITableView()
    var histories: [History]!
    var scoreUpToggle = false
    var timeUpToggle = false
    let reuseIdentifier = "History-Cell"
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "排行榜"
        configureTableView()
        
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 40
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        histories = storage.fetchHistories(withSortKey: "score", up: false)
    }
}

extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "哒咩", message: "戳疼我啦！", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "对不起🧎‍♂️", style: .destructive)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
}

extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = indexPath.item
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! HistoryTableViewCell
        cell.setup(withScore: Int(histories[id].score), time: histories[id].time!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        let scoreBtn = UIButton(type: .system)
        scoreBtn.translatesAutoresizingMaskIntoConstraints = false
        scoreBtn.backgroundColor = .systemBlue
        scoreBtn.addTarget(self, action: #selector(sortByScore), for: .touchUpInside)
        scoreBtn.setTitle("按得分排序", for: .normal)
        scoreBtn.setTitleColor(.white, for: .normal)
        headerView.addSubview(scoreBtn)
        scoreBtn.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        scoreBtn.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        scoreBtn.widthAnchor.constraint(equalToConstant: view.bounds.width / 3).isActive = true
        scoreBtn.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        
        let timeBtn = UIButton(type: .system)
        timeBtn.translatesAutoresizingMaskIntoConstraints = false
        timeBtn.backgroundColor = .darkGray
        timeBtn.addTarget(self, action: #selector(sortByScore), for: .touchUpInside)
        timeBtn.setTitle("按时间排序", for: .normal)
        timeBtn.setTitleColor(.white, for: .normal)
        headerView.addSubview(timeBtn)
        timeBtn.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        timeBtn.leadingAnchor.constraint(equalTo: scoreBtn.trailingAnchor).isActive = true
        timeBtn.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        timeBtn.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        
        
        return headerView
    }
    
    @objc func sortByScore() {
        scoreUpToggle = !scoreUpToggle
        histories = storage.fetchHistories(withSortKey: "score", up: scoreUpToggle)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    @objc func sortByTime() {
        timeUpToggle = !timeUpToggle
        histories = storage.fetchHistories(withSortKey: "time", up: timeUpToggle)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
