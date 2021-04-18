import Cocoa


// https://stackoverflow.com/questions/2730832/how-can-i-duplicate-or-copy-a-core-data-managed-object
extension NSManagedObject {
    
    func copyEntireObjectGraph(context: NSManagedObjectContext) -> NSManagedObject {
        
        var cache = Dictionary<NSManagedObjectID, NSManagedObject>()
        return cloneObject(context: context, cache: &cache)
        
    }
    
    func cloneObject(context: NSManagedObjectContext, cache alreadyCopied: inout Dictionary<NSManagedObjectID, NSManagedObject>) -> NSManagedObject {
        
        guard let entityName = self.entity.name else {
            fatalError("source.entity.name == nil")
        }
        
        if let storedCopy = alreadyCopied[self.objectID] {
            return storedCopy
        }
        
        let cloned = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        alreadyCopied[self.objectID] = cloned
        
        if let attributes = NSEntityDescription.entity(forEntityName: entityName, in: context)?.attributesByName {
            for key in attributes.keys {
                cloned.setValue(self.value(forKey: key), forKey: key)
            }
        }
        
        if let relationships = NSEntityDescription.entity(forEntityName: entityName, in: context)?.relationshipsByName {
            
            for (key, value) in relationships {
                
                if value.isToMany {
                    if let sourceSet = self.value(forKey: key) as? NSMutableOrderedSet {
                        
                        guard let clonedSet = cloned.value(forKey: key) as? NSMutableOrderedSet else {
                            fatalError("Could not cast relationship \(key) to an NSMutableOrderedSet")
                        }
                        
                        let enumerator = sourceSet.objectEnumerator()
                        var nextObject = enumerator.nextObject() as? NSManagedObject
                        
                        while let relatedObject = nextObject {
                            
                            let clonedRelatedObject = relatedObject.cloneObject(context: context, cache: &alreadyCopied)
                            clonedSet.add(clonedRelatedObject)
                            nextObject = enumerator.nextObject() as? NSManagedObject
                            
                        }
                        
                    } else if let sourceSet = self.value(forKey: key) as? NSMutableSet {
                        
                        guard let clonedSet = cloned.value(forKey: key) as? NSMutableSet else {
                            fatalError("Could not cast relationship \(key) to an NSMutableSet")
                        }
                        
                        let enumerator = sourceSet.objectEnumerator()
                        var nextObject = enumerator.nextObject() as? NSManagedObject
                        while let relatedObject = nextObject {
                            
                            let clonedRelatedObject = relatedObject.cloneObject(context: context, cache: &alreadyCopied)
                            clonedSet.add(clonedRelatedObject)
                            nextObject = enumerator.nextObject() as? NSManagedObject
                        }
                    }
                    
                } else {
                    
                    if let relatedObject = self.value(forKey: key) as? NSManagedObject {
                        
                        let clonedRelatedObject = relatedObject.cloneObject(context: context, cache: &alreadyCopied)
                        cloned.setValue(clonedRelatedObject, forKey: key)
                    }
                }
            }
        }
        return cloned
    }
}

extension NSManagedObjectContext
{
    func deleteAllData()
    {
        guard let persistentStore = persistentStoreCoordinator?.persistentStores.last else {
            return
        }

        guard let url = persistentStoreCoordinator?.url(for: persistentStore) else {
            return
        }

        performAndWait { () -> Void in
            self.reset()
            do
            {
                try self.persistentStoreCoordinator?.remove(persistentStore)
                try FileManager.default.removeItem(at: url)
                try self.persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            }
            catch { /*dealing with errors up to the usage*/ }
        }
    }
}

extension NSManagedObject {
    
    enum DeepCopyError: Error {
        case missingContext
        case missingEntityName(NSManagedObject)
        case unmanagedObject(Any)
    }
    
    func deepcopy(context: NSManagedObjectContext? = nil) throws -> NSManagedObject {
        
        if let context = context ?? managedObjectContext {
            
            var cache = Dictionary<NSManagedObjectID, NSManagedObject>()
            return try deepcopy(context: context, cache: &cache)
            
        } else {
            throw DeepCopyError.missingContext
        }
    }

    private func deepcopy(context: NSManagedObjectContext, cache alreadyCopied: inout Dictionary<NSManagedObjectID, NSManagedObject>) throws -> NSManagedObject {
                
        guard let entityName = self.entity.name else {
            throw DeepCopyError.missingEntityName(self)
        }
        
        if let storedCopy = alreadyCopied[self.objectID] {
            return storedCopy
        }

        let cloned = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        alreadyCopied[self.objectID] = cloned
        
        // Loop through all attributes and assign then to the clone
        NSEntityDescription
            .entity(forEntityName: entityName, in: context)?
            .attributesByName
            .forEach { attribute in
                cloned.setValue(value(forKey: attribute.key), forKey: attribute.key)
            }
        
        // Loop through all relationships, and clone them.
        try NSEntityDescription
            .entity(forEntityName: entityName, in: context)?
            .relationshipsByName
            .forEach { relation in
                
                if relation.value.isToMany {
                    if relation.value.isOrdered {
                        
                        // Get a set of all objects in the relationship
                        let sourceSet = mutableOrderedSetValue(forKey: relation.key)
                        let clonedSet = cloned.mutableOrderedSetValue(forKey: relation.key)
                        
                        for object in sourceSet.objectEnumerator() {
                            if let relatedObject = object as? NSManagedObject {
                                
                                // Clone it, and add clone to the set
                                let clonedRelatedObject = try relatedObject.deepcopy(context: context, cache: &alreadyCopied)
                                clonedSet.add(clonedRelatedObject as Any)
                                
                            } else {
                                throw DeepCopyError.unmanagedObject(object)
                            }
                        }
                        
                    } else {
                        
                        // Get a set of all objects in the relationship
                        let sourceSet = mutableSetValue(forKey: relation.key)
                        let clonedSet = cloned.mutableSetValue(forKey: relation.key)
                        
                        for object in sourceSet.objectEnumerator() {
                            if let relatedObject = object as? NSManagedObject {
                                
                                // Clone it, and add clone to the set
                                let clonedRelatedObject = try relatedObject.deepcopy(context: context, cache: &alreadyCopied)
                                clonedSet.add(clonedRelatedObject as Any)
                                
                            } else {
                                throw DeepCopyError.unmanagedObject(object)
                            }
                        }
                    }
                    
                } else if let relatedObject = self.value(forKey: relation.key) as? NSManagedObject {
                    
                    // Clone it, and assign then to the clone
                    let clonedRelatedObject = try relatedObject.deepcopy(context: context, cache: &alreadyCopied)
                    cloned.setValue(clonedRelatedObject, forKey: relation.key)
                }
            }
        
        return cloned
    }
    
    func duplicateTransactions(context: NSManagedObjectContext, entityTrans: EntityTransactions) -> EntityTransactions
    {
        let entityOperation = NSEntityDescription.insertNewObject(forEntityName: "EntityTransactions", into: context) as? EntityTransactions
        
        entityOperation?.dateCree = Date()
        entityOperation?.uuid = UUID()
        
        entityOperation?.dateModifie = Date()
        
        entityOperation?.datePointage  = entityTrans.datePointage
        
        // DateOperation
        entityOperation?.dateOperation  = entityTrans.dateOperation
        
        // Relevé bancaire
        entityOperation?.bankStatement = entityTrans.bankStatement
        
        // ModePaiement
        entityOperation?.paymentMode = entityTrans.paymentMode
        
        // Statut
        entityOperation?.statut = entityTrans.statut
        
        // Operation Link
        entityOperation?.operationLiee = nil
        
        entityOperation?.account = entityTrans.account
        
        let entitySousOperations = entityTrans.sousOperations?.allObjects as! [EntitySousOperations]
        
        for entitySousOperation in entitySousOperations {
            let ent = saveSubTransactions(context: context, entityTrans: entitySousOperation)
            entityOperation?.addToSousOperations(ent)
        }
//        (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
        return entityOperation!
    }
    
    func saveSubTransactions(context: NSManagedObjectContext, entityTrans: EntitySousOperations) -> EntitySousOperations
    {
        let entitySousOperations = NSEntityDescription.insertNewObject(forEntityName: "EntitySousOperations", into: context) as? EntitySousOperations
        entitySousOperations?.category = entityTrans.category
        entitySousOperations?.libelle = entityTrans.libelle
        entitySousOperations?.amount = entityTrans.amount
        return entitySousOperations!
    }
}




