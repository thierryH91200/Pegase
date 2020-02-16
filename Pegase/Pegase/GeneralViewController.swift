import AppKit


final class GeneralViewController: NSViewController, Preferenceable {
    
    let toolbarItemTitle = "General"
    let toolbarItemIcon = NSImage(named: NSImage.preferencesGeneralName)!

    @IBOutlet weak var themeMenu: NSMenu!
    
    override var nibName: NSNib.Name? {
        return  "GeneralViewController"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    
}
