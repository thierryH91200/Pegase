///*
//Expansion Restoration Support for OutlineViewController.
//*/
//
import Cocoa

extension ListTransactionsController {
//    private func nodeFromIdentifier(anObject: Any, nodes: [NSTreeNode]!) -> NSTreeNode? {
//        var treeNode: NSTreeNode?
//        for node in nodes {
//            if let testNode = node.representedObject as? Node {
//                let idCheck = anObject as? String
//                if idCheck == testNode.fullKey {
//                    treeNode = node
//                    break
//                }
//                if node.children != nil {
//                    if let nodeCheck = nodeFromIdentifier(anObject: anObject, nodes: node.children) {
//                        treeNode = nodeCheck
//                        break
//                    }
//                }
//            }
//        }
//        return treeNode
//    }

//    private func nodeFromIdentifier(anObject: Any) -> NSTreeNode? {
//        return nodeFromIdentifier(anObject: anObject, nodes: treeController.arrangedObjects.children)
//    }

    /** When the outline view is restoring the saved expanded items, this method is called for each
     	expanded item, to translate the archived object to an outline view item.
     */
// - Tag: RestoreExpansion
    func outlineView(_ outlineView: NSOutlineView, itemForPersistentObject object: Any) -> Any? {
//        let node = nodeFromIdentifier(anObject: object)  // Incoming object is the identifier.
        
//        let item = object as! String
//        print("itemForPersistentObject : ", item)
//        return (item)

        if let group = object as? GroupedMonthOperations {
            return (group.month)
        }
        if let group = object as? GroupedYearOperations {
//            let grouped = groupedSorted.first{  $0.year == group.year }

            return (group.year)
        }
        return nil
    }

    /** When the outline view is saving the expanded items, this method is called for each expanded
     	item, to translate the outline view item to an archived object.
     */
// - Tag: EncodeExpansion
    func outlineView(_ outlineView: NSOutlineView, persistentObjectForItem item: Any?) -> Any? {
        
                if let group = item as? GroupedMonthOperations {
                    print("persistentObjectForItem : ", group.month as String)
                    return (group.month)
                }
                if let group = item as? GroupedYearOperations {
                    print("persistentObjectForItem : ", group.year as String)
                    let group = self.groupedSorted.first { $0.year == group.year as String }
                    return (group?.year)
                }
                return nil

//        let node = OutlineViewController.node(from: item!)
//        return node?.fullKey // Outgoing object is the identifier.
    }
}

extension Array where Self.Element == String {
    // Search for a node (recursively) until a matching element is found
    func firstNode(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        for element in self {
            if try predicate(element) {
                return element
            }
//            if let matched = try element.children.firstNode(where: predicate) {
//                return matched
//            }
        }
        return nil
    }
}

