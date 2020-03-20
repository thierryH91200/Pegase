

import AppKit

final class MainWindowController: NSWindowController , NSWindowDelegate {
    
    var importWindowController: ImportWindowController?
    var accessoryViewController: TTFormatViewController?
    
    var listeOperationsController: ListeOperationsController?
    var operationController: OperationViewController?
    var sourceListViewController: SourceListViewController?
    var groupeCompteViewController: GroupeCompteViewController?
    
    var rubriquePieController: RubriquePieController?
    var categoryBarController: CategoryBarController?
    var categoryBarController1: CategoryBarController1?
    var rubricBarController: RubricBarController?
    var modePaiementPieController: ModePaiementPieController?
    var incomeExpenseBarController: IncomeExpenseBarController?
    var tresorerieController: TresorerieController?
    
    var parametreController: ParametreController?
    var echeanciersSaisieController: EcheanciersSaisieController?
    var rubriqueViewController: RubriqueViewController?
    var modePaiementViewController: ModePaiementViewController?
    var echeanciersViewController: EcheanciersViewController?
    var chequiersViewController: ChequiersViewController?
    var identiteViewController: IdentiteViewController?
    var webViewController: WebViewController?
    var advancedFilterViewController: AdvancedFilterViewController?

    let preferencesWindowController = PreferencesWindowController(
        viewControllers: [
//           GeneralViewController() ,
            AccountViewController() ,
            PersonViewController()
        ]
    )
    var rateWindowController: RateWindowController? = nil

    @IBOutlet weak var operationView: NSView!
    @IBOutlet weak var tableTargetView: NSView!
    @IBOutlet weak var compteView: NSView!
    @IBOutlet weak var affichageView: NSView!
    @IBOutlet weak var operationViewSecondary: NSView!
    
    @IBOutlet weak var menuColor: NSMenu!
    @IBOutlet weak var popUpColor: NSPopUpButton!
    
    @IBOutlet weak var splitViewPrincipal: NSSplitView!
    @IBOutlet weak var splitViewGauche: NSSplitView!
    @IBOutlet weak var splitViewCentre: NSSplitView!
    @IBOutlet weak var segmentedControl: NSSegmentedControl!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var colorPopUp: NSPopUpButton!
    
    let defaults = UserDefaults.standard
    
    var delimiter = ""
    var quote = ""
    var exportTmp = ""
    
    override var windowNibName: NSNib.Name? {
        return  "MainWindowController"
    }
    
    func windowWillClose(_ notification: Notification) {
        if mainObjectContext.hasChanges == true {
            print ( "mainObjectContext.hasChanges" )
            do {
                try mainObjectContext.save()
            } catch {
                print("error")
            }
        }
        
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.delegate = self
        
        self.splitViewPrincipal.delegate = self
        self.createMenuForSearchField()
        
        var entityCompte = [EntityAccount]()
        let request = NSFetchRequest<EntityAccount>(entityName: "EntityAccount")
        let predicate = NSPredicate(format: "isAccount == YES")
        request.predicate = predicate
        
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            entityCompte = try mainObjectContext.fetch(request)
        } catch { print(error) }
        
        if entityCompte.isEmpty {
            self.groupeCompteViewController?.addCompte(entityCompte)
        } else {
            compteCourant = entityCompte.first
        }
        
        self.setUpGroupeAccount()
        self.setUpSourceList()
        
        self.justForTheFun()
        
        self.splitViewPrincipal.autosaveName = NSSplitView.AutosaveName( "splitViewPrincipal")
        self.splitViewGauche.autosaveName = NSSplitView.AutosaveName( "splitViewLeft")
        self.splitViewCentre.autosaveName = NSSplitView.AutosaveName( "splitViewCenter")
        
        let mainViews = splitViewPrincipal.subviews
        for mainView in mainViews {
            mainView.isHidden = false
        }
        
        var tag = Defaults.integer(forKey: "couleurMenus")
        if tag == 0 {
            tag = 1
            Defaults.set(tag, forKey: "couleurMenus")
            Defaults.set("unie", forKey: "choix couleurs")
        }
        
        let itemArray = colorPopUp.itemArray
        for item in itemArray {
            item.state = .off
            if item.tag == tag {
                item.state = .on
            }
        }
    }
    
    private func justForTheFun() {
        let notification = NSUserNotification()
        notification.title = Localizations.Document.File_Uploaded
        notification.subtitle = "example.txt"
        notification.informativeText = "/Users/John/Documents/example.txt"
        notification.soundName = NSUserNotificationDefaultSoundName
        notification.contentImage = NSImage(named: NSImage.Name("icon_Upload-Information-icon_24x24"))
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    private func setUpSourceList()
    {
        self.sourceListViewController = SourceListViewController()
        self.sourceListViewController?.delegate = self
        let subView = self.sourceListViewController?.view ?? nil
        Commun.shared.addSubview(subView: subView!, toView: affichageView)
        
        Commun.shared.setUpLayoutConstraints(item: self.sourceListViewController!.view, toItem: affichageView)
        self.sourceListViewController!.view.setFrameSize( NSSize(width: 100, height: 200)) //affichageView.bounds
    }
    
    private func setUpGroupeAccount()
    {
        self.groupeCompteViewController = GroupeCompteViewController()
        let subView = self.groupeCompteViewController?.view
        Commun.shared.addSubview(subView: subView!, toView: compteView)
        
        Commun.shared.setUpLayoutConstraints(item: self.groupeCompteViewController!.view, toItem: compteView)
        self.groupeCompteViewController!.view.setFrameSize( NSSize(width: 100, height: 200))
    }

    func setUpViewOperation()
    {
        self.operationController = OperationViewController()
        Commun.shared.addSubview(subView: operationController!.view, toView: operationView)
        
        Commun.shared.setUpLayoutConstraints(item: operationController!.view, toItem: operationView)
        self.operationController!.view.frame = operationView.bounds
        self.operationController?.delegate = listeOperationsController
    }
    
    func setUpGroupeListeOperationsSecondary(_ forced : Bool = false)
    {
        self.listeOperationsController = ListeOperationsController()
        let vc = (self.listeOperationsController?.view)!
        
        if forced == true {
            self.listeOperationsController?.setUpDatePicker()
            self.listeOperationsController?.datePicker.isEnabled = true

        } else {
            self.listeOperationsController?.datePicker.isEnabled = false
        }
        
        Commun.shared.addSubview(subView: vc, toView: operationViewSecondary)
        vc.translatesAutoresizingMaskIntoConstraints = false
        
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["vc"] = vc
        operationViewSecondary.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[vc]|", options: [], metrics: nil, views: viewBindingsDict))
        operationViewSecondary.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[vc]|", options: [], metrics: nil, views: viewBindingsDict))
    }
    
    func setUpViewSaisieEcheancier()
    {
        self.echeanciersSaisieController = EcheanciersSaisieController()
        Commun.shared.addSubview(subView: (echeanciersSaisieController?.view)!, toView: operationView)
        
        Commun.shared.setUpLayoutConstraints(item: echeanciersSaisieController!.view, toItem: operationView)
        self.echeanciersSaisieController!.view.frame = operationView.bounds
    }
}
