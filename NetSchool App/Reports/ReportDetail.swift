import Foundation

enum ReportType {
    case middleMark, dinamicMiddleMark, reportWithSubjects, parentLetter, undefined
}

class ReportDetails: UIViewController {
    
    var reportVC = Reports()
    var reportType: ReportType = .undefined
    fileprivate var selectedIndex = [0,0]
    fileprivate let tableView = UITableView(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAndSetupTableView()
        self.navigationItem.rightBarButtonItem =  UIBarButtonItem(title: "Далее", style: .done , target: self, action: #selector(getReport))
    }
    
    @objc private func getReport() {
        switch reportType {
        case .middleMark:
            let data = """
            {
            "data" : [
            {
            "id" : "1",
            "subject" : "Английский язык",
            "mark_of_class" : "4.92",
            "mark_of_student" : "5"
            },
            {
            "id" : "2",
            "subject" : "Информатика",
            "mark_of_class" : "4.16",
            "mark_of_student" : "3.67"
            },
            {
            "id" : "3",
            "subject" : "Испанский язык",
            "mark_of_class" : "5.57",
            "mark_of_student" : "6.75"
            },
            {
            "id" : "3",
            "subject" : "Итальянский язык",
            "mark_of_class" : "5.82",
            "mark_of_student" : ""
            },
            {
            "id" : "3",
            "subject" : "Литература",
            "mark_of_class" : "4.45",
            "mark_of_student" : "4"
            },
            {
            "id" : "3",
            "subject" : "Немецкий язык",
            "mark_of_class" : "5",
            "mark_of_student" : ""
            },
            {
            "id" : "3",
            "subject" : "Русский язык",
            "mark_of_class" : "4.25",
            "mark_of_student" : "3.5"
            },
            {
            "id" : "3",
            "subject" : "Французский язык",
            "mark_of_class" : "6",
            "mark_of_student" : ""
            },
            {
            "id" : "3",
            "subject" : "Алгебра",
            "mark_of_class" : "5.17",
            "mark_of_student" : "4.75"
            },
            {
            "id" : "3",
            "subject" : "Геометрия",
            "mark_of_class" : "5.31",
            "mark_of_student" : "5.5"
            },
            {
            "id" : "3",
            "subject" : "Биология",
            "mark_of_class" : "4.81",
            "mark_of_student" : "4.5"
            },
            {
            "id" : "3",
            "subject" : "География",
            "mark_of_class" : "5.3",
            "mark_of_student" : "5.67"
            },
            {
            "id" : "3",
            "subject" : "Физика",
            "mark_of_class" : "4.59",
            "mark_of_student" : "4.75"
            },
            {
            "id" : "3",
            "subject" : "Финансовая литература",
            "mark_of_class" : "5.7",
            "mark_of_student" : "5.33"
            },
            {
            "id" : "3",
            "subject" : "История",
            "mark_of_class" : "5.61",
            "mark_of_student" : "5.5"
            },
            {
            "id" : "3",
            "subject" : "ИЗО",
            "mark_of_class" : "5.15",
            "mark_of_student" : ""
            },
            {
            "id" : "3",
            "subject" : "Музыка",
            "mark_of_class" : "5.83",
            "mark_of_student" : ""
            },
            {
            "id" : "3",
            "subject" : "Физкультура",
            "mark_of_class" : "5.49",
            "mark_of_student" : "6.5"
            },
            {
            "id" : "3",
            "subject" : "Дизайн",
            "mark_of_class" : "5.78",
            "mark_of_student" : "6"
            }
            ]
            }
            """
            openTableFromJSON(data, type: 1)
        case .dinamicMiddleMark:
            if selectedIndex[0] == 0 {
                let data = """
                {
                "data" : [
                {
                "id" : "1",
                "subject" : "Russian",
                "mark_of_class" : "1",
                "mark_of_student" : "2"
                },
                {
                "id" : "2",
                "subject" : "English",
                "mark_of_class" : "3",
                "mark_of_student" : "4"
                },
                {
                "id" : "3",
                "subject" : "Biology",
                "mark_of_class" : "5",
                "mark_of_student" : "6"
                }
                ]
                }
                """
                openTableFromJSON(data, type: 1)
            } else {
                let data = """
                {
                "data" : [
                {
                "date" : "13.07",
                "amount_of_student" : "1",
                "mark_of_student" : "2",
                "amount_of_class" : "3",
                "mark_of_class" : "4"
                },
                {
                "date" : "14.07",
                "amount_of_student" : "5",
                "mark_of_student" : "6",
                "amount_of_class" : "7",
                "mark_of_class" : "8"
                },
                {
                "date" : "15.07",
                "amount_of_student" : "9",
                "mark_of_student" : "10",
                "amount_of_class" : "11",
                "mark_of_class" : "12"
                }
                ]
                }
                """
                openTableFromJSON(data, type: 3)
            }
        case .reportWithSubjects:
            let data = """
            {
            "work" : [
            {
            "type" : "Домашняя работа",
            "theme" : "p5, N1:j),m),s),u) + N2:q),w) + N3:c),d)",
            "date" : "12.09.2017",
            "mark" : "3"
            },
            {
            "type" : "Срезовая работа",
            "theme" : "Classwork. To write a frequency table and then to draw frequency histogram and polygon",
            "date" : "15.09.2017",
            "mark" : "5"
            },
            {
            "type" : "Домашняя работа",
            "theme" : "Intrernational Mathematics 3, p85, N3:s),t)+N4:n),o)+N5:o),p)+N6:h),i)",
            "date" : "03.10.2017",
            "mark" : "3"
            },
            {
            "type" : "Домашняя работа",
            "theme" : "Algebra-Geometry 7: p22, N4:e), N5:b), N6:d),e),f),g),i), p23, N8:h)",
            "date" : "05.10.2017",
            "mark" : "4"
            },
            {
            "type" : "Срезовая работа",
            "theme" : "(A)Test on equations and algebraic expressions",
            "date" : "06.10.2017",
            "mark" : "6"
            },
            {
            "type" : "Домашняя работа",
            "theme" : "International Maths 3, p350, N3:a),d)",
            "date" : "12.10.2017",
            "mark" : "1"
            },
            {
            "type" : "Домашняя работа",
            "theme" : "book: Algebra-Geometry 7, p62:N6, N9, N11, N13+Deadline for task:'What does y=mx+c tell us    ",
            "date" : "17.10.2017",
            "mark" : "5"
            }
            ]
            }
            """
            openTableFromJSON(data, type: 4)
        case .parentLetter:
            let data = """
            {
            "data" : [
            {
            "lesson" : "Russian",
            "mark_info" : [
            {
            "mark" : "8",
            "count" : "4"
            },
            {
            "mark" : "7",
            "count" : "6"
            },
            {
            "mark" : "6",
            "count" : "3"
            },
            {
            "mark" : "5",
            "count" : "8"
            },
            {
            "mark" : "4",
            "count" : "3"
            },
            {
            "mark" : "3",
            "count" : "5"
            },
            {
            "mark" : "2",
            "count" : "0"
            },
            {
            "mark" : "1",
            "count" : "1"
            }
            ],
            "middle" : "7",
            "final" : "5"
            }
            ]
            }
            """
            openTableFromJSON(data, type: 6)
        default:
            ()
        }
    }
    
    private func createAndSetupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "сell")
        view.addSubview(tableView)
        tableView.addConstraints(view: view, topConstraintConstant: -(navigationController?.navigationBar.frame.height ?? 0))
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }
    
}

extension ReportDetails: UITableViewDelegate, UITableViewDataSource {
    
    private static let middleMarkTitles = ["Итоговые отметки","Срезовые работы","Итоговые отметки и срезовые работы"]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return reportType == .parentLetter ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch reportType {
        case .middleMark, .dinamicMiddleMark: return 3
        case .reportWithSubjects: return 10
        case .parentLetter: return section == 0 ? 2 : 4
        default: ()
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "сell", for: indexPath) as UITableViewCell
        switch reportType {
        case .middleMark, .dinamicMiddleMark:
            cell.textLabel?.text = ReportDetails.middleMarkTitles[indexPath.row]
            
        case .reportWithSubjects:
            let data = ["Алгебра","Биология","Химия","Физика","Английский язык","Физкультура","Литература","Обществознание","История","Русский язык"]
            cell.textLabel?.text = data[indexPath.row]
        case .parentLetter:
            let data = [
                ["Текущие оценки за период","Итоги учебного периода"],
                ["1 четверть","2 четверть","3 четверть","4 четверть"]
            ]
            cell.textLabel?.text = data[indexPath.section][indexPath.row]
        default: ()
        }
        cell.accessoryType = indexPath.row == selectedIndex[indexPath.section] ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let oldIndex = selectedIndex[indexPath.section]
        if let cell = tableView.cellForRow(at: IndexPath(row: oldIndex, section: indexPath.section)) {
            cell.accessoryType = .none
            if oldIndex != indexPath.row {
                selectionFeedback()
            }
        }
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        tableView.deselectSelectedRow
        selectedIndex[indexPath.section] = indexPath.row
    }
}


















