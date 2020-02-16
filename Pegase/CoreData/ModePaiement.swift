import AppKit

final class ModePaiement {
    
    static let shared = ModePaiement()
    private var entitiesModePaiement = [EntityModePaiement]()
    
    func findModePaiement(entity: EntityModePaiement) -> Int {
        
        let i = entitiesModePaiement.firstIndex { $0 === entity }
        return i!
    }
    
    func findOrCreate ( account: EntityAccount,  name: String, color: NSColor, uuid: UUID) -> EntityModePaiement {
        
        var entity = find( account: account, name: name )
        if entity == nil {
            entity = NSEntityDescription.insertNewObject(forEntityName: "EntityModePaiement", into: mainObjectContext) as? EntityModePaiement
            entity!.name = name
            entity!.color = color
            entity!.uuid = uuid
            entity!.account = account
        }
        return entity!
    }
    
    func find( account: EntityAccount = compteCourant!, name: String) -> EntityModePaiement? {
        
        let p1 = NSPredicate(format: "account == %@", account)
        let p2 = NSPredicate(format: "name == %@", name)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])

        let fetchRequest = NSFetchRequest<EntityModePaiement>(entityName: "EntityModePaiement")
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
    
    // delete ModePaiement
    func remove(entity: EntityModePaiement)
    {
        mainObjectContext.delete(entity)
    }

    func loadModePaiement () -> NSPopUpButton {
        let  modePaiementMenu = NSMenu()
        let popModePaiement =  NSPopUpButton()
        
        var modesPaiement = getAll()
        modesPaiement = modesPaiement.sorted { $0.name! < $1.name! }
        for modePaiement in modesPaiement
        {
            modePaiementMenu.addItem(modePaiementItemFor(modePaiement) )
        }
        popModePaiement.menu = modePaiementMenu
        return popModePaiement
    }

    fileprivate func modePaiementItemFor(_ value: EntityModePaiement) -> NSMenuItem {
        let menuItem = NSMenuItem()
        menuItem.title = value.name!
        menuItem.action = nil
        menuItem.target = self
        menuItem.keyEquivalent = ""
        menuItem.representedObject = value
        menuItem.isEnabled = true
        return menuItem
    }
    
    @discardableResult
    func getAll() -> [EntityModePaiement] {
        
        do {
            let fetchRequest = NSFetchRequest<EntityModePaiement>(entityName: "EntityModePaiement")
            let predicate = NSPredicate(format: "account == %@", compteCourant!)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            fetchRequest.predicate = predicate
            
            entitiesModePaiement = try mainObjectContext.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        defaultModePaiement()
        return entitiesModePaiement
    }
    
    func defaultModePaiement()
    {
        if entitiesModePaiement.count == 0 {
            let modePaiement1 = EntityModePaiement(context: mainObjectContext)
            modePaiement1.name = Localizations.ModePaiement.Bank_Card
            modePaiement1.color = NSColor.green
            modePaiement1.account = compteCourant
            modePaiement1.uuid = UUID()
            
            let modePaiement2 = EntityModePaiement(context: mainObjectContext)
            let name = Localizations.ModePaiement.Cheque
            modePaiement2.name = name
            modePaiement2.color = NSColor.yellow
            modePaiement2.account = compteCourant
            modePaiement2.uuid = UUID()
            
            let modePaiement3 = EntityModePaiement(context: mainObjectContext)
            modePaiement3.name = Localizations.ModePaiement.Especes
            modePaiement3.color = NSColor.blue
            modePaiement3.account = compteCourant
            modePaiement3.uuid = UUID()
            
            let modePaiement4 = EntityModePaiement(context: mainObjectContext)
            modePaiement4.name = Localizations.ModePaiement.Prelevement
            modePaiement4.color = NSColor.red
            modePaiement4.account = compteCourant
            modePaiement4.uuid = UUID()
            
            let modePaiement5 = EntityModePaiement(context: mainObjectContext)
            modePaiement5.name = Localizations.ModePaiement.Remise
            modePaiement5.color = NSColor.gray
            modePaiement5.account = compteCourant
            modePaiement5.uuid = UUID()
            
            let modePaiement6 = EntityModePaiement(context: mainObjectContext)
            modePaiement6.name = Localizations.ModePaiement.RetraitEspeces
            modePaiement6.color = NSColor.orange
            modePaiement6.account = compteCourant
            modePaiement6.uuid = UUID()
            
            let modePaiement8 = EntityModePaiement(context: mainObjectContext)
            modePaiement8.name = Localizations.ModePaiement.Virement
            modePaiement8.color = NSColor.brown
            modePaiement8.account = compteCourant
            modePaiement8.uuid = UUID()
            
            do {
                let fetchRequest = NSFetchRequest<EntityModePaiement>(entityName: "EntityModePaiement")
                let predicate = NSPredicate(format: "account == %@", compteCourant!)
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
                fetchRequest.predicate = predicate
                
                entitiesModePaiement = try mainObjectContext.fetch(fetchRequest)
            } catch {
                print("Error fetching data from CoreData")
            }
        }
    }
}
