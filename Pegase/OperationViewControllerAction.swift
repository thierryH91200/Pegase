//
//  OperationViewControllerAction.swift
//  Pegase
//
//  Created by thierry hentic on 18/09/2019.
//  Copyright © 2019 thierryH24. All rights reserved.
//

import AppKit

extension OperationViewController  {
    
    @IBAction func annulerAction(_ sender: Any) {
        self.resetOperation()
    }
    
    @IBAction func addSousOperation(_ sender: Any) {
        
        var entitySousOperation = EntitySousOperations(context: mainObjectContext)
        
        self.sousOperationModalWindowController = SousOperationModalWindowController()
        self.sousOperationModalWindowController.entitySousOperation = entitySousOperation
        
        let windowAdd = sousOperationModalWindowController.window!
        let windowApp = self.view.window
        windowApp?.beginSheet( windowAdd, completionHandler: {(_ returnCode: NSApplication.ModalResponse) -> Void in
            
            switch returnCode {
            case .OK:
                
                self.addView.isHidden = true
                
                entitySousOperation = self.sousOperationModalWindowController.entitySousOperation!
                self.sousOperations.append(entitySousOperation)
                self.buttonSave.isEnabled = true
                self.outlineViewSSOpe.reloadData()
                                
                self.calcAmount()
                
                self.updateChartData()
                self.setDataCount()
                                
            case .cancel:
                break
                
            default:
                break
            }
            self.sousOperationModalWindowController = nil
        })
        
    }
    
    @IBAction func editSubOperation(_ sender: Any) {
        
        let selectRow = outlineViewSSOpe.selectedRow
        guard selectRow != -1 else { return }
        let item = outlineViewSSOpe.item(atRow: selectRow) as? EntitySousOperations
        
        print(item?.category?.name ?? "category?.name")
        print(item?.category?.rubrique?.name ?? "rubrique?.name")
        
        self.sousOperationModalWindowController = SousOperationModalWindowController()
        self.sousOperationModalWindowController.entitySousOperation = item
        self.sousOperationModalWindowController.edition = true
        
        let windowAdd = self.sousOperationModalWindowController.window!
        let windowApp = self.view.window
        windowApp?.beginSheet( windowAdd, completionHandler: {(_ returnCode: NSApplication.ModalResponse) -> Void in
            
            switch returnCode {
            case .OK:
                
                let entitySousOperation = self.sousOperationModalWindowController.entitySousOperation!
                self.entityOperations.first?.removeFromSousOperations(item!)
                self.entityOperations.first?.addToSousOperations(entitySousOperation)
                self.sousOperations = self.entityOperations.first?.sousOperations?.allObjects as! [EntitySousOperations]
                self.outlineViewSSOpe.reloadData()

                self.calcAmount()
                
                self.updateChartData()
                self.setDataCount()

            case .cancel:
                break
                
            default:
                break
            }
            self.sousOperationModalWindowController = nil
        })
        
    }
    
    @IBAction func removeSubOperation(_ sender: Any) {
        
        let selectRow = outlineViewSSOpe.selectedRow
        guard selectRow != -1 else { return }
        
        let alert = NSAlert()
        alert.messageText = Localizations.GroupeCompte.RemoveAlert.MessageText
        alert.informativeText = Localizations.GroupeCompte.RemoveAlert.InformativeText
        alert.addButton(withTitle: Localizations.GroupeCompte.RemoveAlert.Delete)
        alert.addButton(withTitle: Localizations.GroupeCompte.RemoveAlert.Cancel)
        alert.alertStyle = .informational
        
        alert.beginSheetModal(for: self.outlineViewSSOpe.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                
                print("Document 🗑")
                self.deleteSelection()
                
                if self.sousOperations.count == 0 {
                    self.buttonSave.isEnabled = false
                }
                
                self.outlineViewSSOpe.reloadData()
                self.outlineViewSSOpe.expandItem(nil, expandChildren: true)
                self.outlineViewSSOpe.selectRowIndexes([1], byExtendingSelection: false)
                
                self.calcAmount()
                
                self.updateChartData()
                self.setDataCount()
            }
        })
    }
    
    func deleteSelection() {
        
        let selected = outlineViewSSOpe.selectedRowIndexes
        
        let sourceListItems = selected.map({ return outlineViewSSOpe.item(atRow: $0) })
        for item in sourceListItems {
            
            let entitie = item as! EntitySousOperations
            mainObjectContext.delete(entitie)
        }
        self.outlineViewSSOpe.reloadData()
    }
    
    
    @IBAction func simpleClickedItem(_ sender: NSOutlineView) {
        //1
        let item = sender.item(atRow: sender.clickedRow)
        
        //2
        if item is EntitySousOperations {
            //3
            if sender.isItemExpanded(item) {
                sender.collapseItem(item)
            } else {
                sender.expandItem(item)
            }
        }
    }
    
    func calcAmount() {
        var amount = 0.0
        for sousOperation in self.sousOperations {
            amount += sousOperation.amount
        }
        
        self.textFieldMontant.doubleValue = abs(amount)
        self.textFieldMontant.placeholderString = ""
        self.textFieldMontant.textColor = amount < 0 ? NSColor.red : NSColor.green
        
    }
}
