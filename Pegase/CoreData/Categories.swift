import AppKit

final class Categories : NSObject {
        
    static let shared = Categories()
    private var entities = [EntityCategory]()
    var viewContext : NSManagedObjectContext?

    override init () {
        if let context = mainObjectContext
        {
            self.viewContext = context
        }
    }

    
    func findOrCreate ( account: EntityAccount,  name: String, objectif: Double, uuid: UUID) -> EntityCategory {
        
        var entityCategory = find( account: account, name: name )
        if entityCategory == nil {
            entityCategory = NSEntityDescription.insertNewObject(forEntityName: "EntityCategory", into: viewContext!) as? EntityCategory
            entityCategory!.name = name
            entityCategory!.uuid = UUID()
            entityCategory!.objectif = objectif
        }
        return entityCategory!
    }

    func find( account: EntityAccount = currentAccount!, name: String) -> EntityCategory? {
        
        let p1 = NSPredicate(format: "rubric.account == %@", account)
        let p2 = NSPredicate(format: "name == %@", name)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])

        let fetchRequest = NSFetchRequest<EntityCategory>(entityName: "EntityCategory")
        fetchRequest.predicate = predicate

        do {
            let searchResults = try viewContext!.fetch(fetchRequest)
            let result = searchResults.isEmpty == false ? searchResults.first : nil
            return result
        } catch {
            print("Error with request: \(error)")
            return nil
        }
    }
    func findWithRubric( account: EntityAccount = currentAccount!, rubric: EntityRubric, name: String) -> EntityCategory? {
        
        let categories = rubric.category?.allObjects as! [EntityCategory]
        var category = categories.filter({ $0.name == name }).first
        
        if category == nil {
            category = categories.first
        }
        return category
    }

    // delete Entity
//    func removeCategories(entity: EntityCategory)
//    {
//        mainObjectContext.delete(entity)
//    }
//
//    @discardableResult
//    func getAllCategories() -> [EntityCategory] {
//        
//        let fetchRequest = NSFetchRequest<EntityCategory>(entityName: "EntityCategory")
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: CategorieDisplayProperty.name.rawValue, ascending: true)]
//        let predicate = NSPredicate(format: "rubrique.account == %@", compteCourant!)
//        fetchRequest.predicate = predicate
//        
//        do {
//            
//            entities = try mainObjectContext.fetch(fetchRequest)
//        } catch {
//            print("Error fetching data from CoreData")
//        }
//        return entities
//    }
    
}
