import UIKit

enum ReportCollectionViewType {
    case totalMarks, middleMark, dinamicMiddleMark, progress, attendanceAndProgress, classJournal, parentsLetter, undefined
}

class CustomCollectionViewLayout: UICollectionViewLayout {
    
    var numberOfColumns = 0
    var shouldPinFirstColumn = true
    var shouldPinFirstRow = true
    var reportType: ReportCollectionViewType = .undefined
    
    var itemAttributes = [[UICollectionViewLayoutAttributes]]()
    var rowHeights: [CGFloat] = []
    var columnWidth: [CGFloat] = []
    var maxWidth:CGFloat = 0
    var contentSize: CGSize = .zero
    
    init(_ type: Int) {
        super.init()
        switch type {
        case 0:
            self.reportType = .totalMarks
            numberOfColumns = 8
        case 1:
            self.reportType = .middleMark
            numberOfColumns = 3
        case 3:
            self.reportType = .dinamicMiddleMark
            numberOfColumns = 5
        case 4:
            self.reportType = .progress
            numberOfColumns = 4
        case 5:
            self.reportType = .attendanceAndProgress
            numberOfColumns = 7
        case 6:
            self.reportType = .classJournal
            numberOfColumns = 7
        case 7:
            self.reportType = .parentsLetter
            numberOfColumns = 11
        default:
            ()
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
            generateItemAttributes(collectionView: collectionView)
            return
        }
        
        for section in 0..<collectionView.numberOfSections {
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                if section != 0 && item != 0 {
                    continue
                }
                
                let attributes = layoutAttributesForItem(at: IndexPath(item: item, section: section))!
                
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
            let filteredArray = section.filter { obj -> Bool in
                return rect.intersects(obj.frame)
            }
            attributes.append(contentsOf: filteredArray)
        }
        
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}

// MARK: - Helpers
extension CustomCollectionViewLayout {
    
    func generateItemAttributes(collectionView: UICollectionView) {
//        if itemsSize.count != numberOfColumns {
//            calculateItemSizes()
//        }
        calculateItemSizes()
        
        var column = 0
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        var contentWidth: CGFloat = 0
        
        itemAttributes = []
        
        for section in 0..<collectionView.numberOfSections {
            var sectionAttributes: [UICollectionViewLayoutAttributes] = []
            
            for index in 0..<numberOfColumns {
                let itemSize = CGSize(width: columnWidth[index], height: rowHeights[section])
                let indexPath = IndexPath(item: index, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height).integral
                
                if section == 0 && index == 0 {
                    // First cell should be on top
                    attributes.zIndex = 1024
                } else if section == 0 || index == 0 {
                    // First row/column should be above other cells
                    attributes.zIndex = 1023
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
    
    func calculateItemSizes() {
        columnWidth.removeAll()
        for index in 0..<numberOfColumns {
            columnWidth.append(widthForItemWithColumnIndex(index))
        }
    }
    
    func widthForItemWithColumnIndex(_ columnIndex: Int) -> CGFloat {
        func calculateRatio(_ amount: CGFloat) -> CGFloat {
            let sum = maxWidth + amount
            let width = collectionView?.frame.width ?? 0
            return width < sum ? 1 : width / sum
        }
        switch reportType {
        case .totalMarks:
            // Each column width plus 10*columnsCount
            let ratio = calculateRatio(575)
            switch columnIndex {
            case 0: return (maxWidth+10)*ratio
            case 1,2,3,4: return 70*ratio
            default: return 75*ratio
            }
        case .middleMark:
            let ratio = calculateRatio(290)
            switch columnIndex {
            case 0: return (maxWidth+10)*ratio
            default: return 130*ratio
            }
        case .dinamicMiddleMark:
            ()
        case .progress:
            let ratio = calculateRatio(355)
            switch columnIndex {
            case 0: return (maxWidth+10)*ratio
            case 1: return 200*ratio
            case 2: return 100*ratio
            case 3: return 45*ratio
            default: return 0
            }
//        case .attendanceAndProgress:
//            var text: [NSString] = ["Информатика"]
//            for _ in 0...numberOfColumns-2{
//                text.append("04.03")
//            }
//            var sum: CGFloat = 0
//            for k in text{
//                sum += (k.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)]).width + 10)
//            }
//            let width: CGFloat = text[columnIndex != 0 ? 1 : 0].size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)]).width + 10
//            let koff: CGFloat = (collectionView?.frame.width)! / sum < 1 ? 1 : (collectionView?.frame.width)! / sum
//            return CGSize(width: width*koff, height: 30)
//        case .classJournal:
//            var text: [NSString] = ["Класс", "Физическая культура", "24.05.2018 19:31", "Дурмамбаевский К.Г", "Занятие в расписании", "1 четверть", "Действие"]
//            var sum: CGFloat = 0
//            for k in text{
//                sum += (k.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)]).width + 10)
//            }
//            let width: CGFloat = text[columnIndex].size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)]).width + 10
//
//            let koff: CGFloat = (collectionView?.frame.width)! / sum < 1 ? 1 : (collectionView?.frame.width)! / sum
//            return CGSize(width: width*koff, height: 30)
//        case .parentsLetter:
//            var text: [NSString] = ["Предмет"]
//            for _ in 0...numberOfColumns-4{
//                text.append("33")
//            }
//            text.append("Ср. балл")
//            text.append("Итоговый")
//            var sum: CGFloat = 0
//            for k in text{
//                sum += (k.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)]).width + 10)
//            }
//            let width: CGFloat = text[columnIndex].size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)]).width + 10
//            let koff: CGFloat = (collectionView?.frame.width)! / sum < 1 ? 1 : (collectionView?.frame.width)! / sum
//            return CGSize(width: width*koff, height: 30)
        default:
            ()
        }
        return 0
    }
    
}
