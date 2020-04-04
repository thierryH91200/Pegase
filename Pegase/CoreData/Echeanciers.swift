import AppKit

final class Echeanciers {
    
    static let shared = Echeanciers()
    private var entities = [EntityEcheancier]()
    
    // delete Entity
    func remove(entity: EntityEcheancier)
    {
        mainObjectContext.delete(entity)
    }

    func getAllDatas() -> [EntityEcheancier] {
        
        do {
            let fetchRequest = NSFetchRequest<EntityEcheancier>(entityName: "EntityEcheancier")
            let predicate = NSPredicate(format: "account == %@", currentAccount!)
            fetchRequest.predicate = predicate
            
            entities = try mainObjectContext.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        return entities
    }
    
    func createOperation (entityEcheancier: EntityEcheancier, dateValeur: Date) {
        
        entityEcheancier.nextOccurence += 1

        
        let entityOperation = EntityOperations(context: mainObjectContext)
        
        entityOperation.dateCree       = Date()
        entityOperation.dateModifie    = Date()
        
        entityOperation.account         = entityEcheancier.account
                
        entityOperation.modePaiement   = entityEcheancier.modePaiement
        entityOperation.statut         = Date() >= dateValeur ? 2 : 1
        
        entityOperation.dateOperation  = dateValeur
        entityOperation.datePointage   = dateValeur
        
        entityOperation.bankStatement = 0
        
        let sousOpenation = EntitySousOperations(context: mainObjectContext)
        
        // la rubrique existe t elle ??
        var name = entityEcheancier.category?.rubric?.name
        let color = entityEcheancier.category?.rubric?.color
        var uuid = entityEcheancier.category?.rubric?.uuid
        let entityRubrique = Rubric.shared.findOrCreate(account: entityEcheancier.account!, name: name!, color: color as! NSColor, uuid: uuid!)
        
        // la categorie existe t elle ??
        name = entityEcheancier.category?.name
        let objectif = entityEcheancier.category?.objectif
        uuid = entityEcheancier.category?.uuid
        let entityCategorie = Categories.shared.findOrCreate(account: entityEcheancier.account!, name: name!, objectif: objectif!, uuid: uuid!)
        
        sousOpenation.category = entityCategorie
        sousOpenation.category?.rubric = entityRubrique
        sousOpenation.amount       = -entityEcheancier.amount
        sousOpenation.libelle       = entityEcheancier.libelle

        entityOperation.uuid           = UUID()
        
        
        if entityEcheancier.compteLie != nil {
            
            let entityOperationsTransfert = EntityOperations(context: mainObjectContext)
            
            let compteLie = entityEcheancier.compteLie!
            entityOperationsTransfert.account        = compteLie
            entityOperationsTransfert.statut        = entityOperation.statut
            
            entityOperationsTransfert.bankStatement = entityOperation.bankStatement

            entityOperationsTransfert.dateOperation = entityOperation.dateOperation
            entityOperationsTransfert.datePointage  = entityOperation.datePointage
            entityOperationsTransfert.dateModifie   = entityOperation.dateModifie
            entityOperationsTransfert.dateCree      = entityOperation.dateCree
            
            // le modePaiement existe t il ??
            let name = entityOperationsTransfert.modePaiement?.name
            let color = entityOperationsTransfert.modePaiement?.color
            let uuid = entityOperationsTransfert.modePaiement?.uuid
            let entityModePaiement = ModePaiement.shared.findOrCreate(account: compteLie, name: name!, color: color as! NSColor, uuid: uuid!)
            entityOperationsTransfert.modePaiement  = entityModePaiement

            /// la rubrique existe t elle ??
            let entityRubric = Rubric.shared.findOrCreate(account: compteLie, name: name!, color: color as! NSColor, uuid: uuid!)
            
            /// la categorie existe t elle ?
            let entityCategorie = Categories.shared.findOrCreate(account: compteLie, name: name!, objectif: objectif!, uuid: uuid!)
            sousOpenation.category = entityCategorie
            sousOpenation.category?.rubric = entityRubric
            sousOpenation.amount       = -entityEcheancier.amount

            entityOperationsTransfert.addToSousOperations(sousOpenation)
            
            entityOperationsTransfert.uuid          = UUID()
        }
    }
}
