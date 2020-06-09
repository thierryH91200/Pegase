import AppKit

final class Echeanciers {
    
    static let shared = Echeanciers()
    private var entities = [EntitySchedule]()
    
    // delete Entity
    func remove(entity: EntitySchedule)
    {
        mainObjectContext.delete(entity)
    }

    func getAllDatas() -> [EntitySchedule] {
        
        do {
            let fetchRequest = NSFetchRequest<EntitySchedule>(entityName: "EntitySchedule")
            let predicate = NSPredicate(format: "account == %@", currentAccount!)
            fetchRequest.predicate = predicate
            
            entities = try mainObjectContext.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        return entities
    }
    
    func createSousOperation (entitySchedule: EntitySchedule) -> EntitySousOperations{
        
        // create sous operation
        let entitySousOperation = NSEntityDescription.insertNewObject(forEntityName: "EntitySousOperations", into: mainObjectContext) as! EntitySousOperations

        // la rubrique existe t elle ??
        var name = entitySchedule.category?.rubric?.name
        let color = entitySchedule.category?.rubric?.color
        var uuid = entitySchedule.category?.rubric?.uuid
        let entityRubrique = Rubric.shared.findOrCreate(account: entitySchedule.account!, name: name!, color: color as! NSColor, uuid: uuid!)
        
        // la categorie existe t elle ??
        name = entitySchedule.category?.name
        let objectif = entitySchedule.category?.objectif
        uuid = entitySchedule.category?.uuid
        let entityCategorie = Categories.shared.findOrCreate(account: entitySchedule.account!, name: name!, objectif: objectif!, uuid: uuid!)
        
        entitySousOperation.category         = entityCategorie
        entitySousOperation.category?.rubric = entityRubrique
        entitySousOperation.amount           = -entitySchedule.amount
        entitySousOperation.libelle          = entitySchedule.libelle
        
        return entitySousOperation
    }
        
    func createOperation (entitySchedule: EntitySchedule, dateValeur: Date) {

        entitySchedule.nextOccurence += 1
        
        let entityOperation = NSEntityDescription.insertNewObject(forEntityName: "EntityOperations", into: mainObjectContext) as! EntityOperations
        
        entityOperation.dateCree       = Date()
        entityOperation.dateModifie    = Date()
        entityOperation.dateOperation  = dateValeur
        entityOperation.datePointage   = dateValeur

        entityOperation.account        = entitySchedule.account
                
        entityOperation.paymentMode    = entitySchedule.paymentMode
        entityOperation.statut         = Date() >= dateValeur ? 2 : 1
        
        entityOperation.bankStatement = 0
        entityOperation.uuid           = UUID()

        // create sous operation
        let entitySousOperation = createSousOperation(entitySchedule: entitySchedule)
        
        // addd sous operation
        entityOperation.addToSousOperations(  entitySousOperation)
        
        if entitySchedule.compteLie != nil {
            
            let entityOperationsTransfert = NSEntityDescription.insertNewObject(forEntityName: "EntityOperations", into: mainObjectContext) as! EntityOperations

            entityOperationsTransfert.dateCree      = entityOperation.dateCree
            entityOperationsTransfert.dateModifie   = entityOperation.dateModifie
            entityOperationsTransfert.dateOperation = entityOperation.dateOperation
            entityOperationsTransfert.datePointage  = entityOperation.datePointage
            
            let compteLie = entitySchedule.compteLie!
            entityOperationsTransfert.account        = compteLie

            entityOperationsTransfert.statut        = entityOperation.statut
            entityOperationsTransfert.bankStatement = entityOperation.bankStatement

            // le modePaiement existe t il ??
            let name = entityOperationsTransfert.paymentMode?.name
            let color = entityOperationsTransfert.paymentMode?.color
            let uuid = entityOperationsTransfert.paymentMode?.uuid
            let entityModePaiement = PaymentMode.shared.findOrCreate(account: compteLie, name: name!, color: color as! NSColor, uuid: uuid!)
            entityOperationsTransfert.paymentMode  = entityModePaiement

            /// la rubrique existe t elle ??
            let entityRubric = Rubric.shared.findOrCreate(account: compteLie, name: name!, color: color as! NSColor, uuid: uuid!)
            
            /// la categorie existe t elle ?
            let objectif = entitySchedule.category?.objectif
            let entityCategorie = Categories.shared.findOrCreate(account: compteLie, name: name!, objectif: objectif!, uuid: uuid!)
            entitySousOperation.category = entityCategorie
            entitySousOperation.category?.rubric = entityRubric
            entitySousOperation.amount       = -entitySchedule.amount

            entityOperationsTransfert.addToSousOperations(entitySousOperation)
            
            entityOperationsTransfert.uuid          = UUID()
        }
    }
}
