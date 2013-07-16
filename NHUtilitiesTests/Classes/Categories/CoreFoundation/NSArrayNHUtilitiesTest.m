//
//  NSArray_NHUtilities_Tests.m
//  NHUtilities
//
//  Created by Nicholas Hart on 7/15/13.
//  Copyright (c) 2013 Nicholas Hart. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSArray+NHUtilities.h"

@interface NSArray_NHUtilities_Tests : XCTestCase

@end

@implementation NSArray_NHUtilities_Tests

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

- (void)testArrayWithObjectCount {
    id object = @"Whatever";
    NSArray * result = [NSArray arrayWithObject:object count:5];
    XCTAssertEquals([result count], (NSUInteger)5, @"array is wrong size");
    for (NSUInteger index = 0; index != [result count]; ++index) {
        XCTAssertEqualObjects(result[index], object, @"object at index %u is wrong", index);
    }
}

- (void)testArrayWithNumberRange {
    NSArray * result = [NSArray arrayWithNumberRange:NSMakeRange(0, 5)];
    NSArray * expected = @[[NSNumber numberWithUnsignedInteger:0],
                           [NSNumber numberWithUnsignedInteger:1],
                           [NSNumber numberWithUnsignedInteger:2],
                           [NSNumber numberWithUnsignedInteger:3],
                           [NSNumber numberWithUnsignedInteger:4]];
    XCTAssertEqualObjects(result, expected, @"numbersWithRange returned from range for (0, 5)");
    result = [NSArray arrayWithNumberRange:NSMakeRange(5, 5)];
    expected = @[[NSNumber numberWithUnsignedInteger:5],
                 [NSNumber numberWithUnsignedInteger:6],
                 [NSNumber numberWithUnsignedInteger:7],
                 [NSNumber numberWithUnsignedInteger:8],
                 [NSNumber numberWithUnsignedInteger:9]];
    XCTAssertEqualObjects(result, expected, @"numbersWithRange returned from range for (5, 5)");
}

- (void)runShuffleTestWithSize: (NSUInteger) size histogram: (NSMutableArray *) histogram {
    NSArray * original = [NSArray arrayWithNumberRange:NSMakeRange(0, size)];
    NSArray * shuffled = [original shuffled];
    XCTAssertEquals([original count], [shuffled count], @"original and shuffled array are wrong sizes");
    for (NSUInteger index = 0; index != [original count]; ++index) {
        NSUInteger originalValue = [original[index] unsignedIntegerValue];
        NSUInteger shuffledValue = [shuffled[index] unsignedIntegerValue];
        NSUInteger distanceIndex = originalValue > shuffledValue ? (originalValue - shuffledValue) : (shuffledValue - originalValue);
        NSUInteger distanceValue = [histogram[distanceIndex] unsignedIntegerValue] + 1;
        histogram[distanceIndex] = [NSNumber numberWithUnsignedInteger:distanceValue];
    }
}

- (void)testShuffle {
    const float kGraphScale = 40.0;
    const NSUInteger kShuffleSize = 100;
    const float kHistogramLeeway = 1.1;
    const NSUInteger kTestCount = 10000;
    NSMutableArray * histogram = [[NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:0] count:kShuffleSize] mutableCopy]; // @todo: add mutable overload?
    for (NSUInteger index = 0; index != kTestCount; ++index) {
        [self runShuffleTestWithSize:kShuffleSize histogram:histogram];
    }
    NSUInteger lastDistance = 0;
    for (NSUInteger index = 0; index != kShuffleSize; ++index) {
        NSUInteger distanceValue = [histogram[index] unsignedIntegerValue];
        if (index > 1) {
            XCTAssertEqualsWithAccuracy(distanceValue, lastDistance, lastDistance * kHistogramLeeway, @"unlikely histogram results at index %@", index);
        }
        lastDistance = distanceValue;
        if (distanceValue) {
            NSUInteger scaledValue = (NSUInteger)((float)distanceValue * kGraphScale / (float)kTestCount);
            NSString * graphString = [[NSArray arrayWithObject:@"*" count:scaledValue] componentsJoinedByString:@""];
            NSLog(@"%u (%0.2f): %@", index, (float)distanceValue/(float)kTestCount, graphString);
        }
    }
}

@end
