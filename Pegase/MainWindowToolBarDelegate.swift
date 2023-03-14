//
//  MainWindowToolBarDelegate.swift
//  Pegase
//
//  Created by colombe on 25/05/2022.
//

import AppKit



// MARK: - Toolbar Delegate

extension MainWindowController: NSToolbarDelegate
{
    
    
    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem?
    {
        //  macOS 11: A rounded square appears behind the icon on mouse-over
        //  macOS X : The item has the appearance of an NSButton (button frame)
        //            If false, it's just a free-standing icon as they appear
        //            in typical Preferences windows with toolbars.
        
        let isBordered = true
        
        switch itemIdentifier {
            
        case .print:
            let print = NSToolbarItem(itemIdentifier: itemIdentifier)
            print.isEnabled = true
            return print
            
            
        case .toolbarColorItem:
            let toolbarItem = NSMenuToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.showsIndicator = true // Make `false` if you don't want the down arrow to be drawn
            toolbarItem.menu = self.colorMenu
            toolbarItem.label = "color Menu"
            toolbarItem.paletteLabel = "color Menu"
            toolbarItem.toolTip = "color Menu"
            toolbarItem.isBordered = isBordered
            if  #available(macOS 11.0, *) {
                toolbarItem.image = NSImage(named: NSImage.colorPanelName)
            } else {
                toolbarItem.image = NSImage(named: NSImage.colorPanelName)
            }
            return toolbarItem
            
        case .toolbarItemCalc:
            let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.target = self
            toolbarItem.action = #selector(LaunchCalc(_:))
            toolbarItem.label = "Calc"
            toolbarItem.paletteLabel = "Calc"
            toolbarItem.toolTip = "Launch calc"
            toolbarItem.visibilityPriority = .low
            toolbarItem.isBordered = isBordered
            if  #available(macOS 11.0, *) {
                toolbarItem.image = NSImage(systemSymbolName: "function", accessibilityDescription: "")
            } else {
                toolbarItem.image = NSImage(named: NSImage.userAccountsName)
            }
            return toolbarItem
            
        case .toolbarItemPreference:
            let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.target = self
            toolbarItem.action = #selector(showPreference(_:))
            toolbarItem.label = "Preference"
            toolbarItem.paletteLabel = "Preference"
            toolbarItem.toolTip = "Open Preference"
            toolbarItem.visibilityPriority = .low
            toolbarItem.isBordered = isBordered
            if  #available(macOS 11.0, *) {
                toolbarItem.image = NSImage(systemSymbolName: "switch.2", accessibilityDescription: "")
            } else {
                toolbarItem.image = NSImage(named: NSImage.preferencesGeneralName)
            }
            return toolbarItem
            
        case .toolbarSearch:
            let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.target = self
            toolbarItem.action = #selector(AdvancedFilter(_:))
            toolbarItem.label = "Search"
            toolbarItem.paletteLabel = "Search"
            toolbarItem.toolTip = "Seearch"
            toolbarItem.isBordered = isBordered
            toolbarItem.visibilityPriority = .low
            if  #available(macOS 11.0, *) {
                toolbarItem.image = NSImage(systemSymbolName: "magnifyingglass", accessibilityDescription: "")
            } else {
                toolbarItem.image = NSImage(named: NSImage.infoName)
            }
            return toolbarItem
            
        case .toolbarLightDarItem:
            let titles = ["Light", "Dark"]
            
            // This will either be a segmented control or a drop down depending
            // on your available space.
            //
            // NOTE: When you set the target as nil and use the string method
            // to define the Selector, it will go down the Responder Chain,
            // which in this app, this method is in AppDelegate. Neat!
            let toolbarItem = NSToolbarItemGroup(itemIdentifier: itemIdentifier, titles: titles, selectionMode: .selectOne, labels: titles, target: nil, action: Selector(("appearanceSelection:")) )
            
            toolbarItem.label = "Light/Dark"
            toolbarItem.paletteLabel = "View"
            toolbarItem.toolTip = "Change the appearance view"
            toolbarItem.selectedIndex = 0
            return toolbarItem
            
        case .toolbarShareButtonItem:
            let shareItem = NSSharingServicePickerToolbarItem(itemIdentifier: itemIdentifier)
            shareItem.toolTip = "Share"
            shareItem.delegate = self
            if  #available(macOS 11.0, *) {
                shareItem.menuFormRepresentation?.image = NSImage(systemSymbolName: "square.and.arrow.up", accessibilityDescription: nil)
            }
            return shareItem
            
        case  .toolbarSearchItem:
            //  `NSSearchToolbarItem` is macOS 11 and higher only
            if  #available(macOS 11.0, *) {
                let searchItem = NSSearchToolbarItem(itemIdentifier: itemIdentifier)
                searchItem.searchField.searchMenuTemplate = searchMenu
                searchField = searchItem.searchField
                (searchItem.searchField.cell as? NSSearchFieldCell)?.placeholderString = Localizations.searchMenu.title.all
                
                searchItem.resignsFirstResponderWithCancel = true
                searchItem.searchField.delegate = self
                searchItem.toolTip = "Search"
                return searchItem
            } else {
                return nil
            }

        default:
            return nil
        }
        
        
        
        //        if  itemIdentifier == NSToolbarItem.Identifier.toolbarMoreActions {
        //            let toolbarItem = NSMenuToolbarItem(itemIdentifier: itemIdentifier)
        //            toolbarItem.showsIndicator = true // Make `false` if you don't want the down arrow to be drawn
        //            toolbarItem.menu = self.colorMenu
        //            toolbarItem.label = "More Actions"
        //            toolbarItem.paletteLabel = "More Actions"
        //            toolbarItem.toolTip = "Displays available actions"
        //            toolbarItem.isBordered = isBordered
        //            if  #available(macOS 11.0, *) {
        //                toolbarItem.image = NSImage(systemSymbolName: "paintbrush", accessibilityDescription: "")
        //            } else {
        //                toolbarItem.image = NSImage(named: NSImage.advancedName)
        //            }
        //            return toolbarItem
        //        }
        
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier]
    {
        if  #available(macOS 11.0, *) {
            // The preferred toolbar style in macOS 11 takes up the left side
            // for the window title and subtitle. Let's go with a different
            // toolbar item set for this. You can change the window toolbar
            // style if you want something like macOS 10.15 or older layout.
            return [
                .toolbarSearch,
                NSToolbarItem.Identifier.toolbarItemPreference ,
                NSToolbarItem.Identifier.toolbarColorItem,
                NSToolbarItem.Identifier.print,
                NSToolbarItem.Identifier.flexibleSpace,
                NSToolbarItem.Identifier.toolbarItemCalc,
                NSToolbarItem.Identifier.toolbarItemMoreInfo,
                NSToolbarItem.Identifier.toolbarLightDarItem,
                NSToolbarItem.Identifier.toolbarMoreActions,
                NSToolbarItem.Identifier.toolbarShareButtonItem,
                NSToolbarItem.Identifier.flexibleSpace,
                NSToolbarItem.Identifier.toolbarSearchItem
            ]
        } else {
            // Use the preferred toolbar item set for older versions of macOS.
            return [
                .toolbarSearch,
                NSToolbarItem.Identifier.toolbarItemPreference ,
                NSToolbarItem.Identifier.toolbarColorItem,
                NSToolbarItem.Identifier.print,
                NSToolbarItem.Identifier.flexibleSpace,
                NSToolbarItem.Identifier.toolbarItemCalc,
                NSToolbarItem.Identifier.toolbarItemMoreInfo,
                NSToolbarItem.Identifier.toolbarLightDarItem,
                NSToolbarItem.Identifier.toolbarMoreActions,
                NSToolbarItem.Identifier.toolbarShareButtonItem,
                NSToolbarItem.Identifier.flexibleSpace,
                NSToolbarItem.Identifier.toolbarSearchItem
            ]
        }
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier]
    {
        return [
            .toolbarSearch,
            NSToolbarItem.Identifier.toggleSidebar,
            NSToolbarItem.Identifier.toolbarColorItem,
            NSToolbarItem.Identifier.print,
            NSToolbarItem.Identifier.toolbarMoreActions,
            NSToolbarItem.Identifier.toolbarItemCalc,
            NSToolbarItem.Identifier.toolbarItemMoreInfo,
            NSToolbarItem.Identifier.toolbarLightDarItem,
            NSToolbarItem.Identifier.toolbarShareButtonItem,
            NSToolbarItem.Identifier.toolbarSearchItem,
            NSToolbarItem.Identifier.space,
            NSToolbarItem.Identifier.flexibleSpace
        ]
    }
    
    func toolbarWillAddItem(_ notification: Notification)
    {
        // print("~ ~ toolbarWillAddItem: \(notification.userInfo!)")
    }
    
    func toolbarDidRemoveItem(_ notification: Notification)
    {
        // print("~ ~ toolbarDidRemoveItem: \(notification.userInfo!)")
    }
    
    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier]
    {
        // Return the identifiers you'd like to show as "selected" when clicked.
        // Similar to how they look in typical Preferences windows.
        return []
    }
}
