import AppKit

final class IdentiteViewController: NSViewController {
    
    @IBOutlet var arrayControllerCompte: NSArrayController!
    @IBOutlet var arrayControllerBanque: NSArrayController!
    @IBOutlet var arrayControllerIdentite: NSArrayController!
    
    @objc dynamic var mainContext: NSManagedObjectContext! = mainObjectContext
    @objc dynamic var predicate =  NSPredicate(format: "account == %@", currentAccount!)
    
    public override func viewDidDisappear()
    {
        super.viewDidDisappear()
//        NotificationCenter.default.removeObserver(self, name: .updateCompte, object: nil)
    }
    
    override public func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = Localizations.General.Identity
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.receive(instance: self, name: .updateAccount, selector: #selector(updateChangeCompte(_:)))

        arrayControllerCompte.setSelectionIndex(0)
        arrayControllerBanque.setSelectionIndex(0)
        arrayControllerIdentite.setSelectionIndex(0)

        mainContext = mainObjectContext

        updateData()
    }
    
    @objc func updateChangeCompte(_ note: Notification) {
        
        updateData()
    }

    func updateData() {
        guard currentAccount != nil else {
            return }
        
        Identite.shared.getAll()
        Banque.shared.getAll()
        InitCompte.shared.getAll()

        arrayControllerCompte.filterPredicate = NSPredicate(format: "account == %@", currentAccount!)
        arrayControllerCompte.setSelectionIndex(0)
        
        arrayControllerBanque.filterPredicate = NSPredicate(format: "account == %@", currentAccount!)
        arrayControllerBanque.setSelectionIndex(0)
        
        arrayControllerIdentite.filterPredicate = NSPredicate(format: "account == %@", currentAccount!)
        arrayControllerIdentite.setSelectionIndex(0)
    }
    
}

//public class Email {
//    
//    public static var stricterFilter = true // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
//    
//    // Test if the specified email address is valid
//    public static func isEmailValid(email: String) -> Bool {
//        
//        var filterString: String
//        
//        if Email.stricterFilter {
//            // Strict filter string
//            filterString = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
//        }
//        else {
//            // lax filter string
//            filterString = ".+@.+\\.[A-Za-z]{2}[A-Za-z]*"
//        }
//
//        let emailTest = NSPredicate(format: "SELF MATCHES %@", filterString)
//        return emailTest.evaluate(with: email)
//    }
//}
