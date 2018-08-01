//
//  TodayViewController.swift
//  Shedule
//
//  Created by Kate on 31.07.2018.
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
            sender.isSelected = false
        }
        else{
            self.tableViewHeightConstraint?.constant = cell_height * CGFloat(self.lessons.count)
            sender.isSelected = true
        }
    }
    var lessons = ["Алгебра", "Английский язык", "Испанский язык", "Физическая культура", "География", "Лингвистика", "Информатика"]
    var times = ["08:00 - 08:45", "09:00 - 09:45", "10:00 - 10:45", "11:00 - 11:45", "12:00 - 12:45", "13:00 - 13:45", "14:00 - 14:45"]
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
        return lessons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CustomCell(lesson: lessons[indexPath.row], time_of_lesson: times[indexPath.row], width: tableView.frame.width, height: cell_height, margin: 15)
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


class CustomCell: UITableViewCell {
    var lesson_label: UILabel!
    var time_label: UILabel!
    
    init(lesson: String, time_of_lesson: String, width: CGFloat, height: CGFloat, margin: CGFloat) {
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        lesson_label = UILabel(frame: CGRect(x: margin, y: 0, width: width*0.6-margin, height: height))
        time_label = UILabel(frame: CGRect(x: width*0.6, y: 0, width: width*0.4-margin, height: height))
        lesson_label.textAlignment = .left
        time_label.textAlignment = .right
        lesson_label.text = lesson
        time_label.text = time_of_lesson
        if Int(width) < 320{
            lesson_label.font = UIFont(name: "HelveticaNeue", size: 14)
            time_label.font = UIFont(name: "HelveticaNeue-Light", size:  14)
        }else{
            lesson_label.font = UIFont(name: "HelveticaNeue", size: 16)
            time_label.font = UIFont(name: "HelveticaNeue-Light", size:  16)
        }
        addSubview(lesson_label)
        addSubview(time_label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
}
