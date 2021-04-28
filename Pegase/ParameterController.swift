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
        
        NotificationCenter.remove(instance: chequiersViewController!, name: .updateAccount)
        
        NotificationCenter.remove(instance: modeOfPaymentViewController!, name: .updateAccount)
        NotificationCenter.remove(instance: modeOfPaymentViewController!, name: .selectionDidChangeTable)

        NotificationCenter.remove(instance: rubriqueViewController!, name: .updateAccount)
        NotificationCenter.remove(instance: rubriqueViewController!, name: .selectionDidChangeOutLine)

        NotificationCenter.remove(instance: preferenceOperationViewController!, name: .updateAccount)
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
        tabView.addTabViewItem(rubricItem)
        tabView.addTabViewItem(modeItem)
        tabView.addTabViewItem(operationItem)
        tabView.addTabViewItem(chequiersItem)
        tabView.selectTabViewItem(at: 0)
    }
    
}
