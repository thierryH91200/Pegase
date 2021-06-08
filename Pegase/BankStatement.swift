//
//  BankStatement.swift
//  Pegase
//
//  Created by thierryH24 on 22/04/2021.
//  Copyright © 2021 thierry hentic. All rights reserved.
//

import Cocoa
import PDFKit


final class BankStatement: NSViewController {
    
    @IBOutlet weak var tableBankStatement: NSTableView!
    @IBOutlet weak var noPdfFilesContainerView: DragView!
    @IBOutlet weak var pdfFilesContainerView: NSView!
    @IBOutlet weak var pdfFileListTableView: NSTableView!
    @IBOutlet weak var pdfPreviewView: PDFView!

    
    let pasteboardType = NSPasteboard.PasteboardType(rawValue: "bindPDF.url")
    var urls: [URL] = []

    public override func viewDidDisappear()
    {
        super.viewDidDisappear()
        NotificationCenter.remove(instance: self, name: .updateAccount)
    }

    override public func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Bank Statement"
    }
    
//    override public func viewWillAppear()
//    {
//        super.viewWillAppear()
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do view setup here.
//        
//        let id = currentAccount?.uuid.uuidString
//        self.pdfFileListTableView.autosaveName = "saveBankStatement" + (id)!
//        self.pdfFileListTableView.autosaveTableColumns = true
//        
//        pdfFilesContainerView.isHidden = true
//        pdfFileListTableView.delegate = self
//        pdfFileListTableView.dataSource = self
//        pdfFileListTableView.registerForDraggedTypes([pasteboardType])
//
//    }
//    
//    @IBAction func addButton(_ sender: NSButton) {
//        let openPanel = NSOpenPanel()
//        openPanel.allowedFileTypes = ["pdf", "PDF"]
//        openPanel.allowsMultipleSelection = true
//        openPanel.canChooseDirectories = false
//        openPanel.canCreateDirectories = false
//        openPanel.canChooseFiles = true
//        openPanel.beginSheetModal(for: self.view.window!) { (response) in
//            if response == .OK {
//                for url in openPanel.urls {
//                    self.urls.append(url)
//                }
//            }
//            
//            self.pdfFileListTableView.reloadData()
//            openPanel.close()
//            self.reloadLivePreview()
//        }
//    }
//    
//    func reorderFile(at: Int, to: Int) {
//        pdfFileListTableView.delegate = nil
//        urls.insert(urls.remove(at: at), at: to)
//        pdfFileListTableView.delegate = self
//        
//        reloadLivePreview()
//    }
//
//    func reloadLivePreview() {
//        pdfFilesContainerView.isHidden = urls.count == 0
//        noPdfFilesContainerView.isHidden = urls.count != 0
//        
//        if urls.count == 0 {
//            return
//        }
//        
//        var pageIndex = 0
//        let previewDocument = PDFDocument()
//        
//        for url in urls {
//            if let document = PDFDocument(url: url) {
//                for pageNumber in 1...document.pageCount {
//                    if let page = document.page(at: pageNumber - 1) {
//                        previewDocument.insert(page, at: pageIndex)
//                        pageIndex += 1
//                    }
//                }
//            }
//        }
//        
//        pdfPreviewView.document = previewDocument
//    }
//}
//
//extension BankStatement: NSTableViewDataSource {
//    func numberOfRows(in tableView: NSTableView) -> Int {
//        return urls.count
//    }
//    
//    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
//        let url = urls[row]
//        let pasteboardItem = NSPasteboardItem()
//        pasteboardItem.setString(url.path, forType: pasteboardType)
//        return pasteboardItem
//    }
//    
//    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
//        if dropOperation == .above {
//            return .move
//        } else {
//            return []
//        }
//    }
//    
//    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
//        guard
//            let item = info.draggingPasteboard.pasteboardItems?.first,
//            let theString = item.string(forType: pasteboardType),
//            let url = urls.first(where: { $0.path == theString }),
//            let originalRow = urls.firstIndex(of: url)
//            else {
//                return false
//            }
//        
//        var newRow = row
//        if originalRow < newRow {
//            newRow = row - 1
//        }
//        
//        // Animate the rows
//        pdfFileListTableView.beginUpdates()
//        pdfFileListTableView.moveRow(at: originalRow, to: newRow)
//        pdfFileListTableView.endUpdates()
//        
//        // Update the data model
//        reorderFile(at: originalRow, to: newRow)
//        
//        return true
//    }
//}
//
//extension BankStatement: NSTableViewDelegate {
//    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//        let url = urls[row]
//        if let cell = pdfFileListTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "defaultCell"), owner: nil) as? NSTableCellView {
//            cell.textField?.stringValue = url.lastPathComponent
//            cell.textField?.maximumNumberOfLines = 4
//
//            let pdfDocument = PDFDocument(url: url)
//            if let firstPage = pdfDocument?.page(at: 0) {
//                cell.imageView?.image = firstPage.thumbnail(of: NSSize(width: 256, height: 256), for: .artBox)
//            }
//            
//            return cell
//        }
//        
//        return nil
//    }
//    
//    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
//        let action = NSTableViewRowAction(style: .destructive, title: "Delete") { (action, row) in
//            self.urls.remove(at: row)
//            self.pdfFileListTableView.removeRows(at: IndexSet(integer: row), withAnimation: .effectFade)
//            self.reloadLivePreview()
//        }
//        return [action]
//    }
}


import Cocoa


@objc protocol DragViewDelegate
{
    func dragViewDidReceive(fileURLs: [URL])
}

class DragView: NSView
{
    @IBOutlet weak var delegate: DragViewDelegate?
    let fileExtensions = ["pdf"]


    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        color(to: .clear)
        registerForDraggedTypes([.fileURL])
    }

    override func draggingEntered(_ draggingInfo: NSDraggingInfo) -> NSDragOperation
    {
        var containsMatchingFiles = false
        draggingInfo.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil)?.forEach
        {
            eachObject in
            if let eachURL = eachObject as? URL
            {
                containsMatchingFiles = containsMatchingFiles || fileExtensions.contains(eachURL.pathExtension.lowercased())
                if containsMatchingFiles { print(eachURL.path) }
            }
        }

        switch (containsMatchingFiles)
        {
            case true:
                color(to: .secondaryLabelColor)
                return .copy
            case false:
                color(to: .disabledControlTextColor)
                return .init()
        }
    }

    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool
    {
        // Collect URLs.
        var matchingFileURLs: [URL] = []
        draggingInfo.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil)?.forEach
        {
            eachObject in
            if
                let eachURL = eachObject as? URL,
                fileExtensions.contains(eachURL.pathExtension.lowercased())
            { matchingFileURLs.append(eachURL) }
        }

        // Only if any,
        guard matchingFileURLs.count > 0
        else { return false }

        // Pass to delegate.
        delegate?.dragViewDidReceive(fileURLs: matchingFileURLs)
        return true
    }

    override func draggingExited(_ sender: NSDraggingInfo?)
    { color(to: .clear) }

    override func draggingEnded(_ sender: NSDraggingInfo)
    { color(to: .clear) }

}


extension DragView
{
    func color(to color: NSColor)
    {
        self.wantsLayer = true
        self.layer?.backgroundColor = color.cgColor
    }
}
