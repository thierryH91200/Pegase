import AppKit


// https://www.appcoda.com/nspasteboard-macos/

extension ListTransactionsController {
    
    // MARK: -
    // MARK: undo
    @IBAction func undo(_ sender: Any) {
        
        let context = mainObjectContext

        
        guard (outlineListView) != nil else { return }
        
        context!.undo()
        
        getAllData()
        reloadData()
        self.resetChange()
    }
    
    // MARK: -
    // MARK: redo
    @IBAction func redo(_ sender: Any) {
        
        let context = mainObjectContext

        
        guard (outlineListView) != nil else { return }
        context!.redo()
        
        getAllData()
        reloadData()
        self.resetChange()
    }
    
    // MARK: - duplicate
    @IBAction func duplicate(_ sender: Any) {
        
        guard (outlineListView) != nil else { return }
        
        printTimeElapsedWhenRunningCode(title:"copy paste ") {
            
            copy(sender)
            paste(sender)
        }
        
    }
    
    // MARK: - Copy
    @IBAction func copy(_ sender: Any) {
        
        guard (outlineListView) != nil else { return }
        let selectedRowIndexes = outlineListView.selectedRowIndexes
        printTimeElapsedWhenRunningCode(title:"copy Data: ") {
            
            if selectedRowIndexes.isEmpty == false {
                let listItems = listItemsAtIndexes(selectedRowIndexes)
                writeListItems(listItems: listItems)
            }
        }
    }
    
    // MARK: - Paste
    // If there were no pasted items that are of the Lister pasteboard type, see if there are any String contents on the pasteboard.
    @IBAction func paste(_ sender: Any) {
        
        guard (outlineListView) != nil else { return }
        
        let listItems = listItemsWithStringPasteboardType()
        
        printTimeElapsedWhenRunningCode(title:"Paste Data: ") {
            
            // Only copy/paste if items were inserted.
            if listItems != nil && listItems!.isEmpty == false {
                insertListItems(listItems: listItems!)
            }
            
            (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
            getAllData()
            reloadData(true)
        }
        
        printTimeElapsedWhenRunningCode(title:"reset change Paste : ") {
            DispatchQueue.main.async {

                self.resetChange()
            }
        }

    }
    
    private func insertListItems(listItems: [EntityTransactions]) {
        guard !listItems.isEmpty else { return }
        
        let context = mainObjectContext
        
        for listItem in listItems {
            _ = listItem.copyEntireObjectGraph(context: context!) as! EntityTransactions
        }
        let undoActionName = NSLocalizedString("Insert", comment: "")
        undoManager?.setActionName(undoActionName)
    }

    // MARK: - Cut
    @IBAction func cut(_ sender: Any) {
        
        guard (outlineListView) != nil else { return }
        
        let selectedRowIndexes = outlineListView.selectedRowIndexes
        if selectedRowIndexes.isEmpty == false {
            let listItems = listItemsAtIndexes(selectedRowIndexes)
            
            writeListItems(listItems: listItems )
            removeListItems(listItems)
        }
    }
    
    @IBAction func delete(_ sender: Any) {
        guard (outlineListView) != nil else { return }
        let selectedRowIndexes = outlineListView.selectedRowIndexes
        if selectedRowIndexes.isEmpty == false {
            
            let listItems = listItemsAtIndexes(selectedRowIndexes)
            
            writeListItems(listItems: listItems )
            removeListItems(listItems)
            
            for item in listItems {
                ListTransactions.shared.remove(entity: item.entityTransactions)
            }
        }
        (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)

        self.resetChange()
    }
    
    // MARK: - Divers
    private func writeListItems(listItems: [IdTransactions]) { //, toPasteboard pasteboard: NSPasteboard ) {
        
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        
        pasteBoard.declareTypes([.compatString], owner: self)
        
        // Save `uuid` as a string.
        let uuidString = uuidFromListItems(items: listItems)
        pasteBoard.setString(uuidString, forType: NSPasteboard.PasteboardType.compatString)
    }
    
    private func uuidFromListItems(items: [IdTransactions]) -> String {
        return items.reduce("") { string, item in
            let uuid = item.entityTransactions.uuid
            let str = uuid?.uuidString
            return "\(string)\(str ?? "nil")\n"
        }
    }
    
    private func listItemsAtIndexes(_ indexes: IndexSet) -> [IdTransactions] {
        
        let rowIndexes = Array(indexes)
        let listItems = (0 ..< rowIndexes.count).map { (i) -> IdTransactions in
            let row = rowIndexes[i] as Int
            return self.outlineListView.item(atRow: row) as! IdTransactions
        }
        return listItems
    }
    
    private func removeListItems(_ listItems: [IdTransactions]) {
        guard !listItems.isEmpty else { return }
        
        
//var object = arrayController.selectedObjects.last
//if object == nil {
//    return
//}
//managedObjectContext.undoManager?.beginUndoGrouping()
//managedObjectContext.undoManager
//managedObjectContext.delete(object)
//managedObjectContext.undoManager?.endUndoGrouping()

        //
        ////        delegate?.listPresenterWillChangeListLayout(self, isInitialLayout: false)
        //
        //        /**
        //         We're going to store the indexes of the list items that will be removed in an array.
        //         We do that so that when we insert the same list items back in for undo, we don't need
        //         to worry about insertion order (since it will just be the opposite of insertion order).
        //         */
        //        var removedIndexes = [Int]()
        //
        //        for listItem in listItems {
        //            if let listItemIndex = presentedListItems.index(of: listItem) {
        //                list.items.remove(at: listItemIndex)
        //
        //                delegate?.listPresenter(self, didRemoveListItem: listItem, atIndex: listItemIndex)
        //
        //                removedIndexes += [listItemIndex]
        //            }
        //            else {
        //                preconditionFailure("A list item was requested to be removed that isn't in the list.")
        //            }
        //        }
        //
        //
        //        // Undo
        //        (undoManager?.prepare(withInvocationTarget: self) as AnyObject).insertListItemsForUndo(listItems.reversed(), atIndexes: removedIndexes.reversed())
        //
        //        let undoActionName = NSLocalizedString("Remove", comment: "")
        //        undoManager?.setActionName(undoActionName)
    }
    
    private func listItemsWithStringPasteboardType() -> [EntityTransactions]? {
        
        let pasteboard = NSPasteboard.general
        if pasteboard.canReadItem( withDataConformingToTypes: [NSPasteboard.PasteboardType.compatString.rawValue]) {
            var allItems = [EntityTransactions]()
            
            for pasteboardItem in pasteboard.pasteboardItems! {
                if let targetType = pasteboardItem.availableType(from: [NSPasteboard.PasteboardType.compatString]),
                    let pasteboardString = pasteboardItem.string(forType: targetType) {
                    allItems += entityFromString(string: pasteboardString)
                }
            }
            return allItems
        }
        return nil
    }
    
    private func entityFromString(string: String) -> [EntityTransactions] {
        
        let context = mainObjectContext

        let listItems = [EntityTransactions]()
        
        let enumerationOptions: NSString.EnumerationOptions = [.bySentences, .byLines]
        let range = string.startIndex ..< string.endIndex
        
        let characterSet = NSCharacterSet.whitespacesAndNewlines
        
        string.enumerateSubstrings(in: range, options: enumerationOptions) { substring, _, _, _ in
            let trimmedString = substring!.trimmingCharacters(in: characterSet)
            
            if !trimmedString.isEmpty {
                let uuid = UUID(uuidString: trimmedString)
                let entities = ListTransactions.shared.find(uuid: uuid!)
                               
                let newEntities = entities.duplicateTransactions(context: context!, entityTrans: entities)

                newEntities.uuid = UUID()       // new UUID
                newEntities.account = currentAccount
                newEntities.operationLiee = nil
            }
        }
        return listItems
    }
    
}

