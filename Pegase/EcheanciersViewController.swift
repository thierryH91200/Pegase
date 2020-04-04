import AppKit

@objc public protocol EcheanciersDelegate
{
    /// Called when a value has been selected inside the outline.
    func updateData()
    
}

final class EcheanciersViewController: NSViewController {
    
    public weak var delegate: EcheanciersSaisieDelegate?
    
    @IBOutlet weak var tableView: NSTableView!
    var entityEcheancier =  [EntitySchedule]()
    
    let formatterDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter
    }()
    
    public override func viewDidDisappear()
    {
        super.viewDidDisappear()
        print("EcheanciersViewController viewDidDisappear : ", "updateCompte")
        NotificationCenter.remove( instance: self, name: .updateAccount)
        NotificationCenter.remove( instance: self, name: .selectionDidChangeTable)
    }
    
    // -------------------------------------------------------------------------
    //    viewWillAppear
    // -------------------------------------------------------------------------
    override func viewWillAppear() {
        super.viewWillAppear()
        
        NotificationCenter.receive(instance: self, name: .updateAccount, selector: #selector(updateChangeAccount))
        NotificationCenter.receive(instance: self, name: .selectionDidChangeTable, selector: #selector(selectionDidChange))
    }
    
    override public func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Scheduler"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        mainContext = mainObjectContext
        updateData()
    }
    
    @objc func updateChangeAccount(_ note: Notification) {
        updateData()
    }
    
    //NSOutlineViewDelegate
    @objc func selectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else { return }
        
        let selectedRow = tableView.selectedRow
        if selectedRow >= 0 {
            let quake = entityEcheancier[selectedRow]
            delegate?.editionData( quake )
            
        } else {
            delegate?.razData()
        }
    }
    
    func tableView( _ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return MyNSTableRowView()
    }
    
    @IBAction func removeEcheanciers(_ sender: NSButton) {
        let selectedRow = tableView.selectedRow
        if selectedRow >= 0 {
            let quake = entityEcheancier[selectedRow]
            Echeanciers.shared.remove(entity: quake )
        }
    }
}

extension EcheanciersViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return entityEcheancier.count
    }
}

extension EcheanciersViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = tableColumn!.identifier
        switch identifier {
        case .echLibelle :
            let result = tableView.makeView(withIdentifier: .echLibelle, owner: self) as! NSTableCellView
            result.textField?.stringValue = entityEcheancier[row].libelle!
            return result
            
        case .echDateDebut:
            let result = tableView.makeView(withIdentifier: .echDateDebut, owner: self) as! NSTableCellView
            let time = entityEcheancier[row].dateDebut!
            let formatteddate = formatterDate.string(from: time)
            result.textField?.stringValue = formatteddate
            return result
        case .echDateFin:
            let result = tableView.makeView(withIdentifier: .echDateFin, owner: self) as! NSTableCellView
            let time = entityEcheancier[row].dateFin!
            let formatteddate = formatterDate.string(from: time)
            result.textField?.stringValue = formatteddate
            return result
        case .echDateValeur:
            let result = tableView.makeView(withIdentifier: .echDateValeur, owner: self) as! NSTableCellView
            let time = entityEcheancier[row].dateValeur!
            let formatteddate = formatterDate.string(from: time)
            result.textField?.stringValue = formatteddate
            return result
            
        case .echOccurence:
            let result = tableView.makeView(withIdentifier: .echOccurence, owner: self) as! NSTableCellView
            result.textField?.intValue = Int32(entityEcheancier[row].occurence)
            return result
        case .echFrequence:
            let result = tableView.makeView(withIdentifier: .echFrequence, owner: self) as! NSTableCellView
            result.textField?.intValue = Int32(entityEcheancier[row].frequence)
            return result
        case .echModePaiement:
            let result = tableView.makeView(withIdentifier: .echModePaiement, owner: self) as! NSTableCellView
            result.textField?.stringValue = (entityEcheancier[row].modePaiement?.name)!
            return result
            
        case .echRubrique:
            let result = tableView.makeView(withIdentifier: .echRubrique, owner: self) as! NSTableCellView
            result.textField?.stringValue = (entityEcheancier[row].category?.rubric!.name)!
            return result
        case .echCategorie:
            let result = tableView.makeView(withIdentifier: .echCategorie, owner: self) as! NSTableCellView
            result.textField?.stringValue = (entityEcheancier[row].category?.name)!
            return result
        case .echMontant:
            let result = tableView.makeView(withIdentifier: .echMontant, owner: self) as! NSTableCellView
            result.textField?.doubleValue = entityEcheancier[row].amount
            return result
            
        case .account:
            let result = tableView.makeView(withIdentifier: .account , owner: self) as! NSTableCellView
            result.textField?.stringValue = entityEcheancier[row].account!.name!
            return result
        case .nameAccount:
            let result = tableView.makeView(withIdentifier: .nameAccount, owner: self) as! NSTableCellView
            result.textField?.stringValue = (entityEcheancier[row].account?.identity?.name)!
            return result
        case .surNameAccount:
            let result = tableView.makeView(withIdentifier: .surNameAccount, owner: self) as! NSTableCellView
            result.textField?.stringValue = (entityEcheancier[row].account?.identity?.surName)!
            return result
            
        case .numberAccount:
            let result = tableView.makeView(withIdentifier: .numberAccount, owner: self) as! NSTableCellView
            result.textField?.stringValue = (entityEcheancier[row].account?.initAccount?.codeAccount)!
            return result
            
        default:
            return nil
            
        }
    }
    
    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
        switch edge {
        case .trailing:
            let flagAction = NSTableViewRowAction(style: .regular, title: "Flag") { (_, _) in
                print("Flag Action")
            }

            return [makeDeleteAction(), flagAction]
        case .leading:
            return []
        @unknown default:
            return []
        }
    }
    
    func tableView(_: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 60
    }


//    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
//
//        if edge == .trailing {
//            let deleteAction = NSTableViewRowAction(style: .destructive, title: "Delete") { (_, _) in
//                let quake = self.entityEcheancier[row]
//                Echeanciers.shared.remove(entity: quake )
//                self.updateData()
//            }
//            let flagAction = NSTableViewRowAction(style: .regular, title: "Flag") { (_, _) in
//                print("Flag")
//            }
//            return [makeDeleteAction(), flagAction]
//        }
//        return []
//    }
    
    private func makeDeleteAction() -> NSTableViewRowAction {
        let a = NSTableViewRowAction(
            style: .destructive,
            title: "Delete", //NSLocalizedString("TouchBar.Delete", comment: "Touch Bar"),
            handler: removeRowAndRecord
        )
            a.image = NSImage(named: NSImage.touchBarDeleteTemplateName)
        return a
    }
    
    private func removeRowAndRecord(action: NSTableViewRowAction, row: Int) {
        let quake = self.entityEcheancier[row]
        Echeanciers.shared.remove(entity: quake )
        self.updateData()
    }

}

extension EcheanciersViewController: EcheanciersDelegate {
    func updateData() {
        guard currentAccount != nil else { return }
        entityEcheancier = Echeanciers.shared.getAllDatas()
        
        tableView.reloadData()
    }
    
}
