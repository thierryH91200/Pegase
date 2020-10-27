import AppKit

extension TransactionViewController: ListeOperationsDelegate {
    
    // MARK: razData
    func resetOperation() {
        
        self.edition = false
        self.modeOperation.title = Localizations.Operation.ModeCreation
        self.modeOperation.layer?.backgroundColor = NSColor.orange.cgColor
        
        self.modeOperation2.title = Localizations.Operation.ModeCreation
        self.modeOperation2.layer?.backgroundColor = NSColor.orange.cgColor
        
        self.buttonSave.isEnabled = false
        self.addBUtton.isEnabled = true
        self.removeButton.isEnabled = false
        
        self.addView.isHidden = false
        
        self.setDateOperation.removeAll()
        self.setCheck_In_Date.removeAll()
        self.setModePaiement.removeAll()
        self.setReleve.removeAll()
        self.setStatut.removeAll()
        self.setTransfert.removeAll()
        
        self.setDateOperation.insert(Date())
        self.setCheck_In_Date.insert(Date())
        self.setModePaiement.insert("string")
        self.setReleve.insert(0)
        self.setStatut.insert(0)
        
        self.entityPreference = Preference.shared.getAllDatas()
        
        self.loadAccount()
        self.popUpTransfert.itemTitle(at: 0)
        self.nameCompte.stringValue = ""
        self.nomTitulaire.stringValue = ""
        self.prenomTitulaire.stringValue = ""
        
        self.loadStatut()
        self.popUpStatut.selectItem(at: Int((entityPreference?.statut)!))
        
        self.dateOperation.dateValue = Date()
        self.datePointage.dateValue = Date()
        
        self.loadModePaiement()
        self.popUpModePaiement.selectItem(withTitle: (entityPreference?.paymentMode?.name)!)
        
        self.textFieldReleveBancaire.doubleValue = 0.0
        self.textFieldReleveBancaire.placeholderString = ""
        
        self.textFieldMontant.doubleValue = 0.0
        
        self.subOperations.removeAll()
        self.outlineViewSSOpe.isEnabled = true
        self.outlineViewSSOpe.reloadData()
        
        self.pieChartView.data = nil
        self.pieChartView.data?.notifyDataChanged()
        self.pieChartView.notifyDataSetChanged()
        
        self.dateOperation.allowEmptyDate = false
        self.dateOperation.showPromptWhenEmpty = false
        self.dateOperation.referenceDate = Date()
        self.dateOperation.dateFieldPlaceHolder = Localizations.Operation.Multi
        self.dateOperation.dateValue = Date()
        
        self.datePointage.allowEmptyDate = false
        self.datePointage.showPromptWhenEmpty = false
        self.datePointage.referenceDate = Date()
        self.datePointage.dateFieldPlaceHolder = Localizations.Operation.Multi
        self.datePointage.dateValue = Date()
    }
    
    // MARK: editionDatas
    func editionOperations(_ quakes: [EntityOperations]) {
        
        self.edition = true
        self.modeOperation.title = Localizations.Operation.ModeEdition
        self.modeOperation.layer?.backgroundColor = NSColor.green.cgColor
        
        self.modeOperation2.title = Localizations.Operation.ModeEdition
        self.modeOperation2.layer?.backgroundColor = NSColor.green.cgColor
        
        self.buttonSave.isEnabled = true
        
        self.entityOperations = quakes
        if self.entityOperations.count > 1 {
            
            self.dateOperation.allowEmptyDate = true
            self.dateOperation.showPromptWhenEmpty = true
            
            self.datePointage.allowEmptyDate = true
            self.datePointage.showPromptWhenEmpty = true
            
            self.addBUtton.isEnabled = false
            self.removeButton.isEnabled = false
            
            self.outlineViewSSOpe.isEnabled = false
            
        } else {
            
            self.addBUtton.isEnabled = true
            let sousOperation = self.entityOperations.first?.sousOperations?.allObjects as! [EntitySousOperations]
            if sousOperation.count > 1 {
                self.removeButton.isEnabled = true
            } else {
                self.removeButton.isEnabled = false
            }
            
            self.outlineViewSSOpe.isEnabled = true
            self.textFieldMontant.isEnabled = true
            
            self.subOperations.removeAll()
            self.outlineViewSSOpe.isEnabled = true
            self.outlineViewSSOpe.reloadData()
            
            self.pieChartView.data = nil
            self.pieChartView.data?.notifyDataChanged()
            self.pieChartView.notifyDataSetChanged()
        }
        
        self.subOperations.removeAll()
        self.outlineViewSSOpe.reloadData()
        
        self.setDateOperation.removeAll()
        self.setCheck_In_Date.removeAll()
        self.setModePaiement.removeAll()
        self.setMontant.removeAll()
        self.setReleve.removeAll()
        self.setStatut.removeAll()
        self.setTransfert.removeAll()
        
        for quake in quakes {
            
            let releveBancaire = quake.bankStatement
            self.setReleve.insert(releveBancaire)
            
            let amount = quake.amount
            setMontant.insert(amount)
            
            let modePaiement = quake.paymentMode?.name!
            self.setModePaiement.insert(modePaiement!)
            
            let statut = quake.statut
            self.setStatut.insert(statut)
            
            let compteLie = quake.operationLiee?.account
            let transfert = compteLie?.initAccount?.codeAccount ?? ""
            //            if transfert != "" {
            self.setTransfert.insert(transfert)
            //            }
            
            let datePointage = quake.datePointage ?? Date()
            self.setCheck_In_Date.insert(datePointage)
            
            let dateOperation = quake.dateOperation ?? Date()
            self.setDateOperation.insert(dateOperation)
        }
        
        if setReleve.count > 1 {
            self.textFieldReleveBancaire.stringValue =  ""
            self.textFieldReleveBancaire.alignment =  .left
            self.textFieldReleveBancaire.placeholderString = Localizations.Operation.MultipleValue
        } else {
            self.textFieldReleveBancaire.doubleValue = setReleve.first!
            self.textFieldReleveBancaire.alignment =  .right
            self.textFieldReleveBancaire.placeholderString = ""
        }
        
        if setMontant.count > 1 {
            textFieldMontant.stringValue =  ""
            textFieldMontant.alignment =  .left
            textFieldMontant.placeholderString = Localizations.Operation.MultipleValue
        } else {
            let montant = setMontant.first!
            self.textFieldMontant.alignment =  .right
            self.textFieldMontant.doubleValue = abs(montant)
            textFieldMontant.placeholderString = ""
            textFieldMontant.textColor = montant < 0 ? NSColor.red : NSColor.green
            //            signeMontant.state = montant < 0 ? .on : .off
        }
        
        if setCheck_In_Date.count > 1 {
            self.date5 = nil
            datePointage.updateControlValue(nil)
        } else {
            datePointage.dateValue = setCheck_In_Date.first!
        }
        
        if setDateOperation.count > 1 {
            self.date4 = nil
            dateOperation.updateControlValue(nil)
        } else {
            dateOperation.dateValue = setDateOperation.first!
        }
        
        if setModePaiement.count > 1 && popUpModePaiement.itemTitle(at: 0) != Localizations.Operation.MultipleValue {
            let menuItemMultiplevalue = getMenuItemMultiplevalue()
            menuItemMultiplevalue.action = #selector(optionModePaiement(menuItem:))
            
            self.popUpModePaiement.menu?.insertItem(menuItemMultiplevalue, at: 0)
            self.popUpModePaiement.selectItem(at: 0)
            
        } else {
            var mode = popUpModePaiement.itemTitle(at: 0)
            if mode == Localizations.Operation.MultipleValue {
                
                self.popUpModePaiement.menu?.removeItem(at: 0)
                mode = self.popUpModePaiement.itemTitle(at: 0)
            }
            self.popUpModePaiement.selectItem(withTitle: setModePaiement.first ?? mode)
            if self.popUpModePaiement.indexOfSelectedItem == -1 {
                self.popUpModePaiement.selectItem(at: 0)
            }
        }
        
        if setStatut.count > 1 && popUpStatut.itemTitle(at: 0) != Localizations.Operation.MultipleValue {
            let menuItem = getMenuItemMultiplevalue()
            menuItem.action = #selector(optionStatut(menuItem:))
            
            self.popUpStatut.menu?.insertItem(menuItem, at: 0)
            self.popUpStatut.selectItem(at: 0)
            
        } else {
            let mode = popUpStatut.itemTitle(at: 0)
            if mode == Localizations.Operation.MultipleValue {
                
                self.popUpStatut.menu?.removeItem(at: 0)
            }
            let statut = Int16(0)
            self.popUpStatut.selectItem(at: (Int(setStatut.first ?? statut)))
        }
        
        if setTransfert.count > 1 && popUpTransfert.itemTitle(at: 0) != Localizations.Operation.MultipleValue {
            
            let menuItemMultiplevalue = getMenuItemMultiplevalue()
            menuItemMultiplevalue.action = #selector(optionAccount(menuItem:))
            
            popUpTransfert.menu?.insertItem(menuItemMultiplevalue, at: 0)
            popUpTransfert.selectItem(at: 0)
            nameCompte.stringValue = Localizations.Operation.MultipleValue
            nomTitulaire.stringValue = Localizations.Operation.MultipleValue
            prenomTitulaire.stringValue = Localizations.Operation.MultipleValue
        } else {
            var transfert = popUpTransfert.itemTitle(at: 0)
            if transfert == Localizations.Operation.MultipleValue {
                
                popUpTransfert.menu?.removeItem(at: 0)
                transfert = popUpTransfert.itemTitle(at: 0)
            }
            let linkedAccount = quakes[0].operationLiee?.account
            if linkedAccount != nil {
                popUpTransfert.selectItem(withTitle: setTransfert.first ?? transfert)
                nameCompte.stringValue = (linkedAccount?.name)!
                nomTitulaire.stringValue = (linkedAccount?.identity?.name)!
                prenomTitulaire.stringValue = (linkedAccount?.identity?.surName)!
            } else {
                popUpTransfert.selectItem(at: 0)
                nameCompte.stringValue = ""
                nomTitulaire.stringValue = ""
                prenomTitulaire.stringValue = ""
            }
        }
        resignFirstResponder()
        
        if quakes.count == 1 {
            subOperations = quakes.first?.sousOperations?.allObjects as! [EntitySousOperations]
            self.outlineViewSSOpe.reloadData()
            
            self.updateChartData()
            self.setDataCount()
        }
    }
    
    func getMenuItemMultiplevalue() -> NSMenuItem {
        var labelAttrs: [NSAttributedString.Key: Any] = [:]
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.alignment = .left
        
        labelAttrs = [
            .font: NSFont.systemFont(ofSize: 13.0), 
            .foregroundColor: NSColor.lightGray,
            .paragraphStyle: paragraphStyle]
        let attributedText = NSAttributedString(string: Localizations.Operation.MultipleValue, attributes: labelAttrs)
        
        let menuItem = NSMenuItem()
        menuItem.attributedTitle = attributedText
        menuItem.action = nil
        menuItem.target = self
        menuItem.keyEquivalent = ""
        menuItem.representedObject = nil
        menuItem.isEnabled = true
        return menuItem
    }
}

// MARK: CurrencyField
class CurrencyField: NSTextField {
    
    var percent: Double {
        return Double(Int(numbers) ?? 0) / 100
    }
    
    var currency: String {
        return Number.currency.string(from: percent.number) ?? ""
    }
    
    var numbers: String {
        return stringValue.components(separatedBy: CharacterSet(charactersIn: "0123456789").inverted).joined()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        alignment = .right
        stringValue = currency
    }
    
    override func textDidChange(_ notification: Notification) {
        stringValue = currency
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
}

// MARK: NumberFormatter
extension NumberFormatter {
    convenience init(numberStyle: NumberFormatter.Style) {
        self.init()
        self.numberStyle = numberStyle
        self.isLenient = true
    }
}
struct Number {
    static let currency = NumberFormatter(numberStyle: .currency)
}

extension Double {
    var number: NSNumber {
        return NSNumber(value: self)
    }
}

