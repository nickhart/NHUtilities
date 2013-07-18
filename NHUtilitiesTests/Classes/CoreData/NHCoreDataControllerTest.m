//
//  NHCoreDataControllerTest.m
//  NHUtilities
//
//  Created by Nicholas Hart on 7/17/13.
//  Copyright (c) 2013 Nicholas Hart. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NHCoreDataController.h"

@interface NHCoreDataControllerTest : XCTestCase
@property (nonatomic, strong) NHCoreDataController * coreDataController;
@end

@implementation NHCoreDataControllerTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.coreDataController = [NHCoreDataController coreDataControllerWithDatabaseName:@"testModel" completion:^(NSError * error) {
    } useInMemoryStore:YES];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    self.coreDataController = nil;
    [super tearDown];
}

- (void)testInit {
    
}

@end
