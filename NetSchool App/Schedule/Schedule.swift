import UIKit

class Schedule: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    fileprivate var sheduleDays = [ScheduleDay]()
    fileprivate let days = ["ВОСКРЕСЕНЬЕ", "ПОНЕДЕЛЬНИК", "ВТОРНИК", "СРЕДА", "ЧЕТВЕРГ", "ПЯТНИЦА", "СУББОТА"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let json_data = """
        {
            "days": [
                {
                    "date": "29.07.2018",
                    "lessons": [
                        {
                            "start": "8.30",
                            "end": "9.15",
                            "name": "Английский язык",
                            "classroom": "каб. английского языка"
                        },
                        {
                            "start": "9.30",
                            "end": "10.15",
                            "name": "Информатика и ИКТ",
                            "classroom": "компьютерный класс"
                        }
                    ]
                },
                {
                    "date": "30.07.2018",
                    "lessons": [
                        {
                            "start": "8.30",
                            "end": "9.15",
                            "name": "Физика",
                            "classroom": "каб. физики"
                        },
                        {
                            "start": "9.30",
                            "end": "10.15",
                            "name": "История",
                            "classroom": "каб. истории"
                        }
                    ]
                },
                {
                    "date": "31.07.2018",
                    "lessons": [
                        {
                            "start": "8.30",
                            "end": "9.15",
                            "name": "Геометрия",
                            "classroom": "каб. математики"
                        },
                        {
                            "start": "9.30",
                            "end": "10.15",
                            "name": "Физическая культура",
                            "classroom": "спортзал №1"
                        }
                    ]
                },
                {
                    "date": "29.07.2018",
                    "lessons": [
                        {
                            "start": "8.30",
                            "end": "9.15",
                            "name": "Английский язык",
                            "classroom": "каб. английского языка"
                        },
                        {
                            "start": "9.30",
                            "end": "10.15",
                            "name": "Информатика и ИКТ",
                            "classroom": "компьютерный класс"
                        }
                    ]
                },
                {
                    "date": "30.07.2018",
                    "lessons": [
                        {
                            "start": "8.30",
                            "end": "9.15",
                            "name": "Физика",
                            "classroom": "каб. физики"
                        },
                        {
                            "start": "9.30",
                            "end": "10.15",
                            "name": "История",
                            "classroom": "каб. истории"
                        }
                    ]
                },
                {
                    "date": "31.07.2018",
                    "lessons": [
                        {
                            "start": "8.30",
                            "end": "9.15",
                            "name": "Геометрия",
                            "classroom": "каб. математики"
                        },
                        {
                            "start": "9.30",
                            "end": "10.15",
                            "name": "Физическая культура",
                            "classroom": "спортзал №1"
                        }
                    ]
                },
                {
                    "date": "31.07.2018",
                    "lessons": [
                        {
                            "start": "00:00",
                            "end": "23:59",
                            "name": "Праздник: Всемирный день рок-н-ролла",
                            "classroom": ""
                        },
                        {
                            "start": "00:00",
                            "end": "23:59",
                            "name": "Выходной день",
                            "classroom": ""
                        }
                    ]
                }
            ]
        }
        """
        let json = JSONParser(data:json_data, type: 9)
        self.sheduleDays = json.getParsedScheduleDays()
    }
    
    @objc private func showUsers(sender: AnyObject) {
        selectUsers(sender, self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        let students = getUsers()
        if students.count > 1 {
            self.navigationItem.leftBarButtonItem = createBarButtonItem(imageName: "users", selector: #selector(showUsers))
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
}

//MARK: - SCHEDULE TABLE VIEW
extension Schedule: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: TABLE VIEW SETUP
    func numberOfSections(in tableView: UITableView) -> Int { return sheduleDays.isEmpty ? 1 : sheduleDays.count }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return sheduleDays.isEmpty ? 0 : sheduleDays[section].getCount() }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SheduleCell
        cell.NowLabel.isHidden = true
        let day = sheduleDays[indexPath.section]
        cell.LessonStartLabel.text = day.getLessonStart(indexPath.row)
        cell.LessonEndLabel.text = day.getLessonEnd(indexPath.row)
        cell.AudienceLabel.text = day.getAudience(indexPath.row)
        cell.SubjectLabel.text = day.getSubject(indexPath.row)
        if day.getMinor(indexPath.row) {
            cell.line.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
            cell.SubjectLabel.textColor = .lightGray
        } else if indexPath.section == 0 {
            cell.SubjectLabel.textColor = .black
            let curDate = Date()
            let components = (NSCalendar.current as NSCalendar).components([.year, .month, .day], from: curDate)
            var dateComponents = DateComponents()
            dateComponents.year = components.year
            dateComponents.month = components.month
            dateComponents.day = components.day
            dateComponents.hour =  Int(day.getStartHour(indexPath.row))
            dateComponents.minute = Int(day.getStartMinute(indexPath.row))
            let userCalendar = Calendar.current
            var someDateTime = userCalendar.date(from: dateComponents)
            if someDateTime! < curDate {
                dateComponents.hour = Int(day.getEndHour(indexPath.row))
                dateComponents.minute = Int(day.getEndMinute(indexPath.row))
                someDateTime = userCalendar.date(from: dateComponents)
                if someDateTime! > curDate {
                    cell.NowLabel.text = "сейчас"
                    cell.NowLabel.textColor = UIColor.init(hex: "EA5E54")
                    cell.NowLabel.isHidden = false
                    cell.NowLabel.font = UIFont(name: "BloggerSans", size: 14) ?? .systemFont(ofSize: 14)
                }
            } else {
                if var delta = Calendar.current.dateComponents([.minute], from: curDate, to: someDateTime!).minute {
                    delta += 1
                    if delta < 60 {
                        cell.NowLabel.text = "через \(delta) мин"
                        cell.NowLabel.textColor = .gray
                        cell.NowLabel.isHidden = false
                        cell.NowLabel.font = UIFont(name: "BloggerSans", size: 12) ?? .systemFont(ofSize: 12)
                    }
                }
            }
            cell.line.backgroundColor = lightSchemeColor().withAlphaComponent(0.8)
        } else {
            cell.line.backgroundColor = lightSchemeColor().withAlphaComponent(0.8)
            cell.SubjectLabel.textColor = .black
        }
        return cell
    }
    
    //MARK: HEADER
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 35 }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "   СЕГОДНЯ" }
        if section == 1 { return "   ЗАВТРА" }
        let currentDateTime = Date().addingTimeInterval(Double(86400*section))
        let requestedComponents: NSCalendar.Unit = NSCalendar.Unit.weekday
        let dateTimeComponents = (Calendar.current as NSCalendar).components(requestedComponents, from: currentDateTime)
        return "   " + days[dateTimeComponents.weekday! - 1]
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        headerView.textLabel!.textColor = UIColor(hex: "424242")
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
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sheduleDays.isEmpty ? 35 : 0
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard sheduleDays.isEmpty else { return nil }
        return nil
//        switch status {
//        case .loading: return self.view.loadingFooterView()
//        case .error: return self.view.errorFooterView()
//        default: return nil
//        }
    }
}

class SheduleCell: UITableViewCell {
    @IBOutlet weak var LessonStartLabel: UILabel!
    @IBOutlet weak var LessonEndLabel: UILabel!
    @IBOutlet weak var AudienceLabel: UILabel!
    @IBOutlet weak var line: UIImageView!
    @IBOutlet weak var SubjectLabel: UILabel!
    @IBOutlet weak var NowLabel: UILabel!
}

// MARK: - Schedule Day
class ScheduleDay {
    private let lessons: [ScheduleLesson]
    init(lessons: [ScheduleLesson]) {
        self.lessons = lessons
    }
    func getMinor(_ index: Int) -> Bool { return lessons[index].minor }
    func getCount() -> Int { return lessons.count }
    func getLessonStart(_ index: Int) -> String { return lessons[index].getLessonStart() }
    func getLessonEnd(_ index: Int) -> String { return lessons[index].getLessonEnd() }
    func getSubject(_ index: Int) -> String { return lessons[index].subject }
    func getAudience(_ index: Int) -> String { return lessons[index].audience }
    
    func getStartHour(_ index: Int) -> String { return lessons[index].startHour }
    func getStartMinute(_ index: Int) -> String { return lessons[index].startMinute }
    func getEndHour(_ index: Int) -> String { return lessons[index].endHour }
    func getEndMinute(_ index: Int) -> String { return lessons[index].endMinute }
}

//MARK: - Schedule Lesson
class ScheduleLesson {
    let subject, audience, startHour, endHour, startMinute, endMinute: String
    let minor: Bool
    
    init(lessonTime: String, subject: String) {
        guard !subject.hasPrefix("Праздник") && !subject.hasPrefix("Каникулы") else {
            self.subject = String(subject[subject.index(subject.startIndex, offsetBy: 10)...])
            (startHour, startMinute, endHour, endMinute, minor, audience) = ("00", "00", "23", "59", true, "")
            return
        }
        let times = (try! NSRegularExpression(pattern: "\\d+"))
            .matches(in:lessonTime, range:NSMakeRange(0, lessonTime.utf16.count))
            .map{ (lessonTime as NSString).substring(with: $0.range) as String}
        guard times.count == 4 else {
            self.subject = "Ошибка загрузки"
            (startHour, startMinute, endHour, endMinute, minor, audience) = ("00", "00", "23", "59", true, "")
            return
        }
        (startHour, startMinute, endHour, endMinute) = (times[0], times[1], times[2], times[3])
        guard subject.hasPrefix("Урок") else {
            (self.subject, minor, audience) = (subject, true, "")
            return
        }
        let lesson = (try! NSRegularExpression(pattern: "(?<=\\[).*(?=\\])|(?<=Урок: ).*(?= \\[)"))
            .matches(in:subject, range:NSMakeRange(0, subject.utf16.count))
            .map{(subject as NSString).substring(with: $0.range) as String}
        guard lesson.count == 2 else {
            (self.subject, minor, audience) = (subject.removePart("Урок: "), false, "")
            return
        }
        self.subject = lesson[0]
        minor = false
        audience = ScheduleLesson.decipherAudience(lesson[1])
    }
    
    private static func decipherAudience(_ shortName: String) -> String {
        var audience = shortName.replacingOccurrences(of: "биол.", with: "биологии")
        audience = audience.replacingOccurrences(of: "геогр.", with: "географии")
        audience = audience.replacingOccurrences(of: "рус.яз.-", with: "русского языка ")
        audience = audience.replacingOccurrences(of: "англ.яз.-", with: "английского языка ")
        audience = audience.replacingOccurrences(of: "истор.", with: "истории")
        audience = audience.replacingOccurrences(of: "физ.", with: "физики")
        audience = audience.replacingOccurrences(of: "матем.-", with: "математики ")
        audience = audience.replacingOccurrences(of: "фр.яз.", with: "французского языка")
        audience = audience.replacingOccurrences(of: "исп. яз.", with: "испанского языка")
        audience = audience.replacingOccurrences(of: "спорт.", with: "спортивный ")
        audience = audience.replacingOccurrences(of: "комп. кл.", with: "компьютерный класс")
        return audience
    }
    
    func getLessonStart() -> String { return "\(startHour):\(startMinute)" }
    func getLessonEnd() -> String { return "\(endHour):\(endMinute)" }
}
