import AppKit
//import ThemeKit

final class KSRetailCollectionViewItem: NSCollectionViewItem {
    
    @IBOutlet weak var itemImageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do view setup here.
    }
    
    override var representedObject: Any? {
        didSet {
            super.representedObject = representedObject
            
            if let rep = representedObject as? [String: String] {
                if let aKey = rep["itemImage"] {
                    itemImageView?.image = Bundle.main.image(forResource: NSImage.Name( aKey))
                    itemImageView?.image?.isTemplate = true
                    itemImageView.wantsLayer = true
                    itemImageView.layer?.backgroundColor = NSColor.clear.cgColor
                }
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            view.layer?.borderWidth = isSelected ? 5.0 : 0.0
            view.layer?.borderColor = NSColor.black.cgColor
        }
    }

}
