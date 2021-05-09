import AppKit

//var groupedSorted = [ (key: String, value:  [ String :  [IdOperations]])]()

// MARK: NSTableViewDelegate
extension ListTransactionsController: NSOutlineViewDelegate {
    
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?
    {
        outlineView.columnAutoresizingStyle = NSTableView.ColumnAutoresizingStyle.sequentialColumnAutoresizingStyle
        
        if let folderItem = item as?  TrackingMonth {
            return trackingFolderYear( outlineView: outlineView, folderItem: folderItem)
        }
        
        if let folderItem = item as? TrackingIdTransactions  {
            return trackingFolderMonth(outlineView: outlineView, folderItem: folderItem)
        }
        
        if let item = item as? TrackingSubOperations {
            return manySubOperations(outlineView: outlineView, tableColumn: tableColumn, item: item)
        }
        
        if let item = item as? TrackingSubOperation {
            return oneSubOperation(outlineView: outlineView, tableColumn: tableColumn, item: item)
        }
        return nil
    }

    
// MARK: - trackingFolderYear
    func trackingFolderYear(outlineView: NSOutlineView, folderItem : TrackingMonth) -> NSView? {
        
        var cellView: KSHeaderCellView?
        
        cellView = outlineView.makeView(withIdentifier: .FeedCellYear, owner: self) as? KSHeaderCellView
        cellView?.textField?.stringValue = folderItem.year
        cellView?.textField?.textColor = .labelColor
        cellView?.fillColor = .lightGray
        return cellView
    }
    
// MARK: - trackingFolderMonth
    func trackingFolderMonth(outlineView: NSOutlineView, folderItem : TrackingIdTransactions) -> NSView? {
        
        var cellView: KSHeaderCellView?
        
        let formatterDate: DateFormatter = {
            let fmt = DateFormatter()
            fmt.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMM yyyy", options: 0, locale: Locale.current)
            return fmt
        }()
        
        var title  = ""
        var dateFormatted  = ""
        var dateString = ""
        
        // Header
        if let numericSection = Int(folderItem.month)
        {
            var components = DateComponents()
            components.year = numericSection / 100
            components.month = numericSection % 100
            
            if let date = Calendar.current.date(from: components) {
                dateString = formatterDate.string(from: date)
                dateFormatted = dateString.padding(toLength: 40, withPad: " ", startingAt: 0)
            }
            let nbOperations = folderItem.idOperation.count
            let operationsString = "\(nbOperations) opérations"
            let operationsFormatted = operationsString.padding(toLength: 30, withPad: " ", startingAt: 0)
            
            var expenses = 0.0
            var incomes = 0.0
            var amount = 0.0
            
            for itemF in folderItem.idOperation
            {
                amount = itemF.entityOperations.amount
                if amount < 0.0 {
                    expenses += amount
                } else {
                    incomes += amount
                }
            }
            
            let expense = Localizations.General.Expenses
            let income  = Localizations.General.Income
            
            let expenseStr = formatterPrice.string(from: NSDecimalNumber(value: expenses))
            let expenseFormatted = "\(expense) : \( expenseStr!)".padding(toLength: 30, withPad: " ", startingAt: 0)
            
            let incomeStr = formatterPrice.string(from: NSDecimalNumber(value: incomes))
            let incomeFormatted = "\(income) : \( incomeStr!)".padding(toLength: 30, withPad: " ", startingAt: 0)
            
            let totalStr = formatterPrice.string(from: NSDecimalNumber(value: incomes + expenses))
            let totalFormatted = "Total : \(totalStr!)".padding(toLength: 30, withPad: " ", startingAt: 0)
            
            title = "     " + dateFormatted + operationsFormatted + expenseFormatted + incomeFormatted + totalFormatted
        }
        
        cellView = outlineView.makeView(withIdentifier: .FeedCellMonth, owner: self) as? KSHeaderCellView
        
        cellView?.textField?.stringValue = title
        cellView?.textField?.textColor = .labelColor
        cellView?.backgroundStyle = .normal
        
//        let attribute: [NSAttributedString.Key: Any] = [
//            .font: NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .bold),
//            .foregroundColor: NSColor.black]

        return cellView
    }
    
    func oneSubOperation(outlineView: NSOutlineView, tableColumn: NSTableColumn?, item: TrackingSubOperation) -> NSView? {
        
        var cellView: NSTableCellView?
        
        let identifier = tableColumn!.identifier
        guard let propertyEnum = ListeOperationsDisplayProperty(rawValue: identifier.rawValue) else { return nil }
        
        let sousOperations = item
        
        if identifier.rawValue == "datePointage"
        {
            cellView = outlineView.makeView(withIdentifier: .sousOpCell, owner: self) as? NSTableCellView
        } else
        {
            cellView = outlineView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView
        }
        
        let textField = (cellView?.textField!)!
        textField.stringValue = ""
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        
        switch propertyEnum
        {

        case .dateOperation, .datePointage, .bankStatement, .statut, .liee, .mode, .solde, .checkNumber:
            textField.stringValue = ""
            
        case .rubrique:
            textField.stringValue = sousOperations.category?.rubric?.name ?? ""
        case .categorie:
            textField.stringValue = sousOperations.category?.name ?? ""
        case .libelle:
            textField.stringValue = sousOperations.libelle ?? ""
        case .montant:
            let price = sousOperations.amount as NSNumber
            let formatted = formatterPrice.string(from: price)
            textField.stringValue = formatted!
            paragraph.alignment = .right
        case .depense:
            var price: NSNumber = 0.0
            var formatted = ""
            if sousOperations.amount < 0 {
                price = sousOperations.amount as NSNumber
                formatted = formatterPrice.string(from: price)!
            }
            textField.stringValue = formatted
            paragraph.alignment = .right
        case .recette:
            var price: NSNumber = 0.0
            var formatted = ""
            if sousOperations.amount > 0 {
                price = sousOperations.amount as NSNumber
                formatted = formatterPrice.string(from: price)!
            }
            textField.stringValue = formatted
            paragraph.alignment = .right
        }
        
        var attrs = colorSousOperations (quake: item, propertyEnum: propertyEnum )
        attrs[ NSAttributedString.Key.paragraphStyle] = paragraph
        let attributText = NSMutableAttributedString(string: textField.stringValue)
        attributText.setAttributes(attrs, range: NSRange(location: 0, length: attributText.length))
        textField.attributedStringValue = attributText
        return cellView
    }
    
    func manySubOperations(outlineView: NSOutlineView, tableColumn: NSTableColumn?, item: TrackingSubOperations) -> NSView? {
        
        var cellView: NSTableCellView?
        
        guard tableColumn != nil else { return nil }
        
        let identifier = tableColumn!.identifier
        guard let propertyEnum = ListeOperationsDisplayProperty(rawValue: identifier.rawValue) else { return nil }
        let quake = item.entityOperations
        let sousOperations = item.entityOperations.sousOperations?.allObjects as! [EntitySousOperations]
        
        if identifier.rawValue == "datePointage"
        {
            if sousOperations.count == 1 {
                cellView = outlineView.makeView(withIdentifier: .FeedCell, owner: self) as? NSTableCellView
            } else {
                cellView = outlineView.makeView(withIdentifier: .sousOpCell, owner: self) as? NSTableCellView
            }
        } else
        {
            cellView = outlineView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView
        }
        
        let textField = (cellView?.textField!)!
        textField.stringValue = ""
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        
        switch propertyEnum
        {
        case .dateOperation:
            paragraph.alignment = .center
            var time = Date()
            if quake.dateOperation != nil {
                time = quake.dateOperation!
            }
            let formattedDate = formatterDate.string(from: time)
            textField.stringValue = formattedDate
            
        case .datePointage:
            paragraph.alignment = .center
            var time = Date()
            if quake.datePointage != nil {
                time = quake.datePointage!
            }
            let formatteddate = formatterDate.string(from: time)
            textField.stringValue = formatteddate
            

        case .rubrique:
            if sousOperations.count == 1 {
                textField.stringValue = sousOperations[0].category?.rubric?.name ?? ""
            } else {
                cellView = CrossHatchView()
                textField.stringValue = ""
            }
            
        case .categorie:
            if sousOperations.count == 1 {
                textField.stringValue = sousOperations[0].category?.name ?? ""
            } else {
                cellView = CrossHatchView()
                textField.stringValue = ""
            }
            
        case .libelle:
            if sousOperations.count == 1 {
                textField.stringValue = sousOperations[0].libelle ?? ""
            } else {
                cellView = CrossHatchView()
                textField.stringValue = ""
            }
            
        case .mode:
            paragraph.alignment = .left
            textField.stringValue = quake.paymentMode?.name ?? ""
            
        case .montant:
            let price = quake.amount as NSNumber
            let formatted = formatterPrice.string(from: price)
            textField.stringValue = formatted!
            paragraph.alignment = .right
            
        case .depense:
            var price: NSNumber = 0.0
            var formatted = ""
            if quake.amount < 0 {
                price = quake.amount as NSNumber
                formatted = formatterPrice.string(from: price)!
            }
            textField.stringValue = formatted
            paragraph.alignment = .right
            
        case .recette:
            var price: NSNumber = 0.0
            var formatted = ""
            if quake.amount > 0 {
                price = quake.amount as NSNumber
                formatted = formatterPrice.string(from: price)!
            }
            textField.stringValue = formatted
            paragraph.alignment = .right
            
        case .bankStatement:
            paragraph.alignment = .center
            if quake.bankStatement != 0 {
                textField.doubleValue = quake.bankStatement
            } else {
                textField.stringValue = ""
            }

        case .solde:
            let solde = quake.solde
            let price = solde as NSNumber
            let formatted = formatterPrice.string(from: price)
            textField.stringValue = formatted!
            paragraph.alignment = .right
            
        case .statut:
            var label = ""
            switch Statut.TypeOfStatut(rawValue: Int16(quake.statut)) {
            case .engage:
                label = Localizations.Statut.Engaged
            case .planifie:
                label = Localizations.Statut.Planifie
            case .realise:
                label = Localizations.Statut.Realise
            default:
                label = Localizations.Statut.Engaged
            }
            textField.stringValue = label
            
        case .liee:
            if let liee = quake.operationLiee {
                textField.stringValue = liee.account?.name ?? ""
            } else {
                textField.stringValue = ""
            }
            
        case .checkNumber:
            if let number = quake.checkNumber {
                textField.stringValue = String(number)
            } else {
                textField.stringValue = ""
            }
            paragraph.alignment = .right
        }
        
        textField.sizeToFit()
        var attrs = colorText (quake: quake, propertyEnum: propertyEnum )
        
        attrs[ .paragraphStyle] = paragraph
        let attributText = NSMutableAttributedString(string: textField.stringValue)
        attributText.setAttributes(attrs, range: NSRange(location: 0, length: attributText.length))
        textField.attributedStringValue = attributText
        
        return cellView
    }
    
    func colorText (quake: EntityTransactions, propertyEnum: ListeOperationsDisplayProperty) -> [NSAttributedString.Key: Any]
    {
        var attrs = [NSAttributedString.Key: Any]()
        
        let type = Defaults.string(forKey: "choix couleurs") ?? "recette/depense"
        let typeOfColor = TypeOfColor(rawValue: type)
        
        switch typeOfColor {
        case .some(.unie):
            attrs[.foregroundColor] = NSColor.labelColor
            
        case .some(.income):
            switch propertyEnum {
            
            case .depense, .montant, .recette:
                if quake.amount >= 0.0 {
                    attrs[.foregroundColor] = NSColor.green
                } else {
                    attrs[.foregroundColor] = NSColor.red
                }
            //                attrs[.font] =  NSFont.boldSystemFont(ofSize: 12.0)
            
            case  .solde:
                if quake.solde >= 0.0 {
                    attrs[.foregroundColor] = NSColor.green
                } else {
                    attrs[.foregroundColor] = NSColor.red
                }
                attrs[.font] =  NSFont.boldSystemFont(ofSize: 12.0)
                
            default:
                break
            }
            
        case .some(.rubrique):
            let sousOperations = quake.sousOperations?.allObjects as! [EntitySousOperations]
            attrs[.foregroundColor] = sousOperations.first?.category?.rubric?.color
            
        case .some(.statut):
            let statutEnum = Statut.TypeOfStatut(rawValue: Int16(quake.statut))!
            attrs = statutEnum.attribut
            
        case .some(.mode):
            let color = quake.paymentMode?.color
            attrs[.foregroundColor] = color
            
        case .none:
            attrs[.foregroundColor] = NSColor.labelColor
        }
        return attrs
    }
    
    func colorSousOperations (quake: EntitySousOperations, propertyEnum: ListeOperationsDisplayProperty) -> [NSAttributedString.Key: Any]
    {
        var attrs = [NSAttributedString.Key: Any]()
        attrs[.foregroundColor] = NSColor.labelColor
        
        let type = Defaults.string(forKey: "choix couleurs") ?? "recette/depense"
        let typeOfColor = TypeOfColor(rawValue: type)
        
        switch typeOfColor {
        case .some(.unie):
            attrs[.foregroundColor] = NSColor.labelColor
            
        case .some(.income):
            switch propertyEnum {
            
            case .depense, .montant, .recette:
                if quake.amount >= 0.0 {
                    attrs[.foregroundColor] = NSColor.green
                } else {
                    attrs[.foregroundColor] = NSColor.red
                }
                
            case  .solde:
                break
            default:
                break
            }
            
        case .some(.rubrique):
            attrs[.foregroundColor] = quake.category?.rubric?.color
            
        case .some(.statut):
            break
        case .some(.mode):
            break
        case .none:
            break
        }
        return attrs
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if !isSourceGroupItem(item) {
            return 18.0
        } else {
            return 24.0
        }
    }
    
    // indicates whether a given row should be drawn in the “group row” style.
    public func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool
    {
        
        if item is TrackingMonth {
            return true
        }
        if item is TrackingIdTransactions {
            return true
        }
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        return MyNSTableRowView()
    }
    
    //    Show the expander triangle for group items..
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool
    {
        isSourceGroupItem(item)
    }
    
    //Returns a Boolean value that indicates whether the outline view should select a given item.
    public func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool
    {
        if item is TrackingSubOperations {
            return true
        }
        return false
    }
    
    func outlineViewItemWillCollapse(_ notification: Notification) {
        let ov = notification.object as? NSOutlineView
        ov!.autosaveExpandedItems = true
        
        let optionKeyIsDown = optionKeyPressed()
        if optionKeyIsDown == true && listTransactions.count > 0 {
//            ov!.animator().collapseItem(nil, collapseChildren: true)
        }
    }
    
    func outlineViewItemDidExpand(_ notification: Notification) {
        let ov = notification.object as? NSOutlineView
        ov!.autosaveExpandedItems = true

        let optionKeyIsDown = optionKeyPressed()
        if optionKeyIsDown == true && listTransactions.count > 0 {
            ov!.animator().expandItem(nil, expandChildren: true)
        }
    }
    
    func optionKeyPressed() -> Bool
    {
        let optionKey = NSEvent.modifierFlags.contains(NSEvent.ModifierFlags.option)
        return optionKey
    }
}
