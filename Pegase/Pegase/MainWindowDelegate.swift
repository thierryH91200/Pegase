import AppKit


extension MainWindowController: SourceListDelegate
{
    func changeView(name: String)
    {
        var  vc = NSView()
        
        var isSplitDroitHidden = false
        var isSplitCentreHidden = false
        
        switch name
        {
        case "Liste des opérations":
            self.listeOperationsController = ListeOperationsController()
            vc = (self.listeOperationsController?.view)!
//            self.listeOperationsController?.representedObject = self
            
            setUpViewOperation()
            listeOperationsController?.delegate = operationController
            
            isSplitDroitHidden = false
            isSplitCentreHidden =  true
            operationViewSecondary.isHidden = true
            
            let mainView = splitViewPrincipal.subviews.first!
            mainView.isHidden = false
            segmentedControl.setEnabled(false, forSegment: 1)
            segmentedControl.setSelected(true, forSegment: 2)
            
        case "Courbe de trésorerie":
            self.tresorerieController = TresorerieController()
            vc = (tresorerieController?.view)!
            
            setUpGroupeListeOperationsSecondary()
            tresorerieController?.delegate = listeOperationsController
            
            isSplitDroitHidden = true
            isSplitCentreHidden =  false
            segmentedControl.setEnabled(true, forSegment: 1)
            segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Rubrique Pie":
            self.rubriquePieController = RubriquePieController()
            vc = (self.rubriquePieController?.view)!
            
            self.setUpGroupeListeOperationsSecondary()
            self.rubriquePieController?.delegate = listeOperationsController
            self.rubriquePieController?.setDataHorizontal()
            
            isSplitDroitHidden = true
            isSplitCentreHidden =  false
            self.segmentedControl.setEnabled(true, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Site Web de la banque":
            self.webViewController = WebViewController()
            vc = (webViewController?.view)!
            
            operationViewSecondary.isHidden = true
            isSplitDroitHidden = true
            isSplitCentreHidden =  true
            segmentedControl.setEnabled(false, forSegment: 1)
            segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Recette Depense":
            self.recetteDepenseBarController = RecetteDepenseBarController()
            vc = (recetteDepenseBarController?.view)!
            
            setUpGroupeListeOperationsSecondary()
            recetteDepenseBarController?.delegate = listeOperationsController
            recetteDepenseBarController?.setDataHorizontal()
            
            isSplitDroitHidden  = true
            isSplitCentreHidden =  false
            segmentedControl.setEnabled(true, forSegment: 1)
            segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Rubrique Bar":
            self.rubriqueBarController = RubriqueBarController()
            vc = (rubriqueBarController?.view)!
            
            self.setUpGroupeListeOperationsSecondary()
            self.rubriqueBarController?.delegate = listeOperationsController
            self.rubriqueBarController?.setDataHorizontal()
            
            isSplitDroitHidden  = true
            isSplitCentreHidden =  false
            self.segmentedControl.setEnabled(true, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Categorie Bar":
            self.categorieBarController = CategorieBarController()
            vc = (categorieBarController?.view)!
            
            self.setUpGroupeListeOperationsSecondary()
            self.categorieBarController?.delegate = listeOperationsController
            
            isSplitDroitHidden  = true
            isSplitCentreHidden =  false
            self.segmentedControl.setEnabled(true, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Categorie Bar1":
            self.categorieBarController1 = CategorieBarController1()
            vc = (categorieBarController1?.view)!
            
            self.setUpGroupeListeOperationsSecondary()
            self.categorieBarController1?.delegate = listeOperationsController
            
            isSplitDroitHidden  = true
            isSplitCentreHidden =  false
            self.segmentedControl.setEnabled(true, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Mode de paiement":
            self.modePaiementPieController = ModePaiementPieController()
            vc = (modePaiementPieController?.view)!
            
            self.setUpGroupeListeOperationsSecondary()
            self.modePaiementPieController?.delegate = listeOperationsController
            self.modePaiementPieController?.setDataHorizontal()
            
            isSplitDroitHidden  = true
            isSplitCentreHidden =  false
            self.segmentedControl.setEnabled(true, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Settings":
            self.parametreController = ParametreController()
            vc = ((self.parametreController)?.view)!
            
            self.setUpGroupeListeOperationsSecondary()
            self.parametreController?.rubriqueViewController?.delegate = listeOperationsController
            self.parametreController?.modePaiementViewController?.delegate = listeOperationsController
            
            isSplitDroitHidden  = true
            isSplitCentreHidden =  false
            self.segmentedControl.setEnabled(true, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Scheduler":
            self.echeanciersViewController = EcheanciersViewController()
            vc = (echeanciersViewController?.view)!
            
            self.setUpViewSaisieEcheancier()
            self.echeanciersViewController?.delegate = echeanciersSaisieController
            self.echeanciersSaisieController?.delegate = echeanciersViewController
            
            isSplitDroitHidden = false
            isSplitCentreHidden =  true
            self.operationViewSecondary.isHidden = true
            self.segmentedControl.setEnabled(false, forSegment: 1)
            self.segmentedControl.setEnabled(true, forSegment: 2)
            
        case "Identite":
            self.identiteViewController = IdentiteViewController()
            vc = (identiteViewController?.view)!
            
            isSplitDroitHidden              = true
            isSplitCentreHidden             =  true
            self.operationViewSecondary.isHidden = true
            self.segmentedControl.setEnabled(false, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        case "AdvancedFilterViewController":
            self.advancedFilterViewController = AdvancedFilterViewController()
            vc = (advancedFilterViewController?.view)!
            
            self.setUpGroupeListeOperationsSecondary()
            self.advancedFilterViewController?.delegate = listeOperationsController
            
            isSplitDroitHidden = true
            isSplitCentreHidden =  false
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
        
        setSplitRight( isSplitDroitHidden)
        setSplitCenter( isSplitCentreHidden)
        splitViewPrincipal.adjustSubviews()
    }
    
}
