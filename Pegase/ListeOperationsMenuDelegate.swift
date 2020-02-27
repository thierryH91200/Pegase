import AppKit


extension ListeOperationsController: NSMenuDelegate {

    // MARK: - Show Hide Columns
    func menuWillOpen( _ menu: NSMenu) {
        for menuItem in menu.items
        {
            let col = menuItem.representedObject as? NSTableColumn
            menuItem.state = (col?.isHidden)! ? .off : .on
        }
    }

    /// set up the table header context menu for choosing the columns.
    func createOutlineContextMenu()
    {
        let dict = Defaults.dictionary(forKey: kUserDefaultsKeyVisibleColumns)
        let tableHeaderContextMenu = NSMenu(title: "Select Columns")
        tableHeaderContextMenu.delegate = self
        
        for column in outlineListView.tableColumns
        {
            let title = column.headerCell.title
            let menuItem = tableHeaderContextMenu.addItem(withTitle: title, action: #selector(self.contextMenuSelected), keyEquivalent: "")
            
            menuItem.target = self
            menuItem.representedObject = column
            menuItem.state = .on
            
            if dict != nil {
                let isVisible = dict![column.identifier.rawValue] as! Bool
                column.isHidden = isVisible
            }
            menuItem.state = column.isHidden ? .off : .on
        }
        self.outlineListView.headerView?.menu = tableHeaderContextMenu
    }
    
    /// The outline action. `addItem( withTitle` specifies this func.
    @objc func contextMenuSelected(_ menuItem: NSMenuItem) {
        
        let column = menuItem.representedObject as? NSTableColumn
        
        let shouldHide = !column!.isHidden
        column?.isHidden = shouldHide
        menuItem.state = (column?.isHidden)! ? .off : .on
        
        let parentMenu = menuItem.menu
        
        var columnVisibilityDictionary = UserDefaults.standard.dictionary(forKey: "kUserDefaultsKeyVisisbleColumns")
        
        for column in outlineListView.tableColumns
        {
            columnVisibilityDictionary![column.identifier.rawValue] = !column.isHidden
        }
        let nameCol = column?.identifier.rawValue
        let depense = Localizations.General.Depense
        let recette = Localizations.General.Recette
        let montant = Localizations.General.Amount

        if nameCol == "depense" {
            columnVisibilityDictionary!["recette"] = menuItem.state == .on ? true : false
            columnVisibilityDictionary!["depense"] = menuItem.state == .on ? true : false
            
            let item = parentMenu?.item(withTitle: recette)
            item?.state = menuItem.state
            
            columnVisibilityDictionary!["montant"] = menuItem.state == .on ? false : true
            let itemMontant = parentMenu?.item(withTitle: montant)
            itemMontant?.state = menuItem.state == .on ? .off : .on
        }
        
        if nameCol == "recette" {
            columnVisibilityDictionary!["recette"] = menuItem.state == .on ? true : false
            columnVisibilityDictionary!["depense"] = menuItem.state == .on ? true : false
            
            let item = parentMenu?.item(withTitle: depense)
            item?.state = menuItem.state

            columnVisibilityDictionary!["montant"] = menuItem.state == .on ? false : true
            let itemMontant = parentMenu?.item(withTitle: montant)
            itemMontant?.state = menuItem.state == .on ? .off : .on
        }
        
        if nameCol == "montant" {
            columnVisibilityDictionary!["recette"] = false
            let itemRecette = parentMenu?.item(withTitle: recette)
            itemRecette?.state = menuItem.state == .on ? .off : .on
            
            columnVisibilityDictionary!["depense"] = false
            let itemDepense = parentMenu?.item(withTitle: depense)
            itemDepense?.state = menuItem.state == .on ? .off : .on
        }
        
        for column in outlineListView.tableColumns
        {
            column.isHidden = !((columnVisibilityDictionary![column.identifier.rawValue] )  as! Bool)
            outlineListView.sizeToFit()
        }
        saveTableColumnDefaults()
    }
    
    /// Writes the selection to user defaults. Called every time an item is chosen.
    func saveTableColumnDefaults() {
        var dict = [String: Bool]()

        for column in self.outlineListView.tableColumns {
            dict[column.identifier.rawValue] = column.isHidden
        }
        UserDefaults.standard.set(dict, forKey: kUserDefaultsKeyVisibleColumns)
    }

    
}

