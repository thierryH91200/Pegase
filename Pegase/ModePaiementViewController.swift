import AppKit

final class ModePaiementViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    public weak var delegate: FilterDelegate?
    
    @IBOutlet weak var tablePaiementView: NSTableView!
    @IBOutlet weak var menuLocal: NSMenu!
    
    var modeModalWindowController: ModeModalWindowController!
    var entityPreference: EntityPreference?
    
    var entityModePaiement =  [EntityPaymentMode]()
    
    // -------------------------------------------------------------------------------
    //    viewWillAppear
    // -------------------------------------------------------------------------------
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // listen for selection changes from the NSOutlineView inside MainWindowController
        // note: we start observing after our outline view is populated so we don't receive unnecessary notifications at startup
        NotificationCenter.receive(instance: self, name: .selectionDidChangeTable, selector: #selector(selectionDidChange(_:)))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.receive( instance: self, name: .updateAccount, selector: #selector(updateChangeAccount))
        
        updateData()
    }
    
    @objc func updateChangeAccount(_ note: Notification) {
        
        updateData()
    }
    
    @objc func selectionDidChange(_ notification: Notification) {
        
        guard let tableView = notification.object as? NSTableView,
            tableView == tablePaiementView else { return }
        
        let selectedRow = tableView.selectedRow
        if selectedRow >= 0 {
            let quake = entityModePaiement[selectedRow]
            let label = quake.name!
            
            let p1 = NSPredicate(format: "account == %@", currentAccount!)
            let p2 = NSPredicate(format: "modePaiement.name == %@", label)
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [ p1, p2])
            
            let fetchRequest = NSFetchRequest<EntityOperations>(entityName: "EntityOperations")
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: true)]
            
            delegate?.applyFilter(fetchRequest: fetchRequest)
        }
    }
    
    func updateData() {
        guard currentAccount != nil else { return }
        
        entityModePaiement = PaymentMode.shared.getAllDatas()
    }
    
    // MARK: - Add ModePaiement
    @IBAction func addModePaiement(_ sender: Any) {
        self.modeModalWindowController = ModeModalWindowController()
        let windowAdd = modeModalWindowController.window!
        let windowApp = self.view.window
        windowApp?.beginSheet( windowAdd, completionHandler: {(_ returnCode: NSApplication.ModalResponse) -> Void in
            
            switch returnCode {
            case .OK:
                
                let name          = self.modeModalWindowController.name.stringValue
                let color         = self.modeModalWindowController.colorWell.color
                
                let entityMode        = NSEntityDescription.insertNewObject(forEntityName: "EntityPaymentMode", into: mainObjectContext) as! EntityPaymentMode
                entityMode.name       = name
                entityMode.color     = color
                
                entityMode.uuid = UUID()
                entityMode.account = currentAccount
                
            case .cancel:
                break
                
            default:
                break
            }
            self.modeModalWindowController = nil
        })
    }
    
    @IBAction func editModePaiement(_ sender: Any) {
        
        if let entityMode = self.entityModePaiement.first {
            
            self.modeModalWindowController = ModeModalWindowController()
            modeModalWindowController.edition = true
            modeModalWindowController.namePaiement = entityMode.name ?? ""
            modeModalWindowController.colorPaiement = entityMode.color as! NSColor
            
            let windowAdd = modeModalWindowController.window!
            let windowApp = self.view.window
            windowApp?.beginSheet( windowAdd, completionHandler: {(_ returnCode: NSApplication.ModalResponse) -> Void in
                
                switch returnCode {
                case .OK:
                    entityMode.name       = self.modeModalWindowController.name.stringValue
                    entityMode.color     = self.modeModalWindowController.colorWell.color
                    
                case .cancel:
                    break
                    
                default:
                    break
                }
                self.modeModalWindowController = nil
            })
        }
    }
    
    @IBAction func removeModePaiement(_ sender: Any) {
        
//                let selectedModePaiement = self.arrayController.selectedObjects.first as! EntityModePaiement
//                self.entityPreference = Preference.shared.getAll()
//
//                if self.entityPreference?.modePaiement == selectedModePaiement {
//                    let alert = NSAlert()
//                    alert.alertStyle = NSAlert.Style.critical
//                    alert.icon = nil
//                    alert.messageText = Localizations.Mode.Impossible
//                    alert.runModal()
//                    return
//                }
//
//                let alert = NSAlert()
//                alert.messageText = Localizations.Mode.MessageText
//                alert.informativeText = Localizations.Mode.InformativeText
//                alert.addButton(withTitle: Localizations.Mode.Delete)
//                alert.addButton(withTitle: Localizations.General.Cancel)
//                alert.alertStyle = NSAlert.Style.informational
//
//                alert.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
//                    if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
//
//                        let newModePaiement = (self.entityPreference?.modePaiement)!
//                        self.changeModePaiement(oldModePaiement: selectedModePaiement, newModePaiement: newModePaiement )
//                        self.arrayController.removeObject(selectedModePaiement)
//                    }
//                })
    }
    
    func changeModePaiement(oldModePaiement: EntityPaymentMode, newModePaiement: EntityPaymentMode) {
        var listeOperations = [EntityOperations]()
        
        let p1 = NSPredicate(format: "account == %@", currentAccount!)
        let p2 = NSPredicate(format: "modePaiement.name == %@", oldModePaiement.name!)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])
        
        let fetchRequest = NSFetchRequest<EntityOperations>(entityName: "EntityOperations")
        fetchRequest.predicate = predicate
        
        do {
            listeOperations = try mainObjectContext.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        
        for listeOperation in listeOperations {
            listeOperation.paymentMode = newModePaiement
        }
    }
    
    @IBAction func changeCouleur(_ sender: NSColorWell)
    {
        let row = tablePaiementView.row(for: sender as NSView)
        guard  row != -1 else { return }
        
        let color = sender.color
        let item = entityModePaiement[row]
        item.color = color
        
        let select: IndexSet = [row]
        tablePaiementView.selectRowIndexes(select, byExtendingSelection: false)
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return entityModePaiement.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = tableColumn!.identifier
        switch identifier {
        case .mpName :
            let result = tableView.makeView(withIdentifier: .mpName, owner: self) as! NSTableCellView
            result.textField?.stringValue = entityModePaiement[row].name!
            return result
            
        case .account:
            let result = tableView.makeView(withIdentifier: .account , owner: self) as! NSTableCellView
            result.textField?.stringValue = entityModePaiement[row].account!.name!
            return result
            
        case .mpColor:
            let result = tableView.makeView(withIdentifier: .mpColor, owner: self) as! KSHeaderCellView4
            result.colorWell.color = entityModePaiement[row].color as! NSColor
            return result
            
        case .nameAccount:
            let result = tableView.makeView(withIdentifier: .nameAccount, owner: self) as! NSTableCellView
            result.textField?.stringValue = (entityModePaiement[row].account?.identity?.name)!
            return result
            
        case .surNameAccount:
            let result = tableView.makeView(withIdentifier: .surNameAccount, owner: self) as! NSTableCellView
            result.textField?.stringValue = (entityModePaiement[row].account?.identity?.surName)!
            return result
            
        case .numberAccount:
            let result = tableView.makeView(withIdentifier: .numberAccount, owner: self) as! NSTableCellView
            result.textField?.stringValue = (entityModePaiement[row].account?.initAccount?.codeAccount)!
            return result
            
        default:
            return nil
            
        }
    }
}

