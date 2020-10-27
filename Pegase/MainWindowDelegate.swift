import AppKit


extension MainWindowController: SourceListDelegate
{
    func changeView(name: String)
    {
        var  vc = NSView()
        
        var isSplitRightHidden = false
        var isSplitCenterHidden = false
        
        switch name
        {
        case "Liste des opérations":
            self.listeOperationsController = ListTransactionsController()
            vc = (self.listeOperationsController?.view)!
            self.listeOperationsController?.setUpDatePicker()
            self.listeOperationsController?.datePicker.isEnabled = true

            setUpViewOperation()
            listeOperationsController?.delegate = operationController
            
            isSplitRightHidden = false
            isSplitCenterHidden =  true
            operationViewSecondary.isHidden = true
            
            let mainView = splitViewPrincipal.subviews.first!
            mainView.isHidden = false
            segmentedControl.setEnabled(false, forSegment: 1)
            segmentedControl.setSelected(true, forSegment: 2)
            
        case "Courbe de trésorerie":
            self.tresorerieController = TresorerieController()
            vc = (tresorerieController?.view)!
            
            setUpGroupeListeOperationsSecondary(true)
            tresorerieController?.delegate = listeOperationsController
            
            isSplitRightHidden = true
            isSplitCenterHidden =  false
            segmentedControl.setEnabled(true, forSegment: 1)
            segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Rubrique Pie":
            self.rubricPieController = RubricPieController()
            vc = (self.rubricPieController?.view)!
            
            self.setUpGroupeListeOperationsSecondary()
            self.rubricPieController?.delegate = listeOperationsController
            self.rubricPieController?.setDataHorizontal()
            
            isSplitRightHidden = true
            isSplitCenterHidden =  false
            self.segmentedControl.setEnabled(true, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Site Web de la banque":
            self.webViewController = WebViewController()
            vc = (webViewController?.view)!
            
            operationViewSecondary.isHidden = true
            isSplitRightHidden = true
            isSplitCenterHidden =  true
            segmentedControl.setEnabled(false, forSegment: 1)
            segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Recette Depense":
            self.incomeExpenseBarController = IncomeExpenseBarController()
            vc = (incomeExpenseBarController?.view)!
            
            setUpGroupeListeOperationsSecondary()
            incomeExpenseBarController?.delegate = listeOperationsController
            incomeExpenseBarController?.setDataHorizontal()
            
            isSplitRightHidden  = true
            isSplitCenterHidden =  false
            segmentedControl.setEnabled(true, forSegment: 1)
            segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Rubrique Bar":
            self.rubricBarController = RubricBarController()
            vc = (rubricBarController?.view)!
            
            self.setUpGroupeListeOperationsSecondary()
            self.rubricBarController?.delegate = listeOperationsController
            self.rubricBarController?.setDataHorizontal()
            
            isSplitRightHidden  = true
            isSplitCenterHidden =  false
            self.segmentedControl.setEnabled(true, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Categorie Bar":
            self.categoryBarController = CategoryBarController()
            vc = (categoryBarController?.view)!
            
            self.setUpGroupeListeOperationsSecondary()
            self.categoryBarController?.delegate = listeOperationsController
            
            isSplitRightHidden  = true
            isSplitCenterHidden =  false
            self.segmentedControl.setEnabled(true, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Categorie Bar1":
            self.categoryBarController1 = CategoryBarController1()
            vc = (categoryBarController1?.view)!
            
            self.setUpGroupeListeOperationsSecondary()
            self.categoryBarController1?.delegate = listeOperationsController
            
            isSplitRightHidden  = true
            isSplitCenterHidden =  false
            self.segmentedControl.setEnabled(true, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Mode de paiement":
            self.modePaiementPieController = PaymentModePieController()
            vc = (modePaiementPieController?.view)!
            
            self.setUpGroupeListeOperationsSecondary()
            self.modePaiementPieController?.delegate = listeOperationsController
            self.modePaiementPieController?.setDataHorizontal()
            
            isSplitRightHidden  = true
            isSplitCenterHidden =  false
            self.segmentedControl.setEnabled(true, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Settings":
            self.parameterController = ParameterController()
            vc = ((self.parameterController)?.view)!
            
            self.setUpGroupeListeOperationsSecondary()
            self.parameterController?.rubriqueViewController?.delegate = listeOperationsController
            self.parameterController?.modePaiementViewController?.delegate = listeOperationsController
            
            isSplitRightHidden  = true
            isSplitCenterHidden =  false
            self.segmentedControl.setEnabled(true, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Scheduler":
            self.echeanciersViewController = SchedulerViewController()
            vc = (echeanciersViewController?.view)!
            
            self.setUpViewSaisieEcheancier()
            self.echeanciersViewController?.delegate = echeanciersSaisieController
            self.echeanciersSaisieController?.delegate = echeanciersViewController
            
            isSplitRightHidden = false
            isSplitCenterHidden =  true
            self.operationViewSecondary.isHidden = true
            self.segmentedControl.setEnabled(false, forSegment: 1)
            self.segmentedControl.setEnabled(true, forSegment: 2)
            
        case "Identite":
            self.identiteViewController = IdentiteViewController()
            vc = (identiteViewController?.view)!
            
            isSplitRightHidden              = true
            isSplitCenterHidden             =  true
            self.operationViewSecondary.isHidden = true
            self.segmentedControl.setEnabled(false, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        case "AdvancedFilterViewController":
            self.advancedFilterViewController = AdvancedFilterViewController()
            vc = (advancedFilterViewController?.view)!
            
            self.setUpGroupeListeOperationsSecondary()
            self.advancedFilterViewController?.delegate = listeOperationsController
            
            isSplitRightHidden = true
            isSplitCenterHidden =  false
            self.segmentedControl.setEnabled(true, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        default:
            break
        }
        
        Commun.shared.addSubview(subView: vc, toView: tableTargetView)
        
        vc.translatesAutoresizingMaskIntoConstraints = false
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["vc"] = vc
        tableTargetView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[vc]|", options: [], metrics: nil, views: viewBindingsDict))
        tableTargetView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[vc]|", options: [], metrics: nil, views: viewBindingsDict))
        
        setSplitRight( isSplitRightHidden)
        setSplitCenter( isSplitCenterHidden)
        splitViewPrincipal.adjustSubviews()
    }
    
}
