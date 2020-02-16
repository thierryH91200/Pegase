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
    
    func setupHeaderMenu()
    {
        let savedCols = Defaults.dictionary(forKey: "kUserDefaultsKeyVisisbleColumns")
        let menu = NSMenu()
        menu.delegate = self
        
        var menuItem = NSMenuItem()
        menuItem = NSMenuItem(title: "Ignore Column", action: #selector(self.toggleColumn), keyEquivalent: "")
        menuItem.target = self
        for column in outlineListView.tableColumns
        {
            menuItem = NSMenuItem(title: column.headerCell.stringValue, action: #selector(self.toggleColumn), keyEquivalent: "")
            menuItem.target = self
            if savedCols != nil
            {
                let isVisible = savedCols![column.identifier.rawValue] as! Bool
                column.isHidden = !isVisible
            }
            menuItem.state = column.isHidden ? .off : .on
            menuItem.representedObject = column
            menu.addItem(menuItem)
        }
        outlineListView.headerView?.menu = menu
    }
    
    @objc func toggleColumn(_ menuItem: NSMenuItem)
    {
        let col = menuItem.representedObject as? NSTableColumn
        
        let shouldHide = !col!.isHidden
        col?.isHidden = shouldHide
        menuItem.state = (col?.isHidden)! ? .off : .on
        
        let parentMenu = menuItem.menu
        
        var columnVisibilityDictionary: [String: Bool] = [:]
        //        var columnVisibilityDictionary = UserDefaults.standard.dictionary(forKey: "kUserDefaultsKeyVisisbleColumns")
        
        for column in outlineListView.tableColumns
        {
            columnVisibilityDictionary[column.identifier.rawValue] = !column.isHidden
        }
        let nameCol = col?.identifier.rawValue
        let depense = Localizations.General.Depense
        let recette = Localizations.General.Recette
        let montant = Localizations.General.Amount

        if nameCol == "depense" {
            columnVisibilityDictionary["recette"] = columnVisibilityDictionary["depense"]
            let item = parentMenu?.item(withTitle: recette)
            item?.state = menuItem.state
            
            columnVisibilityDictionary["montant"] = !columnVisibilityDictionary["depense"]!
            let itemMontant = parentMenu?.item(withTitle: montant)
            itemMontant?.state = menuItem.state == .on ? .off : .on
        }
        if nameCol == "recette" {
            columnVisibilityDictionary["depense"] = columnVisibilityDictionary["recette"]
            let item = parentMenu?.item(withTitle: depense)
            item?.state = menuItem.state
            
            columnVisibilityDictionary["montant"] = !columnVisibilityDictionary["recette"]!
            let itemMontant = parentMenu?.item(withTitle: montant)
            itemMontant?.state = menuItem.state == .on ? .off : .on
        }
        if nameCol == "montant" {
            columnVisibilityDictionary["recette"] = !columnVisibilityDictionary["montant"]!
            let itemRecette = parentMenu?.item(withTitle: recette)
            itemRecette?.state = menuItem.state == .on ? .off : .on
            
            columnVisibilityDictionary["depense"] = !columnVisibilityDictionary["montant"]!
            let itemDepense = parentMenu?.item(withTitle: depense)
            itemDepense?.state = menuItem.state == .on ? .off : .on
        }
        
        for menuItem in (parentMenu?.items)!
        {
            let col = menuItem.representedObject as? NSTableColumn
            let shouldHide = menuItem.state == .off ? true : false
            col?.isHidden = shouldHide
        }
        Defaults.set(columnVisibilityDictionary, forKey: "kUserDefaultsKeyVisisbleColumns")
    }
    
}

