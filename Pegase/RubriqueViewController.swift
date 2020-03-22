import Cocoa

final class RubriqueViewController: NSViewController {
    
    public weak var delegate: FilterDelegate?

    @IBOutlet weak var anOutlineView: NSOutlineView!
    @IBOutlet var anTreeController: NSTreeController!
    @IBOutlet weak var menuLocal: NSMenu!
    
    var dragType = [NSPasteboard.PasteboardType]()
    var draggedNode: Any?
    @IBOutlet weak var addRubric: NSButton!
    @IBOutlet weak var removeRubric: NSButton!
    
    @IBOutlet weak var addCategory: NSButton!
    @IBOutlet weak var removeCategory: NSButton!

    var selectIndex = [1]
    
    @objc var managedObjectContext: NSManagedObjectContext = mainObjectContext
    @objc dynamic var customSortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))]
    
    var rubriqueModalWindowController: RubriqueModalWindowController!
    var categorieModalWindowController: CategorieModalWindowController!
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        view.window!.title = Localizations.General.Rubric
        NotificationCenter.receive(instance: self, name:.selectionDidChangeOutLine, selector: #selector(selectionDidChange))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.receive(instance: self, name: .updateAccount, selector: #selector(updateChangeCompte(_:)))
        updateData()
        
        anOutlineView.allowsEmptySelection = false
        let descriptorName = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        anOutlineView.tableColumns[0].sortDescriptorPrototype = descriptorName

        dragType = [NSPasteboard.PasteboardType( "DragType")]
        anOutlineView.registerForDraggedTypes(dragType)
        
        anOutlineView.doubleAction = #selector(doubleClicked)
        anTreeController.sortDescriptors = customSortDescriptors
        
        addRubric.isEnabled = false
        removeRubric.isEnabled = false
        addCategory.isEnabled = false
        removeCategory.isEnabled = false
    }
    
    @objc func updateChangeCompte(_ note: Notification) {
        updateData()
    }

    func updateData() {
        guard currentAccount != nil else { return }
                
        Rubric.shared.getAll()
        anTreeController.fetchPredicate = NSPredicate(format: "account == %@", currentAccount!)
        anTreeController.rearrangeObjects()
        
        DispatchQueue.main.async(execute: {() -> Void in
            self.anOutlineView.expandItem(nil, expandChildren: true)
            DispatchQueue.main.async(execute: {() -> Void in
                self.perform(#selector(self.ExpandAll), with: nil, afterDelay: 0.0)
            })
        })
    }
    
    /// Called when the a row in the sidebar is double clicked
    @objc private func doubleClicked(_ sender: Any?) {
        let clickedRow = anOutlineView.item(atRow: anOutlineView.clickedRow)
        
        if anOutlineView.isItemExpanded(clickedRow) {
            anOutlineView.collapseItem(clickedRow)
        } else {
            anOutlineView.expandItem(clickedRow)
        }
    }
    
    @objc func selectionDidChange(_ notification: Notification) {
        
        guard notification.object as? NSOutlineView == anOutlineView else { return }
        
        let index = anOutlineView.selectedRow
        let rowView = anOutlineView.rowView(atRow: index, makeIfNecessary: false)
        rowView?.isEmphasized = true
        
        let select = anTreeController.selectedObjects
        //
        var identity = select[0]
        if identity is EntityCategory == true {
            identity = (identity as! EntityCategory).rubrique!
        }
        
        let rubriqueName = (identity as? EntityRubrique)?.name!
        
        let p1 = NSPredicate(format: "account == %@", currentAccount!)
        let p2 = NSPredicate(format: "SUBQUERY(sousOperations, $sousOperation, $sousOperation.category.rubrique.name == %@).@count > 0", rubriqueName!)
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [ p1, p2])
        
        let fetch = NSFetchRequest<EntityOperations>(entityName: "EntityOperations")
        fetch.predicate = predicate
        fetch.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: false)]

        DispatchQueue.main.async(execute: {() -> Void in
            self.delegate?.applyFilter(fetchRequest: fetch)
        })
    }
    
    
}

