import AppKit

// Document controller for customization of the open panel.
final class TulsiDocumentController: NSDocumentController {

    override func runModalOpenPanel(_ openPanel: NSOpenPanel, forTypes types: [String]?) -> Int {
        openPanel.message = Localizations.Document.OpenProjectPanelMessage
        return super.runModalOpenPanel(openPanel, forTypes: types)
    }
}



//class MBTransparentWindow: NSWindow {
//    
//    // Override init to make window completely transparent and movable by background
//    override init(contentRect: NSRect, styleMask aStyle: NSWindow.StyleMask, backing bufferingType: NSWindow.BackingStoreType, defer flag: Bool) {
//        
//        super.init(contentRect: contentRect,
//                   styleMask: aStyle,
//                   backing: bufferingType,
//                   defer: flag)
////        self.backgroundColor                                                       = NSColor.clear
//        self.level                                                                 = NSWindow.Level( 0)
//        self.isOpaque                                                              = true
//        self.hasShadow                                                             = false
//        self.titleVisibility                                                       = NSWindow.TitleVisibility.hidden
//        self.titlebarAppearsTransparent                                            = true
//        self.isMovableByWindowBackground                                           = true
//        self.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)?.isHidden = true
//        self.standardWindowButton(NSWindow.ButtonType.zoomButton)?.isHidden        = true
//        self.standardWindowButton(NSWindow.ButtonType.closeButton)?.isHidden       = false
//        
////        self.styleMask.insert(NSWindow.StyleMask.unifiedTitleAndToolbar)
////        self.styleMask.insert(NSWindow.StyleMask.fullSizeContentView)
////        self.styleMask.insert(NSWindow.StyleMask.titled)
////        self.toolbar?.isVisible = false
////        self.titleVisibility = .hidden
////        self.titlebarAppearsTransparent = true
//
//    }
//
//}
