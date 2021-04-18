import AppKit

// just for the debug
extension NSView {
    
    /// ![Swift Logo](/Users/Stuart/Downloads/swift.png "The logo for the Swift programming language")
    override open var description: String {
        let id = identifier ?? NSUserInterfaceItemIdentifier(rawValue: "view ")
        return "id: \(String(describing: id))"
    }
}

extension NSLayoutConstraint {
    
    override open var description: String {
        let id = identifier ?? "00"
        return "id: \(id), constant: \(constant)"
    }
}

func printTimeElapsedWhenRunningCode(title:String, operation:()->()) {
    let startTime = CFAbsoluteTimeGetCurrent()
    operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("Time elapsed for \(title): \(timeElapsed) s.")
}

func timeElapsedInSecondsWhenRunningCode(operation: ()->()) -> Double {
    let startTime = CFAbsoluteTimeGetCurrent()
    operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    return Double(timeElapsed)
}



