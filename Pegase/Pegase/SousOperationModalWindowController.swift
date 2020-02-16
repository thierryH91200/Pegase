import AppKit

final class SousOperationModalWindowController: NSWindowController {
    
    @IBOutlet weak var comboBoxRubrique: NSComboBox!
    @IBOutlet weak var comboBoxCategory: NSComboBox!
    
    @IBOutlet weak var textFieldLibelle: AutoTextField!
    @IBOutlet weak var textFieldMontant: NSTextField!
    @IBOutlet weak var signeMontant: NSButton!
    
    @IBOutlet weak var modeOperation: NSButton!

    var libelles = [String]()
    var edition = false
    
    var entityRubrique = [EntityRubrique]()
    var entityPreference: EntityPreference?
    var entitySousOperation: EntitySousOperations?
    var entityCategories = [EntityCategory]()
    
    var arrayRub = [String]()
    var arrayCat = [String]()

    override var windowNibName: NSNib.Name? {
        return "SousOperationModalWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.modeOperation.bezelStyle = .texturedSquare
        self.modeOperation.isBordered = false
        self.modeOperation.wantsLayer = true
        self.modeOperation.layer?.backgroundColor = NSColor.orange.cgColor
        
        self.libelles = ListeOperations.shared.getAllComment()
        var completions = [[String: String]]()
        for libelle in libelles {
            completions.append(["label": libelle])
        }
        self.textFieldLibelle.arrNames = completions
        
        comboBoxCategory.removeAllItems()
        comboBoxCategory.delegate = self
        
        self.entityRubrique = Rubrique.shared.getAll()
        arrayRub = (0..<entityRubrique.count).map { i -> String in
            return entityRubrique[i].name!
        }

        comboBoxRubrique.removeAllItems()
        comboBoxRubrique.delegate = self
        comboBoxRubrique.addItems(withObjectValues: arrayRub)
        
        if self.edition == false {
            
            self.entityPreference = Preference.shared.getAll()
            
            /// Libelle
            textFieldLibelle.stringValue = ""

            /// Montant
            self.textFieldMontant.doubleValue = 0.0
            signeMontant.state = entityPreference?.signe == true ? .on : .off
            
            /// Rubrique
            var i = entityRubrique.firstIndex { $0 == entityPreference?.category?.rubrique }
            comboBoxRubrique.selectItem(at: i!)
            
            /// Category
            var entityCategory = entityRubrique[i!].category?.allObjects as! [EntityCategory]
            entityCategory = entityCategory.sorted { $0.name! < $1.name! }
            
            i = entityCategory.firstIndex { $0 === entityPreference?.category }
            comboBoxCategory.selectItem(at: i!)
            
        } else {
            
            /// Libelle
            textFieldLibelle.stringValue = (self.entitySousOperation?.libelle)!
            
            /// Amount
            let amount = (entitySousOperation?.amount)!
            textFieldMontant.doubleValue = abs(amount)
            signeMontant.state = amount < 0 ? .on : .off
            
            /// Rubrique
            var i = entityRubrique.firstIndex { $0 == self.entitySousOperation?.category?.rubrique }
            comboBoxRubrique.selectItem(at: i!)
            
            /// Category
            let name = self.entitySousOperation?.category?.name
            i = entityCategories.firstIndex { $0.name == name }
            comboBoxCategory.selectItem(at: i!)
        }
    }

}

