import AppKit

// MARK: - MyNSTableRowView
//final class MyNSTableRowView: NSTableRowView {
//
//    override func drawSelection(in dirtyRect: NSRect) {
//        if self.selectionHighlightStyle != .none {
//            let inset : CGFloat = 2
//            let selectionRect = self.bounds.insetBy(dx: inset, dy: inset)
//            let colorBack = NSColor.findHighlightColor
////            let colorBack = NSColor.scrubberTexturedBackground
//            colorBack.setStroke()
//            colorBack.setFill()
//            let radius : CGFloat  = 0
//            let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: radius, yRadius: radius)
//            selectionPath.fill()
//            selectionPath.stroke()
//        }
//    }
//}

class MyNSTableRowView: NSTableRowView {
    
    override func drawSelection(in dirtyRect: NSRect) {
        super.drawSelection(in: dirtyRect)

        struct SharedColors {
            static let backgroundColor = NSColor(red: 0.76, green: 0.82, blue: 0.92, alpha: 1)
        }
        
        NSColor.selectedControlColor.set()
        __NSRectFill(dirtyRect)
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
        
        let radius : CGFloat  = 5
        let path = NSBezierPath(roundedRect: bounds, xRadius: radius, yRadius: radius)
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



