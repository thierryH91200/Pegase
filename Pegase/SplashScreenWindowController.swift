import AppKit

/// View controller for the "recent document" rows in the tableview in the splash screen.
final class SplashScreenRecentDocumentViewController: NSViewController {
    @IBOutlet weak var icon: NSImageView!
    @IBOutlet weak var filename: NSTextField!
    @IBOutlet weak var path: NSTextField!
    var url: URL?
    
    override var nibName: NSNib.Name? {
        return NSNib.Name( "SplashScreenRecentDocumentView")
    }
    
    override func viewDidLoad() {
        guard let url = url else {
            return }
        icon.image =  NSWorkspace.shared.icon(forFile: url.path)
        filename.stringValue = (url.lastPathComponent as NSString).deletingPathExtension
        path.stringValue = ((url.path as NSString).deletingLastPathComponent as NSString).abbreviatingWithTildeInPath
    }
}

/// Window controller for the splash screen.
class SplashScreenWindowController: NSWindowController {
    
    @IBOutlet var recentDocumentsArrayController: NSArrayController!
    @IBOutlet weak var splashScreenImageView: NSImageView!
    
    @objc dynamic var applicationVersion: String = ""
    @objc dynamic var recentDocumentViewControllers = [SplashScreenRecentDocumentViewController]()
    
    override var windowNibName: NSNib.Name? {
        return "SplashScreenWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Hide the titlebar and title.
        window?.titlebarAppearsTransparent = true
        window?.titleVisibility = .hidden
        
        // Allow the window to be dragged anywhere.
        window?.isMovableByWindowBackground = true
        
        splashScreenImageView.image = NSApplication.shared.applicationIconImage
        
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as? String
        let build = dictionary["CFBundleVersion"] as? String
        
        if let cfBundleVersion = version {
            applicationVersion = cfBundleVersion + "(" + build! + ")"
        }
        recentDocumentViewControllers = getRecentDocumentViewControllers()
    }
    
    @IBAction func createNewDocument(_ sender: NSButton) {
        let documentController = NSDocumentController.shared
        do {
            try documentController.openUntitledDocumentAndDisplay(true)
            self.close()
        } catch let e as NSError {
            let alert = NSAlert()
            alert.messageText = e.localizedFailureReason ?? e.localizedDescription
            alert.informativeText = e.localizedRecoverySuggestion ?? ""
            alert.runModal()
        }
    }
    
    @IBAction func openSampleProject(_ sender: NSButton) {
        preloadDBData()
    }
    
    // https://stackoverflow.com/questions/40761140/how-to-pre-load-database-in-core-data-using-swift-3-xcode-8
    func preloadDBData() {
        let sqlitePath = Bundle.main.path(forResource: "MyDB", ofType: "sqlite")
        //        let sqlitePath_shm = Bundle.main.path(forResource: "MyDB", ofType: "sqlite-shm")
        //        let sqlitePath_wal = Bundle.main.path(forResource: "MyDB", ofType: "sqlite-wal")
        
        let URL1 = URL(fileURLWithPath: sqlitePath!)
        //        let URL2 = URL(fileURLWithPath: sqlitePath_shm!)
        //        let URL3 = URL(fileURLWithPath: sqlitePath_wal!)
        let URL4 = URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/MyDB.sqlite")
        //        let URL5 = URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/MyDB.sqlite-shm")
        //        let URL6 = URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/MyDB.sqlite-wal")
        
        if FileManager.default.fileExists(atPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/MyDB.sqlite") {
            do {
                try FileManager.default.removeItem(at: URL4)
                //                try FileManager.default.removeItem(at: URL5)
                //                try FileManager.default.copyItem(at: URL3, to: URL6)
                
            } catch {
                print("=======================")
                print("ERROR IN REMOVE OPERATION")
                print("=======================")
            }
        }
        
        // Copy 3 files
        do {
            try FileManager.default.copyItem(at: URL1, to: URL4)
            //            try FileManager.default.copyItem(at: URL2, to: URL5)
            //            try FileManager.default.copyItem(at: URL3, to: URL6)
            
        } catch let error {
            print("=======================")
            print("ERROR IN COPY OPERATION")
            print("=======================")
            print("Operation failed again, abort with error: \(error)")
        }
        
        let documentController = NSDocumentController.shared
        documentController.openDocument(withContentsOf: URL4, display: true) {
        (_: NSDocument?, _: Bool, _: Error?) in
            self.close()
        }
    }
    
    @IBAction func didDoubleClickRecentDocument(_ sender: NSTableView) {
        let clickedRow = sender.clickedRow
        guard clickedRow >= 0 else {
            return }
        let documentController = NSDocumentController.shared
        let viewController = recentDocumentViewControllers[clickedRow]
        
        guard let url = viewController.url  else {
            return }
        documentController.openDocument(withContentsOf: url, display: true) {
        (_: NSDocument?, _: Bool, _: Error?) in
            self.close()
        }
    }
    
    func getTulsiBundleExtension() -> String {
//        let bundle = Bundle(for: self)
        let documentTypes = Bundle.main.infoDictionary!["CFBundleDocumentTypes"] as! [[String: AnyObject]]
        let extensions = documentTypes.first!["CFBundleTypeExtensions"] as! [String]
        return extensions.first!
    }

    
    // MARK: - Private methods
    private func getRecentDocumentViewControllers() -> [SplashScreenRecentDocumentViewController] {
        let projectExtension = getTulsiBundleExtension()
        let documentController = NSDocumentController.shared
        
        var recentDocumentViewControllers = [SplashScreenRecentDocumentViewController]()
        var recentDocumentURLs = Set<URL>()
        let fileManager = FileManager.default
        for url in documentController.recentDocumentURLs {
            let path = url.path
            guard path.contains(projectExtension) else { continue }
            if !fileManager.isReadableFile(atPath: path) {
                continue
            }
            
            let components: [String] = url.pathComponents
            var i = components.count - 1
            repeat {
                if (components[i] as NSString).pathExtension == projectExtension {
                    break
                }
                i -= 1
            } while i > 0
            
            let projectURL: URL
            if i == components.count - 1 {
                projectURL = url
            } else {
                let projectComponents = [String](components.prefix(i + 1))
                projectURL = NSURL.fileURL(withPathComponents: projectComponents)! as URL
            }
            if recentDocumentURLs.contains(projectURL) {
                continue
            }
            recentDocumentURLs.insert(projectURL)
            
            let viewController = SplashScreenRecentDocumentViewController()
            viewController.url = projectURL
            recentDocumentViewControllers.append(viewController)
        }
        return recentDocumentViewControllers
    }
}

extension SplashScreenWindowController:  NSTableViewDelegate, NSTableViewDataSource {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return recentDocumentViewControllers[row].view
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return recentDocumentViewControllers.count
    }
}
