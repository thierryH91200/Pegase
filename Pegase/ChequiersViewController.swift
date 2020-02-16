import AppKit

final class ChequiersViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var arrayController: NSArrayController!
    @IBOutlet weak var menuLocal: NSMenu!
    
    @objc dynamic var mainContext: NSManagedObjectContext! = mainObjectContext
    @objc dynamic var predicate =  NSPredicate(format: "account == %@", compteCourant!)
    
    var chequierModalWindowController: ChequierModalWindowController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.receive(instance: self, name: .updateAccount, selector: #selector(updateChangeCompte(_:)))
        mainContext = mainObjectContext
        
        tableView.rowHeight = 24.0
        updateData()
    }
    
    @objc func updateChangeCompte(_ note: Notification) {
        updateData()
    }
    
    func updateData() {
        guard compteCourant != nil else { return }
        arrayController.filterPredicate = NSPredicate(format: "account == %@", compteCourant!)
    }
    
    @IBAction func editChequier(_ sender: Any) {
        
        if let entityCheck = arrayController.selectedObjects.first as? EntityCarnetCheques {
            
            self.chequierModalWindowController = ChequierModalWindowController()
            self.chequierModalWindowController.entityCarnetCheques = entityCheck
            self.chequierModalWindowController.edition = true
            
            let windowAdd = chequierModalWindowController.window!
            let windowApp = self.view.window
            windowApp?.beginSheet( windowAdd, completionHandler: {(_ returnCode: NSApplication.ModalResponse) -> Void in
                
                switch returnCode {
                case .OK:
                    
                    entityCheck.name       = self.chequierModalWindowController.name.stringValue
                    entityCheck.prefix     = self.chequierModalWindowController.prefix.stringValue
                    entityCheck.numPremier = self.chequierModalWindowController.numFirst.intValue
                    entityCheck.numSuivant = self.chequierModalWindowController.numNext.intValue
                    entityCheck.nbCheques  = self.chequierModalWindowController.numberCheques.intValue
                
                case .cancel:
                    print("Cancel button tapped in Custom addCompte Sheet")
                
                default:
                    break
                }
                self.chequierModalWindowController = nil
            })
        }
        arrayController.filterPredicate = NSPredicate(format: "account == %@", compteCourant!)
    }
    
    
    @IBAction func addChequier(_ sender: Any) {
        
        self.chequierModalWindowController = ChequierModalWindowController()
        let windowAdd = chequierModalWindowController.window!
        let windowApp = self.view.window
        windowApp?.beginSheet( windowAdd, completionHandler: {(_ returnCode: NSApplication.ModalResponse) -> Void in
            
            switch returnCode {
            case .OK:
                
                let name          = self.chequierModalWindowController.name.stringValue
                let prefix        = self.chequierModalWindowController.prefix.stringValue
                let numFirst      = self.chequierModalWindowController.numFirst.intValue
                let numNext       = self.chequierModalWindowController.numNext.intValue
                let numberCheques = self.chequierModalWindowController.numberCheques.intValue
                
                let entityCarnetCheques        = NSEntityDescription.insertNewObject(forEntityName: "EntityCarnetCheques", into: mainObjectContext) as! EntityCarnetCheques
                entityCarnetCheques.name       = name
                entityCarnetCheques.prefix     = prefix
                entityCarnetCheques.numPremier = numFirst
                entityCarnetCheques.numSuivant = numNext
                entityCarnetCheques.nbCheques  = numberCheques
                
                entityCarnetCheques.uuid = UUID()
                entityCarnetCheques.account = compteCourant
            
            case .cancel:
                break
            default:
                break
            }
            self.chequierModalWindowController = nil
        })
        arrayController.filterPredicate = NSPredicate(format: "account == %@", compteCourant!)
    }
    
    @IBAction func removeChequierAction(_ sender: Any) {
        
        let alert = NSAlert()
        alert.messageText = Localizations.Check.MessageText
        alert.informativeText = Localizations.Check.InformativeText
        alert.addButton(withTitle: Localizations.Check.Delete)
        alert.addButton(withTitle: Localizations.General.Cancel)
        alert.alertStyle = NSAlert.Style.informational
        
        alert.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                print("Document 🗑")
                if let selectedCheck = self.arrayController.selectedObjects.first as? EntityCarnetCheques {
                    self.arrayController.removeObject(selectedCheck)
                }
            }
        })
    }
    
    
}
