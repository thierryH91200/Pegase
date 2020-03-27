import AppKit

extension OperationViewController {

    // MARK: -
    // MARK: PopUp Account
    func loadAccount () {
        let  transfertMenu = NSMenu()
        
        let comptes = Account.shared.getAll()
        for compte in comptes where compte.isAccount == true
        {
            transfertMenu.addItem(compteItemFor(compte) )
        }
        var items = transfertMenu.items
        items.sort(by: { $0.title < $1.title })
        transfertMenu.removeAllItems()
        for item in items {
            transfertMenu.addItem(item)
        }
        popUpTransfert.menu = transfertMenu
    }
    
    fileprivate func compteItemFor(_ value: EntityAccount) -> NSMenuItem {
        var title = value.initCompte?.codeCompte ?? "----"
        let menuItem = NSMenuItem()
        
        if value == currentAccount {
            title = Localizations.Operation.NoTransfert
            menuItem.representedObject = nil
        } else {
            menuItem.representedObject = value
        }
        menuItem.title = title
        menuItem.action = #selector(optionCompte(menuItem:))
        menuItem.target = self
        menuItem.keyEquivalent = ""
        menuItem.isEnabled = true
        return menuItem
    }
    
    @objc func optionCompte( menuItem: NSMenuItem)
    {
        let selectItem = popUpTransfert.selectedItem
        let account = selectItem?.representedObject as? EntityAccount
        
        if account != nil {
            self.entityCompteTransfert = account
            self.nameCompte.stringValue = (account?.name)!
            self.nomTitulaire.stringValue = (account?.identite?.idName)!
            self.prenomTitulaire.stringValue = (account?.identite?.idPrenom)!
        } else {
            self.nameCompte.stringValue = ""
            self.nomTitulaire.stringValue = ""
            self.prenomTitulaire.stringValue = ""
        }
    }
    
    // MARK: - PopUp ModePaiement
    func loadModePaiement () {
        let  modePaiementMenu = NSMenu()
        
        let modesPaiement = ModePaiement.shared.getAll()
        for modePaiement in modesPaiement
        {
            modePaiementMenu.addItem( modePaiementItemFor( modePaiement ) )
        }
        popUpModePaiement.menu = modePaiementMenu
    }
    
    fileprivate func modePaiementItemFor(_ value: EntityModePaiement) -> NSMenuItem {
        let menuItem = NSMenuItem()
        menuItem.title = value.name!
        menuItem.action = #selector(optionModePaiement(menuItem:))
        menuItem.target = self
        menuItem.keyEquivalent = ""
        menuItem.representedObject = value
        menuItem.isEnabled = true
        return menuItem
    }
    
    @objc func optionModePaiement( menuItem: NSMenuItem)
    {
        if menuItem.title == Localizations.ModePaiement.Cheque {
            self.numCheque.isHidden = false
            self.labelNumCheque.isHidden = false
        } else {
            self.numCheque.isHidden = true
            self.labelNumCheque.isHidden = true
        }
    }
    
    // MARK: -
    // MARK: PopUp Statut
    func loadStatut () {
        let  statutMenu = NSMenu()
        
        let planifie = Localizations.Statut.Planifie
        let engaged = Localizations.Statut.Engaged
        let realise = Localizations.Statut.Realise
        let statuts = [planifie, engaged, realise]
        var i = 0
        for statut in statuts
        {
            let item = statutItemFor(statut)
            item.tag = i
            statutMenu.addItem(item )
            i += 1
        }
        self.popUpStatut.menu = statutMenu
    }
    
    fileprivate func statutItemFor(_ value: String) -> NSMenuItem {
        let menuItem = NSMenuItem()
        menuItem.title = value
        menuItem.action = #selector(optionStatut(menuItem:))
        menuItem.target = self
        menuItem.keyEquivalent = ""
        menuItem.representedObject = value
        menuItem.isEnabled = true
        return menuItem
    }
    
    @objc func optionStatut( menuItem: NSMenuItem)
    {
    }

}
