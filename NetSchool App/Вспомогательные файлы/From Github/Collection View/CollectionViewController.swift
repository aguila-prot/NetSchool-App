import UIKit

class CollectionViewController: UIViewController {
    
    fileprivate static let contentCellIdentifier = "ContentCellIdentifier"
    var data: TableData = TableData(countOfSections: 0, countOfRows: 0, data: [[""]])
    var type = 0
    var maxWidth:CGFloat = 0
    var rowHeights: [CGFloat] = []
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CollectionViewController.contentCellIdentifier)
        let layout = CustomCollectionViewLayout(type)
        layout.rowHeights = rowHeights
        layout.maxWidth = maxWidth
        collectionView.collectionViewLayout = layout
    }

}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension CollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.countOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.countOfRows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewController.contentCellIdentifier, for: indexPath) as! ContentCollectionViewCell
        if indexPath.section == 0 {
            cell.backgroundColor = UIColor(hex: "dddddd")
        } else {
            cell.backgroundColor = indexPath.section % 2 == 0 ? UIColor.white : UIColor(white: 242/255, alpha: 1.0)
        }
        if indexPath.row == 0 && indexPath.section != 0 {
            cell.contentLabel.textColor = UIColor.schemeTintColor
        } else {
            cell.contentLabel.textColor = UIColor(hex: "424242")
        }
        
        if indexPath.section == 0 {
            cell.contentLabel.font = UIFont.boldSystemFont(ofSize: 14)
        } else {
            cell.contentLabel.font = UIFont.systemFont(ofSize: 14)
        }
        
        cell.contentLabel.text = data.data[indexPath.section][indexPath.row]
        cell.contentLabel.lineBreakMode = .byWordWrapping
        cell.contentLabel.numberOfLines = 0
        return cell
    }
}








