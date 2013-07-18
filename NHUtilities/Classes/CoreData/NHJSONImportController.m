//
//  NHJSONImportController.m
//  Pucker
//
//  Created by Nicholas Hart on 2/4/13.
//  Copyright (c) 2013 Nicholas Hart. All rights reserved.
//

#import "NHJSONImportController.h"
#import "NHCoreDataController.h"
#import "NHCommon.h"

static NSString * kGuidUniqueId = @"guid";

// @todo move this to its own file
@interface NSEntityDescription (additions)

- (NSAttributeDescription *)attributeDescriptionForName: (NSString *) attributeName;

@end

@implementation NSEntityDescription (additions)

- (NSAttributeDescription *)attributeDescriptionForName: (NSString *) attributeName {
    return [(NSDictionary *)[self attributesByName] objectForKey:attributeName];
}

@end

@implementation NHJSONImportController

- (id)dataFromJSONResource:(NSString *)resource {
    NSParameterAssert(resource);
    NSURL * dataUrl = [[NSBundle mainBundle] URLForResource:resource withExtension:@"json"];
    NSData * testData = [NSData dataWithContentsOfURL:dataUrl];
    return [NSJSONSerialization JSONObjectWithData:testData options:0 error:nil];
}

- (void)refreshManagedObject: (NSManagedObject *) managedObject withDictionary: (NSDictionary *) dictionary {
    NSEntityDescription * entityDescription = managedObject.entity;
    // @todo: break this out into a separate routine
    NSDictionary * attributesByName = entityDescription.attributesByName;
    for (NSString * key in attributesByName.allKeys) {
        id value = [dictionary objectForKey:key];
        // it's ok if value is nil--it means data wasn't provided (@todo: check for required attributes?)
        if (value) {
            NSAttributeDescription * attributeDescription = [attributesByName objectForKey:key];
            NSAttributeType attributeType = attributeDescription.attributeType;
            id valueToSet = nil;
            switch (attributeType) {
                case NSStringAttributeType:
                    // @todo: support convertions
                    NSParameterAssert([value isKindOfClass:[NSString class]]);
                    if ([value isKindOfClass:[NSString class]]) {
                        valueToSet = value;
                    }
                    break;
                case NSDoubleAttributeType:
                case NSFloatAttributeType:
                case NSBooleanAttributeType:
                case NSInteger64AttributeType:
                case NSInteger32AttributeType:
                case NSInteger16AttributeType:
                    DFLog(@"value class: %@", NSStringFromClass([value class]));
                    NSParameterAssert([value isKindOfClass:[NSNumber class]]);
                    if ([value isKindOfClass:[NSNumber class]]) {
                        valueToSet = value;
                    }
                    break;
                    
                default:
                    // @todo: support other types
                    DLog(@"unsupported attribute: %@ type: %u entity: %@", key, attributeType, entityDescription.name);
                    break;
            }
            [managedObject setValue:valueToSet forKey:key];
        }
    }
    // @todo: break this out into a separate routine
    NSDictionary * relationshipsByName = entityDescription.relationshipsByName;
    for (NSString * key in relationshipsByName.allKeys) {
        id relationshipValues = [dictionary objectForKey:key];
        // it's ok if relationshipValues is nil--it means data wasn't provided (@todo: check for required attributes?)
        if (relationshipValues) {
            NSRelationshipDescription * relationshipDescription = [relationshipsByName objectForKey:key];
            NSEntityDescription * destinationEntity = relationshipDescription.destinationEntity;
            NSString * destinationUniqueKey = @"guid";
            // @todo: provide a map or delegate for the unique keys
//            NSString * destinationUniqueKey = [self.dataController.delegate uniqueKeyForEntityName:destinationEntity.name];
            // @todo: support non-unique values?
            if (destinationUniqueKey) {
                id objectsToSet = nil;
                if ([relationshipDescription isToMany]) {
                    if ([relationshipDescription isOrdered]) {
                        objectsToSet = [NSMutableOrderedSet orderedSetWithCapacity:[relationshipValues count]];
                    }
                    else {
                        // our script doesn't know we're expecting an array
                        if (![relationshipValues isKindOfClass:[NSArray class]]) {
                            relationshipValues = @[relationshipValues]; // convert to an array
                        }
                        objectsToSet = [NSMutableSet setWithCapacity:[relationshipValues count]];
                    }
                    NSParameterAssert(objectsToSet);
                    if (!objectsToSet) {
                        break;
                    }
                }
                if ([relationshipValues isKindOfClass:[NSString class]]) {
                    relationshipValues = @[relationshipValues];
                }
                // iterate through the data for this relationship
                // (it should be an array--if not we have a likely bug in our csvtojson.py script)
                NSParameterAssert([relationshipValues isKindOfClass:[NSArray class]]);
                if ([relationshipValues isKindOfClass:[NSArray class]]) {
                    NSUInteger displayOrder = 0;
                    for (id destinationValue in relationshipValues) {
                        // now look at each destionation value--if it's a string, then it's a key to an existing object (or one that must be created)
                        NSDictionary * destinationDict = nil;
                        if ([destinationValue isKindOfClass:[NSString class]]) {
                            // use the string as the value for the unique key and make a dictionary out of them
                            destinationDict = @{destinationUniqueKey: destinationValue};
                        }
                        else if ([destinationValue isKindOfClass:[NSDictionary class]]) {
                            // use the dictionary as-is
                            destinationDict = destinationValue;
                        }
                        else {
                            DLog(@"unsupported input data class: %@ for relationship: %@ destinationEntity: %@ entity: %@", [destinationValue class], key, destinationEntity.name, entityDescription.name);
                            break;
                        }
                        // now "import" the object
                        if (destinationDict) {
                            NSMutableDictionary * mutableDestinationDict = [destinationDict mutableCopy];
                            [mutableDestinationDict setObject:[NSNumber numberWithLongLong:displayOrder] forKey:@"displayOrder"];
                            id objectToSet = [self importEntity:destinationEntity.name fromDict:mutableDestinationDict uniqueAttribute:destinationUniqueKey];
                            NSParameterAssert(objectToSet);
                            if (objectToSet) {
                                if (objectsToSet) {
                                    [objectsToSet addObject:objectToSet];
                                }
                                else {
                                    // check if overwriting and warn
                                    id existingValue = [managedObject valueForKey:key];
                                    if (!existingValue) {
                                        [managedObject setValue:objectToSet forKey:key];
                                    }
                                    else {
                                        // if the values match, no warning is necessary
                                        if (existingValue != objectToSet) {
                                            DLog(@"not overwriting existing value: %@ with new value: %@ for relationship: %@ destinationEntity: %@ entity: %@", existingValue, objectToSet, key, destinationEntity.name, entityDescription.name);
                                        }
                                    }
                                }
                            }
                        }
                        displayOrder++;
                    }
                    // now set the ordered set of objects we accumulated (@todo: clean this up--break each relationship type out into its own method?)
                    if (objectsToSet) {
                        id existingObjects = [managedObject valueForKey:key];
                        if (![existingObjects count]) {
                            [managedObject setValue:objectsToSet forKey:key];
                        }
                        else {
                            DLog(@"not overwriting existing objects for key: %@ for entity: %@", key, entityDescription.name);
                        }
                    }
                }
            }
            else {
                DLog(@"unsupported non-unique relationship: %@ destinationEntity: %@ entity: %@", key, destinationEntity.name, entityDescription.name);
            }
        }
    }
}

// @todo: stop worrying about the kEntityCountDirective... assume if it's @"guid" and an int64 that we auto-increment
- (id)importEntity: (NSString *) entityName fromDict: (NSDictionary *) entityDict uniqueAttribute: (NSString *) uniqueAttribute {
    id managedObject = nil;
    id uniqueValue = nil;
    NSFetchedResultsController * resultsController = nil;
    // find an existing unique object--or prepare to create a new unique object
    BOOL isGuidAttribute = NO;
    if (uniqueAttribute) {
        // @todo: move this to our csvtojson.py script? might be cleaner to have these defined externally
        // automatically calculate the unique id for guid--but it must be an integer
        if ([uniqueAttribute isEqualToString:kGuidUniqueId]) {
            // @todo: allow us to choose whether we specify a pre-defined guid or auto-create one... and then use lookupEntity:...
            // setup a results controller since we will need it for generating a unique value
            resultsController = [self.dataController resultsControllerForEntityName:entityName sortKey:uniqueAttribute ascending:YES sectionNameKeyPath:nil cacheName:nil predicate:nil];
            isGuidAttribute = YES;
        }
        else {
            // re-use an existing entry, if possible
            uniqueValue = [entityDict objectForKey:uniqueAttribute];
            managedObject = [self.dataController lookupEntity:entityName uniqueAttribute:uniqueAttribute uniqueValue:uniqueValue];
        }
    }
    
    // make a new managed object if necessary
    if (!managedObject) {
        // make a new object
        managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.dataController.managedObjectContext];
        if (isGuidAttribute) {
            // set its unique attribute
            NSAttributeType uniqueAttributeType = [[managedObject entity] attributeDescriptionForName:uniqueAttribute].attributeType;
            switch (uniqueAttributeType) {
                case NSInteger64AttributeType:
                    uniqueValue = [NSNumber numberWithUnsignedLongLong:[resultsController.fetchedObjects count]+1];
                    [managedObject setValue:uniqueValue forKey:uniqueAttribute];
                    break;
                    
                default:
                    DLog(@"unsupported attributeType: %u for uniqueAttribute: %@", uniqueAttributeType, uniqueAttribute);
                    break;
            }
        }
    }
    
    // update the object
    if (managedObject) {
//        if ([entityName isEqualToString:@"Ingredient"]) {
//            DLog(@"importing ingredient: %@", entityDict);
//        }
        [self refreshManagedObject:managedObject withDictionary:entityDict];
        [self.dataController saveContext];
    }
    return managedObject;
}

- (void)importFromData: (id) data {
    NSParameterAssert([data isKindOfClass:[NSDictionary class]]);
    NSParameterAssert(self.dataController.managedObjectContext);
    if ([data isKindOfClass:[NSDictionary class]] && self.dataController.managedObjectContext) {
        NSDictionary * dataDict = data;
        for (NSString * entityName in [dataDict allKeys]) {
            NSParameterAssert([entityName isKindOfClass:[NSString class]]);
            if ([entityName isKindOfClass:[NSString class]]) {
                NSArray * entityDicts = [dataDict objectForKey:entityName];
                NSParameterAssert([entityDicts isKindOfClass:[NSArray class]]);
                if ([entityDicts isKindOfClass:[NSArray class]]) {
                    for (NSDictionary * entityDict in entityDicts) {
                        NSParameterAssert([entityDict isKindOfClass:[NSDictionary class]]);
                        if ([entityDict isKindOfClass:[NSDictionary class]]) {
                            // @todo: improve this bollocks hack
                            NSString * uniqueAttribute = @"guid";
//                            NSString * uniqueAttribute = [self.dataController.delegate uniqueKeyForEntityName:entityName];
                            NSParameterAssert([uniqueAttribute length]);
                            if ([uniqueAttribute length]) {
                                [self importEntity:entityName fromDict:entityDict uniqueAttribute:uniqueAttribute];
                            }
                        }
                    }
                }
            }
        }
    }
}


@end
