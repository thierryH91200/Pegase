//  https://fr.365psd.com/download/beautiful-vector-1-notepad-11884

import Cocoa

let defaults = UserDefaults.standard

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate , NSUserNotificationCenterDelegate {

    var splashScreenWindowController: SplashScreenWindowController! = nil
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        NSUserNotificationCenter.default.delegate = self
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
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
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    // Reopen mainWindow, when the user clicks on the dock icon.
    func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            _ = self.splashScreenWindowController
//                if let splashScreenWindowController = self.splashScreenWindowController {
//                splashScreenWindowController.showWindow(self)
//            }
        }
        return true
    }
    

}
