//
//  CommonViewController.swift
//  XYSegmentView
//
//  Created by 渠晓友 on 2022/2/7.
//

import UIKit

class CommonViewController: UIViewController {
    
    let demoTitles: [String] = ["一行代码看效果"]
    let count = arc4random_uniform(15)
    lazy var tableView: UITableView = {
        let tableview = UITableView(frame: .zero, style: .plain)
        view.addSubview(tableview)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.backgroundColor = UIColor.randomColor()
        return tableview
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.randomColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.frame = view.bounds
        
//        print("当期ContentVc.index = \(currentSegmentIndex)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("当期ContentVc.index = \(currentSegmentIndex)")
        
        print("基础信息 = \(userInfo)")
    }

}

extension CommonViewController: XYSegmentConfigProtocol {}


extension CommonViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if userInfo.isEmpty {
            return Int(count)
        }
        return demoTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell?.accessoryType = .disclosureIndicator
        }
        
        if userInfo.isEmpty {
            cell?.textLabel?.text = "第 \(indexPath.row) 个"
        }else{
            cell?.textLabel?.text = demoTitles[indexPath.row]
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if !userInfo.isEmpty {
            let detailVC = DemoViewController()
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
