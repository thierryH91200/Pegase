import AppKit
import SwiftDate

extension ListeOperationsController: NSDatePickerCellDelegate {
    
    func datePickerCell(_ datePickerCell: NSDatePickerCell,
                        validateProposedDateValue proposedDateValue: AutoreleasingUnsafeMutablePointer<NSDate>,
                        timeInterval proposedTimeInterval: UnsafeMutablePointer<TimeInterval>?) {
        
        guard datePicker.isEnabled == true else { return }
        
        let proposedDate = proposedDateValue.pointee as Date
        guard proposedDate != datePicker.dateValue else { return }
        
        let entityEcheanciers = Echeanciers.shared.getAll()
        
        for entityEcheancier in entityEcheanciers {
            var dateValeur =  entityEcheancier.dateValeur!
            let frequence = Int(entityEcheancier.frequence)
            
            while dateValeur < proposedDate {
                switch entityEcheancier.typeFrequence
                {
                case 0:
                    dateValeur = dateValeur + frequence.days
                
                case 1:
                    dateValeur = dateValeur + frequence.weeks
                
                case 2:
                    dateValeur = dateValeur + frequence.months
                
                case 3:
                    dateValeur = dateValeur + frequence.years
                
                default:
                    print("what ????")
                    break
                }
                entityEcheancier.nextOccurence += 1
                Echeanciers.shared.createOperation(entityEcheancier: entityEcheancier, dateValeur: dateValeur)
            }
            entityEcheancier.dateValeur = dateValeur
        }
        
        print("datePickerCell")
        getAllData()
        reloadData()
        compteCourant?.dateEcheancier = proposedDate
    }
    
}
