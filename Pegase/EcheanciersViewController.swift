import AppKit

@objc public protocol EcheanciersDelegate
{
    /// Called when a value has been selected inside the outline.
    func updateData()
    
}

final class EcheanciersViewController: NSViewController {
    
    public weak var delegate: EcheanciersSaisieDelegate?
    
    @IBOutlet weak var tableView: NSTableView!
    var entityEcheancier =  [EntityEcheancier]()
    
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
            
            Echeanciers.shared.removeEntity(entity: quake )
        }
    }
}
extension EcheanciersViewController: NSTableViewDelegate, NSTableViewDataSource {

    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return entityEcheancier.count
    }
    
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
            result.textField?.stringValue = (entityEcheancier[row].category?.rubrique!.name)!
            return result
        case .echCategorie:
            let result = tableView.makeView(withIdentifier: .echCategorie, owner: self) as! NSTableCellView
            result.textField?.stringValue = (entityEcheancier[row].category?.name)!
            return result
        case .echMontant:
            let result = tableView.makeView(withIdentifier: .echMontant, owner: self) as! NSTableCellView
            result.textField?.doubleValue = entityEcheancier[row].amount
            return result
            
        case .Account:
            let result = tableView.makeView(withIdentifier: .Account , owner: self) as! NSTableCellView
            result.textField?.stringValue = entityEcheancier[row].account!.name!
            return result
        case .NameAccount:
            let result = tableView.makeView(withIdentifier: .NameAccount, owner: self) as! NSTableCellView
            result.textField?.stringValue = (entityEcheancier[row].account?.identite?.idName)!
            return result
        case .SurNameAccount:
            let result = tableView.makeView(withIdentifier: .SurNameAccount, owner: self) as! NSTableCellView
            result.textField?.stringValue = (entityEcheancier[row].account?.identite?.idPrenom)!
            return result
            
        case .NumberAccount:
            let result = tableView.makeView(withIdentifier: .NumberAccount, owner: self) as! NSTableCellView
            result.textField?.stringValue = (entityEcheancier[row].account?.initCompte?.codeCompte)!
            return result
            
        default:
            return nil
            
        }
    }
    
}

extension EcheanciersViewController: EcheanciersDelegate {
    func updateData() {
        guard compteCourant != nil else { return }
        entityEcheancier = Echeanciers.shared.getAll()
        
        tableView.reloadData()
    }
    
}
