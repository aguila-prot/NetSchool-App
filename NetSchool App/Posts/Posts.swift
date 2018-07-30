import UIKit

/// File structure represents file
struct File {
    var link, name: String
    var size: String?
}
struct Post {
    let date, author, title, message: String
    let file: File?
    var hasFile: Bool {
        return file != nil
    }
}

class Posts: UIViewController {
    
    /// Struct represents a post
    
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate var posts = [Post]()
    private var refreshControl = UIRefreshControl()
    var status: Status = .loading
    /// used to cancel URLSessionTask
    private var task: URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.deselectSelectedRow
    }
    
    private func setupUI() {
        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 56
    }
    
    func internetConnectionAppeared() {
        guard status == .error else { return }
        loadData()
    }
    
    @objc private func loadData() {
        status = .loading
        if posts.isEmpty { tableView.reloadData() }
        let data: String = """
            {
                "posts": [
                    {
                        "id": "1",
                        "unread": "True",
                        "author": "Павлова Ольга Вячеславовна",
                        "title": "NEW!!! ГРАФИК ЖИЗНИ ШКОЛЫ 2018-2019 гг.",
                        "date": "8.05.2018",
                        "message": "",
                        "file": "ГРАФИК_ЖИЗНИ_ШКОЛЫ_2018-2019.doc"
                    },
                    {
                        "id": "2",
                        "unread": "False",
                        "author": "Хмельницкий Андрей Леонидович",
                        "title": "ЧЁРНЫЙ годовой календарный график 2017-2018 у.г",
                        "date": "8.05.2018",
                        "message": "",
                        "file": "ЧЁРНЫЙ годовой календарный график 2017-2018 у.г.xls"
                    },
                    {
                        "id": "3",
                        "unread": "True",
                        "author": "Плескач Сергей Георгиевич",
                        "title": "По следам семинаров для родителей. Ссылки на видео",
                        "date": "14.06.2015",
                        "message": "Амонашвили Ш.А. с первого семинара с родителями: \\n http://youtu.be/_L1hEDq90Xs Гатанов Ю.Б. с первого семинара с родителями::\\n http://youtu.be/PaJz5TEng58 Выступление А.Э.Колмановского, которое мы просмотрели на втором семинаре с родителями 28.01.15:\\nhttp://youtu.be/sucoP9PWk8U ",
                        "file": "Ссылки_на_видеозаписи,_которые_мы_просмотрели_на_семинарах_с_родителями.docx"
                    }
                ]
            }

        """
        let json = JSONParser(data:data, type: 10)
        self.posts = json.get_post_data()
    }
    
    fileprivate func createAttributeString(_ indexPath: IndexPath) -> NSMutableAttributedString {
        let post = posts[indexPath.row]
//        var attribute = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 24), NSAttributedStringKey.foregroundColor: UIColor.black]
//        let attributedString = NSMutableAttributedString(string: "\(post.title)\n", attributes: attribute)
//        attribute = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.black ]
//        attributedString.append(NSMutableAttributedString(string: "\(post.message)\n\n", attributes: attribute))
//        attribute = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13), NSAttributedStringKey.foregroundColor: UIColor.gray ]
//        attributedString.append(NSMutableAttributedString(string: "\(post.date),\n\(post.author)\n", attributes: attribute))
        var attribute = [NSAttributedStringKey.font: UIFont(name: "BloggerSans", size: 24)!, NSAttributedStringKey.foregroundColor: UIColor(hex: "222222")]
        let attributedString = NSMutableAttributedString(string: "\(post.title)\n", attributes: attribute)
        attribute = [NSAttributedStringKey.font: UIFont(name: "BloggerSans", size: 5)!]
        attributedString.append(NSMutableAttributedString(string: "\n", attributes: attribute))
        attribute = [NSAttributedStringKey.font: UIFont(name: "BloggerSans", size: 14)!, NSAttributedStringKey.foregroundColor: UIColor(hex: "333333")]
        attributedString.append(NSMutableAttributedString(string: "\(post.message)\n\n", attributes: attribute))
        attribute = [NSAttributedStringKey.font: UIFont(name: "BloggerSans", size: 13)!, NSAttributedStringKey.foregroundColor: UIColor.gray ]
        attributedString.append(NSMutableAttributedString(string: "\(post.date),\n\(post.author)\n", attributes: attribute))
        return attributedString
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? Details,
            let indexPath = tableView.indexPathForSelectedRow {
            destination.attrStr = createAttributeString(indexPath)
            destination.detailType = .posts
            if let file = posts[indexPath.row].file {
                destination.files = [file]
            }
        }
    }
}

//MARK: - 3D Touch peek and pop
extension Posts: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if #available(iOS 9.0, *) {
            guard let indexPath = tableView.indexPathForRow(at: location),
                let cell = tableView.cellForRow(at: indexPath),
                let detailVC = storyboard?.instantiateViewController(withIdentifier: "Details") as? Details else { return nil }
            detailVC.attrStr = createAttributeString(indexPath)
            if posts[indexPath.row].hasFile {
                detailVC.files = [posts[indexPath.row].file!]
            }
            detailVC.detailType = .posts
            detailVC.navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
            previewingContext.sourceRect = cell.frame
            return detailVC
        }
        return nil
    }
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit)
    }
}

// MARK: - TableView Setup
extension Posts: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return posts.isEmpty ? 35 : 0 }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if !posts.isEmpty { return nil }
        switch status {
        case .loading: return self.view.loadingFooterView()
        case .error: return self.view.errorFooterView()
        default:
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 23))
            footerView.backgroundColor = UIColor.clear
            let footerLabel = UILabel(frame: CGRect(x: 10, y: 7, width: tableView.frame.size.width - 30, height: 23))
            footerLabel.addProperties
            footerLabel.text = "Объявлений нет"
            footerView.addSubview(footerLabel)
            return footerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width - 30, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        let attributes = [NSAttributedStringKey.font: UIFont(name: "BloggerSans", size: 18)!, NSAttributedStringKey.foregroundColor: UIColor(hex: "424242")]
        label.attributedText = NSMutableAttributedString(string: "\(posts[indexPath.row].title)", attributes: attributes)
        label.sizeToFit()
        func messageHeight() -> CGFloat {
            if !(posts[indexPath.row].message.unicodeScalars.filter{$0.isASCII}.map{$0.value}).isEmpty {
                let messageLabel =  UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width - 30, height: .greatestFiniteMagnitude))
                messageLabel.numberOfLines = 0
                var attributes = [NSAttributedStringKey.font: UIFont(name: "BloggerSans", size: 15)!]
                let attributeString = NSMutableAttributedString(string: "\n\(posts[indexPath.row].message)", attributes: attributes)
                attributes = [NSAttributedStringKey.font: UIFont(name: "BloggerSans", size: 5)!]
                attributeString.append(NSMutableAttributedString(string: "\n", attributes: attributes))
                messageLabel.attributedText = attributeString
                messageLabel.sizeToFit()
                return messageLabel.frame.height
//                return min(messageLabel.frame.height, 45)
            }
            return 0
        }
        return label.frame.height + 82 + messageHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return posts.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostsCell
        let post = posts[indexPath.row]
        cell.dateLabel.text = cleverDate(post.date)
        cell.titleLabel.text = post.author
        var attributes = [NSAttributedStringKey.font: UIFont(name: "BloggerSans", size: 18)!, NSAttributedStringKey.foregroundColor: UIColor(hex: "424242")]
        let attributedString = NSMutableAttributedString(string: "\(post.title)", attributes: attributes)
        if !(posts[indexPath.row].message.unicodeScalars.filter{$0.isASCII}.map{$0.value}).isEmpty {
            attributes = [NSAttributedStringKey.font: UIFont(name: "BloggerSans", size: 5)!]
            attributedString.append(NSMutableAttributedString(string: "\n", attributes: attributes))
            attributes = [NSAttributedStringKey.font: UIFont(name: "BloggerSans", size: 15)!, NSAttributedStringKey.foregroundColor: UIColor(hex: "9D9D9D")]
            attributedString.append(NSMutableAttributedString(string: "\n\(post.message)", attributes: attributes))
        }
        cell.messageLabel.attributedText = attributedString
        cell.icon.setImage(string: post.author)
        cell.setSelection
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "details")
    }
}

class PostsCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
}
