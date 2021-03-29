/**
 @file      ExtensionTableView.swift
 @author    thierryH24
 @date      10/01/2018

 Copyright 2018 thierryH24

*/

import AppKit


class KSTableCellView2: NSTableCellView {
    
    @IBOutlet weak var objectif: NSTextField!
}

class KSHeaderCellView3: NSTableCellView {
    
    @IBOutlet weak var colorWell: NSColorWell!
    @IBOutlet weak var total: NSTextField!
}

class KSHeaderCellView4: NSTableCellView {
    
    @IBOutlet weak var colorWell: NSColorWell!
}

class KSStatutCellView: NSTableCellView {
    @IBOutlet weak var statutPopup: NSPopUpButton?
}


