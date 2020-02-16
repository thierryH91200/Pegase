import AppKit

final class GroupeCompteViewController: NSViewController {
    
    @IBOutlet weak var anSideBar: NSOutlineView!
    @IBOutlet weak var accountButton: NSButton!
    @IBOutlet weak var menuLocal: NSMenu!
    
    var curtainViewController: CurtainViewController?

    let REORDER_PASTEBOARD_TYPE = "com.th.outline.item"
    var draggedNodes: [EntityAccount]?
    
    var groupModalWindowController: GroupModalWindowController!
    var compteModalWindowController: CompteModalWindowController!
    
    let key = Notification.Name.updateSolde
    
    var rootSourceListItem: EntityAccount!
    
    let formatter = NumberFormatter()
    var indexRow = 0
    
    // -------------------------------------------------------------------------
    //    viewDidAppear
    // -------------------------------------------------------------------------
    override func viewDidAppear() {
        super.viewDidAppear()
        
        anSideBar.selectRowIndexes([1], byExtendingSelection: true)
        NotificationCenter.receive(instance: self, name: key, selector: #selector(updateSolde(_:)))
    }
    
    // -------------------------------------------------------------------------
    //    viewDidLoad
    // -------------------------------------------------------------------------
    override func viewDidLoad() {
        
        anSideBar.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: REORDER_PASTEBOARD_TYPE)])
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        
        rootSourceListItem = Compte.shared.getRoot().first!
        anSideBar.reloadData()

        anSideBar.autosaveExpandedItems = true
        anSideBar.menu = menuLocal
        anSideBar.expandItem(nil, expandChildren: true)
    }
    
    // -------------------------------------------------------------------------
    //    viewWillAppear
    // -------------------------------------------------------------------------
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // listen for selection changes from the NSOutlineView inside MainWindowController
        // note: nous commençons à observer après que outlineview a reçu des donnees
        // nous ne recevrons pas de notifications inutiles au démarrage
        NotificationCenter.receive(instance: self, name: .selectionDidChangeOutLine, selector: #selector(selectionDidChange(_:)))

        anSideBar.selectRowIndexes([1], byExtendingSelection: false)
    }
    
    // -------------------------------------------------------------------------
    //    dealloc
    // -------------------------------------------------------------------------
    deinit {
        NotificationCenter.default.removeObserver(self, name: .selectionDidChangeOutLine, object: nil)
        NotificationCenter.default.removeObserver(self, name: .updateSolde, object: nil)
    }
    
    @objc func updateSolde(_ notification: Notification) {
        indexRow = anSideBar.selectedRow
        anSideBar.reloadData()
        anSideBar.selectRowIndexes([indexRow], byExtendingSelection: false)
    }

    /// Listens for changes outline view row selection
    ///
    /// - Parameter notification: The notification object is the outline view whose selection changed
    @objc func selectionDidChange(_ notification: Notification) {
        
        let outlineView = notification.object as? NSOutlineView
        guard anSideBar == outlineView else { return }
        
        let index = outlineView?.selectedRow
        guard indexRow != index else { return }
        
        if let item = outlineView?.item(atRow: index!) as? EntityAccount
        {
            if item.identite != nil {
                indexRow = index!
                compteCourant = item
                
                Rubrique.shared.getAll()
                ModePaiement.shared.getAll()

                Compte.shared.printAccount(entityCompte: compteCourant!, description: "select")
                NotificationCenter.send(.updateAccount)
            }
        }
    }
    
    @IBAction func showCurtain(_ sender: Any) {
        
        self.curtainViewController = CurtainViewController()
        let height = self.view.window?.toolbarHeight()
        var size = (self.view.window?.frame.size)!
        
        if let height = height {
            size.height = size.height - height
        }
        curtainViewController?.size = size
        self.presentAsSheet(curtainViewController!)
    }
}

