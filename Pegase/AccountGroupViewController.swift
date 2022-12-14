import AppKit

final class AccountGroupViewController: NSViewController {
    
    @IBOutlet weak var anSideBar: NSOutlineView!
    @IBOutlet weak var accountButton: NSButton!
    @IBOutlet weak var menuLocal: NSMenu!
    
    var curtainViewController: CurtainViewController?

    let REORDER_PASTEBOARD_TYPE = "com.th.outline.item"
    var draggedNodes: [EntityAccount]?
    
    var groupModalWindowController: GroupModalWindowController!
    var accountModalWindowController: AccountModalWindowController!
    
    private let key = Notification.Name.updateBalance
    
    var rootSourceListItem: EntityAccount!
    
    let formatter = NumberFormatter()
    var indexRow = 0
    
    // -------------------------------------------------------------------------
    //    viewDidAppear
    // -------------------------------------------------------------------------
    override func viewDidAppear() {
        super.viewDidAppear()
        
        anSideBar.selectRowIndexes([1], byExtendingSelection: true)
        NotificationCenter.receive(instance: self, selector: #selector(updateBalance(_:)), name: key)
    }
    
    // -------------------------------------------------------------------------
    //    viewDidLoad
    // -------------------------------------------------------------------------
    override func viewDidLoad() {
        
        anSideBar.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: REORDER_PASTEBOARD_TYPE)])
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        
        rootSourceListItem = Account.shared.getRoot().first!
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
        // note: nous commen??ons ?? observer apr??s que outlineview a re??u des donnees
        // nous ne recevrons pas de notifications inutiles au d??marrage
        NotificationCenter.receive(instance: self, selector: #selector(selectionDidChange(_:)), name: .selectionDidChangeOutLine)

        anSideBar.selectRowIndexes([1], byExtendingSelection: false)
    }
    
    // -------------------------------------------------------------------------
    //    dealloc
    // -------------------------------------------------------------------------
    deinit {
        NotificationCenter.remove(instance: self, name: .selectionDidChangeOutLine)
        NotificationCenter.remove(instance: self, name: .updateBalance)
    }
    
    @objc func updateBalance(_ notification: Notification) {
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
            if item.identity != nil {
                indexRow = index!
                currentAccount = item
                
                Rubric.shared.getAllDatas()
                PaymentMode.shared.getAllDatas()

//                Account.shared.printAccount(entityAccount: currentAccount!, description: "select")
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

