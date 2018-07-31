//
//  TodayViewController.swift
//  Shedule
//
//  Created by Arthur on 31.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showMoreButton: UIButton!
    
    @IBAction func showMoreLesson(_ sender: UIButton) {
        self.tableView.reloadData()
        if sender.isSelected{
            self.tableViewHeightConstraint?.constant = cell_height
            lessons[0] = String(Int(cell_height))
            sender.isSelected = false
        }
        else{
            self.tableViewHeightConstraint?.constant = cell_height * CGFloat(self.lessons.count)
            lessons[0] = String(Int(cell_height * CGFloat(self.lessons.count)))
            sender.isSelected = true
        }
    }
    var lessons = ["Lesson 1", "Lesson 2", "Lesson 3", "Lesson 4", "Lesson 5", "Lesson 6", "Lesson 7"]
    let cell_height: CGFloat = 36
    private var tableViewHeightConstraint : NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
        if #available(iOSApplicationExtension 10.0, *){
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
            self.showMoreButton.removeFromSuperview()
        }
        else{
            self.tableViewHeightConstraint = NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: cell_height)
            let refreshButtonHeightConstraint = NSLayoutConstraint(item: self.showMoreButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 44)
            NSLayoutConstraint.activate([tableViewHeightConstraint!, refreshButtonHeightConstraint])
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TodayViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Блядь")
        return lessons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.textLabel?.text = lessons[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return cell_height
    }
}

extension TodayViewController: NCWidgetProviding{
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets{
        return UIEdgeInsets.zero
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize){
        if activeDisplayMode == .expanded{
            let full_height: CGFloat = CGFloat(self.lessons.count) * cell_height
            preferredContentSize = CGSize(width: 0.0, height: full_height)
        }
        else{
            preferredContentSize = maxSize
        }
    }
}
