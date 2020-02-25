import AppKit


extension ListeOperationsController {
        
    func createOutlineContextMenu()
    {
        let dict = Defaults.dictionary(forKey: kUserDefaultsKeyVisibleColumns)

        let tableHeaderContextMenu = NSMenu(title: "Select Columns")
        
        for column in outlineListView.tableColumns
        {
            let title = column.headerCell.title
            let menuItem = tableHeaderContextMenu.addItem(withTitle: title, action: #selector(self.toggleColumn), keyEquivalent: "")
            
            menuItem.target = self
            menuItem.representedObject = column
            menuItem.state = .on
            
            if dict != nil {
                let isVisible = dict![column.identifier.rawValue] as! Bool
                column.isHidden = !isVisible
            }
            menuItem.state = column.isHidden ? .off : .on
        }
        self.outlineListView.headerView?.menu = tableHeaderContextMenu
    }
    
    @objc func toggleColumn(_ menuItem: NSMenuItem) {
        
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
            columnVisibilityDictionary["recette"] = menuItem.state == .on ? false : true
            columnVisibilityDictionary["depense"] = menuItem.state == .on ? false : true
            let item = parentMenu?.item(withTitle: recette)
            item?.state = menuItem.state
            
            columnVisibilityDictionary["montant"] = menuItem.state == .on ? true : false
            let itemMontant = parentMenu?.item(withTitle: montant)
            itemMontant?.state = menuItem.state == .on ? .off : .on
        }
        if nameCol == "recette" {
            columnVisibilityDictionary["depense"] = true
            let item = parentMenu?.item(withTitle: depense)
            item?.state = menuItem.state
            
            columnVisibilityDictionary["montant"] = false
            let itemMontant = parentMenu?.item(withTitle: montant)
            itemMontant?.state = menuItem.state == .on ? .off : .on
        }
        if nameCol == "montant" {
            columnVisibilityDictionary["recette"] = false
            let itemRecette = parentMenu?.item(withTitle: recette)
            itemRecette?.state = menuItem.state == .on ? .off : .on
            
            columnVisibilityDictionary["depense"] = false
            let itemDepense = parentMenu?.item(withTitle: depense)
            itemDepense?.state = menuItem.state == .on ? .off : .on
        }
        
        for menuItem in (parentMenu?.items)!
        {
            let col = menuItem.representedObject as? NSTableColumn
            let shouldHide = menuItem.state == .off ? true : false
            col?.isHidden = shouldHide
        }
        Defaults.set(columnVisibilityDictionary, forKey: kUserDefaultsKeyVisibleColumns)
    }
    
}

