import AppKit

extension OperationViewController {

    // MARK: -
    // MARK: PopUp Account
    func loadAccount () {
        let  transfertMenu = NSMenu()
        
        let accounts = Account.shared.getAllDatas()
        for account in accounts where account.isAccount == true
        {
            transfertMenu.addItem(accountItemFor(account) )
        }
        var items = transfertMenu.items
        items.sort(by: { $0.title < $1.title })
        transfertMenu.removeAllItems()
        for item in items {
            transfertMenu.addItem(item)
        }
        popUpTransfert.menu = transfertMenu
    }
    
    fileprivate func accountItemFor(_ value: EntityAccount) -> NSMenuItem {
        var title = value.initAccount?.codeAccount ?? "----"
        let menuItem = NSMenuItem()
        
        if value == currentAccount {
            title = Localizations.Operation.NoTransfert
            menuItem.representedObject = nil
        } else {
            menuItem.representedObject = value
        }
        menuItem.title = title
        menuItem.action = #selector(optionAccount(menuItem:))
        menuItem.target = self
        menuItem.keyEquivalent = ""
        menuItem.isEnabled = true
        return menuItem
    }
    
    @objc func optionAccount( menuItem: NSMenuItem)
    {
        let selectItem = popUpTransfert.selectedItem
        let account = selectItem?.representedObject as? EntityAccount
        
        if account != nil {
            self.entityCompteTransfert = account
            self.nameCompte.stringValue = (account?.name)!
            self.nomTitulaire.stringValue = (account?.identity?.name)!
            self.prenomTitulaire.stringValue = (account?.identity?.surName)!
        } else {
            self.nameCompte.stringValue = ""
            self.nomTitulaire.stringValue = ""
            self.prenomTitulaire.stringValue = ""
        }
    }
    
    // MARK: - PopUp ModePaiement
    func loadModePaiement () {
        let  modePaiementMenu = NSMenu()
        
        let modesPaiement = PaymentMode.shared.getAllDatas()
        for modePaiement in modesPaiement
        {
            modePaiementMenu.addItem( modePaiementItemFor( modePaiement ) )
        }
        popUpModePaiement.menu = modePaiementMenu
    }
    
    fileprivate func modePaiementItemFor(_ value: EntityPaymentMode) -> NSMenuItem {
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
