import AppKit

extension GroupeAccountViewController: NSMenuDelegate {
    
    func menuWillOpen( _ menu: NSMenu) {
        
        let index = anSideBar.selectedRow
        if let item = anSideBar.item(atRow: index) as? EntityAccount {
            
            for menuItem in menu.items
            {
                menuItem.isHidden =  true
                if item.isHeader == true, menuItem.tag == 0 {
                    menuItem.isHidden =  false
                }
                if item.isAccount == true, menuItem.tag == 1 {
                    menuItem.isHidden =  false
                }
            }
        }
    }
    
    @IBAction func modifierCompte(_ sender: Any) {
        
        let index = anSideBar.selectedRow
        if let item = anSideBar.item(atRow: index) as? EntityAccount
        {
            if item.isAccount == true {
                accountModalWindowController = AccountModalWindowController()
                accountModalWindowController.account = item
                accountModalWindowController.edition = true
                
                let windowAdd = accountModalWindowController.window!
                let windowApp = self.view.window
                windowApp?.beginSheet( windowAdd, completionHandler: {(_ returnCode: NSApplication.ModalResponse) -> Void in
                    
                    switch returnCode {
                    case .OK:
                        
                        let libelleAccount   = self.accountModalWindowController.libelleCompte.stringValue
                        let soldeInitial    = self.accountModalWindowController.soldeInitial.doubleValue
                        let nomTitulaire    = self.accountModalWindowController.nomTitulaire.stringValue
                        let prenomTitulaire = self.accountModalWindowController.prenomTitulaire.stringValue
                        let numCompte       = self.accountModalWindowController.numCompte.stringValue
                        let nameImage       = self.accountModalWindowController.imageView.image?.name()
                        let type            = self.accountModalWindowController.typeAccount.indexOfSelectedItem
                        
                        item.name                   = libelleAccount
                        item.initCompte?.realise    = soldeInitial
                        item.identite?.idName       = nomTitulaire
                        item.identite?.idPrenom     = prenomTitulaire
                        item.initCompte?.codeCompte = numCompte
                        item.nameImage              = nameImage
                        item.type                   = Int16(type)
                        
                        //                        let undo = self.undoManager!
                        //                        (undo.prepare(withInvocationTarget: item) as AnyObject).setValue(item, forKeyPath: "item")
                        
                        //                        self.rootSourceListItem.clear()
                        
                        self.anSideBar.reloadData()
                        self.anSideBar.expandItem(nil, expandChildren: true)
                        self.anSideBar.selectRowIndexes([1], byExtendingSelection: false)
                        
                    case .cancel:
                        break
                    default:
                        break
                    }
                    self.accountModalWindowController = nil
                })
                
            }
            
            if item.isHeader == true {
                groupModalWindowController = GroupModalWindowController()
                groupModalWindowController.account = item
                groupModalWindowController.edition = true
                
                let windowAdd = groupModalWindowController.window!
                let windowApp = self.view.window
                windowApp?.beginSheet( windowAdd, completionHandler: {(_ returnCode: NSApplication.ModalResponse) -> Void in
                    
                    switch returnCode {
                    case .OK:
                        
                        let name = self.groupModalWindowController.nameGroup.stringValue
                        item.name = name
                        
                        //                        let undo = self.undoManager!
                        //                        (undo.prepare(withInvocationTarget: item) as AnyObject).setValue(item, forKeyPath: "item")
                        
                        //                        self.rootSourceListItem.clear()
                        
                        self.anSideBar.reloadData()
                        self.anSideBar.expandItem(nil, expandChildren: true)
                        self.anSideBar.selectRowIndexes([1], byExtendingSelection: false)
                        
                    case .cancel:
                        break
                        
                    default:
                        break
                    }
                    self.groupModalWindowController = nil
                })
            }
        }
    }
    
    @IBAction func addAccount(_ sender: Any) {
        
        self.accountModalWindowController = AccountModalWindowController()
        let windowAdd = accountModalWindowController.window!
        let windowApp = self.view.window
        windowApp?.beginSheet( windowAdd, completionHandler: {(_ returnCode: NSApplication.ModalResponse) -> Void in
            
            switch returnCode {
            case .OK:
                
                let nameAccount   = self.accountModalWindowController.libelleCompte.stringValue
                let soldeInitial    = self.accountModalWindowController.soldeInitial.doubleValue
                let nom    = self.accountModalWindowController.nomTitulaire.stringValue
                let prenom = self.accountModalWindowController.prenomTitulaire.stringValue
                let numAccount       = self.accountModalWindowController.numCompte.stringValue
                let nameImage       = self.accountModalWindowController.imageView.image?.name()!
                let type            = self.accountModalWindowController.typeAccount.indexOfSelectedItem
                
                let compte   = Account.shared.create(nameAccount: nameAccount, nameImage: nameImage!, idName: nom, idPrenom: prenom, numAccount: numAccount)
                compte.type = Int16(type)
                compte.initCompte?.realise = soldeInitial
                
                //                let undo = self.undoManager!
                //                (undo.prepare(withInvocationTarget: compte) as AnyObject).setValue(compte, forKeyPath: "compte")
                
                let list = self.rootSourceListItem.children?[0] as? EntityAccount
                list?.insertIntoChildren(compte, at: 0)
                
                //                self.rootSourceListItem.clear()
                
                self.anSideBar.reloadData()
                self.anSideBar.expandItem(nil, expandChildren: true)
                self.anSideBar.selectRowIndexes([1], byExtendingSelection: false)
                
            case .cancel:
                print("Cancel button tapped in Custom addCompte Sheet")
                
            default:
                break
            }
            self.accountModalWindowController = nil
        })
        
    }
    
    @IBAction func addGroupCompte(_ sender: Any) {
        self.groupModalWindowController = GroupModalWindowController()
        let windowAdd = groupModalWindowController.window!
        let windowApp = self.view.window
        windowApp?.beginSheet( windowAdd, completionHandler: {(_ returnCode: NSApplication.ModalResponse) -> Void in
            
            switch returnCode {
            case .OK:
                
                let name = self.groupModalWindowController.nameGroup.stringValue
                
                //create source list headers
                let header = NSEntityDescription.insertNewObject(forEntityName: "EntityAccount", into: mainObjectContext) as! EntityAccount
                header.isHeader = true
                header.name = name
                header.uuid = UUID()
                header.parent = self.rootSourceListItem
                
                //                let undo = self.undoManager!
                //                (undo.prepare(withInvocationTarget: header) as AnyObject).setValue(header, forKeyPath: "header")
                
                //                self.rootSourceListItem.clear()
                
                self.anSideBar.reloadData()
                self.anSideBar.expandItem(nil, expandChildren: true)
                self.anSideBar.selectRowIndexes([1], byExtendingSelection: false)
                
            case .cancel:
                break
                
            default:
                break
            }
            self.groupModalWindowController = nil
        })
        
    }
    
    @IBAction func removeAction(_ sender: Any) {
        
        let alert = NSAlert()
        alert.messageText = Localizations.GroupeAccount.RemoveAlert.MessageText
        alert.informativeText = Localizations.GroupeAccount.RemoveAlert.InformativeText
        alert.addButton(withTitle: Localizations.GroupeAccount.RemoveAlert.Delete)
        alert.addButton(withTitle: Localizations.GroupeAccount.RemoveAlert.Cancel)
        alert.alertStyle = NSAlert.Style.informational
        
        alert.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                
                print("Document 🗑")
                
                self.deleteSelection()
                
                self.rootSourceListItem = Account.shared.getRoot().first!
                self.anSideBar.reloadData()
                self.anSideBar.expandItem(nil, expandChildren: true)
                self.anSideBar.selectRowIndexes([1], byExtendingSelection: false)
            }
        })
    }
    
    func deleteSelection() {
        
        let selected = anSideBar.selectedRowIndexes
        
        let sourceListItems = selected.map({ return anSideBar.item(atRow: $0) })
        for item in sourceListItems {
            
            let entitie = item as! EntityAccount
            if entitie.isHeader == true {
                let entities = entitie.children?.array as! [EntityAccount]
                
                for child in entities {
                    mainObjectContext.delete(child)
                }
            }
            mainObjectContext.delete(entitie)
        }
    }
    
}

