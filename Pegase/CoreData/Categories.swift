

import AppKit

final class Categories {
        
    static let shared = Categories()
    private var entities = [EntityCategory]()
    
    func findOrCreate ( account: EntityAccount,  name: String, objectif: Double, uuid: UUID) -> EntityCategory {
        
        var entityCategory = find( account: account, name: name )
        if entityCategory == nil {
            entityCategory = NSEntityDescription.insertNewObject(forEntityName: "EntityCategory", into: mainObjectContext) as? EntityCategory
            entityCategory!.name = name
            entityCategory!.uuid = UUID()
            entityCategory!.objectif = objectif
        }
        return entityCategory!
    }

    func find( account: EntityAccount = compteCourant!, name: String) -> EntityCategory? {
        
        let p1 = NSPredicate(format: "rubrique.account == %@", account)
        let p2 = NSPredicate(format: "name == %@", name)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])

        let fetchRequest = NSFetchRequest<EntityCategory>(entityName: "EntityCategory")
        fetchRequest.predicate = predicate

        do {
            let searchResults = try mainObjectContext.fetch(fetchRequest)
            let result = searchResults.count > 0 ? searchResults.first : nil
            return result
        } catch {
            print("Error with request: \(error)")
            return nil
        }
    }
    func findWithRubric( account: EntityAccount = compteCourant!, rubric: EntityRubrique, name: String) -> EntityCategory? {
        
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
