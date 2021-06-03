import AppKit

final class AdvancedFilterViewController: NSViewController {

    public weak var delegate: FilterDelegate?
    @IBOutlet weak var predicateEditor: NSPredicateEditor!
    var predicate: NSPredicate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        let templateCompoundTypes = NSPredicateEditorRowTemplate( compoundTypes: [.and, .or, .not] )

        let template1 = RowTemplateRelationshipRubrique(leftExpressions: [NSExpression(forKeyPath: "Rubric")])

        let template2 = RowTemplateRelationshipCategory(leftExpressions: [NSExpression(forKeyPath: "Category")])
        let template3 = RowTemplateRelationshipMontant(leftExpressions: [NSExpression(forKeyPath: "Montant")])

        let template4 = RowTemplateRelationshipStatus(leftExpressions: [NSExpression(forKeyPath: "Status")])
        let template5 = RowTemplateRelationshipMode(leftExpressions: [NSExpression(forKeyPath: "Mode")])
                
        predicateEditor.rowTemplates = [ templateCompoundTypes, template1, template2, template3, template4, template5]
        
        predicateEditor.canRemoveAllRows = false

        if predicateEditor.predicate == nil {
            predicateEditor.addRow(self)
        }
    }
    
    @IBAction func predicateEditorAction(_ sender: NSButton) {
//        print("predicate value changed")
    }
    
    // MARK: - generateQuery
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

