import AppKit

final class SousOperationModalWindowController: NSWindowController {
    
    @IBOutlet weak var comboBoxRubrique: NSComboBox!
    @IBOutlet weak var comboBoxCategory: NSComboBox!
    
    @IBOutlet weak var textFieldLibelle: AutoCompleteTextField!
    @IBOutlet weak var textFieldAmount: CurrencyField!
    @IBOutlet weak var amountSign: NSButton!
    
    @IBOutlet weak var modeOperation: NSButton!

    var libelles = [String]()
    var autoCompleteFilterArray = [String]()

    var completions = [[String: String]]()

    var edition = false
    
    var entityRubric = [EntityRubric]()
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
        
        textFieldLibelle.tableViewDelegate = self

        self.libelles = ListTransactions.shared.getAllComment()
        var completions = [[String: String]]()
        for libelle in libelles {
            completions.append(["label": libelle])
        }
        
//        textFieldAmount.target(self, action: #selector(myTextFieldDidChange), for: .editingChanged)

//        self.textFieldLibelle.arrNames = completions
        
        comboBoxCategory.removeAllItems()
        comboBoxCategory.delegate = self
        
        self.entityRubric = Rubric.shared.getAllDatas()
        arrayRub = (0..<entityRubric.count).map { i -> String in
            return entityRubric[i].name!
        }

        comboBoxRubrique.removeAllItems()
        comboBoxRubrique.delegate = self
        comboBoxRubrique.addItems(withObjectValues: arrayRub)
        
        if self.edition == false {
            
            self.entityPreference = Preference.shared.getAllDatas()
            
            /// Libelle
            textFieldLibelle.stringValue = ""

            /// Montant
            self.textFieldAmount.doubleValue = 0.0
            self.amountSign.state = entityPreference?.signe == true ? .on : .off
            
            /// Rubrique
            var i = entityRubric.firstIndex { $0 == entityPreference?.category?.rubric }
            comboBoxRubrique.selectItem(at: i!)
            
            /// Category
            var entityCategory = entityRubric[i!].category?.allObjects as! [EntityCategory]
            entityCategory = entityCategory.sorted { $0.name! < $1.name! }
            
            i = entityCategory.firstIndex { $0 === entityPreference?.category }
            comboBoxCategory.selectItem(at: i!)
            
        } else {
            
            /// Libelle
            textFieldLibelle.stringValue = (self.entitySousOperation?.libelle)!
            
            /// Amount
            let amount = (entitySousOperation?.amount)!
            textFieldAmount.doubleValue = abs(amount)
            amountSign.state = amount < 0 ? .on : .off
            
            /// Rubrique
            var name = self.entitySousOperation?.category?.rubric!.name
            var i = entityRubric.firstIndex { $0.name == name }
            comboBoxRubrique.selectItem(at: i ?? 0)
            
            /// Category
            name = self.entitySousOperation?.category?.name
            i = entityCategories.firstIndex { $0.name == name }
            comboBoxCategory.selectItem(at: i!)
        }
    }
    
//    override func textDidChange(_ notification: Notification) {
//
//        let amountString = textFieldAmount.stringValue.currencyInputFormatting()
//        textFieldAmount.stringValue = amountString
//
//    }


}

// MARK: - AutoCompleteTableViewDelegate
extension SousOperationModalWindowController  : AutoCompleteTableViewDelegate {
    
    func textField1(_ textField: NSTextField, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: Int) -> [String] {
        
        let searchString = textField.stringValue
        autoCompleteFilterArray = libelles.filter{ $0.capitalized.hasPrefix(searchString) }
        return autoCompleteFilterArray
    }
    
    func tableViewSelection(_ notification: Notification)
    {
        print("tableViewSelection")
    }

}

extension String {

    // formatting text for currency textField
    func currencyInputFormatting() -> String {

        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        var amountWithPrefix = self

        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: self.count), withTemplate: "")

        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))

        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }

        return formatter.string(from: number)!
    }
}


