import AppKit

final class ListeOperations {
    
    static let shared = ListeOperations()
    var entities = [EntityOperations]()
    
    // delete Operation
    func remove(entity: EntityOperations)
    {
        mainObjectContext.undoManager?.beginUndoGrouping()
        mainObjectContext.undoManager?.setActionName("Delete")
        mainObjectContext.delete(entity)
        mainObjectContext.undoManager?.endUndoGrouping()
    }
    
    func find(uuid: UUID) -> EntityOperations
    {
        let fetchRequest = NSFetchRequest<EntityOperations>(entityName: "EntityOperations")
        do {
            entities = try mainObjectContext.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        if let i = entities.firstIndex(where: {$0.uuid == uuid}) {
            return entities[i]
        }
        return entities.first!
    }
    
    func getAllComment() -> [String] {
        
        var comments = [String]()
        
        let entityOperations = getAll()
        for entityOperation in entityOperations {
            let sousOperations = entityOperation.sousOperations?.allObjects as! [EntitySousOperations]
            
            for sousOperation in sousOperations {
                comments.append(sousOperation.libelle!)
            }
        }
        return comments.uniqueElements
    }
    
    func getAll(ascending: Bool = true ) -> [EntityOperations] {
        
        guard compteCourant != nil else { return [] }
        
        let fetchRequest = NSFetchRequest<EntityOperations>(entityName: "EntityOperations")
        let predicate = NSPredicate(format: "account == %@", compteCourant!)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: ascending)]
        
        do {
            entities = try mainObjectContext.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        return entities
    }
    
}

public extension Sequence where Element: Equatable {
    var uniqueElements: [Element] {
        return self.reduce(into: []) {
            uniqueElements, element in
            
            if !uniqueElements.contains(element) {
                uniqueElements.append(element)
            }
        }
    }
}

// MARK: convert dictionary to struct
struct GroupedYearOperations {
    let year : String
    var allMonth : [GroupedMonthOperations]
    
    init( dictionary: (key: String, value: [String: [IdOperations]])) {
        self.year = dictionary.key
        
        self.allMonth = [GroupedMonthOperations]()
        let months = (dictionary.value).map { (key: String , value: [IdOperations]) -> GroupedMonthOperations in
            return GroupedMonthOperations(month : key , idOperations: value)
        }
        self.allMonth = months.sorted(by: {$0.month > $1.month})
    }
}

struct GroupedMonthOperations {
    let month : String
    let idOperation : [ IdOperations ]
    
    init( month: String, idOperations: [IdOperations]) {
        
        self.month = month
        let idAllOperation = (0 ..< idOperations.count).map { (i) -> IdOperations in
            return IdOperations(year : idOperations[i].year, id: idOperations[i].id, entityOperations: idOperations[i].entityOperations)
        }
        self.idOperation = idAllOperation.sorted(by: { $0.entityOperations.dateOperation!.timeIntervalSince1970 > $1.entityOperations.dateOperation!.timeIntervalSince1970 })
    }
}

struct IdOperations {
    let year : String
    let id: String
    let entityOperations: EntityOperations
    
    init( year: String, id: String, entityOperations: EntityOperations) {
        self.year = year
        self.id = id
        self.entityOperations = entityOperations
    }
}
