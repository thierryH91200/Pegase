import AppKit

@objc
public protocol SourceListDelegate
{
    /// Called when a value has been selected inside the outline.
    func changeView(name: String)
}

final class SourceListViewController: NSViewController {
    
    public weak var delegate: SourceListDelegate?
    
    @IBOutlet weak var group: NSButton!
    
    @IBOutlet weak var sidebarOutlineView: NSOutlineView!
    
    var datas        = [Donnees]()
    var selectIndex = [1]
    
    var colorBackGround = NSColor.clear
    var rowSizeStyle: NSTableView.RowSizeStyle  = .default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedList("Feeds")
        
        self.group.title = "Gestion"
        self.reloadData()
    }
    
    func reloadData() {
        
        self.sidebarOutlineView.reloadData()
        self.sidebarOutlineView.expandItem(nil, expandChildren: true)
        self.sidebarOutlineView.selectRowIndexes(IndexSet(selectIndex), byExtendingSelection: false)
    }
    
    func feedList(_ fileName: String) {
        
        let url = Bundle.main.url(forResource: fileName, withExtension: "plist")!
        let data = try! Data(contentsOf: url)
        datas = try! data.decoded()
        // or
        //datas = try! data.decoded() as [Donnees]

        
//        let plistDecoder = PropertyListDecoder()
//        datas = try! plistDecoder.decode([Donnees].self, from: data)
    }
    
}
