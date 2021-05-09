import AppKit

@objc public protocol EcheanciersDelegate
{
    /// Called when a value has been selected inside the outline.
    func updateData()
}

final class SchedulerViewController: NSViewController {
    
    public weak var delegate: SchedulersSaisieDelegate?
    
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
        NotificationCenter.remove( instance: self, name: .updateAccount)
        NotificationCenter.remove( instance: self, name: .selectionDidChangeTable)
    }
    
    // -------------------------------------------------------------------------
    //    viewWillAppear
    // -------------------------------------------------------------------------
    override func viewWillAppear() {
        super.viewWillAppear()
        
        NotificationCenter.receive(instance: self, selector: #selector(updateChangeAccount), name: .updateAccount)
        NotificationCenter.receive(instance: self, selector: #selector(selectionDidChange), name: .selectionDidChangeTable)
    }
    
    override public func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Scheduler"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let id = currentAccount?.uuid.uuidString
        self.tableView.autosaveName = "saveEcheancier" + (id)!
        self.tableView.autosaveTableColumns = true
        
        updateData()
    }
    
    @objc func updateChangeAccount(_ notification: Notification) {
        updateData()
    }
    
    //NSTableViewDelegate
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
//        return MyNSTableRowView()
        return MenuTableRowView()
    }
    
    @IBAction func removeEcheanciers(_ sender: NSButton) {
        let selectedRow = tableView.selectedRow
        if selectedRow >= 0 {
            let quake = entityEcheancier[selectedRow]
            Echeanciers.shared.remove(entity: quake )
            updateData()
        }
    }
}

extension SchedulerViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return entityEcheancier.count
    }
}

extension SchedulerViewController: NSTableViewDelegate {
    
//    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
//            return MenuTableRowView()
//    }
//
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var result : NSTableCellView?
        let identifier = tableColumn!.identifier
        switch identifier {
        case .echLibelle :
            result = tableView.makeView(withIdentifier: .echLibelle, owner: self) as? NSTableCellView
            result?.textField?.stringValue = entityEcheancier[row].libelle!
        case .echDateDebut:
            result = tableView.makeView(withIdentifier: .echDateDebut, owner: self) as? NSTableCellView
            let time = entityEcheancier[row].dateDebut!
            let formatteddate = formatterDate.string(from: time)
            result?.textField?.stringValue = formatteddate
        case .echDateFin:
            result = tableView.makeView(withIdentifier: .echDateFin, owner: self) as? NSTableCellView
            let time = entityEcheancier[row].dateFin!
            let formatteddate = formatterDate.string(from: time)
            result?.textField?.stringValue = formatteddate
        case .echDateValeur:
            result = tableView.makeView(withIdentifier: .echDateValeur, owner: self) as? NSTableCellView
            let time = entityEcheancier[row].dateValeur!
            let formatteddate = formatterDate.string(from: time)
            result?.textField?.stringValue = formatteddate
        case .echOccurence:
            result = tableView.makeView(withIdentifier: .echOccurence, owner: self) as? NSTableCellView
            result?.textField?.intValue = Int32(entityEcheancier[row].occurence)
        case .echFrequence:
            result = tableView.makeView(withIdentifier: .echFrequence, owner: self) as? NSTableCellView
            result?.textField?.intValue = Int32(entityEcheancier[row].frequence)
        case .echModePaiement:
            result = tableView.makeView(withIdentifier: .echModePaiement, owner: self) as? NSTableCellView
            result?.textField?.stringValue = (entityEcheancier[row].paymentMode?.name)!
        case .echRubrique:
            result = tableView.makeView(withIdentifier: .echRubrique, owner: self) as? NSTableCellView
            result?.textField?.stringValue = (entityEcheancier[row].category?.rubric!.name)!
        case .echCategorie:
            result = tableView.makeView(withIdentifier: .echCategorie, owner: self) as? NSTableCellView
            result?.textField?.stringValue = (entityEcheancier[row].category?.name)!
        case .echMontant:
            result = tableView.makeView(withIdentifier: .echMontant, owner: self) as? NSTableCellView
            result?.textField?.doubleValue = entityEcheancier[row].amount
        case .account:
            result = tableView.makeView(withIdentifier: .account , owner: self) as? NSTableCellView
            result?.textField?.stringValue = entityEcheancier[row].account!.name!
        case .nameAccount:
            result = tableView.makeView(withIdentifier: .nameAccount, owner: self) as? NSTableCellView
            result?.textField?.stringValue = (entityEcheancier[row].account?.identity?.name)!
        case .surNameAccount:
            result = tableView.makeView(withIdentifier: .surNameAccount, owner: self) as? NSTableCellView
            result?.textField?.stringValue = (entityEcheancier[row].account?.identity?.surName)!
        case .numberAccount:
             result = tableView.makeView(withIdentifier: .numberAccount, owner: self) as? NSTableCellView
            result?.textField?.stringValue = (entityEcheancier[row].account?.initAccount?.codeAccount)!
        default:
            result = nil
        }
        return result
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
        return 30
    }
    
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

extension SchedulerViewController: EcheanciersDelegate {
    func updateData() {
        guard currentAccount != nil else { return }
        entityEcheancier = Echeanciers.shared.getAllDatas()
        tableView.reloadData()
    }
}
