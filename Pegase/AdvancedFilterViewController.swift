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
    /// - Parameter sender: <#sender description#>
    @IBAction func predicateEditorAction(_ sender: NSButton) {
        print("predicate value changed")
    }
    
    @IBAction func generateQuery(_ sender: NSButton) {

        let fetchRequest = NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
        fetchRequest.predicate = predicateEditor.predicate
        print(predicateEditor.predicate?.description ?? "predicateEditor.predicate")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: true)]
        
        self.delegate?.applyFilter(fetchRequest: fetchRequest)
    }
    
}

