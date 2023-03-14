//
//  BankStatement.swift
//  Pegase
//
//  Created by thierryH24 on 29/10/2021.
//

import Cocoa
import Quartz

import PDFKit

class BankStatementModalWindowController: NSWindowController, DragViewDelegate {

    @IBOutlet weak var dragView: DragView!
    
    @IBOutlet weak var dateDebut: NSDatePicker!
    @IBOutlet weak var dateFin: NSDatePicker!
    @IBOutlet weak var dateInter: NSDatePicker!
    @IBOutlet weak var dateCB: NSDatePicker!

    @IBOutlet weak var soldeInitial: NSTextField!
    @IBOutlet weak var soldeInter: NSTextField!
    @IBOutlet weak var soldeFinal: NSTextField!
    @IBOutlet weak var soldeCB: NSTextField!

    @IBOutlet weak var namePDF: NSTextField!
    
    @IBOutlet weak var reference: NSTextField!

    @IBOutlet weak var modeOperation: NSButton!
    
    var entityBankStatement : EntityBankStatement?
    var edition = false
    
    @IBOutlet var pdfView: PDFView!
    @IBOutlet weak var thumbs: PDFThumbnailView!
    
    var pdf: PDFDocument!
    var pdfName = ""

    override var windowNibName: NSNib.Name? {
        return "BankStatementModalWindowController"
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        // Do view setup here.
        
        self.pdfView.autoresizingMask = [.width, .height]
        self.pdfView.autoScales = true
        
        dragView.delegate = self
        self.reset()
    }
    
    @IBAction func didTapCancelButton(_ sender: NSButton) {
        
        self.entityBankStatement =  nil
        window?.sheetParent?.endSheet(window!, returnCode: .cancel)
        self.window!.close()
    }
        
    @IBAction func didTapDoneButton(_ sender: NSButton) {
        
        window?.sheetParent?.endSheet(window!, returnCode: .OK)
        self.window!.close()
    }
    
    func reset() {
        
        dateDebut.dateValue      = entityBankStatement?.dateDebut ?? Date()
        dateFin.dateValue        = entityBankStatement?.dateFin ?? Date()
        dateInter.dateValue      = entityBankStatement?.dateInter ?? Date()
        dateCB.dateValue         = entityBankStatement?.dateCB ?? Date()

        soldeInitial.doubleValue = entityBankStatement?.soldeDebut ?? 0.0
        soldeInter.doubleValue   = entityBankStatement?.soldeInter ?? 0.0
        soldeFinal.doubleValue   = entityBankStatement?.soldeFin ?? 0.0
        soldeCB.doubleValue      = entityBankStatement?.soldeCB ?? 0.0

        reference.doubleValue    = entityBankStatement?.number ?? 0.0
    }
    
    func resetPref() {
        
        dateDebut.dateValue      = entityBankStatement?.dateFin ?? Date()
        soldeInitial.doubleValue = entityBankStatement?.soldeFin ?? 0.0

        dateInter.dateValue      = entityBankStatement?.dateInter ?? Date()
        soldeInter.doubleValue   = entityBankStatement?.soldeInter ?? 0.0

        dateFin.dateValue        = entityBankStatement?.dateFin ?? Date()
        soldeFinal.doubleValue   = entityBankStatement?.soldeFin ?? 0.0

        dateCB.dateValue         = entityBankStatement?.dateCB ?? Date()
        soldeCB.doubleValue      = entityBankStatement?.soldeCB ?? 0.0

        reference.doubleValue    = entityBankStatement!.number + 1.0
    }

    func dragViewDidReceive(fileURLs: [URL])
    {
        if let firstPdfFileURL = fileURLs.first
        {
            self.pdf = PDFDocument(url: firstPdfFileURL)

            pdfView.document = self.pdf
            self.pdfView.autoScales = true
            self.pdfName = firstPdfFileURL.lastPathComponent
            self.namePDF.stringValue = pdfName
        }
    }
}
