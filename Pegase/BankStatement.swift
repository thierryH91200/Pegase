//
//  BankStatement.swift
//  Pegase
//
//  Created by thierryH24 on 22/04/2021.
//  Copyright © 2021 thierry hentic. All rights reserved.
//

import Cocoa

final class BankStatement: NSViewController {
    
    @IBOutlet weak var tableBankStatement: NSTableView!
    
    
    public override func viewDidDisappear()
    {
        super.viewDidDisappear()
        NotificationCenter.default.removeObserver(self, name: .updateAccount, object: nil)
    }

    override public func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "Bank Statement"
    }
    
    override public func viewWillAppear()
    {
        super.viewWillAppear()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tableBankStatement.autosaveName = "saveBankStatement"
        tableBankStatement.autosaveTableColumns = true
        
    }
    
}
