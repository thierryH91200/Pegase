import AppKit

final class Preference {
    
    static let shared = Preference()
    var entityPreference = [EntityPreference]()
    
    func getAll() -> EntityPreference {
        
        guard compteCourant != nil else { return entityPreference[0] }
        
        let fetchRequest = NSFetchRequest<EntityPreference>(entityName: "EntityPreference")
        let predicate = NSPredicate(format: "account == %@", compteCourant!)
        fetchRequest.predicate = predicate
        
        do {
            entityPreference = try mainObjectContext.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        
        if entityPreference.count == 0 {
            
            let entityPreference = EntityPreference(context: mainObjectContext)
            
            var rubrique = Rubric.shared.getAll()
            rubrique = rubrique.sorted { $0.name! < $1.name! }
            
            var categories = rubrique.first?.category?.allObjects as! [EntityCategory]
            categories = categories.sorted { $0.name! < $1.name! }
            entityPreference.category = categories.first

            let modesPaiement = ModePaiement.shared.getAll()
            entityPreference.modePaiement = modesPaiement.first
            
            entityPreference.statut = 1
            entityPreference.signe = true

            entityPreference.account = compteCourant
            return entityPreference
        }
        return entityPreference.first!
    }

}
