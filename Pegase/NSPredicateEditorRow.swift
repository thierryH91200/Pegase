//
//  NSPredicateEditorRowTemplate.swift
//  KSPredicateEditorSwift
//
//  Created by thierryH24 on 28/11/2018.
//  Copyright © 2018 thierryH24. All rights reserved.
//

import AppKit


final class RowTemplateRelationshipRubrique: NSPredicateEditorRowTemplate {
    
    override init() {
        super.init()
    }
    
    init(leftExpressions: [NSExpression]) {
        let operators: [NSComparisonPredicate.Operator] = [ .equalTo, .notEqualTo, .beginsWith, .contains]
        var operatorsNSNumber: [NSNumber] = []
        for o in operators { operatorsNSNumber.append( NSNumber(value: o.rawValue) ) }
        
        super.init(leftExpressions: leftExpressions ,
                   rightExpressionAttributeType: .stringAttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func predicate(withSubpredicates subpredicates: [NSPredicate]?) -> NSPredicate {
        
        let predicate = super.predicate(withSubpredicates: subpredicates) as! NSComparisonPredicate
        let operatorType = predicate.predicateOperatorType
        let operatorName = findOperatorType(operatorType: operatorType)
        
        let predicateFormat  = String(format : "SUBQUERY(sousOperations, $sousOperation, $sousOperation.category.rubric.name %@ %@).@count > 0", operatorName, predicate.rightExpression)
        let newPredicate = NSPredicate(format: predicateFormat)
        return newPredicate
    }
}

final class RowTemplateRelationshipCategory: NSPredicateEditorRowTemplate {
    
    override init() {
        super.init()
    }
    
    init(leftExpressions: [NSExpression]) {
        let operators: [NSComparisonPredicate.Operator] = [ .equalTo, .notEqualTo, .beginsWith, .contains]
        var operatorsNSNumber: [NSNumber] = []
        for o in operators { operatorsNSNumber.append( NSNumber(value: o.rawValue) ) }
        
        super.init(leftExpressions: leftExpressions ,
                   rightExpressionAttributeType: .stringAttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func predicate(withSubpredicates subpredicates: [NSPredicate]?) -> NSPredicate {
        
        let predicate = super.predicate(withSubpredicates: subpredicates) as! NSComparisonPredicate
        let operatorType = predicate.predicateOperatorType
        let operatorName = findOperatorType(operatorType: operatorType)
        
        let predicateFormat  = String(format : "SUBQUERY(sousOperations, $sousOperation, $sousOperation.category.name %@ %@).@count > 0", operatorName, predicate.rightExpression)
        let newPredicate = NSPredicate(format: predicateFormat)
        return newPredicate
    }
}

final class RowTemplateRelationshipStatus: NSPredicateEditorRowTemplate {
    
    override init() {
        super.init()
    }

    init(leftExpressions: [NSExpression]) {
        let operators: [NSComparisonPredicate.Operator] = [ .equalTo, .notEqualTo, .beginsWith, .contains]
        var operatorsNSNumber: [NSNumber] = []
        for o in operators { operatorsNSNumber.append( NSNumber(value: o.rawValue) ) }
        
        super.init(leftExpressions: leftExpressions ,
                   rightExpressionAttributeType: .stringAttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func predicate(withSubpredicates subpredicates: [NSPredicate]?) -> NSPredicate {
        
        let predicate = super.predicate(withSubpredicates: subpredicates) as! NSComparisonPredicate
        let operatorType = predicate.predicateOperatorType
        let operatorName = findOperatorType(operatorType: operatorType)
        var right = String(format: "%@", predicate.rightExpression)
        right = right[1 ..< right.count - 1 ]
        let findRight = Statut.shared.findStatut(statut: right)
        
        let predicateFormat  = String(format : "%@ %@ %d", predicate.leftExpression , operatorName, findRight)
        
        let newPredicate = NSPredicate(format: predicateFormat)
        return newPredicate
    }
}

final class RowTemplateRelationshipLibelle: NSPredicateEditorRowTemplate {
    
    override init() {
        super.init()
    }

    init(leftExpressions: [NSExpression]) {
        let operators: [NSComparisonPredicate.Operator] = [ .equalTo, .notEqualTo, .beginsWith, .contains]
        var operatorsNSNumber: [NSNumber] = []
        for o in operators { operatorsNSNumber.append( NSNumber(value: o.rawValue) ) }
        
        super.init(leftExpressions: leftExpressions ,
                   rightExpressionAttributeType: .stringAttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func predicate(withSubpredicates subpredicates: [NSPredicate]?) -> NSPredicate{
        
        let predicate = super.predicate(withSubpredicates: subpredicates) as! NSComparisonPredicate
        let operatorType = predicate.predicateOperatorType
        let operatorName = findOperatorType(operatorType: operatorType)
        let predicateFormat = String(format: "SUBQUERY(sousOperations, $sousOperation, $sousOperation.libelle %@ %@).@count > 0", operatorName, predicate.rightExpression)
        
        let newPredicate = NSPredicate(format: predicateFormat)
        return newPredicate
    }
}

final class RowTemplateRelationshipMontant: NSPredicateEditorRowTemplate {
    
    override init() {
        super.init()
    }

    init(leftExpressions: [NSExpression]) {
        let operators: [NSComparisonPredicate.Operator] = RowTemplateRelationshipMontant.numberOperators
        var operatorsNSNumber: [NSNumber] = []
        for o in operators { operatorsNSNumber.append( NSNumber(value: o.rawValue) ) }
        
        super.init(leftExpressions: leftExpressions ,
                   rightExpressionAttributeType: .doubleAttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func predicate(withSubpredicates subpredicates: [NSPredicate]?) -> NSPredicate {
        
        let predicate = super.predicate(withSubpredicates: subpredicates) as! NSComparisonPredicate
        let operatorType = predicate.predicateOperatorType
        let operatorName = findOperatorType(operatorType: operatorType)
        
        let rightExpression = predicate.rightExpression
        
        let predicateFormat  = String(format : "SUBQUERY(sousOperations, $sousOperation, $sousOperation.amount %@ %@).@count > 0", operatorName, rightExpression)
        let newPredicate = NSPredicate(format: predicateFormat)
        
        return newPredicate
    }
}

final class RowTemplateRelationshipMode: NSPredicateEditorRowTemplate {
    
    override init() {
        super.init()
    }

    init(leftExpressions: [NSExpression]) {
        let operators: [NSComparisonPredicate.Operator] = RowTemplateRelationshipMode.stringOperators
        var operatorsNSNumber: [NSNumber] = []
        for o in operators { operatorsNSNumber.append( NSNumber(value: o.rawValue) ) }
        
        super.init(leftExpressions: leftExpressions ,
                   rightExpressionAttributeType: .stringAttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func predicate(withSubpredicates subpredicates: [NSPredicate]?) -> NSPredicate{
        
        let predicate = super.predicate(withSubpredicates: subpredicates) as! NSComparisonPredicate
        let operatorType = predicate.predicateOperatorType
        let operatorName = findOperatorType(operatorType: operatorType)
        
        let predicateFormat  = String(format : "paymentMode.name %@ %@", operatorName, predicate.rightExpression)
        let newPredicate = NSPredicate(format: predicateFormat)
        
        return newPredicate
    }
}

final class RowTemplateRelationshipDate: NSPredicateEditorRowTemplate {
    
    var entity = ""
    
    override init() {
        super.init()
    }

    init(leftExpressions: [NSExpression], leftEntity : String) {
        self.entity = leftEntity
        let operators: [NSComparisonPredicate.Operator] = RowTemplateRelationshipMontant.dateOperators
        var operatorsNSNumber: [NSNumber] = []
        for o in operators { operatorsNSNumber.append( NSNumber(value: o.rawValue) ) }
        
        super.init(leftExpressions: leftExpressions ,
                   rightExpressionAttributeType: .dateAttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func predicate(withSubpredicates subpredicates: [NSPredicate]?) -> NSPredicate{
        
        let predicate = super.predicate(withSubpredicates: subpredicates) as! NSComparisonPredicate
        
        let operatorType = predicate.predicateOperatorType
        let operatorName = findOperatorType(operatorType: operatorType)
        
        let rightExpression = predicate.rightExpression.description
        let beginOfSentence = rightExpression.firstIndex(of: "(")!
        let endOfSentence = rightExpression.firstIndex(of: ",")!
        
        let sentence = TimeInterval(rightExpression[rightExpression.index(after: beginOfSentence)..<endOfSentence])
        
        let date = Date(timeIntervalSinceReferenceDate:  sentence!).noon
        let timeInterval = date.timeIntervalSinceReferenceDate
        let predicateFormat = String(format : "%@ %@ CAST(%.2f, 'NSDate')", self.entity , operatorName, timeInterval)
        
        let newPredicate = NSPredicate(format: predicateFormat)
        return newPredicate
    }
    
}

