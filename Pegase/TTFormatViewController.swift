import AppKit

protocol TTFormatViewControllerDelegate: class {
    func configurationChanged(for formatViewController: TTFormatViewController?)
}

final class TTFormatViewController: NSViewController {
    
    var config = CSV.Configuration()
    weak var delegate: TTFormatViewControllerDelegate?
    
    @IBOutlet weak var horizontal1: NSBox!
    @IBOutlet weak var gridView: NSGridView!

    @IBOutlet weak var filePath: NSPathControl!
    
    @IBOutlet weak var nameCompte: NSTextField!
    @IBOutlet weak var nomTitulaire: NSTextField!
    @IBOutlet weak var prenomTitulaire: NSTextField!

    @IBOutlet var escapeControl: NSSegmentedControl!
    @IBOutlet var separatorControl: NSSegmentedControl!
    @IBOutlet var decimalControl: NSSegmentedControl!
    @IBOutlet var encodingMenu: NSPopUpButton!
    @IBOutlet var useFirstRowAsHeaderCheckbox: NSButton!
    @IBOutlet weak var importButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    
    @IBOutlet weak var formatDate: NSTextField!
    @IBOutlet weak var popUpCompte: NSPopUpButton!
    
    var entityAccountTransfert: EntityAccount?
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        encodingMenu.removeAllItems()
        for encoding in CSV.Configuration.supportedEncodings()! {
            let item = NSMenuItem(title: (encoding[0] as? String)!, action: nil, keyEquivalent: "")
            item.tag = encoding[1] as! Int
            encodingMenu.menu?.addItem(item)
        }
        encodingMenu.selectItem(withTag: 0x1e)
        useFirstRowAsHeaderCheckbox.state = .on
        
        filePath?.isEditable = false
        if popUpCompte != nil {
            loadAccount ()
            popUpCompte.selectItem(withTitle: (currentAccount?.initCompte?.codeCompte)!)
        }
        
        if self.gridView != nil {
            let cell1 = gridView.cell(for: horizontal1)!
            cell1.row!.topPadding = 4
            cell1.row!.mergeCells(in: NSMakeRange(0, 2))
        }
    }
    
    @IBAction func updateConfiguration(_ sender: Any) {
        
        config.encoding = String.Encoding(rawValue: UInt(encodingMenu.selectedTag()))
        if separatorControl.selectedSegment == 2 {
            config.delimiter = "\t"
        } else {
            let delimiter = UnicodeScalar(separatorControl.label(forSegment: separatorControl.selectedSegment)!)
            config.delimiter = delimiter!
        }
        
        config.decimalMark = decimalControl.label(forSegment: decimalControl.selectedSegment)!
        
        if escapeControl.selectedSegment == 0 || escapeControl.selectedSegment == 1 {
            config.quoteCharacter = "\""
        } else {
            config.quoteCharacter = "'"
            config.escapeCharacter = ""
        }
        
        config.escapeCharacter = (escapeControl.label(forSegment: escapeControl.selectedSegment))!
        config.isFirstRowAsHeader = useFirstRowAsHeaderCheckbox.state == .on
        delegate?.configurationChanged(for: self)
    }
    
    func selectFormatByConfig() {
        
        encodingMenu.selectItem(withTag: Int(config.encoding.rawValue))
        
        if config.delimiter == "," {
            separatorControl.selectSegment(withTag: 0)
        } else if config.delimiter == ";" {
            separatorControl.selectSegment(withTag: 1)
        } else {
            separatorControl.selectSegment(withTag: 2)
        }
        
        if config.decimalMark == "." {
            decimalControl.selectSegment(withTag: 0)
        } else {
            decimalControl.selectSegment(withTag: 1)
        }
        
        if config.escapeCharacter == "\"" {
            escapeControl.selectSegment(withTag: 0)
        } else if config.escapeCharacter == "\\" {
            escapeControl.selectSegment(withTag: 1)
        } else {
            escapeControl.selectSegment(withTag: 2)
        }
        useFirstRowAsHeaderCheckbox.state = config.isFirstRowAsHeader ? .on : .off
    }
    
    func loadAccount () {
        let  transfertMenu = NSMenu()
        popUpCompte.removeAllItems()
        
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
        popUpCompte.menu = transfertMenu
        
        let selectItem = popUpCompte.selectedItem
        let compte = selectItem?.representedObject as? EntityAccount
        
        nameCompte.stringValue = (compte?.name)!
        nomTitulaire.stringValue = (compte?.identite?.idName)!
        prenomTitulaire.stringValue = (compte?.identite?.idPrenom)!
    }
    
    fileprivate func compteItemFor(_ account: EntityAccount) -> NSMenuItem {
        let codeCompte = account.initCompte?.codeCompte!
        let menuItem = NSMenuItem()
        
        menuItem.representedObject = account
        menuItem.title = codeCompte!
        menuItem.action = #selector(optionCompte(sender:))
        menuItem.target = self
        menuItem.keyEquivalent = ""
        menuItem.isEnabled = true
        return menuItem
    }
    
    @objc func optionCompte( sender: NSMenuItem)
    {
        let selectItem = popUpCompte.selectedItem
        let compte = selectItem?.representedObject as? EntityAccount
        
        entityAccountTransfert = compte
        
        nameCompte.stringValue = (compte?.name)!
        nomTitulaire.stringValue = (compte?.identite?.idName)!
        prenomTitulaire.stringValue = (compte?.identite?.idPrenom)!
    }
    
}
