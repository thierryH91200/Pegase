import AppKit

final class SourceListCellView: NSTableCellView {
    
    @IBOutlet weak var nbCompte: NSTextField!
    @IBOutlet weak var inLine: NSButton!
}

final class CompteListCellView: NSTableCellView {
    
    @IBOutlet weak var titulaire: NSTextField!
    @IBOutlet weak var numCompte: NSTextField!
    @IBOutlet weak var inLine: NSButton!
}
