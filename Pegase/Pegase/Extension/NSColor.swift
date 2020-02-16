//
//  NSColor.swift
//  Pegase
//
//  Created by thierry hentic on 28/10/2019.
//  Copyright © 2019 thierryH24. All rights reserved.
//

import AppKit


extension NSColor {

     class func color(data:Data) -> NSColor? {
          return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSColor
     }

     func encode() -> Data? {
          return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
     }
}
