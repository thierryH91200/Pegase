import AppKit

final class Preference {
    
    static let shared = Preference()
    var entityPreference = [EntityPreference]()
    
    func getAllDatas() -> EntityPreference {
        
        guard currentAccount != nil else { return entityPreference[0] }
        
        let fetchRequest = NSFetchRequest<EntityPreference>(entityName: "EntityPreference")
        let predicate = NSPredicate(format: "account == %@", currentAccount!)
        fetchRequest.predicate = predicate
        
        do {
            entityPreference = try mainObjectContext.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        
        if entityPreference.isEmpty == true {
            
            let entityPreference = EntityPreference(context: mainObjectContext)
            
            var rubric = Rubric.shared.getAllDatas()
            rubric = rubric.sorted { $0.name! < $1.name! }
            
            var categories = rubric.first?.category?.allObjects as! [EntityCategory]
            categories = categories.sorted { $0.name! < $1.name! }
            entityPreference.category = categories.first

            let modesPaiement = ModePaiement.shared.getAllDatas()
            entityPreference.modePaiement = modesPaiement.first
            
            entityPreference.statut = 1
            entityPreference.signe = true

            entityPreference.account = currentAccount
            return entityPreference
        }
        return entityPreference.first!
    }

}
