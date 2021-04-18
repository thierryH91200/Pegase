//  https://fr.365psd.com/download/beautiful-vector-1-notepad-11884

// https://medium.com/@swift3.0devlopment/core-data-tutorial-part-1-nspersistentcontainer-nsmanagedobjectmodel-d624173d93cc

import Cocoa
import UserNotifications


let defaults = UserDefaults.standard

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate { // , UNUserNotificationCenterDelegate {
    
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
        dict["bankStatement"] = false
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
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Document")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    @IBAction func saveAction(_ sender: Any?) {
        
        return


        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = mainObjectContext
        
//        let context = persistentContainer.viewContext
//        let context = persistentContainer.newBackgroundContext()
        
        context?.deleteAllData()
        
        context?.perform {
            
            if !(context?.commitEditing())! {
                NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
            }
            if context!.hasChanges == true {
                do {
                    try context!.save()
                    print("save Action")
                } catch {
                    // Customize this code block to include application-specific recovery steps.
                    let nserror = error as NSError
                    NSApplication.shared.presentError(nserror)
                }
                context!.reset()
            }
        }
    }
    
    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }


//    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
//        // Save changes in the application's managed object context before the application terminates.
//        let context = persistentContainer.viewContext
//
//        if !context.commitEditing() {
//            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
//            return .terminateCancel
//        }
//
//        if !context.hasChanges {
//            return .terminateNow
//        }
//
//        do {
//            try context.save()
//        } catch {
//            let nserror = error as NSError
//
//            // Customize this code block to include application-specific recovery steps.
//            let result = sender.presentError(nserror)
//            if (result) {
//                return .terminateCancel
//            }
//
//            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
//            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
//            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
//            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
//            let alert = NSAlert()
//            alert.messageText = question
//            alert.informativeText = info
//            alert.addButton(withTitle: quitButton)
//            alert.addButton(withTitle: cancelButton)
//
//            let answer = alert.runModal()
//            if answer == .alertSecondButtonReturn {
//                return .terminateCancel
//            }
//        }
//        // If we got here, it is time to quit.
//        return .terminateNow
//    }

}
