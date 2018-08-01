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

class DiaryContentViewController: ViewControllerErrorHandler {
    
    @IBOutlet weak var tableView: UITableView!
    var haveLoadPermission = true
    var days = [JournalDay]()
    var weekToLoad: String?
    private var PCLID = ""
    var actionIndexPath = IndexPath(row: 0, section: 0)
    /// used to cancel URLSessionTask
    private var task: URLSessionTask?    
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.deselectSelectedRow
        table = tableView
        if !getString(forKey: "username").isEmpty && !getString(forKey: "password").isEmpty && haveLoadPermission && goToLogin {
            goToLogin = false
            load()
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
            load()
        } else {
            status = .canceled
            tableView.reloadData()
        }
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        refreshControl.addTarget(self, action: #selector(load), for:  .valueChanged)
        tableView.addSubview(refreshControl)
        automaticallyAdjustsScrollViewInsets = false
//        bottomConstraint.setBottomConstraint
    }
    
    @objc override func load() {
        let jsonData = try? JSONSerialization.data(withJSONObject: ["week": weekToLoad ?? "", "id": 11198])
        loadData(jsonData: jsonData, method: "get_tasks_and_marks", jsonStruct: Days.self) { data, json in
            guard let json = json as? Days else {
                self.status = .error
                self.reloadTable()
                return
            }
            self.days = json.days.map{ JournalDay(date: $0.date, lessons: $0.lessons.map{ JournalLesson($0) }) }
            if self.days.count == 1 && self.days[0].count() == 1 && self.days[0].getLesson(0).title.isEmpty {
                self.days.removeAll()
            }
            self.status = .successful
            self.reloadTable()
        }
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
}

// MARK: - DIARY TABLE VIEW
extension DiaryContentViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: TABLE VIEW SETUP
    func numberOfSections(in tableView: UITableView) -> Int { return days.isEmpty ? 1 : days.count }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return days.isEmpty ? 0 : days[section].count() }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DiaryCell
        let lesson = days[indexPath.section].getLesson(indexPath.row)
        let typeColor = lesson.getColor()
        cell.secondStateIcon.isHidden = lesson.inTime
        switch lesson.status {
        case 1:
            // new
            cell.firstStateIcon.isHidden = false
            cell.subjectLabelConstraint.constant = 26
            cell.firstStateIcon.image = UIImage(named: "newDot")
            cell.firstStateIcon.setImageBackgroundColor(typeColor)
            cell.backgroundColor = UIColor(red: 239/255, green: 238/255, blue: 244/255, alpha: 1)
        case 0:
            // done
            cell.subjectLabelConstraint.constant = 26
            cell.firstStateIcon.image = UIImage(named: "done")
            cell.firstStateIcon.setImageBackgroundColor(typeColor)
            cell.firstStateIcon.isHidden = false
            cell.backgroundColor = .white
        default:
            // viewed
            cell.firstStateIcon.isHidden = true
            cell.subjectLabelConstraint.constant = 8
            cell.backgroundColor = .white
        }
        cell.DateLabel.text = " \(days[indexPath.section].date) "
        cell.DateLabel.layer.cornerRadius = 3
        cell.DateLabel.layer.masksToBounds = true
        cell.DateLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
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
        case .error: return errorFooterView()
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
        let (color1, color2, color3) = (typeLine.backgroundColor, DateLabel.backgroundColor, firstStateIcon.backgroundColor)
        super.setSelected(selected, animated: animated)
        (typeLine.backgroundColor, DateLabel.backgroundColor, firstStateIcon.backgroundColor)  = (color1, color2, color3)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let (color1, color2, color3) = (typeLine.backgroundColor, DateLabel.backgroundColor, firstStateIcon.backgroundColor)
        super.setHighlighted(highlighted, animated: animated)
        (typeLine.backgroundColor, DateLabel.backgroundColor, firstStateIcon.backgroundColor)  = (color1, color2, color3)
    }
    
    @IBOutlet weak var SubjectLabel: UILabel!
    @IBOutlet weak var ExplainLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var MarkLabel: UILabel!
    @IBOutlet weak var typeLine: UIImageView!
    @IBOutlet weak var firstStateIcon: UIImageView!
    @IBOutlet weak var subjectLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondStateIcon: UIImageView!
    
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
    private let color :Color
    let status: Int
    let lessonID: LessonID
    let inTime, isHomework: Bool
    let subject, mark, title, workType: String
    
    private enum Color {
        case orange, blue, purple, grey, yellow, undefined
    }
    
    private static let colors: [Color:UIColor] = [
        .orange : UIColor(red: 228/255, green: 117/255, blue: 62/255, alpha: 1),
        .blue: UIColor(red: 31/255, green: 175/255, blue: 208/255, alpha: 1),
        .purple: UIColor(red: 140/255, green: 97/255, blue: 166/255, alpha: 1),
        .grey: UIColor(red: 39/255, green: 72/255, blue: 69/255, alpha: 1),
        .yellow: UIColor(red: 226/255, green: 174/255, blue: 12/255, alpha: 1)
    ]
    
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
        color = .orange
        case "О": self.workType = "Ответ на уроке"
        color = .grey
        case "В": self.workType = "Срезовая работа"
        color = .purple
        case "Л": self.workType = "Лабораторная работа"
        color = .yellow
        case "Н": self.workType = "Диктант"
        color = .blue
        case "З": self.workType = "Зачет"
        color = .purple
        case "П": self.workType = "Проект"
        color = .yellow
        case "Ч": self.workType = "Сочинение"
        color = .blue
        case "Т": self.workType = "Тестирование"
        color = .purple
        case "К": self.workType = "Контрольная работа"
        color = .purple
        case "И": self.workType = "Изложение"
        color = .blue
        case "С": self.workType = "Самостоятельная работа"
        color = .purple
        case "Р": self.workType = "Реферат"
        color = .yellow
        case "А": self.workType = "Практическая работа"
        color = .purple
        default: self.workType = "Неизвестно"
        color = .undefined
        }
    }
    
    func getColor() -> UIColor {
        return JournalLesson.colors[color] ?? .black
    }
}
