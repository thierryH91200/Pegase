import AppKit

final class ModePaiementViewController: NSViewController, NSTableViewDelegate
{
    public weak var delegate: FilterDelegate?
    
    @IBOutlet weak var tablePaiementView: NSTableView!
    @IBOutlet var arrayController: NSArrayController!
    @IBOutlet weak var menuLocal: NSMenu!
    
    var modeModalWindowController: ModeModalWindowController!
    var entityPreference: EntityPreference?
    
    @objc dynamic var mainContext: NSManagedObjectContext! = mainObjectContext
    @objc dynamic var customSortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))]
    
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
        
        mainContext = mainObjectContext
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
            let quake = arrayController.selectedObjects[0] as! EntityModePaiement
            let label = quake.name!
            
            let p1 = NSPredicate(format: "account == %@", compteCourant!)
            let p2 = NSPredicate(format: "modePaiement.name == %@", label)
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [ p1, p2])
            
            let fetchRequest = NSFetchRequest<EntityOperations>(entityName: "EntityOperations")
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: true)]
            
            delegate?.applyFilter(fetchRequest: fetchRequest)
        }
    }
    
    func updateData() {
        guard compteCourant != nil else { return }
        
        _ = ModePaiement.shared.getAll()
        arrayController.filterPredicate = NSPredicate(format: "account == %@", compteCourant!)
    }
    
    // MARK: - ModePaiement
    @IBAction func addModePaiement(_ sender: NSButton) {
        self.modeModalWindowController = ModeModalWindowController()
        let windowAdd = modeModalWindowController.window!
        let windowApp = self.view.window
        windowApp?.beginSheet( windowAdd, completionHandler: {(_ returnCode: NSApplication.ModalResponse) -> Void in
            
            switch returnCode {
            case .OK:
                
                let name          = self.modeModalWindowController.name.stringValue
                let color         = self.modeModalWindowController.colorWell.color
                
                let entityMode        = NSEntityDescription.insertNewObject(forEntityName: "EntityModePaiement", into: mainObjectContext) as! EntityModePaiement
                entityMode.name       = name
                entityMode.color     = color
                
                entityMode.uuid = UUID()
                entityMode.account = compteCourant
            
            case .cancel:
                break
            
            default:
                break
            }
            self.modeModalWindowController = nil
        })
        arrayController.filterPredicate = NSPredicate(format: "account == %@", compteCourant!)
    }
    
    @IBAction func editModePaiement(_ sender: NSButton) {
        
        if let entityMode = self.arrayController.selectedObjects.first as? EntityModePaiement {
            
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
            arrayController.filterPredicate = NSPredicate(format: "account == %@", compteCourant!)
        }
    }
    
    @IBAction func removeModePaiement(_ sender: NSButton) {
        
        let selectedModePaiement = self.arrayController.selectedObjects.first as! EntityModePaiement
        self.entityPreference = Preference.shared.getAll()
        
        if self.entityPreference?.modePaiement == selectedModePaiement {
            let alert = NSAlert()
            alert.alertStyle = NSAlert.Style.critical
            alert.icon = nil
            alert.messageText = Localizations.Mode.Impossible
            alert.runModal()
            return
        }
        
        let alert = NSAlert()
        alert.messageText = Localizations.Mode.MessageText
        alert.informativeText = Localizations.Mode.InformativeText
        alert.addButton(withTitle: Localizations.Mode.Delete)
        alert.addButton(withTitle: Localizations.General.Cancel)
        alert.alertStyle = NSAlert.Style.informational
        
        alert.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                
                let newModePaiement = (self.entityPreference?.modePaiement)!
                self.changeModePaiement(oldModePaiement: selectedModePaiement, newModePaiement: newModePaiement )
                self.arrayController.removeObject(selectedModePaiement)
            }
        })
    }
    
    func changeModePaiement(oldModePaiement: EntityModePaiement, newModePaiement: EntityModePaiement) {
        var listeOperations = [EntityOperations]()
        
        let p1 = NSPredicate(format: "account == %@", compteCourant!)
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
            listeOperation.modePaiement = newModePaiement
        }
    }
    
    @IBAction func changeCouleur(_ sender: NSColorWell)
    {
        let row = tablePaiementView.row(for: sender as NSView)
        guard  row != -1 else { return }
        
        let color = sender.color
        
        let item = arrayController.selectedObjects
        let result = item is [EntityModePaiement]
        if result == true && !(item?.isEmpty)! {
            let entityModePaiement = item![0] as! EntityModePaiement
            
            entityModePaiement.color = color
            
            let select: IndexSet = [row]
            tablePaiementView.selectRowIndexes(select, byExtendingSelection: false)
        }
    }
    
}

