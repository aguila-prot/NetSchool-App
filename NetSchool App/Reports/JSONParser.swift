//
//  JSONParser.swift
//  NetSchool App
//
//  Created by Arthur on 14.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//
import Foundation
class JSONParser{
    let data: String
    let inputData: Data
    let decoder = JSONDecoder()
    var result = [[String]]()
    var countOfSections: Int?
    var countOfRows: Int?
    var rowHeights: [CGFloat] = []
    var maxWidth:CGFloat = 0
    
    init(data: String, type:Int){
        self.data = data
        self.inputData = data.data(using: .utf8)!
        switch type {
        case 0: marks()
        case 1: middle_marks()
        case 2: dynamic_middle_marks_t()
        case 3: dynamic_middle_marks_sb()
        case 4: progress_work()
        case 5: permission_to_journal()
        case 6: info_for_parents()
        case 7: big_journal()
        default: ()
        }
        countOfRows = result[0].count
        countOfSections = result.count
    }
    
    private func updateMaxWidth(topic: String) {
        let components = topic.components(separatedBy: " ")
        for component in components {
            let length = component.size(withAttributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14.0)]).width
            maxWidth = max(maxWidth, length)
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
            rowHeights.append(max(label.frame.height, 45))
        }
    }
    
    func marks(){
        let json = try! decoder.decode(Marks.self, from: inputData)
        result.append(["Предмет", "Ⅰ", "Ⅱ", "Ⅲ", "Ⅳ", "Годовая", "Экзамен","Итоговая"])
        updateMaxWidth(topic: "Предмет")
        for row in json.table {
            result.append([row.subject, row.period1, row.period2, row.period3, row.period4, row.year, row.exam, row.final])
            updateMaxWidth(topic: row.subject)
        }
        updateRowHeights(width: maxWidth)
    }
    
    func middle_marks(){
        let json = try! decoder.decode(MiddleMarks.self, from: inputData)
        result.append(["Предмет", "Ср. балл ученика", "Ср. балл класса"])
        updateMaxWidth(topic: "Предмет")
        for row in json.data {
            result.append([row.subject, row.mark_of_student, row.mark_of_class])
            updateMaxWidth(topic: row.subject)
        }
        updateRowHeights(width: maxWidth)
    }
    
    func dynamic_middle_marks_t() {
        let json = try! decoder.decode(DynamicMiddleMarksT.self, from: inputData)
        result.append(["Период", "Балл ученика", "Балл класса"])
        for i in json.data{
            result.append([i.period, i.mark_of_student, i.mark_of_class])
        }
    }
    func dynamic_middle_marks_sb(){
        let json = try! decoder.decode(DynamicMiddleMarksSB.self, from: inputData)
        result.append(["Дата", "Кол-во срезовых работ ученика", "Балл ученика", "Кол-во срезовых работ класса", "Балл класса"])
        for i in json.data {
            result.append([i.date, i.amount_of_student, i.mark_of_student, i.amount_of_class, i.mark_of_class])
        }
    }
    
    func progress_work(){
        let json = try! decoder.decode(Work.self, from: inputData)
        result.append(["Тип задания", "Тема задания", "Дата", "Балл"])
        updateMaxWidth(topic: "Тип задания")
        for row in json.work{
            result.append([row.type, row.theme, row.date, row.mark])
            updateMaxWidth(topic: row.type)
        }
        updateRowHeights(index: 1, width: 200)
    }
    
    func permission_to_journal(){
        let json = try! decoder.decode(JournalTable.self, from: inputData)
        result.append(["Класс", "Предмет", "Дата", "Пользователь", "Занятие в расписании", "Период", "Действие"])
        for i in json.line{
            result.append([i.class_number, i.lesson, i.date_time, i.user, i.info, i.period, i.type])
        }
    }
    
    func info_for_parents(){
        let json = try! decoder.decode(InfoForParents.self, from: inputData)
        result.append(["Предмет"])
        for i in json.data[0].mark_info{
            result[0].append(i.mark)
        }
        result[0].append("Ср. балл")
        result[0].append("Итоговый")
        for i in json.data{
            result.append([i.lesson])
            for j in i.mark_info{
                result[result.count-1].append(j.count)
            }
            result[result.count-1].append(i.middle)
            result[result.count-1].append(i.final)
        }
    }
    
    func month_to_number(data : String) -> String{
        switch data{
        case "January", "Январь", "01", "1":
            return "01"
        case "February", "Февраль", "02", "2":
            return "02"
        case "March", "Март", "03", "3":
            return "03"
        case "April", "Апрель", "04", "4":
            return "04"
        case "May", "Май", "05", "5":
            return "05"
        case "June", "Июнь", "06", "6":
            return "06"
        case "July", "Июль", "07", "7":
            return "07"
        case "August", "Август", "08", "8":
            return "08"
        case "September", "Сентябрь", "09", "9":
            return "09"
        case "October", "Октябрь", "10":
            return "10"
        case "November", "Ноябрь", "11":
            return "11"
        case "December", "Декабрь", "12":
            return "12"
        default:
            return "Error"
        }
    }
    
    func big_journal(){
        let json = try! decoder.decode(BigJournal.self, from: inputData)
        var dates: [String] = []
        var set_sub = Set<String>()
        var subject = [String: Dictionary<String, String>]()
        var i: Int = 1
        result.append(["Предмет"])
        for j in json.table.months{
            for l in j.days{
                dates.append(month_to_number(data: j.name)  + "." + l.number)
                result[0].append(dates.last!)
                for m in l.subjects{
                    set_sub.insert(m.name)
                    var full_mark: String = ""
                    for u in m.marks{
                        full_mark += u
                    }
                    if subject[m.name] == nil{
                        subject[m.name] = Dictionary<String, String>()
                    }
                    subject[m.name]![dates.last!] = full_mark
                }
            }
        }
        for s in set_sub {
            result.append([s])
            for d in dates {
                result[i].append(subject[s]![d] == nil ? "" : subject[s]![d]!)
            }
            i+=1
        }
    }
    
    func parsedData() -> (data:[[String]], countOfSections:Int?, countOfRows:Int?, rowHeights: [CGFloat], maxWidth: CGFloat){
        return (result, countOfSections, countOfRows, rowHeights, maxWidth)
    }
}
