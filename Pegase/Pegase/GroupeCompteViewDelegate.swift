import AppKit
//import ThemeKit

extension GroupeCompteViewController: NSOutlineViewDelegate {
    
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
        let entityCompte = item as! EntityAccount
        
        if entityCompte.isHeader == true {
            let view = outlineView.makeView(withIdentifier: .HeaderCell, owner: self) as! SourceListCellView
            
            view.textField?.stringValue = entityCompte.name!
            
            let count = entityCompte.children?.count ?? 0
            var num = ""
            switch count {
            case 0:
                num = Localizations.General.Compte.Zero
            case 1:
                num = Localizations.General.Compte.Singular
            default:
                num = Localizations.General.Compte.Plural(count)
            }
            view.nbCompte.stringValue = num
            
            var total = 0.0
            
            let childrens = entityCompte.children
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
        
        if entityCompte.isFolder == true
        {
            let view = outlineView.makeView(withIdentifier: .FolderCell, owner: self) as! NSTableCellView
            view.textField?.stringValue = entityCompte.name!
            return view
        }
        
        if entityCompte.isAccount == true
        {
            let view = outlineView.makeView(withIdentifier: .AccountCell, owner: self) as! CompteListCellView
            let name = entityCompte.name ?? "vide"
            view.textField?.stringValue = name
            
            let titulaireNom = entityCompte.identite?.idName ?? ""
            let titulairePrenom = entityCompte.identite?.idPrenom ?? ""
            let titulaire = titulairePrenom + " " + titulaireNom
            view.titulaire.stringValue = titulaire
            
            let numCompte = entityCompte.initCompte?.codeCompte
            view.numCompte.stringValue = numCompte ?? ""
            
            let nameImage = entityCompte.nameImage!
            
            let image = NSImage(named: nameImage)
            image?.isTemplate = true
            view.imageView?.image =  image
            
            let formattedInLine = formatter.string(from: entityCompte.solde as NSNumber)!
            view.inLine.title = formattedInLine
            view.inLine.wantsLayer = true
            view.inLine.layer?.backgroundColor = entityCompte.solde >= 0 ? NSColor.green.cgColor : NSColor.red.cgColor
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

