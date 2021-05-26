///*
//Expansion Restoration Support for OutlineViewController.
//*/
//
import Cocoa

extension ListTransactionsController {
    
    private func nodeFromYear(anObject: String, nodes: [GroupedYearOperations]) -> GroupedYearOperations? {
        for node in nodes {
            if node.year ==  anObject {
                return node
            }
        }
        return nil
    }
    private func nodeFromMonth(anObject: String, nodes: [GroupedMonthOperations]) -> GroupedMonthOperations? {
        for node in nodes {
            if node.month == anObject {
                return node
            }
        }
        return nil
    }


    /* When the outline view is restoring the saved expanded items, this method is called for each
     	expanded item, to translate the archived object to an outline view item.
     */
// MARK: - RestoreExpansion
    func outlineView(_ outlineView: NSOutlineView, itemForPersistentObject object: Any) -> Any? {
        
//        print("Restore Expansion : ",outlineView.autosaveName!)
        
        if let group = object as? String {
            let len1 = group.count == 4
            if len1 == true {
                let item = nodeFromYear(anObject: group, nodes: groupedSorted)
                return (item)
            }
            
            let len = group.count == 6
            if len == true {
                var item: GroupedMonthOperations?
                for grouped in groupedSorted {
                    item = nodeFromMonth(anObject: group, nodes: grouped.allMonth)
                    if item != nil {
                        break
                    }
                }
                return (item)

            }
        }
        return nil
    }

    /* When the outline view is saving the expanded items, this method is called for each expanded
     	item, to translate the outline view item to an archived object.
     */
// MARK: - EncodeExpansion
    func outlineView(_ outlineView: NSOutlineView, persistentObjectForItem item: Any?) -> Any? {
        
//        print("Encode Expansion : ",outlineView.autosaveName!)
                
        if let group = item as? GroupedYearOperations {
            return (group.year)
        }
        if let group = item as? GroupedMonthOperations {
            return (group.month)
        }
        if let group = item as? IdTransactions {
            return (group.id)
        }
        return nil
    }
}
