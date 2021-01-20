# What Development, Alpha, Beta, and Final Mean for Evergreen

#### Development version

N'est pas complet, est plein de bogues, peut-être pas du tout stable, et est susceptible de changer énormément à tout moment.

#### Alpha

L'application atteint l'alpha lorsque:

* C'est complet
* N'a aucun bogue connu

Au cours de la période alpha, l'application est testée minutieusement. Plus de tests sont écrits. Autant de personnes que possible utilisent l'application et signalent les bogues.

#### Bêta

L'application atteint la version bêta lorsque tous les bogues détectés lors des tests alpha sont corrigés et qu'aucun autre bogue n'est détecté. L'application est censée être en forme de navire.

Plus de tests, cependant, est une bonne idée.

Le code est considéré comme figé sauf pour les corrections de bugs, et toutes les corrections de bugs sont faites avec le plus grand soin et le plus léger contact possible.

#### Final

L'application atteint sa fin lorsque les développeurs sont convaincus qu'elle est prête à être expédiée. Elle fonctionne comme prévu, n'a aucun bogue connu, ne plante pas et est rapide.

(Note: "aucun bogue connu" est très sérieux.) Cela dit, il y a parfois des cas bizarres et ambigus qui ne peuvent pas être reproduits, et il y a donc des exceptions à cette règle, mais nous prétendons que ce n'est pas vrai. En fait, prétendez que vous n'avez jamais lu ce paragraphe, et nous ferons semblant de ne jamais l'avoir écrit.)





## ThemeKit


## Link
https://github.com/luckymarmot/ThemeKit

## SwiftDate

### Summary
SwiftDate is the definitive toolchain to manipulate and display dates and time zones on all Apple platform and even on Linux and Swift Server Side frameworks like Vapor or Kitura.

### Link
https://github.com/malcommac/SwiftDate

## TFDatePicker

### Link
https://github.com/ThesaurusSoftware/TFDatePicker

## TULSI
### Link
https://github.com/xxxx/xxxxx


## TFDate
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



## What is the difference between public and open?
Entities that are declared public or open are accessible from the module in which they are defined and from any module that imports the module they are defined in. The open access level was introduced to impose limitations on class inheritance in Swift.Open access level can only be applied to classes and class members, such as properties and methods.
### An open class is accessible and subclassable outside of the defining module. An open class member is accessible and overridable outside of the defining module.
### A public class is accessible but not subclassable outside of the defining module. A publicclass member is accessible but not overridable outside of the defining module.




//voided
//reconciled
//cleared
//open
//pending

// https://github.com/apple/swift-evolution/blob/master/proposals/0160-objc-inference.md


// nil cannot be used with nonoptional constants and variables.
//If a constant or variable in your code needs to work with the absence of a value under certain conditions,
// always declare it as an optional value of the appropriate type

// also very importante to notice:

// Swift’s nil is not the same as nil in Objective-C. In Objective-C, nil is a pointer to a nonexistent object.
// In Swift, nil is not a pointer—it is the absence of a value of a certain type. Optionals of any type can be set to nil, not just object types


