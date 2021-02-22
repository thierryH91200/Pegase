import Cocoa

final class ParameterController: NSViewController {

    @IBOutlet weak var tabView: NSTabView!
    
    var chequiersViewController: ChequiersViewController!
    var modeOfPaymentViewController: ModeOfPaymentViewController!
    var rubriqueViewController: RubriqueViewController!
    var preferenceOperationViewController: PreferenceOperationViewController!
    
    public override func viewDidDisappear()
    {
        super.viewDidDisappear()
        
        NotificationCenter.default.removeObserver(chequiersViewController!, name: .updateAccount, object: nil)
        
        NotificationCenter.default.removeObserver(modeOfPaymentViewController!, name: .updateAccount, object: nil)
        NotificationCenter.default.removeObserver(modeOfPaymentViewController!, name: .selectionDidChangeTable, object: nil)

        NotificationCenter.default.removeObserver(rubriqueViewController!, name: .updateAccount, object: nil)
        NotificationCenter.default.removeObserver(rubriqueViewController!, name: .selectionDidChangeOutLine, object: nil)

        NotificationCenter.default.removeObserver(preferenceOperationViewController!, name: .updateAccount, object: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chequiersViewController = ChequiersViewController()
        modeOfPaymentViewController = ModeOfPaymentViewController()
        rubriqueViewController = RubriqueViewController()
        preferenceOperationViewController = PreferenceOperationViewController()

        let chequiersItem = NSTabViewItem(viewController: chequiersViewController)
        chequiersItem.label = Localizations.ModePaiement.Cheque
        
        let modeItem = NSTabViewItem(viewController: modeOfPaymentViewController)
        modeItem.label = Localizations.General.Mode_Paiement
        
        let rubricItem = NSTabViewItem(viewController: rubriqueViewController)
        rubricItem.label = Localizations.General.Rubrique
        
        let operationItem = NSTabViewItem(viewController: preferenceOperationViewController)
        operationItem.label = Localizations.General.Operation

        let items = tabView.tabViewItems
        for item in items {
            tabView.removeTabViewItem(item)
        }
        tabView.addTabViewItem(chequiersItem)
        tabView.addTabViewItem(modeItem)
        tabView.addTabViewItem(rubricItem)
        tabView.addTabViewItem(operationItem)
        tabView.selectTabViewItem(at: 0)
    }
    
}
