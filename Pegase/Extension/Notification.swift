import AppKit


public extension Notification.Name {
    
    static let updateOperation           = Notification.Name( "updateOperation")
    static let updateSolde               = Notification.Name( "updateSolde")
    static let updateAccount             = Notification.Name( "updateAccount")

    static let selectionDidChangeTable   = NSTableView.selectionDidChangeNotification
    static let selectionDidChangeOutLine = NSOutlineView.selectionDidChangeNotification
//    static let selectionDidChangeComboBox = NSComboBox.selectionDidChangeNotification
}

extension NotificationCenter {
    
    // Send(Post) Notification
    static func send(_ key: Notification.Name) {
        self.default.post(
            name: key,
            object: nil
        )
    }
    
    // Receive(addObserver) Notification
    static func receive(instance: Any, name: Notification.Name, selector: Selector) {
        self.default.addObserver(
            instance,
            selector: selector,
            name: name,
            object: nil
        )
    }
    
    // Remove(removeObserver) Notification
    static func remove( instance: Any, name: Notification.Name  ) {
        self.default.removeObserver(
            instance,
            name: name,
            object: nil
        )
    }

}
