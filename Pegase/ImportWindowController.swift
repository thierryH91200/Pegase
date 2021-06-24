import AppKit

struct HeaderColumnForMenu {
    var numCol: Int
    var nameCol: String
    var numMenu: Int
    var nameMenu: String
    
    init( numCol: Int, nameCol: String, numMenu: Int, nameMenu: String ) {
        self.numCol  = numCol
        self.nameCol  = nameCol
        self.numMenu  = numMenu
        self.nameMenu  = nameMenu
    }
}

final class ImportWindowController: NSWindowController, NSSearchFieldDelegate {
    
    public weak var delegate: OperationsDelegate?
    
    @IBOutlet var anTableView: NSTableView!
    @IBOutlet var splitView: NSSplitView!
    @IBOutlet weak var infoView: NSView!
    @IBOutlet var m_window: NSWindow!
    
    var menuHeader = NSMenu()
        
    var headerColumnForMenu = [HeaderColumnForMenu]()
    
    var statusBarFormatViewController: TTFormatViewController?
    
    var line = 0
    var nColumns = 0
    var url = ""
    
    var allData = [[String]]()
    var dataLine = [String]()
    var headerData = [String]()
    var dataArray = [String]()
    
    var csvConfig =  CSV.Configuration()
    
    override var windowNibName: NSNib.Name? {
        return "ImportWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        if statusBarFormatViewController == nil {
            statusBarFormatViewController = TTFormatViewController(nibName: NSNib.Name( "TTFormatViewController"), bundle: nil)
            statusBarFormatViewController?.delegate = self
            statusBarFormatViewController?.config = csvConfig
        }
        
        infoView.isHidden = false
        
        splitView.addSubview((statusBarFormatViewController?.view)!, positioned: .above, relativeTo: splitView)
        statusBarFormatViewController?.selectFormatByConfig()
        
        setupHeaderMenu()
        readParseFile()
//        self.close()

    }
    
    /// Pops up the menu at the specified location.
    @IBAction func tableViewClick(_ sender: NSTableView) {
        
        let column = sender.clickedColumn
        let row = sender.clickedRow
        
        guard column > -1, row == -1 else { return }
        
        let colRect = sender.headerView?.headerRect(ofColumn: column)
        
        let point = CGPoint(x: (colRect?.origin.x)!, y: (colRect?.origin.y)!)
        let menu = menuHeader
        menu.popUp( positioning: menu.item(at: 0), at: point, in: sender)
    }
    
    @IBAction func cancelImport(_ sender: NSButton) {
        self.close()
    }
    
    @IBAction func actionImport(_ sender: NSButton) {
        
        let context = mainObjectContext

        let entityPreference = Preference.shared.getAllDatas()
        let formatDate = statusBarFormatViewController?.formatDate.stringValue
        
        let menuItem = statusBarFormatViewController?.popUpCompte.selectedItem
        let account = menuItem?.representedObject as! EntityAccount
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatDate
        
        let itemHeader = menuHeader.items
        
        
        let reverse = statusBarFormatViewController?.reverseSignAmountCheckBbox.state
        let sign = reverse == .on ? -1 : 1
        
        for data in allData {
            
            let entityOperation = NSEntityDescription.insertNewObject(forEntityName: "EntityTransactions", into: context!) as! EntityTransactions

            entityOperation.account = account
            
            entityOperation.dateCree = Date()
            entityOperation.dateModifie = Date()
            
            /// Date transaction
            var headerColumn = itemHeader[1].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                
                var dateTransaction =  Date().noon
                let column = headerColumn[0].numCol
                let date = data[ column]
                if date == "" {
                    dateTransaction = Date().noon
                } else {
                    dateTransaction = dateFormatter.date(from: date)!.noon
                }
                entityOperation.dateOperation = dateTransaction
            } else {
                entityOperation.dateOperation = Date().noon
            }
            
            /// Date Pointage
            headerColumn = itemHeader[2].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                
                var datePointage =  Date().noon
                let column = headerColumn[0].numCol
                let dateStr = data[ column]
                if dateStr == "" {
                    datePointage = entityOperation.dateOperation!
                } else {
                    datePointage = dateFormatter.date(from: dateStr)!.noon
                }
                entityOperation.datePointage = datePointage
            } else {
                entityOperation.datePointage = entityOperation.dateOperation
            }
            
            /// Statut
            headerColumn = itemHeader[3].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                let column = headerColumn[0].numCol
                let statut = data[ column]
                entityOperation.statut = Statut.shared.findStatut(statut: statut)
            } else {
                entityOperation.statut = entityPreference.statut
            }
            
            /// Mode Paiement
            headerColumn = itemHeader[4].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                let column = headerColumn[0].numCol
                
                let label = data[ column]
                let entityModePaiement = PaymentMode.shared.find(name: label) ?? (entityPreference.paymentMode)!
                entityOperation.paymentMode = entityModePaiement
                
            } else {
                let modePaiement = entityPreference.paymentMode
                entityOperation.paymentMode = modePaiement
            }
            
            // Creation entitySousOperation
            let entitySousOperation = NSEntityDescription.insertNewObject(forEntityName: "EntitySousOperations", into: context!) as! EntitySousOperations

            
            // Libelle
            headerColumn = itemHeader[5].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                
                let column = headerColumn[0].numCol
                if  data.count > column {
                    entitySousOperation.libelle = data[ column ]
                } else {
                    entitySousOperation.libelle = ""
                }
            } else {
                entitySousOperation.libelle = ""
            }
            
            /// Montant
            headerColumn = itemHeader[6].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                
                let colMontant = headerColumn[0].numCol
                var amountStr = data[ colMontant]
                if amountStr != "" {
                    amountStr = amountStr.replacingOccurrences(of: ",", with: ".")
                    amountStr = amountStr.replacingOccurrences(of: " ", with: "")
                    // https://stackoverflow.com/questions/5105053/iphone-uilabel-non-breaking-space
                    amountStr = amountStr.replacingOccurrences(of: "\u{00a0}", with: "")
                    let amount = Double(amountStr) ?? 0.0
                    entitySousOperation.amount = amount * Double(sign)
                }
            } else {
                entitySousOperation.amount = 0.0
            }
            
            /// Rubric
//            headerColumn = itemHeader[7].representedObject as!  [HeaderColumnForMenu]
//            if headerColumn.isEmpty == false {
//
//                let colRub = headerColumn[0].numCol
//                let labelRub = data[ colRub ]
//
//                let entityRubric = Rubric.shared.find(name: labelRub)
//                entitySousOperation.category?.rubric = entityRubric ?? entityPreference.category?.rubric
//            } else {
//
//                let rubric = entityPreference.category?.rubric
//                entitySousOperation.category?.rubric = rubric
//            }
            
            /// Categorie
            headerColumn = itemHeader[8].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                
                let colCat = headerColumn[0].numCol
                let labelCat = data[ colCat ]
                
                let entityCategory = Categories.shared.find(name: labelCat)
                entitySousOperation.category = entityCategory ?? entityPreference.category
            } else {
                
                let category = entityPreference.category
                entitySousOperation.category = category
            }

            entityOperation.addToSousOperations(entitySousOperation)
            entityOperation.uuid = UUID()
        }
        
        delegate?.getAllData()
        delegate?.reloadData(true, false)
        
        NotificationCenter.send(.updateBalance)
        
        self.close()
    }
    
    func readParseFile() {
        
        if let url = NSOpenPanel().selectUrl {
            
            infoView.isHidden = true
            
            self.url = url.path
            let stream = InputStream(fileAtPath: self.url)
            
            let configuration = CSV.Configuration.detectConfiguration(url: url )!
            
            var config = statusBarFormatViewController?.config
            config?.delimiter = configuration.delimiter
            config?.isFirstRowAsHeader = true
            config?.isReverseSignAmountCheckBbox = false
            config?.encoding = configuration.encoding
            statusBarFormatViewController?.filePath.url = url
            
            statusBarFormatViewController?.config = config!
            statusBarFormatViewController?.selectFormatByConfig()
            
            let parser = CSV.Parser(inputStream: stream!, configuration: configuration)
            parser.delegate = self
            do {
                try parser.parse()
            } catch {
                print("Error fetching data from CSV")
            }
            setupHeaderMenu()
        } else {
            print("file selection was canceled")
        }
    }
    
//   just for the debug
//    func printHeader() {
//        headerColumn.removeAll()
//        for i in 0 ..< menuHeader.items.count
//        {
//            headerColumnForMenu = menuHeader.items[i].representedObject as!  [HeaderColumnForMenu]
//            print(i, " ", headerColumnForMenu)
//
//            for j in 0 ..< headerColumnForMenu.count {
//                headerColumn.append(headerColumnForMenu[j])
//            }
//        }
//        print("--------------")
//
//        headerColumn = headerColumn.sorted { $0.numCol < $1.numCol }
//        for i in 0 ..< headerColumn.count {
//            print(headerColumn[i])
//        }
//    }
    
}
