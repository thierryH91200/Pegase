import AppKit

final class CarnetCheques {
    
    static let shared = CarnetCheques()
    private var entities = [EntityCarnetCheques]()
    
    func getAllDatas() -> [EntityCarnetCheques] {
        
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
        if entities.isEmpty == true {
            
            
            let entityCarnetCheques = NSEntityDescription.insertNewObject(forEntityName: "EntityCarnetCheques", into: mainObjectContext) as? EntityCarnetCheques
            
            entityCarnetCheques!.name = Localizations.ModePaiement.Cheque
            entityCarnetCheques!.prefix = "CH"
            entityCarnetCheques!.numPremier = 1_000
            entityCarnetCheques!.numSuivant = 1_000
            entityCarnetCheques!.nbCheques = 25
            entityCarnetCheques!.account = currentAccount
            entityCarnetCheques!.uuid = UUID()
        }
    }
}
