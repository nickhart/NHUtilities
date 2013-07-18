//
//  NHJSONImportController.h
//  Pucker
//
//  Created by Nicholas Hart on 2/4/13.
//  Copyright (c) 2013 Nicholas Hart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NHCoreDataController;
@interface NHJSONImportController : NSObject

@property (nonatomic, strong) NHCoreDataController * dataController;

- (id)dataFromJSONResource: (NSString *) resource;
- (id)importEntity: (NSString *) entityName fromDict: (NSDictionary *) entityDict uniqueAttribute: (NSString *) uniqueAttribute;
- (void)importFromData: (id) data;

@end
