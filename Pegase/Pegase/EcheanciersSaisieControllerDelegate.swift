import AppKit
import SwiftDate


extension EcheanciersSaisieController: EcheanciersSaisieDelegate {
    
    func editionData(_ quake: EntityEcheancier) {
        edition = true
        modeOperation.title = Localizations.Operation.ModeEdition
        modeOperation.layer?.backgroundColor = NSColor.green.cgColor
        
        modeOperation2.title = Localizations.Operation.ModeEdition
        modeOperation2.layer?.backgroundColor = NSColor.green.cgColor
        
        entityEcheancier = quake
        
        libelle.stringValue = entityEcheancier?.libelle ?? ""
        libelle.becomeFirstResponder()
        
        dateValeur.dateValue = (entityEcheancier?.dateValeur)!
        dateDebut.dateValue = (entityEcheancier?.dateDebut)!
        dateFin.dateValue = (entityEcheancier?.dateFin)!
        occurence.intValue = Int32((entityEcheancier?.occurence)!)
        frequence.intValue = Int32((entityEcheancier?.frequence)!)
        popUpFrequence.selectItem(at: Int(entityEcheancier?.typeFrequence ?? 0))
        
        let rubrique = popUpRubrique.itemTitle(at: 0)
        popUpRubrique.selectItem(withTitle: (entityEcheancier?.category?.rubrique?.name ?? rubrique)!)
        if popUpRubrique.indexOfSelectedItem == -1 {
            popUpRubrique.selectItem(at: 0)
        }
        
        loadCategory()
        popUpCategorie.selectItem(withTitle: (entityEcheancier?.category?.name ?? "")!)
        if popUpCategorie.indexOfSelectedItem == -1 {
            popUpCategorie.selectItem(at: 0)
        }
        
        let mode = popUpModePaiement.itemTitle(at: 0)
        popUpModePaiement.selectItem(withTitle: (entityEcheancier?.modePaiement?.name ?? mode)!)
        
        let valeurMontant = entityEcheancier?.amount ?? 0.0
        montant.textColor = valeurMontant < 0 ? NSColor.red : NSColor.green
        montant.doubleValue = abs(valeurMontant)
        signeMontant.state = valeurMontant < 0 ? .on : .off
        
        popUpTransfert.selectItem(withTitle: entityEcheancier?.compteLie?.initCompte?.codeCompte ?? "(no transfert)")
        
        becomeFirstResponder()
//        resignFirstResponder()
    }
    
    func razData()
    {
        entityPreference = Preference.shared.getAll()
        
        edition = false
        modeOperation.title = Localizations.Operation.ModeCreation
        modeOperation.layer?.backgroundColor = NSColor.orange.cgColor
        
        modeOperation2.title = Localizations.Operation.ModeCreation
        modeOperation2.layer?.backgroundColor = NSColor.orange.cgColor
        
        account.stringValue = (compteCourant?.name)!
        name.stringValue = (compteCourant?.identite?.idName)!
        surname.stringValue = (compteCourant?.identite?.idPrenom)!
        number.stringValue = (compteCourant?.initCompte?.codeCompte)!
        
        loadCompte()
        popUpTransfert.itemTitle(at: 0)
        
        loadRubrique()
        popUpRubrique.selectItem(withTitle: (entityPreference?.category?.rubrique?.name)!)
        
        loadCategory()
        popUpCategorie.selectItem(withTitle: (entityPreference?.category?.name)!)
        
        loadModePaiement()
        popUpModePaiement.selectItem(withTitle: (entityPreference?.modePaiement?.name)!)
        
        libelle.stringValue = ""
        
        popUpFrequence.selectItem(at: 2)
        dateDebut.dateValue = Date()
        dateFin.dateValue = Date() + 12.months
        dateValeur.dateValue = Date()
        frequence.intValue = 1
        occurence.intValue = 12
        
        montant.doubleValue = 0.0
        montant.textColor = NSColor.systemGreen
        signeMontant.state = entityPreference?.signe == true ? .on : .off
    }

}

