import AppKit

final class SuggestionsWindow: NSWindow {
    
    convenience init(contentRect: NSRect, defer flag: Bool) {
        self.init(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: true)
    }

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {

        super.init(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: flag)

        // This window is always has a shadow and is transparent. Force those setting here.
        hasShadow = true
        backgroundColor = NSColor.clear
        isOpaque = false
    }
}
