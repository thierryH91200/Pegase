import AppKit

final class Rubrique {
    
    fileprivate enum RubriqueDisplayProperty: String {
        case name
        case color
    }
    
    static let shared = Rubrique()
    private var entitiesRubrique = [EntityRubrique]()
    
    func findOrCreate ( compte: EntityAccount,  name: String, color: NSColor, uuid: UUID) -> EntityRubrique {
        
        var entityRubrique = find( compte: compte, name: name )
        if entityRubrique == nil {
            entityRubrique = NSEntityDescription.insertNewObject(forEntityName: "EntityRubrique", into: mainObjectContext) as? EntityRubrique
            entityRubrique!.name = name
            entityRubrique!.color = color
            entityRubrique!.uuid = UUID()
            entityRubrique!.account = compte
        }
        return entityRubrique!
    }
    
    func find( compte: EntityAccount = compteCourant!, name: String) -> EntityRubrique? {
        
        let p1 = NSPredicate(format: "account == %@", compte)
        let p2 = NSPredicate(format: "name == %@", name)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])
        
        let fetchRequest = NSFetchRequest<EntityRubrique>(entityName: "EntityRubrique")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let searchResults = try mainObjectContext.fetch(fetchRequest)
            let result = searchResults.count > 0 ? searchResults.first : nil
            return result
        } catch {
            print("Error with request: \(error)")
            return nil
        }
    }
    
    func remove(entity: EntityRubrique)
    {
        mainObjectContext.delete(entity)
    }
    
    @discardableResult
    func getAll() -> [EntityRubrique] {
        
        guard compteCourant != nil else { return [] }

        do {
            let fetchRequest = NSFetchRequest<EntityRubrique>(entityName: "EntityRubrique")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            let predicate = NSPredicate(format: "account == %@", compteCourant!)
            fetchRequest.predicate = predicate

            entitiesRubrique = try mainObjectContext.fetch(fetchRequest)
            
        } catch {
            print("Error fetching data from CoreData")
        }
        
        defaultEntity()
        return entitiesRubrique
    }
    
    func defaultEntity()
    {
        var isEmpty: Bool {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "EntityRubrique")
                let predicate = NSPredicate(format: "account == %@", compteCourant!)
                
                fetchRequest.predicate = predicate
                let count  = try mainObjectContext.count(for: fetchRequest)
                return count == 0 ? true : false
            } catch {
                return true
            }
        }
        
        if entitiesRubrique.count == 0 {
            var content = ""
            do {
                let url = Bundle.main.url(forResource: "rubrique", withExtension: "csv")
                content =  try String(contentsOf: url!)
            } catch {
                print(error)
            }
            
            let csv = CSwiftV(with: content, separator: ";", replace: "\r")
            let keys = csv.keyedRows
            if let keys = keys
            {
                for key in keys
                {
                    if isEmpty == false {
                        do {
                            let p1 = NSPredicate(format: "account == %@", compteCourant!)
                            let p2 = NSPredicate(format: "name == %@", key["rubrique"]!)
                            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])

                            let fetchRequest = NSFetchRequest<EntityRubrique>(entityName: "EntityRubrique")
                            fetchRequest.predicate = predicate
                            fetchRequest.sortDescriptors = [NSSortDescriptor(key: RubriqueDisplayProperty.name.rawValue, ascending: true)]
                            
                            entitiesRubrique = try mainObjectContext.fetch(fetchRequest)
                        } catch {
                            print("Error fetching data from CoreData")
                        }
                    }
                    
                    if entitiesRubrique.count == 0 {
                        
                        let entityRubrique = EntityRubrique(context: mainObjectContext)
                        entityRubrique.name = key["rubrique"]
                        let color = Color.init(rawValue: key["color"]!)?.color
                        entityRubrique.color = color
                        entityRubrique.uuid = UUID()
                        entityRubrique.account = compteCourant

                        let entityCategory = EntityCategory(context: mainObjectContext)
                        entityCategory.name = key["categorie"]
                        entityCategory.objectif = Double(key["objectif"] ?? "0.0")!
                        entityCategory.uuid = UUID()
                        entityCategory.rubrique = entityRubrique

                        entityRubrique.category?.adding(entityCategory)
                    } else {
                        let entityCategory = EntityCategory(context: mainObjectContext)
                        entityCategory.name = key["categorie"]
                        entityCategory.objectif = Double(key["objectif"] ?? "0.0")!
                        entityCategory.uuid = UUID()
                        entityCategory.rubrique = entitiesRubrique[0]
                        
                        entitiesRubrique[0].category?.adding(entityCategory)
                    }
                }
            }
            do {
                let fetchRequest = NSFetchRequest<EntityRubrique>(entityName: "EntityRubrique")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: RubriqueDisplayProperty.name.rawValue, ascending: true)]
                entitiesRubrique = try mainObjectContext.fetch(fetchRequest)
            } catch {
                print("Error fetching data from CoreData")
            }
        }
    }
    
    enum Color: String {
        case black
        case blue
        case brown
        case gray
        case green
        case orange
        case darkGray
        case purple
        case red
        case yellow
        
        var color: NSColor {
            switch self {
            case .red:
                return .red
            case .blue:
                return .blue
            case .green:
                return .green
            case .black:
                return .black
            case .purple:
                return .purple
            case .orange:
                return .orange
            case .brown:
                return .brown
            case .darkGray:
                return .darkGray
            case .yellow:
                return .yellow
            case .gray:
                return .gray
            }
        }
    }
    
}
