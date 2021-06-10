import AppKit

// MARK: - NSMenuDelegate
extension ImportWindowController: NSMenuDelegate {
    
    func menuWillOpen( _ menu: NSMenu) {
        
        guard anTableView.clickedColumn != -1 else { return }
        guard menu == menuHeader else { return }

        let indexCol = anTableView.clickedColumn
        anTableView.selectColumnIndexes(NSIndexSet(index: indexCol) as IndexSet, byExtendingSelection: true)
        
        for i in 0 ..< menu.items.count
        {
            menu.items[i].state =  .off
            
            headerColumnForMenu = menu.items[i].representedObject as!  [HeaderColumnForMenu]
            let index = headerColumnForMenu.firstIndex { $0.numCol == indexCol }
            if index != nil {
                menu.items[i].state =  .on
            }
        }
    }
    
    func setupHeaderMenu()
    {
        let tableColumns = self.anTableView.tableColumns
        
        dataArray.removeAll()
        dataArray.append(Localizations.ImportSimplifiee.Menu.ignoreCol)
        dataArray.append(Localizations.ImportSimplifiee.Menu.dateTransaction)
        dataArray.append(Localizations.ImportSimplifiee.Menu.datePointage)
        dataArray.append(Localizations.ImportSimplifiee.Menu.statut)
        dataArray.append(Localizations.ImportSimplifiee.Menu.modePaiement)

        dataArray.append(Localizations.ImportSimplifiee.Menu.comment)
        dataArray.append(Localizations.ImportSimplifiee.Menu.amount)
        dataArray.append(Localizations.ImportSimplifiee.Menu.rubric)
        dataArray.append(Localizations.ImportSimplifiee.Menu.catégory)
        
        headerColumnForMenu.removeAll()
        headerColumnForMenu = (0 ..< tableColumns.count).map { (i) -> HeaderColumnForMenu in
            
            tableColumns[i].identifier = NSUserInterfaceItemIdentifier("\(i)")
            let nameCol = "\(i)"
            return HeaderColumnForMenu(numCol: i, nameCol: nameCol, numMenu: 0, nameMenu: dataArray[0])
        }
        
        menuHeader.removeAllItems()
        menuHeader.delegate = self
        for i in 0 ..< dataArray.count
        {
            let menuItem = NSMenuItem(title: dataArray[i], action: #selector(self.toggleColumn), keyEquivalent: "")
            menuItem.target = self
            menuItem.identifier = NSUserInterfaceItemIdentifier("\(i)")
            
            if i == 0 {
                menuItem.state = .on
                menuItem.representedObject = headerColumnForMenu
            } else {
                menuItem.state = .off
                menuItem.representedObject = []
            }
            menuHeader.addItem(menuItem)
        }
    }
    
    @objc func toggleColumn(_ menuItem: NSMenuItem)
    {
        let indexCol = anTableView.clickedColumn
        guard indexCol != -1 else { return }
        
        let indexMenu = Int((menuItem.identifier?.rawValue)!)!
        let items = menuHeader.items
        
        // Item existant précedent
        for i in 0 ..< items.count {
            var headerColumnForMenu = items[i].representedObject as!  [HeaderColumnForMenu]
            let index = headerColumnForMenu.firstIndex { $0.numMenu == indexMenu }
            if index != nil {
                
                print("remove oldItem")
                var oldItem = headerColumnForMenu[index!]
                headerColumnForMenu.remove(at: index!)
                items[i].representedObject = headerColumnForMenu
                
                print("move oldItem")
                var headerColumnForMenu1 = items[0].representedObject as! [HeaderColumnForMenu]
                oldItem.numMenu = 0
                oldItem.nameMenu = dataArray[0]
                headerColumnForMenu1.append(oldItem)
                items[0].representedObject =  headerColumnForMenu1
                break
            }
        }
        
        // Item existant en cours
        for i in 0 ..< items.count {
            var headerColumnForMenu = items[i].representedObject as!  [HeaderColumnForMenu]
            let findCol = headerColumnForMenu.firstIndex { $0.numCol == indexCol }
            if findCol != nil {
                
                print("remove newItem")
                var newItem = headerColumnForMenu[findCol!]
                headerColumnForMenu.remove(at: findCol!)
                items[i].representedObject = headerColumnForMenu
                
                print("move newItem")
                var rep1 = items[indexMenu].representedObject as! [HeaderColumnForMenu]
                newItem.numMenu = indexMenu
                newItem.nameMenu = dataArray[indexMenu]
                if indexMenu != 0 {
                    rep1.removeAll()
                }
                rep1.append(newItem)
                menuItem.representedObject =  rep1
                break
            }
        }
        anTableView.reloadData()
    }
    
}
