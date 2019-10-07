//
//  FastingLegendTableView.swift
//  ponomar
//
//  Created by Alexey Smirnov on 10/7/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit

public class FastingLegendTableView: UITableViewController {
    let fastingTypes : [FastingModel] = (FastingModel.fastingLevel == .monastic) ? FastingModel.monasticTypes : FastingModel.laymenTypes
    let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")

    public init() {
        super.init(nibName: nil, bundle: nil)
    }
        
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "#FFEBCD")

        let backButton = UIBarButtonItem(image: UIImage(named: "close", in: toolkit, compatibleWith: nil)!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(close))
        
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func close() {
        navigationController?.popViewController(animated: true)
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fastingTypes.count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCell = tableView.dequeueReusableCell()
        let fasting = fastingTypes[indexPath.row]
        
        cell.title.text = fasting.descr
        cell.icon.backgroundColor = fasting.color
        cell.backgroundColor = .clear
        
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

}
