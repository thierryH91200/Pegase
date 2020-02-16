import AppKit

extension ImportWindowController: ParserDelegate {
    
    func parserDidBeginDocument(_ parser: CSV.Parser) {
        allData.removeAll()
        headerData.removeAll()
        nColumns = 0
    }
    
    func parser(_ parser: CSV.Parser, didBeginLineAt index: UInt) {
        line = Int(index)
        dataLine.removeAll()
    }
    
    func parser(_ parser: CSV.Parser, didReadFieldAt index: UInt, value: String) {
        if (statusBarFormatViewController?.config.isFirstRowAsHeader)! && line == 0 {
            headerData.append(value)
        } else {
            dataLine.append(value)
        }
    }
    
    func parser(_ parser: CSV.Parser, didEndLineAt index: UInt) {
        if dataLine.count > nColumns {
            nColumns = dataLine.count
        }
        let isFirstRowAsHeader = (statusBarFormatViewController?.config.isFirstRowAsHeader)!
        if !(isFirstRowAsHeader == true && line == 0) {
            allData.append(dataLine)
        }
    }
    
    func parserDidEndDocument(_ parser: CSV.Parser) {
        while let col = anTableView?.tableColumns.last {
            anTableView?.removeTableColumn(col)
        }
        
        for i in 0 ..< nColumns {
            let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier( "\(i)"))
            col.sizeToFit()
            col.headerCell.alignment = .center
            col.resizingMask = [.userResizingMask, .autoresizingMask]
            
            if (statusBarFormatViewController?.config.isFirstRowAsHeader)! && headerData.count > i {
                col.headerCell.title = headerData[i]
            }
            anTableView?.addTableColumn(col)
        }
        anTableView?.reloadData()
        anTableView.sizeToFit()
    }

}
