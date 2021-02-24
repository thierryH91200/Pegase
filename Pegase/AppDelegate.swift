//  https://fr.365psd.com/download/beautiful-vector-1-notepad-11884

import Cocoa
import UserNotifications


let defaults = UserDefaults.standard

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate , UNUserNotificationCenterDelegate {
    
    var splashScreenWindowController: SplashScreenWindowController! = nil
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
//        let center = UNUserNotificationCenter.current()
//        center.delegate = self

//        NSUserNotificationCenter.default.delegate = self
//        if #available(OSX 10.14, *) {
//            UNUserNotificationCenter.current().registerNotificationCategories()
//            UNUserNotificationCenter.current().delegate = self
//        }

    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        
        let kUserDefaultsKeyVisibleColumns = "kUserDefaultsKeyVisibleColumns"
        
        // Register user defaults. Use a plist in real life.
        var dict = [String : Bool]()
        dict["datePointage"]   = false
        dict["dateOperation"]  = false
        dict["libelle"]        = false
        dict["rubrique"]       = false
        dict["categorie"]      = false
        dict["mode"]           = false
        dict["releveBancaire"] = false
        dict["statut"]         = false
        
        dict["montant"]        = false
        dict["depense"]        = true
        dict["recette"]        = true
        dict["solde"]          = false
        dict["liee"]           = false
        var defaults           = [String :Any]()
        defaults[kUserDefaultsKeyVisibleColumns] = dict as Any
        UserDefaults.standard.register(defaults: defaults)
        
        // Create the shared document controller.
        _ = TulsiDocumentController()
    }
    
    /// applicationShouldOpenUntitledFile
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        splashScreenWindowController = SplashScreenWindowController()
        splashScreenWindowController.showWindow(self)
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed (_ sender: NSApplication) -> Bool {
        return false
    }
        
    // Reopen mainWindow, when the user clicks on the dock icon.
    func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag == false {
            _ = self.splashScreenWindowController
            if let splashScreenWindowController = self.splashScreenWindowController {
                splashScreenWindowController.showWindow(self)
                return false
            }
        }
        return true
    }
        
}
