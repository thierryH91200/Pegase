import AppKit

final class CarnetCheques {
    
    static let shared = CarnetCheques()
    private var entities = [EntityCarnetCheques]()
    
    func getAllCarnetCheques() -> [EntityCarnetCheques] {
        
        do {
            let fetchRequest = NSFetchRequest<EntityCarnetCheques>(entityName: "EntityCarnetCheques")
            let predicate = NSPredicate(format: "account == %@", currentAccount!)
            fetchRequest.predicate = predicate
            
            entities = try mainObjectContext.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        defaultCarnetCheques()
        return entities
    }
    
    func defaultCarnetCheques()
    {
        if entities.count == 0 {
            let chequier1 = EntityCarnetCheques(context: mainObjectContext)
            
            chequier1.name = Localizations.ModePaiement.Cheque
            chequier1.prefix = "CH"
            chequier1.numPremier = 1_000
            chequier1.numSuivant = 1_000
            chequier1.nbCheques = 25
            chequier1.account = currentAccount
            chequier1.uuid = UUID()
        }
    }
}
