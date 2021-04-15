import AppKit
import Charts
import TFDate

// OperationController -> ListeOperationsController
@objc public protocol OperationsDelegate {
    func getAllData()
    func reloadData(_ expand: Bool )
}

final class TransactionViewController: NSViewController, NSTextFieldDelegate, NSControlTextEditingDelegate {
    
    let appDelegate = NSApplication.shared.delegate as! AppDelegate;

    
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
    
    var entityOperation: EntityTransactions?
    var entityOperations : [EntityTransactions] = []
    var entityOperationsTransfert: EntityTransactions?
    var entityPreference: EntityPreference?
    var entityCompteTransfert: EntityAccount?
    var subOperations : [EntitySousOperations] = []
    
    var sousOperationModalWindowController: SousOperationModalWindowController!
    
    var setReleve        = Set<Double>()
    var setMontant       = Set<Double>()
    var setModePaiement  = Set<String>()
    var setStatut        = Set<Int16>()
    var setTransfert     = Set<String>()
    var setCheck_In_Date = Set<Date>()
    var setDateOperation = Set<Date>()
    
    // edition = false => creation 1 operation
    // edition = true => edition 1 to n operation(s)
    var edition = false
    
    let key1 = Notification.Name.updateTransaction
    let key2 = Notification.Name.updateAccount
    
    var attrs = [NSAttributedString.Key: Any]()
    
    var dataRubricPie = [DataGraph]()
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

        
        self.numCheque.isEnabled = true
        self.addView.isHidden = false
        
        numCheque.delegate = self
        textFieldReleveBancaire.delegate = self
        
//        NotificationCenter.default.addObserver(self, selector: #selector(willShowPopup), name: NSPopUpButton.willPopUpNotification, object: nil);

        dateOperation.locale = Locale.current
        
        //        self.resetOperation()

        
        self.initChart()
    }
    
    @IBAction func popUpButtonUsed(_ sender: Any) {
        print("sender.indexOfSelectedItem")
    }

    @objc func willShowPopup(_ notification: Notification) {
//                guard let btn = notification.object as? NSPopUpButton else {
//                    return;
//                }
        //        guard let btn = notification.object as? NSPopUpButton, self.actionButton == btn else {
        //            return;
        //        }
//
//        guard let menu = btn.menu?.item(withTitle: "Share")?.submenu else {
//            return;
//        }
//
//        print("menu:", menu.items.map({ it in it.title }));
//
//        menu.removeAllItems();
//
//        guard let item = self.item else {
//            return;
//        }
//        guard let localUrl = DownloadStore.instance.url(for: "\(item.id)") else {
//            return;
//        }
//
//        let sharingServices = NSSharingService.sharingServices(forItems: [localUrl]);
//        for service in sharingServices {
//            let item = menu.addItem(withTitle: service.title, action: nil, keyEquivalent: "");
//            item.image = service.image;
//            item.target = self;
//            item.action = #selector(shareItemSelected);
//            item.isEnabled = true;
//        }
//        print("menu:", menu.items.map({ it in it.title }));
    }

    
    @objc func updateChangeCompte(_ notification: Notification) {

        self.resetOperation()
    }
    
    func controlTextDidEndEditing (_ notification: Notification) {
    
//        super.controlTextDidEndEditing(notification)

        guard let textField = notification.object as? NSTextField else { return  }
        
        var bar = ""
        if textField == textFieldReleveBancaire {
            bar = "textFieldReleveBancaire"
            saveActions(notification)
        }
        if textField == numCheque {
            bar = "numCheque"
            saveActions(notification)
        }
        
        guard let popUpButton = notification.object as? NSPopUpButton else { return  }
        if popUpButton == popUpStatut {
            bar = "popUpStatut"
            saveActions(notification)
        }

        print(bar)
    }
    
    private func initChart() {
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let attribut: [ NSAttributedString.Key: Any] =
            [  .font: NSFont(name: "HelveticaNeue-Light", size: 8.0)!,
               .foregroundColor: NSColor.gray,
               .paragraphStyle: paragraphStyle]
        
        let centerText = NSMutableAttributedString(string: Localizations.Transaction.operation)
        centerText.setAttributes(attribut, range: NSRange(location: 0, length: centerText.length))
        
        self.pieChartView.centerAttributedText = centerText
        self.pieChartView.highlightPerTapEnabled = true
        self.pieChartView.drawSlicesUnderHoleEnabled = false
        self.pieChartView.holeRadiusPercent = 0.58
        self.pieChartView.transparentCircleRadiusPercent = 0.61
        self.pieChartView.drawCenterTextEnabled = true
        self.pieChartView.usePercentValuesEnabled = true
        self.pieChartView.drawEntryLabelsEnabled = false
        
        initializeLegend(self.pieChartView.legend)

        self.pieChartView.chartDescription?.enabled = false
        self.pieChartView.noDataText = Localizations.Chart.No_chart_Data_Available
        self.pieChartView.holeColor = .windowBackgroundColor
    }
    
    // MARK: Legend
    func initializeLegend(_ legend: Legend) {
        legend.horizontalAlignment = .left
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        
        legend.xEntrySpace = 7
        legend.yEntrySpace = 0
        legend.yOffset = 0

        legend.font = NSFont(name: "HelveticaNeue-Light", size: 8.0)!
        legend.textColor = NSColor.labelColor
    }

    // MARK: update Chart Data
    func updateChartData()
    {
        self.dataRubricPie.removeAll()
        
        var nameRubric = ""
        var value = 0.0
        var color = NSColor.red
        for sousOperation in subOperations {
            
            value = sousOperation.amount
            nameRubric = (sousOperation.category?.rubric!.name)!
            color = (sousOperation.category?.rubric!.color) as! NSColor
            self.dataRubricPie.append(DataGraph(name: nameRubric, value: value, color: color))
        }
        self.groupedBonds = Dictionary(grouping: self.dataRubricPie) { (DataRubriquePie) -> String in
            return DataRubriquePie.name }
    }
    
    func setDataCount()
    {
        guard dataRubricPie.isEmpty == false else {
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
            
            self.entityOperation = NSEntityDescription.insertNewObject(forEntityName: "EntityTransactions", into: mainObjectContext) as? EntityTransactions

            self.entityOperation?.dateCree = Date()
            self.entityOperation?.uuid = UUID()
            self.entityOperation?.account = currentAccount

            let setSousOperation = NSSet(array: subOperations)
            self.entityOperation?.addToSousOperations(setSousOperation)

            self.entityOperations.append(entityOperation!)
        }
        
        // creation = one operation
        if self.entityOperations.count == 1 && edition == true {
            
            let setSousOperation = NSSet(array: subOperations)
            
//            let sub = entityOperations.first?.sousOperations
//            self.entityOperations.first?.removeFromSousOperations(sub!)
            self.entityOperations.first?.addToSousOperations(setSousOperation)
        }
    }
    
    // MARK: - saveActions
    // edition = false => create  1 operation
    // edition = true  => edition 1 to n operation(s)
    @IBAction func saveActions(_ sender: Any) {
        
        printTimeElapsedWhenRunningCode(title:"saveActions ") {
            self.contextSaveEdition()
            
            /// Multiple value
            for oneOperation in self.entityOperations {
                
                oneOperation.dateModifie = Date()
                
                // DatePointage
                if (setCheck_In_Date.count > 1 && date5 != nil) || setCheck_In_Date.count == 1 {
                    oneOperation.datePointage  = datePointage.dateValue.noon
                }
                
                // DateOperation
                if (setDateOperation.count > 1 && date4 != nil) || setDateOperation.count == 1 {
                    oneOperation.dateOperation  = dateOperation.dateValue.noon
                }
                
                // Relevé bancaire
                if (setReleve.count > 1 && textFieldReleveBancaire.stringValue != "") || setReleve.count == 1 {
                    oneOperation.bankStatement = textFieldReleveBancaire.doubleValue
                }
                
                // ModePaiement
                if (setModePaiement.count > 1 && popUpModePaiement.indexOfSelectedItem != 0) || setModePaiement.count == 1 {
                    let menuItem = self.popUpModePaiement.selectedItem
                    let entityMode = menuItem?.representedObject as! EntityPaymentMode
                    oneOperation.paymentMode = entityMode
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
            
            (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
            
            self.delegate?.getAllData()
            self.delegate?.reloadData(true)
            
            NotificationCenter.send(.updateBalance)
            
            self.resetOperation()
//        self.delegate?.resetChange()
        }
    }
    
    func getTodoItems() {
        if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                entityOperations = try context.fetch(EntityTransactions.fetchRequest())
                print("get: \(entityOperations)")
            } catch {
            }
            self.delegate?.getAllData()
                    self.delegate?.reloadData(true)

        }
    }

    func createOperationLiee(oneOperation: EntityTransactions ) {

        print("Operation Liée")        
        if oneOperation.operationLiee == nil {
            
            self.entityOperationsTransfert = NSEntityDescription.insertNewObject(forEntityName: "EntityTransactions", into: mainObjectContext) as? EntityTransactions
            self.entityOperationsTransfert?.operationLiee = oneOperation
            oneOperation.operationLiee = entityOperationsTransfert
        
        } else {
            entityOperationsTransfert = oneOperation.operationLiee
        }
        
        let menuItem = popUpTransfert.selectedItem
        let compteTransfert = menuItem?.representedObject as! EntityAccount
        
        entityOperationsTransfert?.account       = compteTransfert
        
        entityOperationsTransfert?.dateModifie   = oneOperation.dateModifie
        entityOperationsTransfert?.dateCree      = oneOperation.dateCree

        
        /// Date operation
        entityOperationsTransfert?.dateOperation = oneOperation.dateOperation
        
        /// Date Pointage
        entityOperationsTransfert?.datePointage  = oneOperation.datePointage
        
        // le modePaiement existe t il ??
        let name = oneOperation.paymentMode?.name
        let color = oneOperation.paymentMode?.color
        let uuid = oneOperation.paymentMode?.uuid
        let entityModePaiement = PaymentMode.shared.findOrCreate(account: compteTransfert, name: name!, color: color as! NSColor, uuid: uuid!)
        entityOperationsTransfert?.paymentMode  = entityModePaiement
        
        entityOperationsTransfert?.statut        = oneOperation.statut
        entityOperationsTransfert?.bankStatement = oneOperation.bankStatement
        
        let entityPreference = Preference.shared.getAllDatas()

        let setSout = oneOperation.sousOperations
        subOperations = setSout?.allObjects as! [EntitySousOperations]
        
        print("count subOperations = ", subOperations.count )
//        entityOperationsTransfert?.removeFromSousOperations(setSout!)
        for sousOperation in subOperations {
            
            let entitySousOperationsTransfert = NSEntityDescription.insertNewObject(forEntityName: "EntitySousOperations", into: mainObjectContext) as? EntitySousOperations

            // la rubrique existe t elle ??
            let labelCat = (sousOperation.category?.name)!
            let entityCategory = Categories.shared.find(name: labelCat)
            entitySousOperationsTransfert!.category = entityCategory ?? entityPreference.category
            
            // Amount
            entitySousOperationsTransfert!.amount       = -sousOperation.amount
            
            // Libelle
            entitySousOperationsTransfert!.libelle       = sousOperation.libelle
           
            entityOperationsTransfert?.addToSousOperations(entitySousOperationsTransfert!)
            
            print("count = ", entityOperationsTransfert?.sousOperations?.count ?? 0)
        }
        entityOperationsTransfert?.uuid          = UUID()
    }
}

extension TransactionViewController: NSMenuDelegate {
    // MARK: - Enable Menu item
    func menuWillOpen( _ menu: NSMenu) {
        for menuItem in menu.items
        {
            let tag = menuItem.tag
            if tag == 1  {
                menuItem.isEnabled = outlineViewSSOpe.selectedRow != -1 ? true : false
            }
            if tag == 2 {
                menuItem.isEnabled = subOperations.count > 1 && outlineViewSSOpe.selectedRow != -1 ? true : false
            }
        }
    }
    
}

extension TransactionViewController: NSWindowDelegate, NSAlertDelegate {
    
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
