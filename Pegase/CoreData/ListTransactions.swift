import AppKit

final class ListTransactions {
    
    static let shared = ListTransactions()
    var entities = [EntityTransactions]()
    var ascending = false
    var viewContext : NSManagedObjectContext?

    init () {
        if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
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
                comments.append(sousOperation.libelle!)
            }
        }
        return comments.uniqueElements
    }
    
    func getAllDatas(ascending: Bool = true ) -> [EntityTransactions] {
        
        guard currentAccount != nil else { return [] }
        self.ascending = ascending
        
        let fetchRequest = NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
        let predicate = NSPredicate(format: "account == %@", currentAccount!)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: ascending)]
        
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
    let entityOperations: EntityTransactions
    
    init( year: String, id: String, entityOperations: EntityTransactions) {
        self.year = year
        self.id = id
        self.entityOperations = entityOperations
    }
}

//public typealias TrackingYear           = [ GroupedYearOperations ]
//public typealias TrackingMonth          = GroupedYearOperations
//public typealias TrackingIdOperations   = GroupedMonthOperations
//public typealias TrackingSubOperations  = IdOperations
//public typealias TrackingSubOperation   = EntitySousOperations

//struct GroupedYearOperations {
//    let year : String
//    var allMonth : [GroupedMonthOperations]
//
//    init( dictionary: ((key: String, value: [String: [IdOperations]]))) {
//        self.year = dictionary.key
//
//        let groupedID = dictionary.value
//        allMonth = [GroupedMonthOperations]()
//        var oneMonth : [GroupedMonthOperations] = []
//
//        for grouped in groupedID {
//            let groupedMonth = GroupedMonthOperations(month: grouped.key, idOpes: grouped.value)
//            oneMonth.append(groupedMonth)
//        }
//        self.allMonth = oneMonth.sorted(by: {$0.month > $1.month})
//    }
//}
//
//struct GroupedMonthOperations {
//    let month : String
//    let idOperation : [ IdOperations ]
//
//    init( month: String, idOpes: [IdOperations]) {
//        self.month = month
//
//        var idAllOperation : [IdOperations] = []
//        for idOpe in idOpes {
//            let idOperation = IdOperations(year: idOpe.year, id: idOpe.id, entityOperations: idOpe.entityOperations)
//            idAllOperation.append(idOperation)
//        }
//        self.idOperation = idAllOperation.sorted(by: {Double($0.entityOperations.dateOperation!.timeIntervalSince1970) > Double($1.entityOperations.dateOperation!.timeIntervalSince1970)})
//    }
//}
//
