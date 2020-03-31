import AppKit
import Charts
import TFDate

// OperationController -> ListeOperationsController
@objc public protocol OperationsDelegate {
    func getAllData()
    func reloadData()
}

final class OperationViewController: NSViewController {
    
    public weak var delegate: OperationsDelegate?
    
    @IBOutlet weak var outlineViewSSOpe: NSOutlineView!
    @IBOutlet var menuLocal: NSMenu!
    @IBOutlet weak var addView: NSView!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var gridView: NSGridView!
    
    @objc dynamic var mainContext: NSManagedObjectContext! = mainObjectContext
    //    @objc dynamic var predicate =  NSPredicate(format: "account == %@", compteCourant!)
    
    @IBOutlet weak var buttonSave: NSButton!
    @IBOutlet weak var modeOperation: NSButton!
    @IBOutlet weak var modeOperation2: NSButton!
    @IBOutlet weak var column0: NSGridColumn!
    @IBOutlet weak var addBUtton: NSPopUpButton!
    @IBOutlet weak var removeButton: NSButton!
    
    @IBOutlet weak var popUpModePaiement: NSPopUpButton!
    @IBOutlet weak var popUpStatut: NSPopUpButton!
    @IBOutlet weak var popUpTransfert: NSPopUpButton!
    
    @IBOutlet weak var nameCompte: NSTextField!
    @IBOutlet weak var nomTitulaire: NSTextField!
    @IBOutlet weak var prenomTitulaire: NSTextField!
    
    @IBOutlet weak var textFieldMontant: NSTextField!
    @IBOutlet weak var textFieldReleveBancaire: NSTextField!
    
    @IBOutlet weak var dateOperation: TFDatePicker!
    @IBOutlet weak var datePointage: TFDatePicker!
    
    @objc var date4: Date?
    @objc var date5: Date?
    
    @IBOutlet weak var numCheque: NSTextField!
    @IBOutlet weak var labelNumCheque: NSTextField!
    
    var entityOperation: EntityOperations?
    var entityOperations : [EntityOperations] = []
    var entityOperationsTransfert: EntityOperations?
    var entityPreference: EntityPreference?
    var entityCompteTransfert: EntityAccount?
    var sousOperations : [EntitySousOperations] = []
    
    var sousOperationModalWindowController: SousOperationModalWindowController!
    
    var setReleve        = Set<Double>()
    var setMontant       = Set<Double>()
    var setModePaiement  = Set<String>()
    var setStatut        = Set<Int16>()
    var setTransfert     = Set<String>()
    var setDatePointage  = Set<Date>()
    var setDateOperation = Set<Date>()
    
    // edition = false => creation 1 operation
    // edition = true => edition 1 to n operation(s)
    var edition = false
    
    let key1 = Notification.Name.updateOperation
    let key2 = Notification.Name.updateAccount
    
    var attrs = [NSAttributedString.Key: Any]()
    
    var dataRubriquePie = [DataGraph]()
    var groupedBonds = [String: [DataGraph]]()
    
    let formatterPrice: NumberFormatter = {
        let _formatter = NumberFormatter()
        _formatter.locale = Locale.current
        _formatter.numberStyle = .currency
        return _formatter
    }()
    
    public override func viewDidDisappear()
    {
        super.viewDidDisappear()
        NotificationCenter.default.removeObserver(self, name: key1, object: nil)
        NotificationCenter.default.removeObserver(self, name: key2, object: nil)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.receive(instance: self, name: key1,  selector: #selector(updateChangeCompte(_:)))
        NotificationCenter.receive(instance: self, name: key2,  selector: #selector(updateChangeCompte(_:)))
        
        self.modeOperation.bezelStyle = .texturedSquare
        self.modeOperation.isBordered = false //Important
        self.modeOperation.wantsLayer = true
        
        self.modeOperation2.bezelStyle = .texturedSquare
        self.modeOperation2.isBordered = false //Important
        self.modeOperation2.wantsLayer = true
        
        self.textFieldMontant.isEnabled = false

        self.resetOperation()
        
        self.numCheque.isEnabled = false
        self.addView.isHidden = false
        
        dateOperation.locale = Locale.current
        
        self.initChart()
    }
    
    @objc func updateChangeCompte(_ notification: Notification) {

        self.resetOperation()
    }
    
    private func initChart() {
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let attribut: [ NSAttributedString.Key: Any] =
            [  .font: NSFont(name: "HelveticaNeue-Light", size: 8.0)!,
               .foregroundColor: NSColor.gray,
               .paragraphStyle: paragraphStyle]
        
        let centerText = NSMutableAttributedString(string: "Operations")
        centerText.setAttributes(attribut, range: NSRange(location: 0, length: centerText.length))
        
        self.pieChartView.highlightPerTapEnabled = true
        self.pieChartView.drawSlicesUnderHoleEnabled = false
        self.pieChartView.holeRadiusPercent = 0.58
        self.pieChartView.transparentCircleRadiusPercent = 0.61
        self.pieChartView.drawCenterTextEnabled = true
        self.pieChartView.centerAttributedText = centerText
        self.pieChartView.usePercentValuesEnabled = true
        self.pieChartView.drawEntryLabelsEnabled = false
        
        let legend = pieChartView.legend
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        legend.xEntrySpace = 7
        legend.yEntrySpace = 0
        legend.yOffset = 0
        legend.font = NSFont(name: "HelveticaNeue-Light", size: 8.0)!
        
        self.pieChartView.chartDescription?.enabled = false
        self.pieChartView.noDataText = Localizations.Chart.No_chart_Data_Available
        self.pieChartView.backgroundColor = .white
    }
    
    func updateChartData()
    {
        self.dataRubriquePie.removeAll()
        
        var nameRubrique = ""
        var value = 0.0
        var color = NSColor.red
        for sousOperation in sousOperations {
            
            value = sousOperation.amount
            nameRubrique = (sousOperation.category?.rubrique!.name)!
            color = (sousOperation.category?.rubrique!.color) as! NSColor
            self.dataRubriquePie.append(DataGraph(name: nameRubrique, value: value, color: color))
        }
        self.groupedBonds = Dictionary(grouping: self.dataRubriquePie) { (DataRubriquePie) -> String in
            return DataRubriquePie.name }
    }
    
    func setDataCount()
    {
        guard dataRubriquePie.isEmpty == false else {
            pieChartView.data = nil
            pieChartView.data?.notifyDataChanged()
            pieChartView.notifyDataSetChanged()
            return }
        
        self.addView.isHidden = groupedBonds.isEmpty == false ? true : false

        
        // MARK: PieChartDataEntry
        var entries = [PieChartDataEntry]()
        var colors : [NSColor] = []
        
        for (key, values) in groupedBonds {
            
            var amount = 0.0
            for value in values {
                amount += value.value
            }
            
            let color = values[0].color
            entries.append(PieChartDataEntry(value: abs(amount), label: key))
            colors.append( color )
        }
        
        // MARK: PieChartDataSet
        let dataSet = PieChartDataSet(entries: entries, label: "Rubriques")
        dataSet.sliceSpace = 2.0
        
        dataSet.colors = colors
        dataSet.yValuePosition = .outsideSlice
        
        // MARK: PieChartData
        let data = PieChartData(dataSet: dataSet)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        data.setValueFont(NSFont(name: "HelveticaNeue-Light", size: CGFloat(8.0))!)
        data.setValueTextColor( .labelColor)
        self.pieChartView.data = data
        self.pieChartView.highlightValues(nil)
    }
    
    // edition = false => creation 1 operation
    // edition = true => edition 1 to n operation(s)
    func contextSaveEdition() {
        // creation = one operation
        if edition == false {
            self.entityOperation = EntityOperations(context: mainObjectContext)

            self.entityOperation?.dateCree = Date()
            self.entityOperation?.uuid = UUID()
            self.entityOperation?.account = currentAccount

            let setSousOperation = NSSet(array: sousOperations)
            self.entityOperation?.addToSousOperations(setSousOperation)

            self.entityOperations.append(entityOperation!)
        }
        
        if self.entityOperations.count == 1 && edition == true {
            let setSousOperation = NSSet(array: sousOperations)
            self.entityOperations.first?.addToSousOperations(setSousOperation)
        }

    }
    
    // MARK: saveActions
    // edition = false => create 1 operation
    // edition = true => edition 1 to n operation(s)
    @IBAction func saveActions(_ sender: Any) {
        
        self.contextSaveEdition()
        
        /// Multiple value
        for oneOperation in self.entityOperations {
            
            oneOperation.dateModifie = Date()
            
            // DatePointage
            if (setDatePointage.count > 1 && date5 != nil) || setDatePointage.count == 1 {
                oneOperation.datePointage  = datePointage.dateValue.noon
            }
            
            // DateOperation
            if (setDateOperation.count > 1 && date4 != nil) || setDatePointage.count == 1 {
                oneOperation.dateOperation  = dateOperation.dateValue.noon
            }
            
            // Relevé bancaire
            if (setReleve.count > 1 && textFieldReleveBancaire.stringValue != "") || setReleve.count == 1 {
                oneOperation.releveBancaire  = textFieldReleveBancaire.doubleValue
            }
            
            // ModePaiement
            if (setModePaiement.count > 1 && popUpModePaiement.indexOfSelectedItem != 0) || setModePaiement.count == 1 {
                let menuItem = self.popUpModePaiement.selectedItem
                let entityMode = menuItem?.representedObject as! EntityModePaiement
                oneOperation.modePaiement = entityMode
            }
            
            // Statut
            if (setStatut.count > 1 && popUpStatut.indexOfSelectedItem != 0) || setStatut.count == 1 {
                let item = self.popUpStatut.selectedItem
                let statut = Int16(item?.tag ?? 0)
                oneOperation.statut = statut
            }
            
            // Operation Link
            if (setTransfert.isEmpty == false && popUpTransfert.indexOfSelectedItem != 0)  {
                createOperationLiee(oneOperation: oneOperation)
            }
        }
        
        self.delegate?.getAllData()
        self.delegate?.reloadData()
                
        NotificationCenter.send(.updateBalance)
        self.resetOperation()
    }
    
    func createOperationLiee(oneOperation: EntityOperations ) {
        print("Operation Liée")
        
        if oneOperation.operationLiee == nil {
            
            entityOperationsTransfert = EntityOperations(context: mainObjectContext)
            entityOperationsTransfert?.operationLiee = oneOperation
            oneOperation.operationLiee = entityOperationsTransfert
        } else {
            entityOperationsTransfert = oneOperation.operationLiee
        }
        
        let menuItem = popUpTransfert.selectedItem
        let compteTransfert = menuItem?.representedObject as! EntityAccount
        
        entityOperationsTransfert?.account       = compteTransfert
        
        /// Date operation
        entityOperationsTransfert?.dateOperation = oneOperation.dateOperation
        
        /// Date Pointage
        entityOperationsTransfert?.datePointage  = oneOperation.datePointage
        entityOperationsTransfert?.dateModifie   = oneOperation.dateModifie
        entityOperationsTransfert?.dateCree      = oneOperation.dateCree
        
        // le modePaiement existe t il ??
        let name = oneOperation.modePaiement?.name
        let color = oneOperation.modePaiement?.color
        let uuid = oneOperation.modePaiement?.uuid
        let entityModePaiement = ModePaiement.shared.findOrCreate(account: compteTransfert, name: name!, color: color as! NSColor, uuid: uuid!)
        entityOperationsTransfert?.modePaiement  = entityModePaiement
        
        
        entityOperationsTransfert?.statut        = oneOperation.statut
        entityOperationsTransfert?.releveBancaire  = oneOperation.releveBancaire
        
        let entityPreference = Preference.shared.getAll()

        sousOperations = oneOperation.sousOperations?.allObjects as! [EntitySousOperations]
        for sousOperation in sousOperations {
            
            let entitySousOperationsTransfert = EntitySousOperations(context: mainObjectContext)
            
            // la rubrique existe t elle ??
            
            let labelCat = (sousOperation.category?.name)!
            let entityCategory = Categories.shared.find(name: labelCat)
//            sousOperation.category = entityCategory ?? entityPreference.category
            entitySousOperationsTransfert.category = entityCategory ?? entityPreference.category


//            let nameRub = sousOperation.category?.rubrique?.name
//            let colorRub = sousOperation.category?.rubrique?.color
//            let uuidRub = sousOperation.category?.rubrique?.uuid
//            let entityRubric = Rubrique.shared.findOrCreate(compte: compteTransfert, name: nameRub!, color: colorRub as! NSColor, uuid: uuidRub!)
//
//            // la categorie existe t elle ??
//            let nameCat = sousOperation.category?.name
//            let objectif = sousOperation.category?.objectif
//            let uuid = sousOperation.category?.uuid
//            let entityCategory = Categories.shared.findOrCreate(account: compteTransfert, name: nameCat!, objectif: objectif!, uuid: uuid!)
            
            entitySousOperationsTransfert.category = entityCategory
//            entitySousOperationsTransfert.category?.rubrique = entityRubric
            
            // Montant
            entitySousOperationsTransfert.amount       = -sousOperation.amount
            
            // Libelle
            entitySousOperationsTransfert.libelle       = sousOperation.libelle
           
            entityOperationsTransfert?.addToSousOperations(entitySousOperationsTransfert)
        }
        entityOperationsTransfert?.uuid          = UUID()
    }
    
}

extension OperationViewController: NSMenuDelegate {
    // MARK: - Enable Menu item
    func menuWillOpen( _ menu: NSMenu) {
        for menuItem in menu.items
        {
            let tag = menuItem.tag
            if tag == 1  {
                menuItem.isEnabled = outlineViewSSOpe.selectedRow != -1 ? true : false
            }
            if tag == 2 {
                menuItem.isEnabled = sousOperations.count > 1 && outlineViewSSOpe.selectedRow != -1 ? true : false
            }
        }
    }
    
}

extension OperationViewController: NSWindowDelegate, NSAlertDelegate {
    
    func window(_ window: NSWindow, willPositionSheet sheet: NSWindow, using rect: NSRect) -> NSRect {
        
        if sheet == self.sousOperationModalWindowController?.window ||
            sheet == self.outlineViewSSOpe.window
        {
            var rectToReturn = self.outlineViewSSOpe.frame
            let rectWin = window.frame
            rectToReturn.size = CGSize(width: rectToReturn.width, height: 0)
            rectToReturn.origin.x = rectWin.width - rectToReturn.width
            rectToReturn.origin.y = rect.origin.y //- rectAddView.height
            return rectToReturn
        } else {
            return rect
        }
    }
    
}
