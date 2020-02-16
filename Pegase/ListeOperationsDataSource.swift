import AppKit

//var groupedSorted = [ (key: String, value:  [ String :  [IdOperations]])]()

extension ListeOperationsController: NSOutlineViewDataSource {
    
    //Returns the number of child items encompassed by a given item.
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
                        
        // Root number year
        if item == nil {
            let nbYear = groupedSorted.count
//            debugPrint("nbYear : ", nbYear)
            return nbYear
        }
        // Root number month
        if let folderItem = item as? TrackingMonth  {
            let nbMonths = folderItem.allMonth.count
//            debugPrint("nbMonths : ", nbMonths)
            return nbMonths
        }
        // number EntityOperations
        if let folderItem = item as?  TrackingIdOperations {
            let nbIdOperations = folderItem.idOperation.count
//            debugPrint("nbIdOperations : ",nbIdOperations)
            return nbIdOperations
        }
        // number EntitySousOperations
        if let idOperation = item as? TrackingSubOperations {
            let nbSousOperations = idOperation.entityOperations.sousOperations?.count ?? 0
//            debugPrint("nbSousOperations : ", nbSousOperations)
            return nbSousOperations
        }
        debugPrint("numberOfChildrenOfItem : BAD ITEM")
        return 0
    }
    
    // Returns the child item at the specified index of a given item
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        // Root year
        if item == nil {
            let child = groupedSorted[index]
            return child
        }
        // Root month
        if let folderItem = item as? TrackingMonth {
            let folder = folderItem.allMonth
            let val = folder[index]
            return val
        }
        // EntityOperations
        if let folderItem = item as? TrackingIdOperations  {
            let idOperations = folderItem.idOperation[index]
            return idOperations
        }
        // EntitySousOperations
        if let idOperation = item as? TrackingSubOperations {
            let sousOperations = idOperation.entityOperations.sousOperations?.allObjects as! [EntitySousOperations]
            return sousOperations[index]
        }
        debugPrint("child index : BAD ITEM")
        return "child index : BAD ITEM"
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return isSourceGroupItem(item)
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem: Any?) -> Any? {
        
        if let item = byItem as? (key: String, value: [IdOperations]) {
            return item.key
        }
        if let item = byItem as? EntityOperations {
            return item
        }
        return "???????"
    }
    
    func isSourceGroupItem(_ item: Any) -> Bool
    {
        if item is TrackingYear {
            return true
        }
        if item is TrackingMonth {
            return true
        }
        if item is TrackingIdOperations {
            return true
        }

        if item is IdOperations {
            let idOperation = item as! IdOperations
            let count = (idOperation.entityOperations.sousOperations?.count)!
            if count > 1 {
                return true
            }
        }
        return false
    }
    
}
