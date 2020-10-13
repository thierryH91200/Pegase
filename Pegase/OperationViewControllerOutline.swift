import AppKit


// MARK: NSOutlineViewDelegate
extension OperationViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?
    {
        var cellView: NSTableCellView?

        if  item is EntitySousOperations {
            cellView = outlineView.makeView(withIdentifier: .FeedCellHeader, owner: self) as? NSTableCellView
            
            let amount = (item as! EntitySousOperations).amount as NSNumber
            let formatted = formatterPrice.string(from: amount)

            let str = (item as! EntitySousOperations).libelle! + "  " + formatted!
            cellView?.textField!.stringValue = str
            
        } else {
            
            cellView = outlineView.makeView(withIdentifier: .FeedCellHeader, owner: self) as? NSTableCellView
            cellView?.textField!.stringValue = item as! String
        }
        
        let attributText = NSMutableAttributedString(string: (cellView?.textField!.stringValue)! )
        attributText.setAttributes(attrs, range: NSRange(location: 0, length: attributText.length))
        cellView?.textField?.attributedStringValue = attributText
        return cellView
    }
    
    public func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        let rowView = MyNSTableRowView()
        return rowView
    }

}

// MARK: NSOutlineViewDataSource
extension OperationViewController: NSOutlineViewDataSource {
    
    /// Returns the number of child items encompassed by a given item.
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        // Root
        if item == nil {
            return subOperations.count
        }
        // child
        return 4
    }
    
    /// Returns the child item at the specified index of a given item
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        // Root
        if item == nil {
            let root = subOperations[index]
            attrs.removeAll()
            attrs[.foregroundColor] = root.category?.rubric?.color
            return root
        }
        
        // child
        var child = ""
        let sousOperation = item as! EntitySousOperations
        switch index {
        case 0:
            child = sousOperation.libelle!
        case 1:
            child = (sousOperation.category?.rubric!.name)!
        case 2:
            child = (sousOperation.category?.name)!
        case 3:
            let amount = sousOperation.amount as NSNumber
            let priceFormatted = formatterPrice.string(from: amount)
            child = priceFormatted!

        default:
            child = sousOperation.libelle!
        }
        attrs.removeAll()
        attrs[.foregroundColor] = sousOperation.category?.rubric?.color
        return child
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return isSourceGroupItem(item)
    }
    
    func isSourceGroupItem(_ item: Any) -> Bool
    {
        if item is  EntitySousOperations {
            return true
        }
        return false
    }
    
    //    Show the expander triangle for group items..
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool
    {
        return isSourceGroupItem(item)
    }
    
    //  Returns a Boolean value that indicates whether the outline view should select a given item.
    public func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool
    {
        if item is EntitySousOperations {
            return true
        }
        return false
    }
    
}
