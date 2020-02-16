//  https://fr.365psd.com/download/beautiful-vector-1-notepad-11884

import Cocoa


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
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }

}
