import AppKit

final class AdvancedFilterViewController: NSViewController {

    public weak var delegate: FilterDelegate?
    @IBOutlet weak var predicateEditor: NSPredicateEditor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        if predicateEditor.predicate == nil {
            predicateEditor.addRow(self)
        }
    }
    
    /// predicateEditorAction
    ///
    /// - Parameter sender:
    @IBAction func predicateEditorAction(_ sender: NSButton) {
        print("predicate value changed")
    }
    
    @IBAction func generateQuery(_ sender: NSButton) {

        let fetchRequest = NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
        let p1 = NSPredicate(format: "account == %@", currentAccount!)
        let p2 = predicateEditor.predicate
        print("predicateEditor : ", predicateEditor.predicate ?? "predicate default")
        print(predicateEditor.predicate?.description ?? "predicateEditor.predicate")

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2!])

        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: true)]
        
        self.delegate?.applyFilter(fetchRequest: fetchRequest)
    }
}

