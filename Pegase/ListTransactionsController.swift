import AppKit
//import SwiftDate
import TFDate

// ListeOperationsController -> OperationController
@objc public protocol ListeOperationsDelegate
{
    /// Called when a value has been selected inside the outline.
    func editionOperations(_ quakes: [EntityOperations])
    func resetOperation()
}

// xxxxController -> ListeOperationsController
@objc public protocol  FilterDelegate
{
    func applyFilter( fetchRequest: NSFetchRequest<EntityOperations>)
    func updateListeOperations( liste: [EntityOperations])
}

final class ListTransactionsController: NSViewController {
    
    public typealias TrackingYear           = [ GroupedYearOperations ]
    public typealias TrackingMonth          = GroupedYearOperations
    public typealias TrackingIdOperations   = GroupedMonthOperations
    public typealias TrackingSubOperations  = IdOperations
    public typealias TrackingSubOperation   = EntitySousOperations

    
    @objc var managedObjectContext2 = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    var theDocument = NSPersistentDocument()

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
    }

    enum TypeOfColor: String {
        case unie     = "unie"
        case income  = "recette/depense"
        case rubrique = "rubrique"
        case statut   = "statut"
        case mode     = "mode"
    }
    
    enum TypeOfStatut: Int {
        case planifie
        case engage
        case realise
        
        var label: String
        {
            switch self {
            case .planifie: return Localizations.Statut.Planifie
            case .engage: return Localizations.Statut.Engaged
            case .realise: return Localizations.Statut.Realise
            }
        }
        var color: NSColor
        {
            switch self {
            case .planifie:
                return .green
            case .engage:
                return .blue
            case .realise:
                return .black
            }
        }
        var attribut: [NSAttributedString.Key: Any]
        {
            var attribut = [NSAttributedString.Key: Any]()
            attribut[.foregroundColor] = self.color

            switch self {
            case .planifie:
                attribut[.font ] = NSFont(name: "Avenir-Oblique", size: 12.0)!
            case .engage:
                attribut[.font ] = NSFont(name: "Avenir", size: 12.0)!
            case .realise:
                attribut[.font ] = NSFont(name: "Avenir", size: 12.0)!
            }
            return attribut
        }
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
    
    var listeOperations = [EntityOperations]()
    
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
        
        NotificationCenter.receive(instance: self, name: .updateAccount, selector: #selector(updateChangeAccount(_:)))
        NotificationCenter.receive(instance: self, name: .selectionDidChangeOutLine, selector: #selector(selectionDidChange(_:)))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createOutlineContextMenu()
        
        //vintage playback view
        self.theBox1.contentView?.isHidden = false
        self.theBox1.boxType = .custom
        self.theBox1.borderType = .bezelBorder
        self.theBox1.borderWidth = 1.1
        self.theBox1.cornerRadius = 3
        self.theBox1.fillColor = NSColor(patternImage: NSImage(named: NSImage.Name( "Gradient"))!)
        
        //vintage playback view
        self.theBox2.contentView?.isHidden = false
        self.theBox2.boxType = .custom
        self.theBox2.borderType = .bezelBorder
        self.theBox2.borderWidth = 1.1
        self.theBox2.cornerRadius = 3
        self.theBox2.fillColor = NSColor(patternImage: NSImage(named: NSImage.Name( "Gradient"))!)
        
        //vintage playback view
        self.theBox3.contentView?.isHidden = false
        self.theBox3.boxType = .custom
        self.theBox3.borderType = .bezelBorder
        self.theBox3.borderWidth = 1.1
        self.theBox3.cornerRadius = 3
        self.theBox3.fillColor = NSColor(patternImage: NSImage(named: NSImage.Name( "Gradient"))!)
        
        self.outlineListView.doubleAction = #selector(doubleClicked)

        self.outlineListView.rowSizeStyle = .custom
        self.outlineListView.reloadData()
        self.outlineListView.allowsEmptySelection = true
        self.outlineListView.expandItem(nil, expandChildren: true)
        
        outlineListView.menu = menuTable
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
    
    /// Called when the a row in the sidebar is double clicked
    @objc private func doubleClicked(_ sender: Any?) {
        let clickedRow = outlineListView.item(atRow: outlineListView.clickedRow)
        
        if outlineListView.isItemExpanded(clickedRow) {
            outlineListView.collapseItem(clickedRow)
        } else {
            outlineListView.expandItem(clickedRow)
        }
    }
    
    @objc func updateChangeAccount(_ notification: Notification) {
        
        self.datePicker.dateValue = (currentAccount?.dateEcheancier!)!
        self.delegate?.resetOperation()
        self.getAllData()
        self.reloadData()
        
        self.resetChange()
        
//        let count = listeOperations.count
//        let str = String(format: "%d opérations", count)
//        self.labelInfo.stringValue = str
    }
    
    // ------------------------------------------------------------------------
    //    dealloc
    // ------------------------------------------------------------------------
    deinit
    {
        NotificationCenter.default.removeObserver(self, name: .selectionDidChangeOutLine, object: nil)
    }
    
    func resetChange() {
        self.removeButton.isHidden = true
        let count = outlineListView.numberOfRows
        
        var amount = 0.0
        var total = 0.0
        var expense = 0.0
        var income = 0.0
        var info = ""
        var select = ""
        var number = 0

        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        
        for row in 0..<count {
            let item = outlineListView.item(atRow: row) as? IdOperations
            if item != nil {
                number += 1
                amount = (item?.entityOperations.amount)!
                total += amount
                if amount < 0 {
                    expense += amount
                } else {
                    income += amount
                }
            }
        }

        let strAmount = formatter.string(from: total as NSNumber)!
        let strExpense = formatter.string(from: expense as NSNumber)!
        let strIncome = formatter.string(from: income as NSNumber)!
        
        if number < 2 {
            select =   Localizations.ListeOperation.operation.singular(number)
        } else {
            select =   Localizations.ListeOperation.operation.plural(number)
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
            var operationsSelected = [EntityOperations]()
            
            var amount = 0.0
            var solde = 0.0
            var expense = 0.0
            var income = 0.0
            var select = ""
            
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.numberStyle = .currency
            
            for row in selectedRow {
                let item = outlineView.item(atRow: row) as? IdOperations
                
                operationsSelected.append((item?.entityOperations)!)

                amount = (item?.entityOperations.amount)!
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
                select =   Localizations.ListeOperation.operation.selectionnee.singular(count)
            } else {
                select =   Localizations.ListeOperation.operation.selectionnee.plural(count)
            }
            let info = select + Localizations.ListeOperation.info( strExpense, strIncome, amountStr)

            let attributedText = NSAttributedString(string: info, attributes: attribute)
            self.labelInfo.attributedStringValue = attributedText
            
            self.delegate?.editionOperations(operationsSelected)

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
        var groupedID : [ String:  [ String :  [IdOperations] ] ] = [:]

        balanceCalculation()
        let IdOperation = (0 ..< listeOperations.count).map { (i) -> IdOperations in
            return IdOperations(year : listeOperations[i].sectionYear!, id: listeOperations[i].sectionIdentifier!, entityOperations: listeOperations[i])
        }
        
        // Grouped year / month
        let groupedYear = Dictionary(grouping: IdOperation, by: { $0.year })
        for (key, value) in groupedYear {
            let valueID = Dictionary(grouping: value, by: {$0.id})
            groupedID[key] = valueID
        }

        // convert to struct - more fast and easy to sort
        var allGroupedYear : [ GroupedYearOperations ] = []

        printTimeElapsedWhenRunningCode(title:"convert dict to struct : ") {
            for grouped in groupedID {
                let groupedYear = GroupedYearOperations(dictionary: grouped)
                allGroupedYear.append(groupedYear)
            }
            groupedSorted = allGroupedYear.sorted(by: {$0.year > $1.year })
        }
    }
    
    private func balanceCalculation()
    {
        let initCompte = InitAccount.shared.getAllDatas()
        var soldeRealise = initCompte.realise
        var soldePrevu  = initCompte.prevu
        var soldeEngage = initCompte.engage
        let soldeInitial = soldePrevu + soldeEngage + soldeRealise
        let count = listeOperations.count
        
        for index in stride(from: count - 1, to: -1, by: -1)
        {
            let propertyEnum = TypeOfStatut(rawValue: Int(listeOperations[index].statut))!
            switch propertyEnum
            {
            case .planifie:
                soldePrevu += listeOperations[index].amount
            case .engage:
                soldeEngage += self.listeOperations[index].amount
            case .realise:
                soldeRealise += self.listeOperations[index].amount
            }
            listeOperations[index].solde = index == count - 1 ? listeOperations[index].amount + soldeInitial : listeOperations[index + 1].solde + listeOperations[index ].amount
        }
        
        self.soldeBanque.doubleValue = soldeRealise
        self.soldeReel.doubleValue   = soldeRealise + soldeEngage
        self.soldeFinal.doubleValue  = soldeRealise + soldeEngage + soldePrevu
        
        NotificationCenter.send(.updateBalance)
    }
    
    @IBAction func removeOperation(_ sender: Any) {
        let selectedRow = outlineListView.selectedRowIndexes
        guard selectedRow.isEmpty == false else { return }
        
        for row in selectedRow {
            let item = outlineListView.item(atRow: row) as? IdOperations
            ListeOperations.shared.remove(entity: (item?.entityOperations)!)
        }
        
        self.getAllData()
        self.outlineListView.reloadData()
        self.outlineListView.expandItem(nil, expandChildren: true)
        
        self.resetChange()
    }
    
}

extension ListTransactionsController: FilterDelegate {
    
    func applyFilter( fetchRequest: NSFetchRequest<EntityOperations>) {
        do {
            listeOperations = try mainObjectContext.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        transformData()
        reloadData()
    }
    
    func updateListeOperations( liste: [EntityOperations]) {
        
        listeOperations = liste
        
        self.transformData()
        self.reloadData()
    }
    
}

extension ListTransactionsController: OperationsDelegate {
    
    func getAllData() {
        
////        DispatchQueue.main.async(execute: {() -> Void in
//            self.progressIndicator.isHidden = false
//            self.progressIndicator.startAnimation(nil)
//
////            for _ in 0..<1000 {
//                self.listeOperations.removeAll()
//                self.listeOperations = ListeOperations.shared.getAll(ascending: false)
//                self.transformData()
////            }
//
//            self.progressIndicator.isHidden = true
//            self.progressIndicator.stopAnimation(nil)
////        })
//
        
//        progressIndicator.isHidden = false
//        progressIndicator.startAnimation(nil)

//        for _ in 0..<1000 {
            listeOperations = ListeOperations.shared.getAllDatas(ascending: false)
            self.transformData()
//        }

    }
    
    func reloadData() {
        self.outlineListView.reloadData()
        
//        var item = [Any]()
//        let numberOfChildren = self.outlineListView.numberOfChildren(ofItem: nil)
//
//        for i in 0 ..< numberOfChildren {
//            item.append( self.outlineListView.item(atRow: i)!)
//            self.outlineListView.expandItem(item[i])
//        }
//        for i in 0 ..< numberOfChildren {
//            self.outlineListView.expandItem(item[i])
//        }
        
//        self.outlineListView.selectRowIndexes(NSIndexSet(index: 1) as IndexSet, byExtendingSelection: false)
        self.outlineListView.expandItem(nil, expandChildren: true)

    }
}
