import AppKit
//import SwiftDate
import TFDate

// ListTransactionsController -> OperationController
@objc public protocol ListeOperationsDelegate
{
    /// Called when a value has been selected inside the outline.
    func editionOperations(_ quakes: [EntityTransactions])
    func resetOperation()
}

// xxxxController -> ListTransactionsController
@objc public protocol  FilterDelegate
{
    func updateListeTransactions( liste: [EntityTransactions])
    func applyFilter( fetchRequest: NSFetchRequest<EntityTransactions>)
    func expandAll()
}

final class ListTransactionsController: NSViewController {
    
    public typealias TrackingYear           = [ GroupedYearOperations ]
    public typealias TrackingMonth          = GroupedYearOperations
    public typealias TrackingIdTransactions = GroupedMonthOperations
    public typealias TrackingSubOperations  = IdTransactions
    public typealias TrackingSubOperation   = EntitySousOperations
    
//    var theDocument = NSPersistentDocument()
    
    enum ListeOperationsDisplayProperty: String {
        case categorie
        case dateOperation
        case datePointage
        case depense
        case libelle
        case liee
        case mode
        case montant
        case recette
        case bankStatement
        case rubrique
        case solde
        case statut
        case checkNumber
    }
    
    enum TypeOfColor: String {
        case unie     = "unie"
        case income   = "recette/depense"
        case rubrique = "rubrique"
        case statut   = "statut"
        case mode     = "mode"
    }
    
    //    private let _undoManager = UndoManager()
    //    override var undoManager: UndoManager {
    //        return _undoManager
    //    }
    
    public weak var delegate: ListeOperationsDelegate?
    
    @IBOutlet weak var outlineListView: NSOutlineView!
    
    @IBOutlet weak var theBox1: NSBox!
    @IBOutlet weak var theBox2: NSBox!
    @IBOutlet weak var theBox3: NSBox!
    
    @IBOutlet weak var removeButton: NSButton!
    
    @IBOutlet weak var soldeBanque: NSTextField!
    @IBOutlet weak var soldeReel: NSTextField!
    @IBOutlet weak var soldeFinal: NSTextField!
    @IBOutlet weak var labelInfo: NSTextField!
    @IBOutlet weak var datePicker: TFDatePicker!
    
    @IBOutlet var menuTable: NSMenu!
    
    var colorBackGround = #colorLiteral(red: 0.8157508969, green: 0.8595363498, blue: 0.9023539424, alpha: 1)
    
    let attribute: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .bold),
        .foregroundColor: NSColor.black]
    
    var listTransactions = [EntityTransactions]()
    
    let formatterPrice: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        return formatter
    }()
    
    let formatterDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter
    }()
    
    /// the key in user defaults
    let kUserDefaultsKeyVisibleColumns = "kUserDefaultsKeyVisibleColumns"
    
    var groupedSorted = [ GroupedYearOperations ]()
    
    override func viewDidDisappear()
    {
        super.viewDidDisappear()
        NotificationCenter.remove( instance: self, name: .updateAccount )
        NotificationCenter.remove( instance: self, name: .selectionDidChangeOutLine)
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = Localizations.General.Liste_des_opérations
        self.resetChange()
    }
    
    // -----------------------------------------------------------------------
    //    viewWillAppear
    // listen for selection changes from the NSOutlineView inside MainWindowController
    // note: we start observing after our outline view is populated so we don't receive unnecessary notifications at startup
    // -----------------------------------------------------------------------
    override func viewWillAppear() {
        super.viewWillAppear()
        
        NotificationCenter.receive(instance: self, selector: #selector(updateChangeAccount(_:)), name: .updateAccount)
        NotificationCenter.receive(instance: self, selector: #selector(selectionDidChange(_:)), name: .selectionDidChangeOutLine)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createOutlineContextMenu()
        
        //vintage playback view
        self.theBox1.contentView?.isHidden = false
        self.theBox1.boxType = .custom
        //        self.theBox1.borderType = .bezelBorder
        self.theBox1.borderWidth = 1.1
        self.theBox1.cornerRadius = 3
        self.theBox1.fillColor = NSColor(patternImage: NSImage(named: NSImage.Name( "Gradient"))!)
        
        //vintage playback view
        self.theBox2.contentView?.isHidden = false
        self.theBox2.boxType = .custom
        //        self.theBox2.borderType = .bezelBorder
        self.theBox2.borderWidth = 1.1
        self.theBox2.cornerRadius = 3
        self.theBox2.fillColor = NSColor(patternImage: NSImage(named: NSImage.Name( "Gradient"))!)
        
        //vintage playback view
        self.theBox3.contentView?.isHidden = false
        self.theBox3.boxType = .custom
        //        self.theBox3.borderType = .bezelBorder
        self.theBox3.borderWidth = 1.1
        self.theBox3.cornerRadius = 3
        self.theBox3.fillColor = NSColor(patternImage: NSImage(named: NSImage.Name( "Gradient"))!)
        
        self.outlineListView.doubleAction = #selector(doubleClicked)
        
        self.outlineListView.rowSizeStyle = .custom
        self.outlineListView.allowsEmptySelection = true
        self.outlineListView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle

        let id = currentAccount?.uuid.uuidString
        outlineListView.sizeLastColumnToFit()

        self.outlineListView.autosaveName = "save" + (id)!
        self.outlineListView.autosaveExpandedItems = true
        self.outlineListView.autosaveTableColumns = true


        self.reloadData(false, true)

        outlineListView.menu = menuTable
    }
    
    // ------------------------------------------------------------------------
    //    dealloc
    // ------------------------------------------------------------------------
    deinit
    {
        NotificationCenter.remove(instance: self, name: .selectionDidChangeOutLine)
        NotificationCenter.remove(instance: self, name: .updateAccount)
    }

    func setUpDatePicker() {
        
        self.datePicker.delegate = self
        self.datePicker.allowEmptyDate = false
        self.datePicker.showPromptWhenEmpty = false
        self.datePicker.referenceDate = Date()
        self.datePicker.dateFieldPlaceHolder = ""
        self.datePicker.dateValue = (currentAccount?.dateEcheancier!)!
        self.datePicker.minDate = Date()
    }
    
    // Called when the a row in the sidebar is double clicked
    @objc private func doubleClicked(_ sender: Any?) {
        let clickedRow = outlineListView.item(atRow: outlineListView.clickedRow)
        
        if outlineListView.isItemExpanded(clickedRow) {
            outlineListView.collapseItem(clickedRow)
        } else {
            outlineListView.expandItem(clickedRow)
        }
    }
    
    @objc func updateChangeAccount(_ notification: Notification) {
        
        printTimeElapsedWhenRunningCode(title:"updateChangeAccount ") {
            
            let id = currentAccount?.uuid.uuidString
            self.outlineListView.autosaveName = "save" + (id)!
            
            self.datePicker.dateValue = (currentAccount?.dateEcheancier!)!
            self.delegate?.resetOperation()
            
            self.getAllData()
            self.reloadData(false, true)
            
            outlineListView.deselectAll(nil)
            self.resetChange()
        }
    }
    
    func resetChange() {
        self.removeButton.isHidden = true

        var amount  = 0.0
        var total   = 0.0
        var expense = 0.0
        var income  = 0.0
        var info    = ""
        var select  = ""
        var number  = 0
        
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        
        number = listTransactions.count
        for listTransaction in listTransactions {
            amount = listTransaction.amount
            total += amount
            if amount < 0 {
                expense += amount
            } else {
                income += amount
            }
        }
        
        let strAmount = formatter.string(from: total as NSNumber)!
        let strExpense = formatter.string(from: expense as NSNumber)!
        let strIncome = formatter.string(from: income as NSNumber)!
        
        if number < 2 {
            select =   Localizations.ListeOperation.transaction.singular(number)
        } else {
            select =   Localizations.ListeOperation.transaction.plural(number)
        }
        info = select + "  " + Localizations.ListeOperation.info(strExpense, strIncome, strAmount)
        
        let attributedText = NSAttributedString(string: info, attributes: attribute)
        self.labelInfo.attributedStringValue = attributedText
        
        self.delegate?.resetOperation()
    }
    
    @objc func selectionDidChange(_ notification: Notification) {
        
        guard let outlineView = notification.object as? NSOutlineView,
              outlineView == outlineListView else { return }
        
        let selectedRow = outlineView.selectedRowIndexes
        let selectRow = outlineView.selectedRow
        
        guard selectRow != -1 else {
            resetChange()
            return }
        
        let rowView = outlineView.rowView(atRow: selectRow, makeIfNecessary: false)
        rowView?.isEmphasized = true
        
        if selectedRow.isEmpty == false {
            
            self.removeButton.isHidden = false
            var transactionsSelected = [EntityTransactions]()
            
            var amount = 0.0
            var solde = 0.0
            var expense = 0.0
            var income = 0.0
            var select = ""
            
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.numberStyle = .currency
            
            for row in selectedRow {
                let item = outlineView.item(atRow: row) as? IdTransactions
                
                transactionsSelected.append((item?.entityTransactions)!)
                
                amount = (item?.entityTransactions.amount)!
                solde += amount
                if amount < 0 {
                    expense += amount
                } else {
                    income += amount
                }
            }
            
            // Info
            let amountStr = formatter.string(from: solde as NSNumber)!
            let strExpense = formatter.string(from: expense as NSNumber)!
            let strIncome = formatter.string(from: income as NSNumber)!
            let count = selectedRow.count
            
            if count < 2 {
                select =   Localizations.ListeOperation.transaction.selectionnee.singular(count)
            } else {
                select =   Localizations.ListeOperation.transaction.selectionnee.plural(count)
            }
            let info = select + Localizations.ListeOperation.info( strExpense, strIncome, amountStr)
            
            let attributedText = NSAttributedString(string: info, attributes: attribute)
            self.labelInfo.attributedStringValue = attributedText
            
            self.delegate?.editionOperations(transactionsSelected)
            self.becomeFirstResponder()
        }
    }
    
    func printTimeElapsedWhenRunningCode(title:String, operation:()->()) {
        let startTime = CFAbsoluteTimeGetCurrent()
        operation()
        let timeElapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        print("Time elapsed for \(title): \(timeElapsed) ms.")
    }
    
    private func transformData()
    {
        var groupedID : [ String:  [ String :  [IdTransactions] ] ] = [:]
        
        balanceCalculation()
        let IdOperation = (0 ..< listTransactions.count).map { (i) -> IdTransactions in
            return IdTransactions(year : listTransactions[i].sectionYear!, id: listTransactions[i].sectionIdentifier!, entityOperations: listTransactions[i])
        }
        
        // Grouped year / month
        let groupedYear = Dictionary(grouping: IdOperation, by: { $0.year })
        for (key, value) in groupedYear {
            let valueID = Dictionary(grouping: value, by: {$0.id})
            groupedID[key] = valueID
        }
        
        // convert to struct - more fast and easy to sort
        var allGroupedYear : [ GroupedYearOperations ] = []
        
        for grouped in groupedID {
            let groupedYear = GroupedYearOperations(dictionary: grouped)
            allGroupedYear.append(groupedYear)
        }
        groupedSorted = allGroupedYear.sorted(by: {$0.year > $1.year })
    }
    
    private func balanceCalculation()
    {
        let initCompte   = InitAccount.shared.getAllDatas()
        var soldeRealise = initCompte.realise
        var soldePrevu   = initCompte.prevu
        var soldeEngage  = initCompte.engage
        let initialBalance = soldePrevu + soldeEngage + soldeRealise
        let count        = listTransactions.count
        
        for index in stride(from: count - 1, to: -1, by: -1)
        {
            let propertyEnum = Statut.TypeOfStatut(rawValue: Int16(listTransactions[index].statut))!
            switch propertyEnum
            {
            case .planifie:
                soldePrevu += listTransactions[index].amount
            case .engage:
                soldeEngage += self.listTransactions[index].amount
            case .realise:
                soldeRealise += self.listTransactions[index].amount
            }
            listTransactions[index].solde = index == count - 1 ? listTransactions[index].amount + initialBalance : listTransactions[index + 1].solde + listTransactions[index ].amount
        }
        
        self.soldeBanque.doubleValue = soldeRealise
        self.soldeReel.doubleValue   = soldeRealise + soldeEngage
        self.soldeFinal.doubleValue  = soldeRealise + soldeEngage + soldePrevu
        
        NotificationCenter.send(.updateBalance)
    }
    
    @IBAction func removeTransaction(_ sender: Any) {
        let selectedRows = outlineListView.selectedRowIndexes
        guard selectedRows.isEmpty == false else { return }
        
        for selectedRow in selectedRows {
            let item = outlineListView.item(atRow: selectedRow) as? IdTransactions
            ListTransactions.shared.remove(entity: (item?.entityTransactions)!)
        }

        self.getAllData()
        self.outlineListView.reloadData()
        self.reloadData(true)
        
        self.resetChange()
    }
    
    @IBAction func compactTransaction(_ sender: Any) {
        let selectedRows = outlineListView.selectedRowIndexes
        guard selectedRows.isEmpty == false else { return }
        
        var listTransactions = [EntityTransactions]()
        
//        let context = mainObjectContext

//        var entityOperation = NSEntityDescription.insertNewObject(forEntityName: "EntityTransactions", into: context!) as? EntityTransactions

        for selectedRow in selectedRows {
            let item = outlineListView.item(atRow: selectedRow) as? IdTransactions
            listTransactions.append(item!.entityTransactions)
        }
        
//        for list in listTransactions {
//            ListTransactions.shared.remove(entity: list)
//        }
        
        self.getAllData()
        self.outlineListView.reloadData()
        self.reloadData(true)
        
        self.resetChange()
    }
}

extension ListTransactionsController: FilterDelegate {
    
    func applyFilter( fetchRequest: NSFetchRequest<EntityTransactions>) {
        
        let context = mainObjectContext
        
        do {
            listTransactions = try context!.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        transformData()
        reloadData(true, false)
        resetChange()
    }
    
    func updateListeTransactions( liste: [EntityTransactions]) {
        
        listTransactions = liste
        
        self.transformData()
        self.reloadData(true, false)
    }
}

extension ListTransactionsController: OperationsDelegate {
    
    func updateAccount() {
        
        self.datePicker.dateValue = (currentAccount?.dateEcheancier!)!
        self.delegate?.resetOperation()
        self.getAllData()
        self.reloadData()
        
        self.resetChange()
    }
    
    func getAllData() {
        
        listTransactions = ListTransactions.shared.getAllDatas(ascending: false)
        self.transformData()
    }
    
    func reloadData(_ expand: Bool = false,_ auto: Bool = false) {
        
        DispatchQueue.main.async {
            self.outlineListView.autosaveExpandedItems = false
            self.outlineListView.reloadData()
            self.outlineListView.autosaveExpandedItems = auto

            if expand == true {
                self.outlineListView.expandItem(nil, expandChildren: true)
                return
            }
            
            if self.outlineListView.autosaveExpandedItems,
               let autosaveName = self.outlineListView.autosaveName,
               let persistentObjects = UserDefaults.standard.array(forKey: "NSOutlineView Items \(autosaveName)"),
               let itemIds = persistentObjects as? [String] {
                let items = itemIds.sorted{ $0 < $1}
                items.forEach {
                    let item = self.outlineListView.dataSource?.outlineView?(self.outlineListView, itemForPersistentObject: $0)
                    if let item = item as? GroupedYearOperations {
                        self.outlineListView.expandItem(item)
                    }
                    if let item = item as? GroupedMonthOperations {
                        self.outlineListView.expandItem(item)
                    }
                }
            }
        }
    }
    
    func expandAll() {
        if listTransactions.count > 0 {
            self.outlineListView.expandItem(nil, expandChildren: true)
        }
    }
}
