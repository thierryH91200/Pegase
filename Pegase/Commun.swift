import AppKit

var mainObjectContext: NSManagedObjectContext!
var compteCourant: EntityAccount?
let Defaults = UserDefaults.standard


enum TypeOfStatut: Int16 {
    case planifie
    case engage
    case realise
    
    var label: String
    {
        switch self {
        case .planifie: return Localizations.Statut.Planifie
        case .engage: return Localizations.Statut.Engaged
        case .realise: return Localizations.Statut.Realise        }
    }
    var attribut: [NSAttributedString.Key: Any]
    {
        var attrs = [NSAttributedString.Key: Any]()
        switch self {
        case .planifie:
            attrs[.foregroundColor] = NSColor.green
            attrs[.font ] = NSFont(name: "Avenir-Oblique", size: 12.0)!
        case .engage:
            attrs[.foregroundColor] = NSColor.blue
            attrs[.font ] = NSFont(name: "Avenir", size: 12.0)!
        case .realise:
            attrs[.foregroundColor] = NSColor.labelColor
            attrs[.font ] = NSFont(name: "Avenir", size: 12.0)!
        }
        return attrs
    }
}

func findStatut ( statut: String) -> Int16 {
    if TypeOfStatut(rawValue: 0 )?.label == statut {
        return 0
    }
    if TypeOfStatut(rawValue: 1 )?.label == statut {
        return 1
    }
    if TypeOfStatut(rawValue: 2 )?.label == statut {
        return 2
    }
    return 1
    
}
