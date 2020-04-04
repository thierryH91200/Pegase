import AppKit

extension RubriqueViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var cellView: NSView?
        if isHeader(item: item) {
            let cellView =  outlineView.makeView(withIdentifier: .RubriqueCell, owner: self) as! KSHeaderCellView3
            cellView.colorWell.isEnabled = false
            return cellView
        } else {
            cellView = outlineView.makeView(withIdentifier: .CategoryCell, owner: self)
        }
        return cellView

    }
    
    // indicates whether a given row should be drawn in the “group row” style.
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool
    {
        return isHeader(item: item)
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool
    {
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        let rowView = MyNSTableRowView()
        return rowView
    }

    
    func outlineViewSelectionDidChange(_ notification: Notification)
    {
        
        let selected = self.anOutlineView.selectedRow
        let rowView = anOutlineView.rowView(atRow: selected, makeIfNecessary: false)
        rowView?.isEmphasized = true
        
        let item = self.anOutlineView.item(atRow: selected)
        let treeNode = item as? NSTreeNode
        let managedObject = treeNode?.representedObject as? NSManagedObject
        
        let entityRubrique = managedObject as? EntityRubric
        if entityRubrique != nil {
            addRubric.isEnabled = true
            removeRubric.isEnabled = true
            addCategory.isEnabled = false
            removeCategory.isEnabled = false
        } else {
            addRubric.isEnabled = false
            removeRubric.isEnabled = false
            addCategory.isEnabled = true
            removeCategory.isEnabled = true

        }
    }
    
    func isHeader(item: Any) -> Bool {
        
        let treeNode = item as? NSTreeNode
        return treeNode?.representedObject is EntityRubric
    }

}

