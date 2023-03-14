    //
    //  ListBankStatementControllerAction.swift
    //  Pegase
    //
    //  Created by thierryH24 on 30/10/2021.
    //

import Cocoa
import PDFKit

extension ListBankStatementController  {
    
    @objc func doubleClicked(_ sender: Any) {
        var url : URL
        
        let selectedRow = self.tableBankStatement!.selectedRow
        guard selectedRow != -1 else { return }
        
        if let pdfDoc = entityBankStatements[selectedRow].pdfDoc {
            
            let name = entityBankStatements[selectedRow].pdfName!
            url = savePdf(name: name, data: pdfDoc)
            let task = Process.launchedProcess(launchPath: "/usr/bin/open", arguments: [
                "-a",
                "Preview",
                url.absoluteString
            ])
            task.waitUntilExit()
            if task.terminationStatus == 0 {

                fileDelete(filePath: url)
            }
        }
        else {
            editBankStatement( tableBankStatement! )
        }
    }
    
    fileprivate func savePdf(name: String, data: Data)-> URL {
        
        guard let directoryURl = getFilePath(name: name) else {
            print("Pdf save error")
            return URL(fileURLWithPath: "")
        }
        
        let fileURL = directoryURl.appendingPathComponent("\(name)")
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print(error.localizedDescription)
        }
        return fileURL
    }
    
    fileprivate func fileDelete(filePath : URL) {
        
        do {
            let fileManager = FileManager.default

                // Check if file exists
            if fileManager.fileExists(atPath: filePath.path) == true {
                    // Delete file
                try fileManager.removeItem(at: filePath)
            } else {
                print("File does not exist")
            }
        }
        catch let error as NSError {
            print("An error took place: \(error.localizedDescription)")
        }
    }
    
    fileprivate func getFilePath(name: String ) -> URL? {
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryURl = documentDirectoryURL.appendingPathComponent(name, isDirectory: true)
        
        if FileManager.default.fileExists(atPath: directoryURl.path) {
            return directoryURl
        } else {
            do {
                try FileManager.default.createDirectory(at: directoryURl, withIntermediateDirectories: true, attributes: nil)
                return directoryURl
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
    }
    
    @IBAction func addBankStatement(_ sender: Any) {
        
        let context = mainObjectContext
        
        self.bankStatementModalWindowController = BankStatementModalWindowController()
        
        let windowAdd = bankStatementModalWindowController.window!
        let windowApp = self.view.window
        
        
        let entityMode = entityBankStatements.last ?? nil
        bankStatementModalWindowController.dateDebut.dateValue = entityMode?.dateFin ?? Date()
        bankStatementModalWindowController.soldeInitial.doubleValue = entityMode?.soldeFin ?? 0.0
        bankStatementModalWindowController.reference.doubleValue    = (entityMode?.number ?? -1.0) + 1.0

        windowApp?.beginSheet( windowAdd, completionHandler: {(_ returnCode: NSApplication.ModalResponse) -> Void in
            
            switch returnCode {
            case .OK:
                
                let entityBankStatement = NSEntityDescription.insertNewObject(forEntityName: "EntityBankStatement", into: context!) as! EntityBankStatement
                
                entityBankStatement.dateDebut = self.bankStatementModalWindowController.dateDebut.dateValue
                entityBankStatement.dateFin = self.bankStatementModalWindowController.dateFin.dateValue
                entityBankStatement.dateInter = self.bankStatementModalWindowController.dateInter.dateValue
                entityBankStatement.dateCB = self.bankStatementModalWindowController.dateCB.dateValue
                
                entityBankStatement.soldeDebut =  self.bankStatementModalWindowController.soldeInitial.doubleValue
                entityBankStatement.soldeInter =  self.bankStatementModalWindowController.soldeInter.doubleValue
                entityBankStatement.soldeFin =  self.bankStatementModalWindowController.soldeFinal.doubleValue
                entityBankStatement.soldeCB =  self.bankStatementModalWindowController.soldeCB.doubleValue
                
                let ref = self.bankStatementModalWindowController.reference.doubleValue
                entityBankStatement.number = ref
                
                entityBankStatement.pdfDoc     = self.bankStatementModalWindowController.pdf?.dataRepresentation()
                entityBankStatement.pdfName     = self.bankStatementModalWindowController.pdfName

                entityBankStatement.uuid =  UUID()
                entityBankStatement.account = currentAccount

            case .cancel:
                break

            default:
                break
            }
            self.bankStatementModalWindowController = nil
            self.updateData()
        })
    }
    
    @IBAction func editBankStatement(_ sender: Any) {
        
        var selectRow = sender as? Int
        if selectRow == nil {
            selectRow = tableBankStatement.selectedRow
            guard selectRow != -1 else { return }
        }
            
        let entityMode = entityBankStatements[ selectRow!]
        
        self.bankStatementModalWindowController = BankStatementModalWindowController()
        bankStatementModalWindowController.edition = true
        let windowAdd = bankStatementModalWindowController.window!
        
        bankStatementModalWindowController.dateDebut.dateValue = entityMode.dateDebut ?? Date()
        bankStatementModalWindowController.dateInter.dateValue = entityMode.dateInter ?? Date()
        bankStatementModalWindowController.dateFin.dateValue = entityMode.dateFin ?? Date()
        bankStatementModalWindowController.dateCB.dateValue = entityMode.dateCB ?? Date()
        
        self.bankStatementModalWindowController.soldeInitial.doubleValue =   entityMode.soldeDebut
        self.bankStatementModalWindowController.soldeInter.doubleValue =   entityMode.soldeInter
        self.bankStatementModalWindowController.soldeFinal.doubleValue = entityMode.soldeFin
        self.bankStatementModalWindowController.soldeCB.doubleValue = entityMode.soldeCB
        
        self.bankStatementModalWindowController.namePDF.stringValue = entityMode.pdfName ?? ""

        self.bankStatementModalWindowController.reference.doubleValue = entityMode.number
        if let dataPDF = entityMode.pdfDoc {
            let data = PDFDocument(data: dataPDF)
            self.bankStatementModalWindowController.pdfView.document = PDFDocument(data:  (data?.dataRepresentation())! )
        }
        
        let windowApp = self.view.window
        windowApp?.beginSheet( windowAdd, completionHandler: {(_ returnCode: NSApplication.ModalResponse) -> Void in
            
            switch returnCode {
            case .OK:
                entityMode.dateDebut  = self.bankStatementModalWindowController.dateDebut.dateValue
                entityMode.dateInter  = self.bankStatementModalWindowController.dateInter.dateValue
                entityMode.dateFin    = self.bankStatementModalWindowController.dateFin.dateValue
                entityMode.dateCB     = self.bankStatementModalWindowController.dateCB.dateValue
                
                entityMode.soldeDebut =  self.bankStatementModalWindowController.soldeInitial.doubleValue
                entityMode.soldeInter =  self.bankStatementModalWindowController.soldeInter.doubleValue
                entityMode.soldeFin   =  self.bankStatementModalWindowController.soldeFinal.doubleValue
                entityMode.soldeCB    =  self.bankStatementModalWindowController.soldeCB.doubleValue
                
                entityMode.number     = self.bankStatementModalWindowController.reference.doubleValue
                if let data =  self.bankStatementModalWindowController.pdf {
                    entityMode.pdfDoc     = data.dataRepresentation()
                    entityMode.pdfName = self.bankStatementModalWindowController.pdfName 
                }

            case .cancel:
                break
                
            default:
                break
            }
            self.bankStatementModalWindowController = nil
            self.updateData()
        })
    }
    
    @IBAction func removeBankStatement(_ sender: Any) {
              
        let selectRow = tableBankStatement.selectedRow
        guard selectRow != -1 else { return }
        
        let entity = entityBankStatements[ selectRow]
        print("Document 🗑")
        BankStatement.shared.remove(entity: entity)
        updateData()
    }
    
    @IBAction  func printBankStatement(_ sender: Any) {
        
        let view = tableBankStatement
        
        let headerLine = "List Bank Statement"
        
        let printOpts: [NSPrintInfo.AttributeKey: Any] = [.headerAndFooter: true, .orientation: 0]
        let printInfo = NSPrintInfo(dictionary: printOpts)
        
        printInfo.leftMargin = 20
        printInfo.rightMargin = 20
        printInfo.topMargin = 40
        printInfo.bottomMargin = 20
        
        printInfo.horizontalPagination = .fit
        printInfo.verticalPagination = .automatic
        
        printInfo.scalingFactor = 1.0
        printInfo.paperSize = NSSize(width: 595, height: 842)
        
        let myPrintView = MyPrintViewTable(tableView: view, andHeader: headerLine)
        
        let printBankStatement = NSPrintOperation(view: myPrintView, printInfo: printInfo)
        printBankStatement.printPanel.options.insert(NSPrintPanel.Options.showsPaperSize)
        printBankStatement.printPanel.options.insert(NSPrintPanel.Options.showsOrientation)
        
        printBankStatement.showsPrintPanel = true
        printBankStatement.run()
        printBankStatement.cleanUp()
    }
}
