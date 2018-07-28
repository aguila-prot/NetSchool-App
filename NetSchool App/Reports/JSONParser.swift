import Foundation
class JSONParser {
    private let data: String
    private let inputData: Data
    private let decoder = JSONDecoder()
    private var result = [[String]]()
    private var rowHeights: [CGFloat] = []
    private var columnWidth: [CGFloat] = [70]
    private var status: Int
    private var sheduleDays: [ScheduleDay] = []
    
    init(data: String, type:Int) {
        self.status = 1
        self.data = data
        self.inputData = data.data(using: .utf8)!
        switch type {
        case 0: marks()
        case 1: middleMarks()
        case 2: dynamicMiddleMarksT()
        case 3: dynamicMiddleMarksSB()
        case 4: progress()
        case 5: classJournal()
        case 6: parentsLetter()
        case 7: attendanceAndProgress()
        case 8: parentsLetter(1)
        case 9: schedule_days()
        default: ()
        }
    }
    
    private func JSON_Error(){
        self.status = 1
    }
    
    private func updateMaxWidth(topic: String) {
        let components = topic.components(separatedBy: " ")
        for component in components {
            let length = component.size(withAttributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14.0)]).width
            columnWidth[0] = max(columnWidth[0], length)
        }
    }
    
    private func updateRowHeights(index: Int = 0, width: CGFloat) {
        rowHeights.removeAll()
        for row in result {
            let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 45))
            label.numberOfLines = 0
            let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
            label.attributedText = NSMutableAttributedString(string: row[index], attributes: attributes)
            label.sizeToFit()
            rowHeights.append(max(label.frame.height + 10, 45))
        }
    }
    private func schedule_days(){
        guard let json = try? decoder.decode(ScheduleClass.self, from: inputData) else {
            JSON_Error()
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        for i in json.days{
            _ = dateFormatter.date(from: i.date)
            var temp_lesson: [ScheduleLesson] = []
            for j in i.lessons{
                if j.classroom != ""{
                    temp_lesson.append(ScheduleLesson(lessonTime: j.start + "-" + j.end
                        , subject:"Урок: " + j.name + " [" +  j.classroom + "]"))
                }else{
                    temp_lesson.append(ScheduleLesson(lessonTime: j.start + "-" + j.end
                        , subject: j.name))
                }
            }
            sheduleDays.append(ScheduleDay(lessons: temp_lesson))
        }
    }
    func getParsedScheduleDays() -> [ScheduleDay]{
        return sheduleDays
    }
    
    private func marks() {
        guard let json = try? decoder.decode(Marks.self, from: inputData) else {
            JSON_Error()
            return
        }
        result.append(["Предмет", "Ⅰ", "Ⅱ", "Ⅲ", "Ⅳ", "Годовая", "Экзамен","Итоговая"])
        for row in json.table {
            result.append([row.subject, row.period1, row.period2, row.period3, row.period4, row.year, row.exam, row.final])
            updateMaxWidth(topic: row.subject)
        }
        updateRowHeights(width: columnWidth[0])
        columnWidth = [columnWidth[0]+10, 70, 70, 70, 70, 75, 75, 75]
    }
    
    private func middleMarks() {
        guard let json = try? decoder.decode(MiddleMarks.self, from: inputData) else {
            JSON_Error()
            return
        }
        result.append(["Предмет", "Ср. балл ученика", "Ср. балл класса"])
        for row in json.data {
            result.append([row.subject, row.mark_of_student, row.mark_of_class])
            updateMaxWidth(topic: row.subject)
        }
        updateRowHeights(width: columnWidth[0])
        columnWidth = [columnWidth[0]+10, 130, 130]
    }
    
    private func dynamicMiddleMarksT() {
        guard let json = try? decoder.decode(DynamicMiddleMarksT.self, from: inputData) else {
            JSON_Error()
            return
        }
        result.append(["Период", "Балл ученика", "Балл класса"])
        for i in json.data{
            result.append([i.period, i.mark_of_student, i.mark_of_class])
        }
    }
    
    private func dynamicMiddleMarksSB() {
        guard let json = try? decoder.decode(DynamicMiddleMarksSB.self, from: inputData) else {
            JSON_Error()
            return
        }
        result.append(["Дата", "Кол-во срезовых работ ученика", "Балл ученика", "Кол-во срезовых работ класса", "Балл класса"])
        for i in json.data {
            result.append([i.date, i.amount_of_student, i.mark_of_student, i.amount_of_class, i.mark_of_class])
        }
        updateRowHeights(width: columnWidth[0])
        columnWidth = [70, 70, 70, 70, 70]
    }
    
    private func progress() {
        guard let json = try? decoder.decode(Work.self, from: inputData) else {
            JSON_Error()
            return
        }
        result.append(["Тип задания", "Тема задания", "Дата", "Балл"])
        updateMaxWidth(topic: "Тип задания")
        for row in json.work{
            result.append([row.type, row.theme, row.date, row.mark])
            updateMaxWidth(topic: row.type)
        }
        updateRowHeights(index: 1, width: 200)
        columnWidth = [columnWidth[0]+10, 200, 100, 45]
    }
    
    private func classJournal() {
        guard let json = try? decoder.decode(JournalTable.self, from: inputData) else {
            JSON_Error()
            return
        }
        result.append(["Предмет", "Класс", "Дата", "Пользователь", "Занятие в расписании", "Период", "Действие"])
        var teacherWidth: CGFloat = 100
        for line in json.line {
            result.append([line.lesson, line.class_number, line.date_time, line.user, line.info.replacingOccurrences(of: ",", with: ", "), line.period, line.type])
            let length = line.user.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)]).width
            teacherWidth = max(teacherWidth, length)
            updateMaxWidth(topic: line.lesson)
        }
        updateRowHeights(width: 200)
        for index in 0..<result.count {
            let label =  UILabel(frame: CGRect(x: 0, y: 0, width: 170, height: 45))
            label.numberOfLines = 0
            let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
            label.attributedText = NSMutableAttributedString(string: result[index][4], attributes: attributes)
            label.sizeToFit()
            rowHeights[index] = max(label.frame.height + 10, rowHeights[index])
        }
        columnWidth = [columnWidth[0]+10, 51, 125, teacherWidth, 170, 85, 75]
    }
    
    private func parentsLetter(_ type: Int = 0) {
        guard let json = try? decoder.decode(InfoForParents.self, from: inputData) else {
            JSON_Error()
            return
        }
        var final: [String] = []
        var count: [Int] = []
        var full_average: Float = 0
        result.append(["Предмет"])
        columnWidth.removeAll()
        columnWidth.append(85)
        let count_of_marks: Int = json.table[0].marks.count
        for i in stride(from: count_of_marks, through: 1, by: -1) {
            result[0].append(String(i))
            count.append(0)
            columnWidth.append(40)
        }
        result[0].append("Ср. балл")
        columnWidth.append(70)
        for i in (json.table){
            var temp: [String] = []
            temp.append(i.name)
            for j in i.marks{
                temp.append(j)
            }
            temp.append(i.average_mark)
            full_average += Float(i.average_mark)!
            final.append(i.mark_for_period)
            result.append(temp)
        }
        if type == 1 {
            result[0].append("Итоговая")
            columnWidth.append(70)
            for i in stride(from: 1, to: result.count, by: 1){
                result[i].append(final[i-1])
            }
        }
        updateRowHeights(width: columnWidth[0])
        for i in stride(from: 1, to: result.count, by: 1){
            for j in stride(from: 1, through: count_of_marks, by: 1){
                count[Int(result[0][j])! - 1] += Int(result[i][j])!
            }
        }
        count.reverse()
        var temp: [String] = ["Итого"]
        for i in count{
            temp.append(String(i))
        }
        temp.append(String(full_average))
        if type == 1 {
            temp.append("")
        }
        result.append(temp)
        updateRowHeights(width: columnWidth[0])
    }
    
    private func attendanceAndProgress() {
        guard let json = try? decoder.decode(BigJournal.self, from: inputData) else {
            JSON_Error()
            return
        }
        var dates: [String] = []
        var setOfSubjects = Set<String>()
        var subjectMarksToDates = [String: Dictionary<String, String>]()
        var index = 1
        result.append(["Предмет"])
        func monthToNumber(data : String) -> String {
            switch data {
            case "January", "Январь", "01", "1": return "01"
            case "February", "Февраль", "02", "2": return "02"
            case "March", "Март", "03", "3": return "03"
            case "April", "Апрель", "04", "4": return "04"
            case "May", "Май", "05", "5": return "05"
            case "June", "Июнь", "06", "6": return "06"
            case "July", "Июль", "07", "7": return "07"
            case "August", "Август", "08", "8": return "08"
            case "September", "Сентябрь", "09", "9": return "09"
            case "October", "Октябрь", "10": return "10"
            case "November", "Ноябрь", "11": return "11"
            case "December", "Декабрь", "12": return "12"
            default: return data
            }
        }
        for month in json.table.months {
            for day in month.days {
                dates.append(day.number + "." + monthToNumber(data: month.name))
                result[0].append(dates.last!)
                var maxWidthForColumn:CGFloat = 45
                for subject in day.subjects {
                    setOfSubjects.insert(subject.name)
                    var fullMark: String = " "
                    for mark in subject.marks {
                        fullMark += mark + " "
                    }
                    let length = fullMark.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)]).width
                    maxWidthForColumn = max(maxWidthForColumn, length)
                    if subjectMarksToDates[subject.name] == nil {
                        subjectMarksToDates[subject.name] = Dictionary<String, String>()
                    }
                    subjectMarksToDates[subject.name]![dates.last!] = fullMark
                }
                columnWidth.append(maxWidthForColumn)
            }
        }
        var maxSubjectWidth: CGFloat = 70
        for subject in setOfSubjects {
            let length = subject.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)]).width
            maxSubjectWidth = max(maxSubjectWidth, length)
            result.append([subject])
            for date in dates {
                if let marks = subjectMarksToDates[subject]?[date] {
                    result[index].append(marks)
                } else {
                    result[index].append("")
                }
            }
            index += 1
        }
        columnWidth[0] = maxSubjectWidth
        updateRowHeights(width: columnWidth[0])
    }
    
    func parsedData() -> (data:[[String]], rowHeights: [CGFloat], columnWidth: [CGFloat]) {
        return (result, rowHeights, columnWidth)
    }
}
