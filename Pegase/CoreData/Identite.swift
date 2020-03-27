import AppKit

// MARK: - Banque
final class Banque {
    
    static let shared = Banque()
    var entitiesBanque = [EntityBanque]()
    
    func create() -> EntityBanque {
        let entity = EntityBanque(context: mainObjectContext)
        
        entity.adresse = ""
        entity.banque = ""
        entity.cp = 0
        entity.email = ""
        entity.fonction = ""
        entity.mobile = ""
        entity.nom = ""
        entity.pays = ""
        entity.telephone = ""
        entity.ville = ""
        entity.uuid = UUID()
        
        entity.account = currentAccount
        return entity
    }
    
    @discardableResult func getAll() -> EntityBanque {
        
        do {
            let fetchRequest = NSFetchRequest<EntityBanque>(entityName: "EntityBanque")
            let predicate = NSPredicate(format: "account == %@", currentAccount!)
            fetchRequest.predicate = predicate
            entitiesBanque = try mainObjectContext.fetch(fetchRequest)
            
        } catch {
            print("Error fetching data from CoreData")
        }
        if entitiesBanque.first != nil {
            return entitiesBanque.first!
        } else {
            return create()
        }
    }
}

// MARK: - InitAccount
final class InitAccount {
    
    static let shared = InitAccount()
    var entitiesInitCompte = [EntityInitCompte]()
    
    func create(numAccount : String = "" ) -> EntityInitCompte {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "EntityInitCompte", into: mainObjectContext) as! EntityInitCompte
        
        entity.bic = ""
        entity.cleRib = 0
        entity.codeBanque = 0
        entity.codeCompte = numAccount
        entity.codeGuichet = 0
        entity.engage = 0
        entity.iban1 = ""
        entity.iban2 = ""
        entity.iban3 = ""
        entity.iban4 = ""
        entity.iban5 = ""
        entity.iban6 = ""
        entity.iban7 = ""
        entity.iban8 = ""
        entity.iban9 = ""
        entity.prevu = 0
        entity.realise = 0
        return entity
    }
    
    @discardableResult func getAll() -> EntityInitCompte {
        
        do {
            let fetchRequest = NSFetchRequest<EntityInitCompte>(entityName: "EntityInitCompte")
            let predicate = NSPredicate(format: "account == %@", currentAccount!)
            fetchRequest.predicate = predicate
            entitiesInitCompte = try mainObjectContext.fetch(fetchRequest)
            
        } catch {
            print("Error fetching data from CoreData")
        }
        if entitiesInitCompte.first != nil {
            return entitiesInitCompte.first!
        } else {
            return create()
        }
    }
    
}

// MARK: - Identite
final class Identite {
    
    static let shared = Identite()
    var entitiesIdentite = [EntityIdentite]()
    
    func create(name: String = "", prenom: String = "") -> EntityIdentite {
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "EntityIdentite", into: mainObjectContext) as! EntityIdentite
        entity.idName        = name
        entity.idPrenom      = prenom
        entity.idAdresse     = ""
        entity.idComplement  = ""
        entity.idCp          = 0
        entity.idVille       = ""
        entity.idTelephone   = ""
        entity.idPays        = ""
        entity.idMobile      = ""
        entity.idEmail       = ""
        return entity
    }
    
    @discardableResult func getAll() -> EntityIdentite {
        
        do {
            let fetchRequest = NSFetchRequest<EntityIdentite>(entityName: "EntityIdentite")
            let predicate = NSPredicate(format: "account == %@", currentAccount!)
            fetchRequest.predicate = predicate
            entitiesIdentite = try mainObjectContext.fetch(fetchRequest)
            
        } catch {
            print("Error fetching data from CoreData")
        }
        if entitiesIdentite.first != nil {
            return entitiesIdentite.first!
        } else {
            return create()
        }
    }
    
}
