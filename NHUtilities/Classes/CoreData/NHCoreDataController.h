//
//  NHCoreDataController.h
//  NHUtilities
//
//  Created by Nicholas Hart on 7/17/13.
//  Copyright (c) 2013 Nicholas Hart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSPersistentStoreCoordinator+NHUtilities.h"
#import "NSManagedObjectContext+NHUtilities.h"
#import "NSManagedObject+NHUtilities.h"
#import "NSFetchedResultsController+NHUtilities.h"
#import "NSFetchRequest+NHUtilities.h"


@interface NHCoreDataController : NSObject

@property (nonatomic, readonly) NSManagedObjectContext * managedObjectContext;

+ (id)coreDataControllerWithDatabaseName: (NSString *) databaseName completion: (void(^)(NSError *)) completion useInMemoryStore: (BOOL) useInMemoryStore;
- (void)openDatabaseName: (NSString *) databaseName completion: (void(^)(NSError *)) completion;

- (void)saveContext;
- (id)lookupEntity: (NSString *) entityName uniqueAttribute: (NSString *) uniqueAttribute uniqueValue: (id) uniqueValue;
- (NSFetchedResultsController *)resultsControllerForEntityName: (NSString *) entityName sortKey: (NSString *) sortKey ascending: (BOOL) ascending sectionNameKeyPath: (NSString *) sectionNameKeyPath cacheName: (NSString *) cacheName predicate: (NSPredicate *) predicate;

@end
