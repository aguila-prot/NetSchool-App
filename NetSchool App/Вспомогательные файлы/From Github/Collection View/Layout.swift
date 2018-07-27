import UIKit

enum ReportCollectionViewType {
    case totalMarks, middleMark, dinamicMiddleMark, progress, attendanceAndProgress, classJournal, parentsLetter, undefined
}

class CustomCollectionViewLayout: UICollectionViewLayout {
    
    var reportType: ReportCollectionViewType = .undefined
    var rowHeights: [CGFloat] = [], columnWidth: [CGFloat] = []
    
    private var itemAttributes = [[UICollectionViewLayoutAttributes]]()
    private var numberOfColumns = 0
    private var contentSize: CGSize = .zero
    private var columnWidthSum: CGFloat = 0
    
    init(_ type: Int, rowHeights: [CGFloat], columnWidth: [CGFloat]) {
        super.init()
        self.rowHeights = rowHeights
        self.columnWidth = columnWidth
        numberOfColumns = columnWidth.count
        switch type {
        case 0:
            self.reportType = .totalMarks
            columnWidthSum = 575 + columnWidth[0]
        case 1:
            self.reportType = .middleMark
            columnWidthSum = 290 + columnWidth[0]
        case 3:
            self.reportType = .dinamicMiddleMark
//            numberOfColumns = 5
        case 4:
            self.reportType = .progress
            columnWidthSum = 355 + columnWidth[0]
        case 5:
            self.reportType = .classJournal
//            numberOfColumns = 11
            print(numberOfColumns)
            for width in columnWidth {
                columnWidthSum += width + 10
            }
        case 6:
            self.reportType = .parentsLetter
//            numberOfColumns = 7
            for width in columnWidth {
                columnWidthSum += width + 10
            }
        case 7:
            self.reportType = .attendanceAndProgress
            for width in columnWidth {
                columnWidthSum += width + 10
            }
        default:
            ()
        }
        let width = collectionView?.frame.width ?? 0
        let ratio = width < columnWidthSum ? 1 : width / columnWidthSum
        for index in 0..<numberOfColumns {
            self.columnWidth[index] *= ratio
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        guard let collectionView = collectionView, collectionView.numberOfSections != 0 else {
            return
        }
        
        if itemAttributes.count != collectionView.numberOfSections {
            generateItemAttributes(collectionView)
            return
        }
        
        for section in 0..<collectionView.numberOfSections {
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                if section != 0 && item != 0 {
                    continue
                }
                let attributes = layoutAttributesForItem(at: IndexPath(item: item, section: section))!
                if section == 0 {
                    var frame = attributes.frame
                    frame.origin.y = collectionView.contentOffset.y
                    attributes.frame = frame
                }
                if item == 0 {
                    var frame = attributes.frame
                    frame.origin.x = collectionView.contentOffset.x
                    attributes.frame = frame
                }
            }
        }
        
    }
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemAttributes[indexPath.section][indexPath.row]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        for section in itemAttributes {
            let filteredArray = section.filter { object -> Bool in
                return rect.intersects(object.frame)
            }
            attributes.append(contentsOf: filteredArray)
        }
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    private func generateItemAttributes(_ collectionView: UICollectionView) {
        var column = 0, xOffset: CGFloat = 0, yOffset: CGFloat = 0, contentWidth: CGFloat = 0
        itemAttributes.removeAll()
        for section in 0..<collectionView.numberOfSections {
            var sectionAttributes: [UICollectionViewLayoutAttributes] = []
            for index in 0..<numberOfColumns {
                let itemSize = CGSize(width: columnWidth[index], height: rowHeights[section])
                let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: section))
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height).integral
                if section == 0 && index == 0 {
                    attributes.zIndex = 1024
                } else if section == 0 || index == 0 {
                    attributes.zIndex = 1023
                }
                if section == 0 {
                    var frame = attributes.frame
                    frame.origin.y = collectionView.contentOffset.y
                    attributes.frame = frame
                }
                if index == 0 {
                    var frame = attributes.frame
                    frame.origin.x = collectionView.contentOffset.x
                    attributes.frame = frame
                }
                sectionAttributes.append(attributes)
                xOffset += itemSize.width
                column += 1
                if column == numberOfColumns {
                    if xOffset > contentWidth {
                        contentWidth = xOffset
                    }
                    column = 0
                    xOffset = 0
                    yOffset += itemSize.height
                }
            }
            itemAttributes.append(sectionAttributes)
        }
        if let attributes = itemAttributes.last?.last {
            contentSize = CGSize(width: contentWidth, height: attributes.frame.maxY)
        }
    }
}
