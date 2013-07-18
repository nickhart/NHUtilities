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

+ (id)coreDataControllerWithDatabaseName: (NSString *) databaseName completion: (void(^)(NSError *)) completion;
- (void)openDatabaseName: (NSString *) databaseName completion: (void(^)(NSError *)) completion;

@end
