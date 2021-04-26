import AppKit

extension MainWindowController {
    //    extension MainWindowController: NSMenuDelegate {
    
    @IBAction func appearanceSelection(_ sender: NSSegmentedControl) {
        let appearance: NSAppearance.Name = sender.selectedSegment == 0 ? .aqua : .darkAqua
        window?.appearance = NSAppearance(named: appearance)
    }
    
    
    @IBAction func ActionSegmentedControl(_ sender: Any) {
        
        let segmentedControl = sender as! NSSegmentedControl
        var state = false
        
        switch segmentedControl.selectedSegment {
        case 0:
            state = segmentedControl.isSelected(forSegment: 0)
            setSplitLeft(!state)
            
        case 1:
            state = segmentedControl.isSelected(forSegment: 1)
            setSplitCenter(!state)
            
        case 2:
            state = segmentedControl.isSelected(forSegment: 2)
            setSplitRight(!state)
            
        default:
            break
        }
    }
    
    func setSplitLeft( _ isHidden: Bool) {
        
        if isHidden == true {
            splitViewPrincipal.setPosition(  0, ofDividerAt: 0)
        } else {
            splitViewPrincipal.setPosition(250, ofDividerAt: 0)
        }
        
        let mainView = splitViewPrincipal.subviews.first!
        mainView.isHidden = isHidden
        
        segmentedControl.setSelected(!isHidden, forSegment: 0)
        splitViewPrincipal.adjustSubviews()
    }
    
    func setSplitCenter( _ isHidden: Bool) {
        
        if isHidden == true {
            splitViewCentre.setPosition(splitViewCentre.bounds.height, ofDividerAt: 0)
        } else {
            splitViewCentre.setPosition( splitViewCentre.bounds.height / 2, ofDividerAt: 0)
        }
        operationViewSecondary.isHidden = isHidden
        
        segmentedControl.setSelected(!isHidden, forSegment: 1)
        splitViewCentre.adjustSubviews()
        splitViewPrincipal.adjustSubviews()
        
    }
    
    func setSplitRight( _ isHidden: Bool) {
        
        if isHidden == true {
            splitViewPrincipal.setPosition(splitViewPrincipal.bounds.width, ofDividerAt: 1)
        } else {
            splitViewPrincipal.setPosition( splitViewPrincipal.bounds.width - 249, ofDividerAt: 1)
        }
        operationView.isHidden = isHidden
        segmentedControl.setSelected(!isHidden, forSegment: 2)
        splitViewPrincipal.adjustSubviews()
    }
    
    @IBAction  func printDocument(_ sender: Any) {
        
        let view = listTransactionsController?.outlineListView
        
        let headerLine = "Liste Opérations"
        //        var myPrintView = NSView()
        
        let printOpts: [NSPrintInfo.AttributeKey: Any] = [.headerAndFooter: true, .orientation: 1]
        let printInfo = NSPrintInfo(dictionary: printOpts)
        
        printInfo.leftMargin = 20
        printInfo.rightMargin = 20
        printInfo.topMargin = 40
        printInfo.bottomMargin = 20
        
        printInfo.horizontalPagination = .fit
        printInfo.verticalPagination = .automatic
        
        printInfo.scalingFactor = 1.0
        printInfo.paperSize = NSSize(width: 595, height: 842)
        
        let myPrintView = MyPrintViewOutline(tableView: view, andHeader: headerLine)
        
        let printTransaction = NSPrintOperation(view: myPrintView, printInfo: printInfo)
        printTransaction.printPanel.options.insert(NSPrintPanel.Options.showsPaperSize)
        printTransaction.printPanel.options.insert(NSPrintPanel.Options.showsOrientation)
        
        printTransaction.run()
        printTransaction.cleanUp()
    }
    
    @objc func pageLayoutDidEnd( pageLayout: NSPageLayout?, returnCode: Int, contextInfo: UnsafeMutableRawPointer?) {
        if returnCode == Int(NSApplication.ModalResponse.OK.rawValue) {
        }
    }
    
    @IBAction func LaunchCalc(_ sender: Any) {
        
        var isAlreadyRunning = false
        let running = NSWorkspace.shared.runningApplications
        
        for app in running {
            let id = app.bundleIdentifier
            if id == "com.apple.calculator" {
                isAlreadyRunning = true
                break
            }
        }
        
        if isAlreadyRunning == false {
//            let path = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: "com.apple.calculator")
            guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.calculator") else { return }

            let configuration = NSWorkspace.OpenConfiguration()
            let path = "/bin"
            configuration.arguments = [path]
            NSWorkspace.shared.openApplication(at: url,
                                               configuration: configuration,
                                               completionHandler: nil)
//            _ = NSWorkspace.shared.launchApplication(path!)
        }
    }
    
    @IBAction func chooseCouleur(_ sender: NSPopUpButton) {
        var titre = ""
        let selectItem = sender.selectedItem
        let button: NSPopUpButton? = sender
        
        if let tag = selectItem?.tag {
            
            switch tag {
            case 1:
                titre = "unie"
            case 2:
                titre = "recette/depense"
            case 3:
                titre = "rubrique"
            case 4:
                titre = "mode"
            case 5:
                titre = "statut"
                
            default:
                break
            }
            Defaults.set(titre, forKey: "choix couleurs")
            Defaults.set(tag, forKey: "couleurMenus")
            
            // Loop thorugh all menu items and toggle on the selected item
            let selectedItem = button?.selectedItem
            selectedItem?.state = .on
            
            for item in (button?.menu?.items)! where selectedItem != item {
                item.state = .off
            }
            listTransactionsController?.reloadData()
        }
    }
    
    @IBAction func AdvancedFilter(_ sender: Any) {
        
        changeView(name: "AdvancedFilterViewController")
    }
    
    @IBAction func rateAppStore(_ sender: Any) {
        
        let configure = RateConfigure()
        configure.name = Localizations.RateConfigure.name
        configure.icon = NSImage(named: NSImage.Name("AppIcon-1"))
        configure.detailText = Localizations.RateConfigure.detailText
        configure.likeButtonTitle = Localizations.RateConfigure.likeButtonTitle
        configure.ignoreButtonTitle = Localizations.RateConfigure.ignoreButtonTitle
        configure.rateURL = URL(string: "https://www.apple.com")
        
        rateWindowController = RateWindowController(configure: configure)
        rateWindowController?.nTimeout = 10
        rateWindowController?.requestRateWindow(.center, with: { rlst in
            print(String(format: "%lu", UInt(Float(rlst.rawValue))))
        })
    }
    
    @IBAction func showPreference(_ sender: Any) {
        
        preferencesWindowController.showWindow()
    }
    
    // MARK: - Import Operations Detaillee
    @IBAction func ImportOperationsDetaillee(_ sender: Any) {
        
        importWindowController = ImportWindowController()
        
        importWindowController?.delegate = listTransactionsController
        importWindowController?.showWindow(nil)
    }
    
    func findStatut ( statut: String) -> Int16 {
        if TypeOfStatut(rawValue: 0 )?.label == statut {
            return 0
        }
        if TypeOfStatut(rawValue: 1 )?.label == statut {
            return 1
        }
        if TypeOfStatut(rawValue: 2 )?.label == statut {
            return 2
        }
        return 1
        
    }
    
    // MARK: - Import Operations Simplifiee
    @IBAction func ImportOperationsSimplifiee(_ sender: Any) {
        
        let context = mainObjectContext

        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["csv", "txt"]
        
        panel.beginSheetModal(for: self.window!) { (result) in
            var content = ""
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                
                let url = panel.urls.first!
                do {
                    content = try String(contentsOf: url, encoding: String.Encoding.macOSRoman)
                } catch {
                    print(error)
                }
                
                let entityPreference = Preference.shared.getAllDatas()
                let dateformatter = DateFormatter()
                dateformatter.dateStyle = .short
                let now = dateformatter.string(from: Date().noon)
                
                let result = content.replacingOccurrences(of: ",", with: ",", options: String.CompareOptions.literal, range: nil)
                let csv = CSwiftV(with: result, separator: ";")
                
                let allKey = csv.keyedRows
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .none
                
                if let keys = allKey
                {
                    let dateTransaction = Localizations.ImportSimplifiee.dateOperation
                    let datePointage = Localizations.ImportSimplifiee.datePointage
                    let mode = Localizations.ImportSimplifiee.mode
                    let statut = Localizations.ImportSimplifiee.statut
                    
                    // SousOperations
                    let keyAmount = Localizations.ImportSimplifiee.montant
                    let keyCategorie = Localizations.ImportSimplifiee.category
                    let keyLibelle = Localizations.ImportSimplifiee.comment
                    
                    for key in keys
                    {
                        let amount = key[keyAmount] ?? "0.0"
                                               
                        let entity = NSEntityDescription.insertNewObject(forEntityName: "EntityTransactions", into: context!) as! EntityTransactions

                        entity.account = currentAccount
                        
                        entity.dateCree = Date()
                        entity.dateModifie = Date()
                        entity.dateOperation = dateFormatter.date(from: key[dateTransaction] ?? now)
                        entity.datePointage = dateFormatter.date(from: key[datePointage] ?? now)
                        
                        let labelMode = key[mode] ?? (entityPreference.paymentMode?.name)!
                        let entityModePaiement = PaymentMode.shared.find(name: labelMode) ?? (entityPreference.paymentMode)!
                        entity.paymentMode = entityModePaiement
                        
                        let labelStatut = TypeOfStatut(rawValue: entityPreference.statut)!.label
                        let numStatut = self.findStatut( statut: key[statut] ?? labelStatut)
                        entity.statut = numStatut
                        
                        // EntitySousOperations
                        let entitySousOperation = NSEntityDescription.insertNewObject(forEntityName: "EntitySousOperations", into: context!) as! EntitySousOperations
                        entitySousOperation.amount = Double(amount)!
                        entitySousOperation.libelle = key[keyLibelle] ?? keyLibelle
                        
                        let labelCat = key[keyCategorie] ?? (entityPreference.category?.name)!
                        let entityCategory = Categories.shared.find(name: labelCat)
                        entitySousOperation.category = entityCategory
                        
                        entity.addToSousOperations(entitySousOperation)
                        
                        entity.uuid = UUID()
                        entity.account?.name = key["compte"] ?? entityPreference.account?.name
                    }
                    self.listTransactionsController?.getAllData()
                    self.listTransactionsController?.reloadData()
                }
            }
        }
    }
    
    @IBAction func ExportOperations(_ sender: Any) {
        
        accessoryViewController = TTFormatViewController(nibName: NSNib.Name( "TTFormatViewControllerAccessory"), bundle: nil)
        
        let csvConfig =  accessoryViewController?.config
        
        let savePanel = NSSavePanel()
        savePanel.accessoryView = accessoryViewController?.view
        accessoryViewController?.config.isFirstRowAsHeader = (csvConfig?.isFirstRowAsHeader)!
        savePanel.allowedFileTypes = ["csv"]
        savePanel.begin { (result) -> Void in
            
            let encoding = self.accessoryViewController?.config.encoding
            if result == NSApplication.ModalResponse.OK {
                let filename = savePanel.url
                let exportString = self.createExportString()
                
                do {
                    try exportString.write(to: filename!, atomically: true, encoding: encoding!)
                } catch {
                    // failed to write file (bad permissions, bad filename etc.)
                }
            }
        }
    }
    
    func createExportString() -> String {
        
        let config = accessoryViewController?.config
        delimiter = String((config?.delimiter)!)
        quote = (config?.quoteCharacter)!
        
        let listeTransactions = ListTransactions.shared.getAllDatas()
        
        var account = ""
        var data = ""
        
        export = ""
        export = quote + Localizations.General.Date_Pointage + "\(quote)\(delimiter)"
        export = quote + Localizations.General.Date_Operation + "\(quote)\(delimiter)"
        export = quote + Localizations.General.Statut + "\(quote)\(delimiter)"
        export = quote + Localizations.General.Mode_Paiement + "\(quote)\(delimiter)"
        
        export = quote + Localizations.General.Libelle + "\(quote)\(delimiter)"
        export = quote + Localizations.General.Rubrique + "\(quote)\(delimiter)"
        export = quote + Localizations.General.Category + "\(quote)\(delimiter)"
        export = quote + Localizations.General.Amount + "\(quote)\(delimiter)"
        
        export = quote + Localizations.General.Account.Singular + "\(quote)\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        for listeTransaction in listeTransactions {
            
            let sousOperations = listeTransaction.sousOperations!.allObjects as! [EntitySousOperations]
            for sousOperation in sousOperations {
                
                data  = dateFormatter.string(from: listeTransaction.datePointage!)
                export = "\(quote)\(data)\(quote)\(delimiter)"
                
                data = dateFormatter.string(from: listeTransaction.dateOperation!)
                export = "\(quote)\(data)\(quote)\(delimiter)"
                
                data        = String(listeTransaction.statut)
                export = "\(quote)\(data)\(quote)\(delimiter)"
                
                data  = (listeTransaction.paymentMode?.name!)!
                export = "\(quote)\(data)\(quote)\(delimiter)"
                
                data       = sousOperation.libelle!
                export = "\(quote)\(data)\(quote)\(delimiter)"
                
                data      = (sousOperation.category?.rubric?.name)!
                export = "\(quote)\(data)\(quote)\(delimiter)"
                
                data     = (sousOperation.category?.name)!
                export = "\(quote)\(data)\(quote)\(delimiter)"
                
                data       = String(sousOperation.amount)
                export = "\(quote)\(data)\(quote)\(delimiter)"
                
                account        = (listeTransaction.account?.name)!
                export = "\(quote)\(account)\(quote)\n"
            }
        }
        return export
    }
    
    private var export: String {
        get {
            return exportTmp
        }
        set {
            exportTmp += newValue
        }
    }
    
    func createMenuForSearchField() {
        let menu = NSMenu()
        menu.title =  Localizations.searchMenu.title.menu
        
        let allMenuItem = NSMenuItem()
        allMenuItem.title =  Localizations.searchMenu.title.all
        allMenuItem.target = self
        allMenuItem.action = #selector(changeSearchFieldItem(_:))
        
        let fNameMenuItem = NSMenuItem()
        fNameMenuItem.title = Localizations.searchMenu.title.libelle
        fNameMenuItem.target = self
        fNameMenuItem.action = #selector(changeSearchFieldItem(_:))
        
        menu.addItem(allMenuItem)
        menu.addItem(fNameMenuItem)
        
        self.searchField.searchMenuTemplate = menu
        self.changeSearchFieldItem(allMenuItem)
    }
    
    @objc func changeSearchFieldItem(_ sender: AnyObject) {
        (self.searchField.cell as? NSSearchFieldCell)?.placeholderString = sender.title
    }
}

extension MainWindowController: NSControlTextEditingDelegate {
    
    func controlTextDidChange(_ obj: Notification) {
        
        guard obj.object as? NSSearchField == searchField else { return }
        
        let searchString = self.searchField.stringValue
        var predicate  = NSPredicate()
        if searchString.isEmpty {
            listTransactionsController?.getAllData()
        } else {
            let p1 = NSPredicate(format: "account == %@", currentAccount!)
            
            if (self.searchField.cell as? NSSearchFieldCell)?.placeholderString == "All" {
                let p2 = NSPredicate(format: "libelle contains %@", searchString)
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])
            } else if (self.searchField.cell as? NSSearchFieldCell)?.placeholderString == "Libellé" {
                let p2 = NSPredicate(format: "libelle contains %@", searchString)
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])
            }
            
            let fetchRequest = NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: false)]
            
            listTransactionsController?.applyFilter(fetchRequest: fetchRequest)
        }
    }
}

