import AppKit

final class Compte {
    
    static let shared = Compte()
    var entities = [EntityAccount]()
    
    func getAll() -> [EntityAccount] {

        do {
            entities = try mainObjectContext.fetch(EntityAccount.fetchRequest())
        } catch {
            print("Error fetching data from CoreData")
        }
        return entities
    }
    
    
    // MARK: create compte
    func create(nameCompte: String, nameImage: String, idName: String, idPrenom: String, numCompte: String) -> EntityAccount {
        let account = NSEntityDescription.insertNewObject(forEntityName: "EntityAccount", into: mainObjectContext) as! EntityAccount
        account.name = nameCompte
        account.nameImage = nameImage
        account.dateEcheancier = Date()
        account.isAccount = true
        account.uuid = UUID()
        
        let identite = Identite.shared.create(name: idName, prenom: idPrenom, isAddAccount: false)
        identite.account = account
        account.identite = identite
        
        let initCompte = InitCompte.shared.create(numCompte: numCompte, isAddAccount: false)
        initCompte.account = account
        account.initCompte = initCompte

        return account
    }
    
    func getRoot() -> [EntityAccount] {
        
        let fetchRequest = NSFetchRequest<EntityAccount>(entityName: "EntityAccount")
        let predicate = NSPredicate(format: "isRoot == true")
        fetchRequest.predicate = predicate
        
        do {
            entities = try mainObjectContext.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        return entities
    }
    
    // just for the debug
    func printAccount(entityCompte: EntityAccount, description: String) {
        let name = entityCompte.name ?? "nameCompte"
        
        let identite = entityCompte.identite
        let idName = identite?.idName ?? "name"
        let idPrenom = identite?.idPrenom ?? "prenom"
        let idNumber = entityCompte.initCompte?.codeCompte ?? "codeCompte"
        
        print("\(description) : \(name) \(idName) \(idPrenom) \(idNumber)")
    }
}
