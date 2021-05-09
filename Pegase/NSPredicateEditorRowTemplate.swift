//
//  NSPredicateEditorRowTemplate.swift
//  KSPredicateEditorSwift
//
//  Created by thierryH24 on 28/11/2018.
//  Copyright © 2018 thierryH24. All rights reserved.
//

import AppKit

extension NSPredicateEditorRowTemplate {
    
    convenience init( compoundTypes: [NSCompoundPredicate.LogicalType] ) {
        
        let compoundTypesNSNumber = (0..<compoundTypes.count).map { (i) -> NSNumber in
            return NSNumber(value: compoundTypes[i].rawValue)
        }
        self.init( compoundTypes: compoundTypesNSNumber )
    }
    
    // Constant values
    convenience init( forKeyPath keyPath: String, withValues values: [Any] , operators: [NSComparisonPredicate.Operator]) {
        
        let keyPaths: [NSExpression] = [NSExpression(forKeyPath: keyPath)]
        var constantValues: [NSExpression] = []
        for value in values {
            constantValues.append( NSExpression(forConstantValue: value) )
        }
        
        let operatorsNSNumber = (0..<operators.count).map { (i) -> NSNumber in
            return NSNumber(value: operators[i].rawValue)
        }
        
        self.init( leftExpressions: keyPaths,
                   rightExpressions: constantValues,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: (Int(NSComparisonPredicate.Options.caseInsensitive.rawValue | NSComparisonPredicate.Options.diacriticInsensitive.rawValue)) )
    }
    
    // String
    convenience init( stringCompareForKeyPaths keyPaths: [String] , operators: [NSComparisonPredicate.Operator]) {
        
        let leftExpressions = (0..<keyPaths.count).map { (i) -> NSExpression in
            return NSExpression(forKeyPath: keyPaths[i])
        }
        let operatorsNSNumber = (0..<operators.count).map { (i) -> NSNumber in
            return NSNumber(value: operators[i].rawValue)
        }
        
        self.init( leftExpressions: leftExpressions,
                   rightExpressionAttributeType: .stringAttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: (Int(NSComparisonPredicate.Options.caseInsensitive.rawValue | NSComparisonPredicate.Options.diacriticInsensitive.rawValue)) )
    }
    
    // Int
    convenience init( IntCompareForKeyPaths keyPaths: [String], operators: [NSComparisonPredicate.Operator] = [.equalTo, .notEqualTo]) {
        
        let leftExpressions = (0..<keyPaths.count).map { (i) -> NSExpression in
            return NSExpression(forKeyPath: keyPaths[i])
        }
        let operatorsNSNumber = (0..<operators.count).map { (i) -> NSNumber in
            return NSNumber(value: operators[i].rawValue)
        }
        
        self.init( leftExpressions: leftExpressions,
                   rightExpressionAttributeType: .integer16AttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: 0 )
    }
    
    // Date
    convenience init( DateCompareForKeyPaths keyPaths: [String] , operators: [NSComparisonPredicate.Operator]) {
        
        let leftExpressions = (0..<keyPaths.count).map { (i) -> NSExpression in
            return NSExpression(forKeyPath: keyPaths[i])
        }
        let operatorsNSNumber = (0..<operators.count).map { (i) -> NSNumber in
            return NSNumber(value: operators[i].rawValue)
        }
        
        self.init( leftExpressions: leftExpressions,
                   rightExpressionAttributeType: .dateAttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: 0 )
    }
    
    // Bool
    convenience init( BoolCompareForKeyPaths keyPaths: [String] , operators: [NSComparisonPredicate.Operator]) {
        
        let leftExpressions = (0..<keyPaths.count).map { (i) -> NSExpression in
            return NSExpression(forKeyPath: keyPaths[i])
        }
        let operatorsNSNumber = (0..<operators.count).map { (i) -> NSNumber in
            return NSNumber(value: operators[i].rawValue)
        }
        
        self.init( leftExpressions: leftExpressions,
                   rightExpressionAttributeType: .booleanAttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: 0 )
    }
    
    func findOperatorType(operatorType : NSComparisonPredicate.Operator) -> String {
        
        var operatorName = ""
        switch (operatorType) {
        case .equalTo:
            operatorName = "=="
        case .beginsWith:
            operatorName = "BEGINSWITH"
        case .endsWith:
            operatorName = "ENDSWITH"
        case .contains:
            operatorName = "CONTAINS[cd]"
        case .lessThan:
            operatorName = "<"
        case .lessThanOrEqualTo:
            operatorName = "<="
        case .greaterThan:
            operatorName = ">"
        case .greaterThanOrEqualTo:
            operatorName = ">="
        case .notEqualTo:
            operatorName = "!="
        case .matches:
            operatorName = "MATCHES"
        case .like:
            operatorName = "LIKE"
        case .in:
            operatorName = "'in'"
        case .customSelector:
            operatorName = "CONTAINS[cd]"
        case .between:
            operatorName = "BETWEEN"
        @unknown default:
            operatorName = "CONTAINS[cd]"
        }
        return operatorName
    }
}

final class RowTemplateRelationshipRubrique: NSPredicateEditorRowTemplate {
    
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
    
    override func predicate(withSubpredicates subpredicates: [NSPredicate]?) -> NSPredicate {
        
        let predicate = super.predicate(withSubpredicates: subpredicates) as! NSComparisonPredicate
        let operatorType = predicate.predicateOperatorType
        let operatorName = findOperatorType(operatorType: operatorType)
        
        let predicateFormat  = String(format : "SUBQUERY(sousOperations, $sousOperation, $category.name %@ %@).@count > 0", operatorName, predicate.rightExpression)
        let newPredicate = NSPredicate(format: predicateFormat)
        return newPredicate
    }
}
final class RowTemplateRelationshipStatus: NSPredicateEditorRowTemplate {
    
    override func predicate(withSubpredicates subpredicates: [NSPredicate]?) -> NSPredicate {
        
        let predicate = super.predicate(withSubpredicates: subpredicates) as! NSComparisonPredicate
        let operatorType = predicate.predicateOperatorType
        let operatorName = findOperatorType(operatorType: operatorType)
//        let right = TypeOfStatut(rawValue: predicate.rightExpression.r)
        
        let predicateFormat  = String(format : "%@ %@ %@", predicate.leftExpression , operatorName, predicate.rightExpression)
        print(predicateFormat)
        
        let newPredicate = NSPredicate(format: predicateFormat)
        return newPredicate
    }
}

final class RowTemplateRelationshipLibelle: NSPredicateEditorRowTemplate {
    
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
    
    override func predicate(withSubpredicates subpredicates: [NSPredicate]?) -> NSPredicate{
        
        let predicate = super.predicate(withSubpredicates: subpredicates) as! NSComparisonPredicate
        let operatorType = predicate.predicateOperatorType
        let operatorName = findOperatorType(operatorType: operatorType)

        let predicateFormat  = String(format : "SUBQUERY(sousOperations, $sousOperation, $sousOperation.amount %@ %@).@count > 0", operatorName, predicate.rightExpression)
        let newPredicate = NSPredicate(format: predicateFormat)
        
        return newPredicate
    }
}

final class RowTemplateRelationshipDate: NSPredicateEditorRowTemplate {
    
    override func predicate(withSubpredicates subpredicates: [NSPredicate]?) -> NSPredicate{
        
        let predicate = super.predicate(withSubpredicates: subpredicates) as! NSComparisonPredicate
        
        let operatorType = predicate.predicateOperatorType
        let operatorName = findOperatorType(operatorType: operatorType)
        
        let rightExpression = predicate.rightExpression.description
        let beginOfSentence = rightExpression.firstIndex(of: "(")!
        let endOfSentence = rightExpression.firstIndex(of: ",")!
        
        let sentense = TimeInterval(rightExpression[rightExpression.index(after: beginOfSentence)..<endOfSentence])
        
        let date = Date(timeIntervalSinceReferenceDate:  sentense!).noon
        let timeInterval = date.timeIntervalSinceReferenceDate
        let predicateFormat = String(format : "%@ %@ CAST(%.2f, 'NSDate')", predicate.leftExpression , operatorName, timeInterval)

        let newPredicate = NSPredicate(format: predicateFormat)
        return newPredicate
    }
    
}

