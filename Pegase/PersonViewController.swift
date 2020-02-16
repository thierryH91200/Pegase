import AppKit

final class PersonViewController: NSViewController, Preferenceable {
    
    let toolbarItemTitle = "List"
    let toolbarItemIcon = NSImage(named: NSImage.listViewTemplateName)!

    override var nibName: NSNib.Name? {
        return  "PersonViewController"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
