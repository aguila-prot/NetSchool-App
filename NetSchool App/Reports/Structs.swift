//////////////ИТОГОВЫЕ ОТМЕТКИ//////////////
struct TableMarks: Codable{
    let subject: String
    let period1: String
    let period2: String
    let period3: String
    let period4: String
    let year: String
    let exam: String
    let final: String
}
struct Marks: Codable {
    let table: [TableMarks]
}
//////////////СРЕДНИЙ БАЛЛ//////////////
struct TableOfMiddleMarks: Codable{
    let id: String
    let subject: String
    let mark_of_class: String
    let mark_of_student: String
}
struct MiddleMarks: Codable {
    let data: [TableOfMiddleMarks]
}
//////////////ДИНАМИКА СРЕДНЕГО БАЛЛА//////////////
struct DynamicMiddleMarksT: Codable{
    let data: [TableOfMiddleDynamicMarksT]
}
struct TableOfMiddleDynamicMarksT: Codable{
    let period: String
    let mark_of_class: String
    let mark_of_student: String
}
struct DynamicMiddleMarksSB: Codable{
    let data: [TableOfMiddleDynamicMarksSB]
}
struct TableOfMiddleDynamicMarksSB: Codable{
    let date: String
    let amount_of_student: String
    let mark_of_student: String
    let amount_of_class: String
    let mark_of_class: String
}

//////////////ОТЧЕТ ОБ УСПЕВАЕМОСТИ И ПОСЕЩАЕМОСТИ//////////////
struct SubjectsJourn: Codable{
    let name: String
    let marks: [String]
}
struct DaysJourn: Codable{
    let number: String
    let subjects: [SubjectsJourn]
}
struct MonthsJourn: Codable{
    let name: String
    let days: [DaysJourn]
}
struct AverageMarksJourn: Codable{
    let name: String
    let mark: String
}
struct TableJourn: Codable{
    let months: [MonthsJourn]
    let average_marks: [AverageMarksJourn]
}
struct BigJournal: Codable{
    let table: TableJourn
}
//////////////ОТЧЕТ ОБ УСПЕВАЕМОСТИ//////////////
struct TableWork: Codable{
    let type: String
    let theme: String
    let date: String
    let mark: String
}
struct Work: Codable{
    let work: [TableWork]
}
//////////////ОТЧЕТ О ДОСТУПЕ К КЛАССНОМУ ЖУРНАЛУ//////////////
struct JournalTable: Codable{
    let line: [JournalLine]
}
struct JournalLine: Codable{
    let class_number: String
    let lesson: String
    let date_time: String
    let user: String
    let info: String
    let period: String
    let type: String
}
//////////////ИНФОРМАЦИОННОЕ ПИСЬМО ДЛЯ РОДИТЕЛЕЙ//////////////
struct TableForInfoForParents: Codable{
    let name: String
    let marks: [String]
    let average_mark: String
    let mark_for_period: String
}
struct InfoForParents: Codable{
    let table: [TableForInfoForParents]
}
//////////////РАСПИСАНИЕ//////////////
struct ScheduleLessonJSON: Codable{
    let start: String
    let end: String
    let name: String
    let classroom: String
}
struct ScheduleDayJSON: Codable{
    let date: String
    let lessons: [ScheduleLessonJSON]
}
struct ScheduleClass: Codable{
    let days: [ScheduleDayJSON]
}
//////////////ОБЪЯВЛЕНИЯ//////////////
struct PostJSON: Codable{
    let id: String
    let unread: String
    let author: String
    let title: String
    let date: String
    let message: String
    let file: String
}
struct PostsClass: Codable{
    let posts: [PostJSON]
}
//////////////ДНЕВНИК//////////////
///2.1.1 Получение списка учеников
struct DiaryStudents: Codable{
    let name: String
    let id: String
}
struct GetListOfStudents: Codable{
    let students: [DiaryStudents]
}
///2.1.2 Получение заданий и оценок на неделю.
struct LessonInformation: Codable{
    let id: String
    let status: String
    let inTime: String
    let name: String
    let author: String
    let title: String
    let type: String
    let mark: String
    let weight: String
}
struct DayDiaryWeek: Codable{
    let date: String
    let lessons: [LessonInformation]
}
struct DayDiaryWeekClass: Codable{
    let days: [DayDiaryWeek]
}
///2.1.3 Получение подробностей урока
struct DescriptionOfLesson: Codable{
    let theme_type: String
    let theme_info: String
    let date_type: String
    let date_info: String
    let comments: [String]
    let file: String
    let attachment_id: String
}
struct DescriptionOfLessonClass: Codable{
    let description: DescriptionOfLesson
    let file_link: String
}
///Получение статуса
struct GetSuccessClass: Codable{
    let success: String
}
//////////////ФОРУМ//////////////
///2.7.1 Загрузка списка тем
struct ForumPostsList: Codable{
    let date: String
    let last_author: String
    let id: String
    let creator: String
    let answers: String
    let title: String
    let unread: String
}
struct ForumPostsListClass: Codable{
    let posts: [ForumPostsList]
}
///2.7.2 Загрузка сообщении из темы
struct ForumInfoOfPost: Codable{
    let date: String
    let author: String
    let role: String
    let message: String
    let unread: String
}
struct ForumInfoOfPostClass: Codable{
    let messages: [ForumInfoOfPost]
}
//////////////Почта//////////////
///2.6.1 Получение списка писем
struct EmailLettersList: Codable{
    let date: String
    let id: String
    let author: String
    let title: String
    let unread: String
}
struct EmailLettersListClass: Codable{
    let letters: [EmailLettersList]
}
//2.6.2 Получение подробностей письма
struct NameAndIdClass: Codable{
    let name: String
    let id: String
}
struct FilesClass: Codable{
    let file_name: String
    let link: String
}
struct EmailGetInfoOfMessageClass: Codable{
    let to: [NameAndIdClass]
    let copy: [NameAndIdClass]
    let description: String
    let files: [FilesClass]
}
///Загрузка адресной книги
struct ParentClass: Codable{
    let parent: String
    let parent_if: String
}
struct AdressBookGroup: Codable{
    let title: String
    let users: [NameAndIdClass]
}
struct AdressBookUser: Codable{
    let student: String
    let student_id: String
    let parents: [ParentClass]
    
}
struct AdressBookClasses: Codable{
    let class_name: String
    let users: [AdressBookUser]
    let name: String
    let id: String
}
struct AdressBookInfo: Codable{
    let groups: [AdressBookGroup]
    let classes: [AdressBookClasses]
}
struct AdressBookClass: Codable{
    let adress_book: [AdressBookInfo]
}
//////////////ШКОЛЬНЫЕ РЕСУРСЫ//////////////
struct NameAndLinkClass: Codable{
    let name: String
    let link: String
}
struct SchoolResourcesSubGroup: Codable{
    let subgroup_title: String
    let files: [NameAndLinkClass]
}
struct SchoolResourcesGroup: Codable{
    let group_title: String
    let files: [NameAndLinkClass]
    let subgroups: [SchoolResourcesSubGroup]
}
struct SchoolResourcesClass: Codable{
    let groups: [SchoolResourcesGroup]
}
