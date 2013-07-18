//
//  NHCoreDataController.m
//  NHUtilities
//
//  Created by Nicholas Hart on 7/17/13.
//  Copyright (c) 2013 Nicholas Hart. All rights reserved.
//

#import "NHCoreDataController.h"

#define kResetDataControllerKey @"ResetDataController"

@interface NHCoreDataController ()
@property (nonatomic, assign) void(^completionHandler)(NSError *);
@property (nonatomic, assign) dispatch_queue_t mainContextQueue;
@property (nonatomic, assign) NSString * databaseName;
@property (nonatomic, assign) BOOL useInMemoryStore;
@property (nonatomic, strong) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel * managedObjectModel;
@end

@implementation NHCoreDataController

+ (id)coreDataControllerWithDatabaseName: (NSString *) databaseName completion: (void(^)(NSError *)) completion {
    NHCoreDataController * coreDataController = [[NHCoreDataController alloc] init];
    if (coreDataController) {
        [coreDataController openDatabaseName:databaseName completion:completion];
    }
    return self;
}

- (void)openDatabaseName: (NSString *) databaseName completion: (void(^)(NSError *)) completion {
    NSParameterAssert(!_managedObjectContext);
    if (!_managedObjectContext) {
        self.completionHandler = completion;
        [self managedObjectContext];
    }
}

#pragma mark private methods

- (void)reset {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kResetDataControllerKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    abort(); // restart the app
    // @todo: need to tear down the coredata stack, delete the sqlite file, reconstruct the stack and reset all view controllers
}

- (void)reportError: (NSError *) error {
    NSLog(@"NHCoreDataController failed: %@ (%@)", [error localizedDescription], [error userInfo]);
    if (self.completionHandler) {
        self.completionHandler(error);
    }
    else {
        abort();
    }
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            [self reportError:error];
        }
    }
}

- (void)performFetch: (NSFetchedResultsController *) resultsController {
    NSError *error = nil;
    if (![resultsController performFetch:&error]) {
        [self reportError:error];
    }
}

// @todo: move to delegate?
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSParameterAssert(self.databaseName);
    if (self.databaseName) {
        NSURL * modelURL = [[NSBundle mainBundle] URLForResource:self.databaseName withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    BOOL resetStore = NO;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kResetDataControllerKey] boolValue]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kResetDataControllerKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        resetStore = YES;
    }
    
    NSError * error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    // are we using an in-memory store?
    if (self.useInMemoryStore) {
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error]) {
            [self reportError:error];
            _persistentStoreCoordinator = nil;
        }
    }
    else {
        // make sure we're configured with a DB name
        NSParameterAssert(self.databaseName);
        if (self.databaseName) {
            NSString * databaseFile = [NSString stringWithFormat:@"%@.sqlite", self.databaseName];
            NSURL * storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:databaseFile];
            if (resetStore) {
                @try {
                    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
                    if (error) {
                        [self reportError:error];
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"NHCoreDataController exception: %@", [exception debugDescription]);
                }
                @finally {
                }
            }
            // figure out if we need to init the database
            BOOL databaseNeedsInitialization = resetStore || ![storeURL checkResourceIsReachableAndReturnError:nil];
            // try to setup the DB
            if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
                // failure--delete the old DB one and retry
                [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
                if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
                    // XXXNH: this is untested--but if we can't delete the old DB??? yeah, we're hosed.
                    // report the error, let the delegate deal with it and reset
                    [self reportError:error];
                    _persistentStoreCoordinator = nil;
                }
                else {
                    // report the error, but attempt to initialize the new DB
                    [self reportError:error];
                    databaseNeedsInitialization = YES;
                }
            }
            // init the new DB
            if (databaseNeedsInitialization) {
                NSParameterAssert(_persistentStoreCoordinator);
                NSLog(@"todo: populate new DB");
//                [self.delegate populateDatabase];
            }
        }
        else {
            // XXXNH: this is untested--but it will only happen if the app delegate is not configured to return a database name
            // report the error, let the delegate deal with it and reset
            [self reportError:error];
            _persistentStoreCoordinator = nil;
        }
    }
    return _persistentStoreCoordinator;
}

#pragma CoreData helpers

- (id)lookupSingletonEntity: (NSString *) entityName {
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    [fetchRequest setFetchLimit:1]; // we only need one
    id result = nil;
    NSError * error = nil;
    NSArray * results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([results count]) {
        if ([results count] > 1) {
            NSLog(@"multiple unique objects for entity: %@", entityName);
        }
        result = [results objectAtIndex:0];
    }
    return result;
}

- (id)lookupEntity: (NSString *) entityName uniqueAttribute: (NSString *) uniqueAttribute uniqueValue: (id) uniqueValue {
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSPredicate * predicate = nil;
    if ([uniqueValue isKindOfClass:[NSString class]]) {
        NSString * predicateFormat = [NSString stringWithFormat:@"%@ == %%@", uniqueAttribute];
        predicate = [NSPredicate predicateWithFormat:predicateFormat, uniqueValue];
    }
    else {
        NSLog(@"unsupported predicate type: %@ for key: %@ entity: %@", [uniqueValue class], uniqueAttribute, uniqueValue);
    }
    id result = nil;
    if (predicate) {
        [fetchRequest setPredicate:predicate];
        [fetchRequest setFetchLimit:1]; // we only need one
        NSError * error = nil;
        NSArray * results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if ([results count]) {
            if ([results count] > 1) {
                NSLog(@"multiple unique objects for entity: %@ unique key: %@ value: %@", entityName, uniqueAttribute, uniqueValue);
            }
            result = [results objectAtIndex:0];
        }
        else if ([uniqueAttribute isEqualToString:@"guid"]) {
            NSLog(@"couldn't find unique object for entity: %@ unique key: %@ value: %@", entityName, uniqueAttribute, uniqueValue);
        }
    }
    return result;
}

- (NSFetchedResultsController *)resultsControllerForEntityName: (NSString *) entityName sortKey: (NSString *) sortKey ascending: (BOOL) ascending sectionNameKeyPath: (NSString *) sectionNameKeyPath cacheName: (NSString *) cacheName predicate: (NSPredicate *) predicate {
    NSFetchedResultsController * resultsController = nil;
    NSParameterAssert(entityName);
    NSParameterAssert(self.managedObjectContext);
    if (entityName && self.managedObjectContext) {
        NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
        if (sortKey) {
            [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:sortKey ascending:ascending]]];
        }
        if (predicate) {
            [fetchRequest setPredicate:predicate];
        }
        resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionNameKeyPath cacheName:cacheName];
        NSError * error = nil;
        if (![resultsController performFetch:&error]) {
            NSLog(@"performFetch error: %@ (%@)", [error localizedDescription], [error userInfo]);
            resultsController = nil;
        }
    }
    return resultsController;
}

@end
