import Cocoa

extension NSManagedObject {
    
    enum CopyBehavior: String {
        case none, copy, deepcopy
    }
    
    func duplicate(only: [String]) -> NSManagedObject {
        return duplicate { only.contains($0) ? .deepcopy : .none }
    }
    
    func duplicate(except: [String], deep: [String] = []) -> NSManagedObject {
        return duplicate { deep.contains($0) ? .deepcopy : except.contains($0) ? .none : .copy }
    }
    
    func duplicate(byProperties fun: (String) -> CopyBehavior) -> NSManagedObject {
        let duplicate = NSEntityDescription.insertNewObject(forEntityName: "EntityOperations", into: mainObjectContext!)
        
        for propertyName in entity.propertiesByName.keys {
            switch fun(propertyName) {
            case .copy:
                let value = self.value(forKey: propertyName)
                duplicate.setValue(value, forKey: propertyName)
            case .deepcopy:
                let value = self.value(forKey: propertyName)
                if let value = value as? NSSet {
                    let copy = value.map {
                        return ($0 as! NSManagedObject).duplicate(byProperties: fun)
                    }
                    duplicate.setValue(copy, forKey: propertyName)
                } else if let value = value as? NSOrderedSet {
                    let copy = value.map {
                        return ($0 as! NSManagedObject).duplicate(byProperties: fun)
                    }
                    duplicate.setValue(NSOrderedSet(array: copy), forKey: propertyName)
                } else if let value = value as? NSManagedObject {
                    let copy = value.duplicate(byProperties: fun)
                    duplicate.setValue(copy, forKey: propertyName)
                } else {
                    fatalError("Unrecognized deepcopy attribute!")
                }
            case .none:
                break
            }
        }
        return duplicate
    }
    
    func Transform() -> [String: Any] {
        
        var infoData = [String: Any]()
        
        for propertyName in entity.propertiesByName.keys {
            let value = self.value(forKey: propertyName)
            infoData[propertyName] = value
        }
        return infoData
    }
}





