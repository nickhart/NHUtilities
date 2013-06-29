//
//  NHRandomTest.m
//  NHUtilities
//
//  Created by Nicholas Hart on 6/29/13.
//  Copyright (c) 2013 Nicholas Hart. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NHRandom.h"

@interface NHRandomTest : XCTestCase

@end

@implementation NHRandomTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testShuffle {
    NHRandom * random = [[NHRandom alloc] init];
    const NSUInteger kLength = 52;
    NSUInteger deck[kLength];
    for (NSUInteger index = 0; index != 52; index++) {
        deck[index] = index;
    }
    [random shuffleUnsignedIntegerArray:deck withLength:kLength];
    NSUInteger matches = 0;
    for (NSUInteger index = 0; index != 52; index++) {
        if (deck[index] == index) {
            matches++;
        }
    }
    // we could do some really fancy statistical analysis here, but let's just make sure that at least half of our numbers are in a different place.  And this migh fail on very small arrays...
    XCTAssertTrue(matches < (kLength/2), @"shuffle might not be working properly...");
    
}

@end
