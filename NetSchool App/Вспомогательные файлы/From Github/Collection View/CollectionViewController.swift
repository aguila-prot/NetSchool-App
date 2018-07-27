import UIKit

class CollectionViewController: UIViewController {
    
    var data = [[String]]()
    var type = 0
    var columnWidth: [CGFloat] = []
    var rowHeights: [CGFloat] = []
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView.collectionViewLayout = CustomCollectionViewLayout(type, rowHeights: rowHeights, columnWidth: columnWidth)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension CollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return rowHeights.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return columnWidth.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ContentCollectionViewCell
        if indexPath.section == 0 {
            cell.backgroundColor = UIColor(hex: "dddddd")
        } else {
            cell.backgroundColor = indexPath.section % 2 == 0 ? UIColor.white : UIColor(white: 242/255, alpha: 1.0)
        }
        if indexPath.row == 0 && indexPath.section != 0 {
            cell.contentLabel.textColor = .schemeTintColor
        } else {
            cell.contentLabel.textColor = UIColor(hex: "424242")
        }
        
        cell.contentLabel.font = indexPath.section == 0 ? .boldSystemFont(ofSize: 14) : .systemFont(ofSize: 14)
        cell.contentLabel.text = data[indexPath.section][indexPath.row]
        cell.contentLabel.lineBreakMode = .byWordWrapping
        cell.contentLabel.numberOfLines = 0
        return cell
    }
}








