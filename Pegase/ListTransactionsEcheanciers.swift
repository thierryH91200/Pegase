import AppKit
import SwiftDate

extension ListTransactionsController: NSDatePickerCellDelegate {
    
    func datePickerCell(_ datePickerCell: NSDatePickerCell,
                        validateProposedDateValue proposedDateValue: AutoreleasingUnsafeMutablePointer<NSDate>,
                        timeInterval proposedTimeInterval: UnsafeMutablePointer<TimeInterval>?) {
        
        guard datePicker.isEnabled == true else { return }
        guard currentAccount != nil else { return }
        
        let proposedDate = proposedDateValue.pointee as Date
        guard proposedDate != datePicker.dateValue else { return }
        
        let entityEcheanciers = Echeanciers.shared.getAllDatas()
        
        for entitySchedule in entityEcheanciers {
            var dateValeur =  entitySchedule.dateValeur!
            let frequence = Int(entitySchedule.frequence)
            
            while dateValeur < proposedDate {
                switch entitySchedule.typeFrequence
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
                }
                entitySchedule.nextOccurence += 1
                Echeanciers.shared.createOperation(entitySchedule: entitySchedule, dateValeur: dateValeur)
            }
            entitySchedule.dateValeur = dateValeur
        }
        
        getAllData()
        reloadData(false)
        currentAccount?.dateEcheancier = proposedDate
    }
    
}
