import AppKit
//import ThemeKit

extension GroupeAccountViewController: NSOutlineViewDelegate {
    
    // return true to indicate a particular row should have the "group row" style drawn for that row, otherwise false.
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        let item = item as! EntityAccount
        return item.isHeader
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        let source = item as! EntityAccount
        if source.isHeader == true
        {
            return true
        }
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let entityAccount = item as! EntityAccount
        
        if entityAccount.isHeader == true {
            let view = outlineView.makeView(withIdentifier: .HeaderCell, owner: self) as! SourceListCellView
            
            view.textField?.stringValue = entityAccount.name!
            
            let count = entityAccount.children?.count ?? 0
            var num = ""
            switch count {
            case 0:
                num = " "
//                num = Localizations.General.Account.Zero
            case 1:
                num = Localizations.General.Account.Singular
            default:
                num = " "
//                num = Localizations.General.Account.Plural(count)
            }
            view.nbCompte.stringValue = num
            
            var total = 0.0
            
            let childrens = entityAccount.children
            for children in childrens! {
                let child = children as! EntityAccount
                total += child.solde
            }

            let formattedInLine = formatter.string(from: total as NSNumber)!
            view.inLine.title = formattedInLine
            view.inLine.wantsLayer = true
            view.inLine.layer?.backgroundColor = total >= 0 ? NSColor.green.cgColor : NSColor.red.cgColor
            view.inLine.layer?.cornerRadius = 7

            return view
        }
        
        if entityAccount.isFolder == true
        {
            let view = outlineView.makeView(withIdentifier: .FolderCell, owner: self) as! NSTableCellView
            view.textField?.stringValue = entityAccount.name!
            view.textField?.textColor = .textColor
            return view
        }
        
        if entityAccount.isAccount == true
        {
            let view = outlineView.makeView(withIdentifier: .AccountCell, owner: self) as! CompteListCellView
            let name = entityAccount.name ?? "vide"
            view.textField?.stringValue = name
            view.textField?.textColor = .textColor

            let titulaireNom = entityAccount.identity?.name ?? ""
            let titulairePrenom = entityAccount.identity?.surName ?? ""
            let titulaire = titulairePrenom + " " + titulaireNom
            view.titulaire.stringValue = titulaire
            
            let numCompte = entityAccount.initAccount?.codeAccount
            view.numCompte.stringValue = numCompte ?? ""
            
            let nameImage = entityAccount.nameImage!
            
            let image = NSImage(named: nameImage)
            image?.isTemplate = true
            view.imageView?.image =  image
            
            let formattedInLine = formatter.string(from: entityAccount.solde as NSNumber)!
            view.inLine.title = formattedInLine
            view.inLine.wantsLayer = true
            view.inLine.layer?.backgroundColor = entityAccount.solde >= 0 ? NSColor.green.cgColor : NSColor.red.cgColor
            view.inLine.layer?.cornerRadius = 7
            return view
        }
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        let source = item as! EntityAccount
        if source.isHeader == true {
            return 60.0
        }
        return 50.0
    }
    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        let rowView = MyNSTableRowView()
        return rowView
    }

}

