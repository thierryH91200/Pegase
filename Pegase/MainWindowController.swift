import AppKit
import UserNotifications

final class MainWindowController: NSWindowController , NSWindowDelegate, UNUserNotificationCenterDelegate {
    
    var importWindowController: ImportWindowController?
    var accessoryViewController: TTFormatViewController?
    
    var listTransactionsController: ListTransactionsController?
    var transactionController: TransactionViewController?
    var sourceListViewController: SourceListViewController?
    var groupeAccountViewController: AccountGroupViewController?
    
    var tresorerieController: TresorerieController?
    var rubricPieController: RubricPieController?
    var categoryBarController: CategoryBarController?
    var categoryBarController1: CategoryBarController1?
    var modePaiementPieController: PaymentModePieController?
    var incomeExpenseBarController: IncomeExpenseBarController?
    var rubricBarController: RubricBarController?

    var parameterController: ParameterController?
    
    var echeanciersSaisieController: SchedulersSaisieController?
    var echeanciersViewController: SchedulerViewController?
    
    var identiteViewController: IdentiteViewController?
    var webViewController: WebViewController?
    var advancedFilterViewController: AdvancedFilterViewController?

    @IBOutlet weak var preferencesItem: NSToolbarItem!
    @IBOutlet weak var printItem: NSToolbarItem!
    @IBOutlet weak var suqreButton: NSToolbarItem!
    @IBOutlet weak var segmentedItem: NSToolbarItem!
    
    
    let preferencesWindowController = PreferencesWindowController(
        viewControllers: [
//           GeneralViewController() ,
            AccountViewController() ,
            PersonViewController()
        ]
    )
    var rateWindowController: RateWindowController?

    @IBOutlet weak var operationView: NSView!
    @IBOutlet weak var tableTargetView: NSView!
    @IBOutlet weak var accountView: NSView!
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
    
    private var center: UNUserNotificationCenter?
    private let handler = NotificationHandler()
    private let notifyCategoryIdentifier = "test"
    private let notificationsHelper = NotificationsHelper()
    

    
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
        
        preferencesItem.view?.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        preferencesItem.view?.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        printItem.view?.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        printItem.view?.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        suqreButton.view?.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        suqreButton.view?.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        segmentedItem.view?.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        segmentedItem.view?.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true

        printItem.label = "Print"

        self.window?.delegate = self
        
        self.splitViewPrincipal.delegate = self
        self.createMenuForSearchField()
        
        var entityAccount = [EntityAccount]()
        let request = NSFetchRequest<EntityAccount>(entityName: "EntityAccount")
        let predicate = NSPredicate(format: "isAccount == YES")
        request.predicate = predicate
        
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            entityAccount = try mainObjectContext.fetch(request)
        } catch { print(error) }
        
        if entityAccount.isEmpty {
            self.groupeAccountViewController?.addAccount(entityAccount)
        } else {
            currentAccount = entityAccount.first
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
        
        self.center = UNUserNotificationCenter.current()
        self.center?.delegate = self.handler
        self.initNotifications()
//        self.requestPermission()
        notificationsHelper.requestPermission(for:  [.alert, .sound, .badge])
        
        notificationsHelper.scheduleNotification(timeInterval: 1, repeats: false)
    }
    
//    public func requestPermission(for authorization: UNAuthorizationOptions = []) {
//
//        self.center?.requestAuthorization(
//            options: authorization) { (permissionGranted, error) in
//                guard let checkedError = error else {
//                    if !permissionGranted {
//                        print("Notification permission denied")
//                    }
//                    else {
//                        print("Notification permission granted")
//                    }
//                    return
//                }
//                print("ERROR:::", checkedError.localizedDescription)
//        }
//    }

    private func initNotifications() {
        guard let center = self.center else { return }
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
  //              print("Successful authorized!")
                // Define the custom actions.
                let byeAction = UNNotificationAction(identifier: NotificationActionsEnum.bye.rawValue, title: NSLocalizedString("Bye", comment: ""), options: UNNotificationActionOptions(rawValue: 0))
                let helloAction = UNNotificationAction(identifier: NotificationActionsEnum.sayHello.rawValue, title: NSLocalizedString("Hello", comment: ""), options: UNNotificationActionOptions(rawValue: 0))
                
                // Define the notification type
                let testCategory = UNNotificationCategory(identifier: self.notifyCategoryIdentifier, actions: [byeAction, helloAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
                
                center.setNotificationCategories([testCategory])
            } else {
                print("Authorization denied!")
                return
            }
        }
    }


//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        // pull out the buried userInfo dictionary
//        let userInfo = response.notification.request.content.userInfo
//
//        if let customData = userInfo["customData"] as? String {
//            print("Custom data received: \(customData)")
//
//            switch response.actionIdentifier {
//            case UNNotificationDefaultActionIdentifier:
//                // the user swiped to unlock
//                print("Default identifier")
//
//            case "show":
//                // the user tapped our "show more info…" button
//                print("Show more information…")
//
//            default:
//                break
//            }
//        }
//
//        // you must call the completion handler when you're done
//        completionHandler()
//    }

    private func justForTheFun() {
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        let show = UNNotificationAction(
            identifier: "file",
            title: Localizations.Document.File_Uploaded,
            options: .foreground)
        
        let category = UNNotificationCategory(identifier: "show", actions: [show], intentIdentifiers: [])

        center.setNotificationCategories([category])


        
//        UNNotificationAction* snoozeAction = [UNNotificationAction
//                                              actionWithIdentifier:@"SNOOZE_ACTION"
//                                              title:@"Snooze"
//                                              options:UNNotificationActionOptionNone];  // 03-25-2019 The action has the default behavior.
//
//        let notification = NSUserNotification()
//        notification.title = Localizations.Document.File_Uploaded
//        notification.subtitle = "example.txt"
//        notification.informativeText = "/Users/John/Documents/example.txt"
//        notification.soundName = NSUserNotificationDefaultSoundName
//        notification.contentImage = NSImage(named: NSImage.Name("icon_Upload-Information-icon_24x24"))
//        NSUserNotificationCenter.default.deliver(notification)
    }
    
    private func setUpSourceList()
    {
        self.sourceListViewController = SourceListViewController()
        self.sourceListViewController?.delegate = self
        let subView = self.sourceListViewController?.view
        Commun.shared.addSubview(subView: subView!, toView: affichageView)
        
        Commun.shared.setUpLayoutConstraints(item: self.sourceListViewController!.view, toItem: affichageView)
        self.sourceListViewController!.view.setFrameSize( NSSize(width: 100, height: 200)) //affichageView.bounds
    }
    
    private func setUpGroupeAccount()
    {
        self.groupeAccountViewController = AccountGroupViewController()
        let subView = self.groupeAccountViewController?.view
        Commun.shared.addSubview(subView: subView!, toView: accountView)
        
        Commun.shared.setUpLayoutConstraints(item: self.groupeAccountViewController!.view, toItem: accountView)
        self.groupeAccountViewController!.view.setFrameSize( NSSize(width: 100, height: 200))
    }

    func setUpViewtTansaction()
    {
        self.transactionController = TransactionViewController()
        Commun.shared.addSubview(subView: transactionController!.view, toView: operationView)
        
        Commun.shared.setUpLayoutConstraints(item: transactionController!.view, toItem: operationView)
        self.transactionController!.view.frame = operationView.bounds
        self.transactionController?.delegate = listTransactionsController
    }
    
    func setUpGroupeListTransactionsSecondary(_ forced : Bool = false)
    {
        self.listTransactionsController = ListTransactionsController()
        let vc = (self.listTransactionsController?.view)!
        
        if forced == true {
            self.listTransactionsController?.setUpDatePicker()
            self.listTransactionsController?.datePicker.isEnabled = true

        } else {
            self.listTransactionsController?.datePicker.isEnabled = false
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
        self.echeanciersSaisieController = SchedulersSaisieController()
        Commun.shared.addSubview(subView: (echeanciersSaisieController?.view)!, toView: operationView)
        
        Commun.shared.setUpLayoutConstraints(item: echeanciersSaisieController!.view, toItem: operationView)
        self.echeanciersSaisieController!.view.frame = operationView.bounds
    }
}
