import AppKit

final class ListTransactions : NSObject {
    
    static let shared = ListTransactions()
    var entities = [EntityTransactions]()
    var ascending = false
    var viewContext : NSManagedObjectContext?
    
    override init () {
        if let context = mainObjectContext
        {
            self.viewContext = context
        }
    }
    
    // delete Operation
    func remove(entity: EntityTransactions)
    {
        viewContext!.undoManager?.beginUndoGrouping()
        viewContext!.undoManager?.setActionName("DeleteTransaction")
        viewContext!.delete(entity)
        viewContext!.undoManager?.endUndoGrouping()
    }
    
    func find(uuid: UUID) -> EntityTransactions
    {
        let fetchRequest = NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
        do {
            entities = try viewContext!.fetch(fetchRequest)
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
        
        let entityOperations = getAllDatas()
        for entityOperation in entityOperations {
            let sousOperations = entityOperation.sousOperations?.allObjects as! [EntitySousOperations]
            
            for sousOperation in sousOperations {
                let libelle = sousOperation.libelle ?? "vide"
                comments.append(libelle)
            }
        }
        return comments.uniqueElements
    }
    
    func getAllDatas(ascending: Bool = true , forcing : Bool = false) -> [EntityTransactions] {
        
        guard currentAccount != nil else { return [] }
//        guard forcing == true else { return [] }
        self.ascending = ascending
        
        let fetchRequest = NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
        let predicate = NSPredicate(format: "account == %@", currentAccount!)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "datePointage", ascending: ascending),
                                        NSSortDescriptor(key: "dateOperation", ascending: ascending)]

        do {
            entities = try viewContext!.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
            return []
        }
        if currentAccount?.isDemo == true {
            adjustDate()
        }
        return entities
    }
    
    func adjustDate () {
        guard entities.isEmpty == false else {return}
        let diffDate = (entities.first?.dateOperation!.timeIntervalSinceNow)!
        for entityOperation in entities {
            entityOperation.datePointage  = (entityOperation.datePointage!  - diffDate).noon
            entityOperation.dateOperation = (entityOperation.dateOperation! - diffDate).noon
        }
        currentAccount?.isDemo = false
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

// MARK: convert dictionary to class
class GroupedYearOperations : NSObject {
    let year : String
    var allMonth : [GroupedMonthOperations]
    
    init( dictionary: (key: String, value: [String: [IdTransactions]])) {
        self.year = dictionary.key
        
        self.allMonth = [GroupedMonthOperations]()
        let months = (dictionary.value).map { (key: String , value: [IdTransactions]) -> GroupedMonthOperations in
            return GroupedMonthOperations(month : key , idOperations: value)
        }
        self.allMonth = months.sorted(by: {$0.month > $1.month})
    }
}

class GroupedMonthOperations : NSObject {
    let month       : String
    let idTransaction : [ IdTransactions ]
    
    init( month: String, idOperations: [IdTransactions]) {
        
        self.month = month
        let idAllOperation = (0 ..< idOperations.count).map { (i) -> IdTransactions in
            return IdTransactions(year : idOperations[i].year, id: idOperations[i].id, entityOperations: idOperations[i].entityTransactions)
        }
        self.idTransaction = idAllOperation.sorted(by: { $0.entityTransactions.datePointage!.timeIntervalSince1970 > $1.entityTransactions.datePointage!.timeIntervalSince1970 })
    }
}

class IdTransactions : NSObject {
    let year             : String
    let id               : String
    let entityTransactions : EntityTransactions
    
    init( year: String, id: String, entityOperations: EntityTransactions) {
        self.year = year
        self.id = id
        self.entityTransactions = entityOperations
    }
}

