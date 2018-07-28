import UIKit
import JavaScriptCore

struct LessonID {
    let AID, CID, TP: Int
}

struct Lesson: Codable {
    let AID, CID, TP, status: Int
    let inTime: Bool
    let name, mark, title, type: String
}

struct Day: Codable {
    var date:String
    let lessons: [Lesson]
}

struct Days: Codable {
    let days: [Day]
}

class DiaryContentViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var haveLoadPermission = true
    var days = [JournalDay]()
    var weekToLoad: String?
    private var (PCLID, refreshControl) = ("", UIRefreshControl())
    var status: Status = .loading
    private var goToLogin = false
    var actionIndexPath = IndexPath(row: 0, section: 0)
    /// used to cancel URLSessionTask
    private var task: URLSessionTask?
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.deselectSelectedRow
        if !getString(forKey: "username").isEmpty && !getString(forKey: "password").isEmpty && haveLoadPermission && goToLogin {
            goToLogin = false
            loadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
        if getString(forKey: "username").isEmpty || getString(forKey: "password").isEmpty {
            goToLogin = true
            let loginVC = Login()
            loginVC.navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
            loginVC.modalTransitionStyle = .coverVertical
            present(loginVC)
        } else if haveLoadPermission {
            impactFeedback()
            loadData()
        } else {
            status = .canceled
            tableView.reloadData()
        }
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        refreshControl.addTarget(self, action: #selector(loadData), for:  .valueChanged)
        tableView.addSubview(refreshControl)
        automaticallyAdjustsScrollViewInsets = false
        //        bottomConstraint.setBottomConstraint
    }
    
    @objc private func loadData() {
        let sessionName = UserDefaults.standard.value(forKey: "sessionName") as? String ?? ""
        let cookie = UserDefaults.standard.value(forKey: sessionName) as? String ?? ""
        guard !sessionName.isEmpty && !cookie.isEmpty else {
            print("No Authorization")
            return
        }
        let jsonData = try? JSONSerialization.data(withJSONObject: ["week": weekToLoad ?? "", "id": 11198])
        var request = URLRequest(url: URL(string: "http://77.73.26.195:8000/get_tasks_and_marks")!)
        request.httpMethod = "POST"
        
        request.setValue(sessionName, forHTTPHeaderField: "sessionName")
        request.setValue(cookie, forHTTPHeaderField: sessionName)
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil,
                let data = data,
                let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        self.status = .error
                        self.tableView.reloadData()
                    }
                    return
            }
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(Days.self, from: data) {
                    print(json)
                    self.days = json.days.map{ JournalDay(date: $0.date, lessons: $0.lessons.map{ JournalLesson($0) }) }
                    self.status = .successful
                    self.reloadTable()
                } else if data.count == 13,
                    let daysData = String(data: data, encoding: String.Encoding.utf8),
                    daysData == "{\"days\":null}" {
                    self.days.removeAll()
                    self.status = .successful
                    self.reloadTable()
                } else {
                    self.status = .error
                    self.reloadTable()
                }
            case 400:
                if let errorDescription = String(data: data, encoding: String.Encoding.utf8)  {
                    print(errorDescription)
                }
                self.status = .error
                self.reloadTable()
            default:
                self.status = .error
                self.reloadTable()
            }
            }.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? Details,
            let indexPath = self.tableView.indexPathForSelectedRow {
            destination.lesson = days[indexPath.section].getLesson(indexPath.row)
            destination.fullDate = days[indexPath.section].fullDate
            destination.detailType = .diary
            destination.diaryVC = self
        }
    }
    
    private func reloadTable() {
        DispatchQueue.main.async {
            self.refreshControl.stop
            self.tableView.reloadData()
        }
    }
    
}

// MARK: - DIARY TABLE VIEW
extension DiaryContentViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: TABLE VIEW SETUP
    func numberOfSections(in tableView: UITableView) -> Int { return days.isEmpty ? 1 : days.count }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return days.isEmpty ? 0 : days[section].count() }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DiaryCell
        
        let lesson = days[indexPath.section].getLesson(indexPath.row)
        let typeColor = lesson.color
        cell.StateIcon.isHidden = false
        if !lesson.inTime {
            cell.StateIcon.image = UIImage(named: "warn")
            cell.StateIcon.setImageBackgroundColor(UIColor(red: 219/255, green: 45/255, blue: 69/255, alpha: 1))
            cell.SubjectLabelConstraint.constant = 33
        } else {
            switch lesson.status {
            case 1:
                // new
                cell.SubjectLabelConstraint.constant = 33
                cell.StateIcon.image = UIImage(named: "dot")
                cell.StateIcon.setImageBackgroundColor(typeColor)
            case 2:
                // done
                cell.SubjectLabelConstraint.constant = 33
                cell.StateIcon.image = UIImage(named: "done")
                cell.StateIcon.setImageBackgroundColor(typeColor)
            default:
                // viewed
                cell.StateIcon.isHidden = true
                cell.SubjectLabelConstraint.constant = 11
            }
        }
        cell.DateLabel.text = " \(days[indexPath.section].date) "
        cell.DateLabel.layer.cornerRadius = 3
        cell.DateLabel.layer.masksToBounds = true
        cell.setSelection
        cell.SubjectLabel.text = lesson.subject
        cell.ExplainLabel.text = lesson.title
        cell.MarkLabel.text = lesson.mark
        cell.typeLine.backgroundColor = typeColor
        cell.typeLine.layer.backgroundColor = typeColor.cgColor
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "details")
    }
    
    //MARK: HEADER
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return section < days.count ? days[section].sectionDate : "" }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = UIColor(hex: "39393a")
        headerView.textLabel?.font = UIFont.systemFont(ofSize: 15)
        let borderBottom = CALayer(), borderTop = CALayer()
        let width = CGFloat(0.5)
        borderBottom.borderColor = UIColor.lightGray.withAlphaComponent(0.55).cgColor
        borderTop.borderColor = UIColor.lightGray.withAlphaComponent(0.55).cgColor
        borderBottom.frame = CGRect(x: 0, y: headerView.frame.size.height - width, width:  headerView.frame.size.width, height: 0.5)
        borderTop.frame = CGRect(x: 0, y: 0, width:  headerView.frame.size.width, height: 0.5)
        borderBottom.borderWidth = width
        borderTop.borderWidth = width
        headerView.layer.addSublayer(borderBottom)
        headerView.layer.addSublayer(borderTop)
        headerView.layer.masksToBounds = true
    }
    
    //MARK: FOOTER
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return days.isEmpty ? 35 : 0 }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard days.isEmpty else { return nil }
        switch status {
        case .loading: return self.view.loadingFooterView()
        case .error: return self.view.errorFooterView()
        default:
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 23))
            footerView.backgroundColor = UIColor.clear
            let footerLabel = UILabel(frame: CGRect(x: 0, y: 7, width: tableView.frame.size.width, height: 23))
            footerLabel.addProperties
            footerLabel.text = status == .successful ? "Заданий нет" : "Загрузка прервана"
            footerView.addSubview(footerLabel)
            return footerView
        }
    }
}

//MARK: - 3D Touch peek and pop
extension DiaryContentViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if #available(iOS 9.0, *) {
            guard let indexPath = tableView.indexPathForRow(at: location),
                let cell = tableView.cellForRow(at: indexPath),
                let detailVC = storyboard?.instantiateViewController(withIdentifier: "Details") as? Details else { return nil }
            actionIndexPath = indexPath
            detailVC.lesson = days[indexPath.section].getLesson(indexPath.row)
            detailVC.fullDate = days[indexPath.section].fullDate
            detailVC.detailType = .diary
            detailVC.diaryVC = self
            previewingContext.sourceRect = cell.frame
            return detailVC
        }
        return nil
    }
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit)
    }
}

class DiaryCell: UITableViewCell {
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let (color1, color2, color3) = (typeLine.backgroundColor, DateLabel.backgroundColor, StateIcon.backgroundColor)
        super.setSelected(selected, animated: animated)
        (typeLine.backgroundColor, DateLabel.backgroundColor, StateIcon.backgroundColor)  = (color1, color2, color3)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let (color1, color2, color3) = (typeLine.backgroundColor, DateLabel.backgroundColor, StateIcon.backgroundColor)
        super.setHighlighted(highlighted, animated: animated)
        (typeLine.backgroundColor, DateLabel.backgroundColor, StateIcon.backgroundColor)  = (color1, color2, color3)
    }
    
    @IBOutlet weak var SubjectLabel: UILabel!
    @IBOutlet weak var ExplainLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var MarkLabel: UILabel!
    @IBOutlet weak var typeLine: UIImageView!
    @IBOutlet weak var StateIcon: UIImageView!
    @IBOutlet weak var SubjectLabelConstraint: NSLayoutConstraint!
}

// MARK: - JournalDay
class JournalDay {
    private var lessons: [JournalLesson]
    let date, sectionDate, fullDate: String
    private static let fullMonths = ["января", "февраля", "марта", "апреля", "мая", "июня", "июля", "августа", "сентября", "октября", "ноября", "декабря"]
    private static let namesOfWeeks = ["Пн": "ПОНЕДЕЛЬНИК", "Вт": "ВТОРНИК", "Ср": "СРЕДА", "Чт": "ЧЕТВЕРГ", "Пт": "ПЯТНИЦА", "Сб": "СУББОТА", "Вс": "ВОСКРЕСЕНЬЕ"]
    
    init(date: String, lessons: [JournalLesson]) {
        self.lessons = lessons
        var components = date.components(separatedBy: ".")
        if components.count == 3 {
            if components[0][components[0].startIndex] == "0" { components[0].remove(at: components[0].startIndex) }
            let weekDay = components[2].components(separatedBy: " ").last!
            let index = Int(components[1])! - 1
            let date = JournalDay.fullMonths[index]
            self.date = "\(components[0]) \(date[..<date.index(date.startIndex, offsetBy: 3)]), \(weekDay)"
            sectionDate = JournalDay.namesOfWeeks[weekDay]!
            fullDate = "\(JournalDay.namesOfWeeks[weekDay]!.lowercased()), \(components[0]) \(JournalDay.fullMonths[index])"
        } else {
            self.date = "Неизвестная дата"
            sectionDate = self.date
            fullDate = self.date
        }
    }
    func count() -> Int { return lessons.count }
    func getLesson(_ index: Int) -> JournalLesson { return lessons[index] }
}

// MARK: - JournalLesson
class JournalLesson {
    let color :UIColor
    let status: Int
    let lessonID: LessonID
    let inTime, isHomework: Bool
    let subject, mark, title, workType: String
    
    init(_ lesson: Lesson) {
        lessonID = LessonID(AID: lesson.AID, CID: lesson.CID, TP: lesson.TP)
        status = lesson.status
        inTime = lesson.inTime
        subject = lesson.name
        mark = lesson.mark == "-" ? "" : lesson.mark
        title = lesson.title.capitalizeFirst
        isHomework = lesson.type == "Д"
        switch lesson.type {
        case "Д": self.workType = "Домашняя работа"
        color = UIColor(red: 228/255, green: 117/255, blue: 62/255, alpha: 1)
        case "О": self.workType = "Ответ на уроке"
        color = UIColor(red: 0, green: 170/255, blue: 150/255, alpha: 1)
        case "В": self.workType = "Срезовая работа"
        color = UIColor(red: 219/255, green: 45/255, blue: 69/255, alpha: 1)
        case "Л": self.workType = "Лабораторная работа"
        color = UIColor(red: 140/255, green: 97/255, blue: 166/255, alpha: 1)
        case "Н": self.workType = "Диктант"
        color = UIColor(red: 175/255, green: 192/255, blue: 108/255, alpha: 1)
        case "З": self.workType = "Зачет"
        color = UIColor(red: 60/255, green: 91/255, blue: 114/255, alpha: 1)
        case "П": self.workType = "Проект"
        color = UIColor(red: 226/255, green: 174/255, blue: 12/255, alpha: 1)
        case "Ч": self.workType = "Сочинение"
        color = UIColor(red: 31/255, green: 175/255, blue: 208/255, alpha: 1)
        case "Т": self.workType = "Тестирование"
        color = UIColor(red: 39/255, green: 72/255, blue: 69/255, alpha: 1)
        case "К": self.workType = "Контрольная работа"
        color = UIColor(red: 219/255, green: 45/255, blue: 69/255, alpha: 1)
        case "И": self.workType = "Изложение"
        color = UIColor(red: 100/255, green: 34/255, blue: 40/255, alpha: 1)
        case "С": self.workType = "Самостоятельная работа"
        color = UIColor(red: 219/255, green: 45/255, blue: 69/255, alpha: 1)
        case "Р": self.workType = "Реферат"
        color = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1)
        case "А": self.workType = "Практическая работа"
        color = UIColor(red: 177/255, green: 179/255, blue: 215/255, alpha: 1)
        default: self.workType = "Неизвестно"
        color = .black
        }
    }
}
