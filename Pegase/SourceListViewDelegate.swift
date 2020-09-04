import AppKit


extension SourceListViewController: NSOutlineViewDelegate {
        
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {

        if let section = item as? Donnees
        {
            let cell = outlineView.makeView(withIdentifier: .FeedCellHeader, owner: self) as? KSHeaderCellView

            cell?.fillColor = self.colorBackGround
            cell?.textField!.stringValue = section.name.uppercased()
            cell?.textField!.textColor = NSColor.labelColor

            cell?.imageView!.image =   #imageLiteral(resourceName: section.icon)  //  #imageLiteral(resourceName: section.icon)
            return cell
        } else if let account = item as? Children
        {
            let cell = outlineView.makeView(withIdentifier: .FeedCell, owner: self) as? NSTableCellView
            
            cell?.imageView!.image       =  #imageLiteral(resourceName: account.icon)  //#imageLiteral(resourceName: account.icon)
            cell?.textField!.stringValue = account.name
            cell?.textField!.textColor = NSColor.labelColor
            return cell
        }
        return nil
    }

    func outlineViewSelectionDidChange(_ notification: Notification)
    {
        let sideBar = notification.object as? NSOutlineView
        guard sideBar == sidebarOutlineView else { return }
        
        let selectedIndex = sidebarOutlineView.selectedRow
        if let item = sidebarOutlineView.item(atRow: selectedIndex) as? Children
        {
            delegate?.changeView( name: item.nameView)
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        return MyNSTableRowView()
    }
    
    /// Returns a Boolean value that indicates whether the outline view should select a given item.
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool
    {
        return !isSourceGroupItem(item)
    }


}
