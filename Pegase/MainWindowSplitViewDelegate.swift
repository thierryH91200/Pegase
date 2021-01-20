import AppKit


extension MainWindowController: NSSplitViewDelegate {
    
    func splitView(_ splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        if splitViewPrincipal == splitView && operationView == subview && operationView.isHidden == false {
            return true
        }
        if splitViewPrincipal == splitView && affichageView == subview && affichageView.isHidden == false {
            return true
        }

        if splitViewCentre == splitView && operationViewSecondary == subview && operationViewSecondary.isHidden == false {
            return true
        }
        return false
    }
    
    func splitView(_ splitView: NSSplitView, shouldHideDividerAt dividerIndex: Int) -> Bool {
        
        if splitViewPrincipal == splitView && dividerIndex == 1 {
            return true
        }
        if splitViewPrincipal == splitView && dividerIndex == 0 {
            return true
        }
        
        if splitViewCentre == splitView {
            return true
        }
        return false
    }
    
    func splitView(_ splitView: NSSplitView, effectiveRect proposedEffectiveRect: NSRect, forDrawnRect drawnRect: NSRect, ofDividerAt dividerIndex: Int) -> NSRect {
        let state = segmentedControl.isSelected(forSegment: 1)
        if splitViewCentre == splitView && state == false {
            return NSRect.zero
        }
        return proposedEffectiveRect
    }
}
