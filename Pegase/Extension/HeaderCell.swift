import AppKit

// MARK: - MyNSTableRowView
final class MyNSTableRowView: NSTableRowView {
    
    override func drawSelection(in dirtyRect: NSRect) {
        if self.selectionHighlightStyle != .none {
//            let selectionRect = NSInsetRect(self.bounds, 2.5, 2.5)
            let selectionRect = self.bounds.insetBy(dx: 2.5, dy: 2.5)
            let colorBack = NSColor.selectedControlColor
            colorBack.setStroke()
            colorBack.setFill()
            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
            selectionPath.fill()
            selectionPath.stroke()
        }
    }
}

// MARK: - KSHeaderCellView
final class KSHeaderCellView: NSTableCellView {
    
    var fillColor = NSColor.orange
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let bPath = NSBezierPath(rect: dirtyRect)
        
        fillColor.set()
        bPath.fill()
    }
}

// MARK: - CrossHatchView
final class CrossHatchView: NSTableCellView {
    
    override func draw(_ rect: CGRect) {
        
        let path = NSBezierPath(roundedRect: bounds, xRadius: 5, yRadius: 5)
        //            path.addClip()
        
        let pathBounds = path.bounds
        path.removeAllPoints()
        let p1 = CGPoint(x:pathBounds.maxX, y:0)
        let p2 = CGPoint(x:0, y:pathBounds.maxX)
        path.move(to: p1)
        path.line(to: p2)
        path.lineWidth = bounds.width * 2
        
        let dashes:[CGFloat] = [0.5, 7.0]
        path.setLineDash(dashes, count: 2, phase: 0.0)
        NSColor.lightGray.withAlphaComponent(0.8).set()
        path.stroke()
    }
    
//    var fillColor = NSColor.orange
//
//    override func draw(_ dirtyRect: NSRect) {
//        super.draw(dirtyRect)
//
//        let bPath = NSBezierPath(rect: dirtyRect)
//
//        fillColor.set()
//        bPath.fill()
//    }

}



