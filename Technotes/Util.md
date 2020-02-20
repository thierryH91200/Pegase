


# Util

## Pegase

### Requirements

Xcode 9/10 and Swift 4.2



## ThemeKit

### Summary
ThemeKit is a lightweight theming library completely written in Swift that provides theming capabilities to both Swift and Objective-C macOS applications.

### Link
https://github.com/luckymarmot/ThemeKit

## SwiftDate

### Summary
SwiftDate is the definitive toolchain to manipulate and display dates and time zones on all Apple platform and even on Linux and Swift Server Side frameworks like Vapor or Kitura.

### Link
https://github.com/malcommac/SwiftDate

## TFDatePicker

### Link
https://github.com/ThesaurusSoftware/TFDatePicker


https://stackoverflow.com/questions/14401755/can-i-clear-a-nsdatepicker

Can I clear a NSDatePicker ?
Short answer: no!
But you can for example subclass it and replace drawInRect method...

Enhanced textual Cocoa NSDatePicker, which has a popover control to selecting date and time using the standard controls.


###  NIL

nil cannot be used with nonoptional constants and variables. 
If a constant or variable in your code needs to work with the absence of a value under certain conditions,
always declare it as an optional value of the appropriate type

### also very importante to notice:

Swift’s nil is not the same as nil in Objective-C. In Objective-C, nil is a pointer to a nonexistent object.
iIn Swift, nil is not a pointer—it is the absence of a value of a certain type. Optionals of any type can be set to nil, not just object types


## Laurine

### Summary
Localization code generator written (with love) for Swift, intended to end the constant problems that localizations present developers.

### Link
https://github.com/JiriTrecak/Laurine

## BartyCrouch

### Summary
BartyCrouch incrementally updates your Strings files from your Code and from Interface Builder files. "Incrementally" means that BartyCrouch will by default keep both your already translated values and even your altered comments. Additionally you can also use BartyCrouch for machine translating from one language to 40+ other languages. Using BartyCrouch is as easy as running a few simple commands from the command line what can even be automated using a build script within your project.

### Link
https://github.com/Flinesoft/BartyCrouch



# Manuel

## But
Ce programme donne une grande place à l'information.

## Généralités
Chaque compte a ses propres préférences.

- Sa propre liste de mode de paiement.
- Sa propre liste de catégorie/rubrique.
- Ses propres carnets de chèques

## Opérations
Autocomplétion pour les libellés
Possiblité de modifier plusieurs opérations simultanément
Possibilité de lier une opération à un autre compte

- **Libéllé** : Description de l'opération
- **Mode paiement** : Choix du mode de paiement 
- Rubrique : Famille de la catégorie
- Catégorie
 -Date opération : Date à laquelle l'opération a été réalisée
- Date de pointage : Date à laquelle l'opération est prise en compte
- Statut : 

	- L'opération est prévue. Elle n'est ni réalisée ni pointée. Je pense faire un achat quel est la conséquence sur le compte  
	- L'opération est réalisée
	- L'opération est pointée



## Trésorerie
Possibilité de choisir facilement la date début et la date de fin pour pouvoir zoomer sur une période définie



## Bilan
Animation des graphes

Affichage des opérations concernées pour la période donnée

Possibilité de choisir facilement la date début et la date de fin pour pouvoir zoomer sur une période définie

## Dark Mode

// macOS
let aColor = NSColor(named: NSColor.Name("customControlColor"))

