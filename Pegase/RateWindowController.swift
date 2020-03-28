import AppKit

final class RateWindowController: NSWindowController {
    
    enum RateWindowPosition: Int {
        case center
        case topRight
        case topLeft
    }
    enum RateResult: Int {
        case rated
        case later
        case timeout
    }
    
    typealias RateCompletionCallback = (RateResult) -> Void
    
    var configure: RateConfigure!
    var ivIcon: NSImageView!
    var lbName: NSTextField!
    var lbDetailText: NSTextField!
    var btnLike: NSButton!
    var btnIgnore: NSButton!
    var nTimeout: Int = 0
    var block: RateCompletionCallback!
    
    init(configure: RateConfigure) {
        
        self.configure = configure
        
        super.init(window: nil)
        self.initializeRateWindowController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private methods
    func initializeRateWindowController() {
        
        nTimeout = 0
        block = nil
        let rctWindow = NSRect(x: 0, y: 0, width: 210, height: 306)
        let window = NSWindow(contentRect: rctWindow, styleMask: [.titled, .fullSizeContentView], backing: .buffered, defer: true)
        self.window = window
        window.level = .floating
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.center()
        window.backgroundColor = NSColor.textBackgroundColor
        
        ivIcon = NSImageView(frame: NSMakeRect((NSWidth(rctWindow) - 64) / 2, NSHeight(rctWindow) - 86, 64, 64))
        ivIcon.imageScaling = .scaleAxesIndependently
        window.contentView?.addSubview(ivIcon)
        ivIcon.image = configure?.icon
        
        lbName = NSTextField(frame: NSRect(
            x: 0,
            y: ivIcon.frame.minY - 40,
            width: rctWindow.width,
            height: 30))
        
        lbName.isEditable            = false
        lbName.isBezeled             = false
        lbName.isSelectable          = false
        lbName.textColor             = .labelColor
        lbName.backgroundColor       = .clear
        lbName.font                  = NSFont(name: "HelveticaNeue", size: 21)
        lbName.alignment             = .center
        lbName.stringValue           = (configure?.name)!
        window.contentView?.addSubview(lbName)
        
        lbDetailText = NSTextField(frame: NSRect(
            x: 35,
            y: lbName.frame.minY - 100,
            width: rctWindow.width - 70,
            height: 90))
        
        lbDetailText.isEditable      = false
        lbDetailText.isBezeled       = false
        lbDetailText.isSelectable    = false
        lbDetailText.textColor       = .labelColor
        lbDetailText.backgroundColor = .clear
        lbDetailText.font            = NSFont(name: "HelveticaNeue", size: 12)
        lbDetailText.lineBreakMode   = .byWordWrapping
        lbDetailText.stringValue     = (configure?.detailText)!
        window.contentView?.addSubview(lbDetailText)
        
        btnLike  = NSButton(frame: NSRect(
            x: 30,
            y: lbDetailText.frame.minY - 50,
            width: rctWindow.width - 60,
            height: 40))
        
        btnLike.title               = (configure?.likeButtonTitle)!
        btnLike.bezelStyle           = .rounded
        btnLike.font                 = NSFont(name: "HelveticaNeue", size: 15)
        btnLike.keyEquivalent        = "\r"
        btnLike.target               = self
        btnLike.action               = #selector(self.likeButton_click(_ :))
        window.contentView?.addSubview(btnLike)
        
        btnIgnore = NSButton(frame: NSRect(
            x: 30,
            y: btnLike.frame.minY - 10,
            width: rctWindow.width - 60,
            height: 15))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont(name: "HelveticaNeue", size: 11)!,
            .foregroundColor: NSColor.lightGray,
            .paragraphStyle: paragraphStyle
        ]
        let title = configure?.ignoreButtonTitle
        let attributedTitle = NSAttributedString(string: title!, attributes: attributes)
        
        btnIgnore.attributedTitle = attributedTitle
        btnIgnore.target = self
        btnIgnore.action = #selector(self.ignoreButton_click(_:))
        btnIgnore.bezelStyle = .roundRect
        btnIgnore.isBordered = false
        window.contentView?.addSubview(btnIgnore)
    }
    
    func requestRateWindow(_ pos: RateWindowPosition, with block: @escaping RateCompletionCallback) {
        self.block               = block
        let nGap: CGFloat  = 10
        let rctScreen            = NSScreen.main?.visibleFrame
        var rctTmpWnd            = (window?.frame)!
        var rctWnd               = (window?.frame)!
        
        window?.orderOut(nil)
        
        switch pos {
        case .topLeft:
            rctTmpWnd.origin.x = rctScreen!.minX - rctWnd.width
            rctTmpWnd.origin.y = rctScreen!.maxY - rctWnd.height - CGFloat(nGap)
            window?.makeKeyAndOrderFront(nil)
            window?.setFrame(rctTmpWnd, display: false)
            rctWnd.origin.x = rctScreen!.minX + nGap
            rctWnd.origin.y = rctScreen!.maxY - rctWnd.height - nGap
            window?.animator().setFrame(rctWnd, display: true)
        
        case .topRight:
            rctTmpWnd.origin.x = rctScreen!.maxX
            rctTmpWnd.origin.y = rctScreen!.maxY - rctWnd.height - nGap
            window?.makeKeyAndOrderFront(nil)
            window?.setFrame(rctTmpWnd, display: false)
            rctWnd.origin.x = rctScreen!.maxX - rctWnd.width - nGap
            rctWnd.origin.y = rctScreen!.maxY - rctWnd.height - nGap
            window?.animator().setFrame(rctWnd, display: true)
        
        case .center:
            window?.makeKeyAndOrderFront(nil)
            window?.center()
        }
        
        if nTimeout > 0 {
            perform(#selector(self.timeoutFunc), with: nil, afterDelay: TimeInterval(nTimeout))
        }
    }
    
    @IBAction func likeButton_click(_ sender: Any) {
        if nil != configure?.rateURL {
            NSWorkspace.shared.open(configure!.rateURL!)
        }
        window?.orderOut(nil)
        if block != nil {
            block!(.rated)
        }
    }
    
    @IBAction func ignoreButton_click(_ sender: Any) {
        window?.orderOut(nil)
        if block != nil {
            block!(.later)
        }
    }
    
    @objc func timeoutFunc() {
        if (window?.isVisible)! {
            window?.orderOut(nil)
            if block != nil {
                block!(.timeout)
            }
        }
    }
}
