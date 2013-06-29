//
//  NHBitSetTest.m
//  NHUtilities
//
//  Created by Nicholas Hart on 6/29/13.
//  Copyright (c) 2013 Nicholas Hart. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NHBitSet.h"

@interface NHBitSetTest : XCTestCase

@end

@implementation NHBitSetTest

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

- (void)testBitSet {
    const NSUInteger kTestBitSize = 52; // ie: a full deck of cards
    NHBitSet * bitSet = [NHBitSet bitSetWithNumBits:kTestBitSize];
    // verify all are zero
    for (NSUInteger index = 0; index != kTestBitSize; index++) {
        XCTAssertFalse([bitSet testBit:index], @"bit at index %u should be 0", index);
    }
    // set some bits
    NSUInteger setBits[6] = {0, 13, 31, 32, 47, 51};
    for (NSUInteger index = 0; index != 6; index++) {
        NSUInteger bitIndex = setBits[index];
        [bitSet setBit:bitIndex];
    }
    // verify those bits are one
    for (NSUInteger index = 0; index != 6; index++) {
        NSUInteger bitIndex = setBits[index];
        XCTAssertTrue([bitSet testBit:bitIndex], @"bit at index %u should be 1", index);
    }
    // clear those bits
    for (NSUInteger index = 0; index != 6; index++) {
        NSUInteger bitIndex = setBits[index];
        [bitSet clearBit:bitIndex];
    }
    // verify those bits are zero
    for (NSUInteger index = 0; index != 6; index++) {
        NSUInteger bitIndex = setBits[index];
        XCTAssertFalse([bitSet testBit:bitIndex], @"bit at index %u should be 1", index);
    }
    // set some bits
    for (NSUInteger index = 0; index != 6; index++) {
        NSUInteger bitIndex = setBits[index];
        [bitSet setBit:bitIndex];
    }
    // clear all bits
    [bitSet clearAllBits];
    // verify all are zero
    for (NSUInteger index = 0; index != kTestBitSize; index++) {
        XCTAssertFalse([bitSet testBit:index], @"bit at index %u should be 0", index);
    }
    // create another bit set
    NHBitSet * otherBitSet = [NHBitSet bitSetWithNumBits:kTestBitSize];
    // set some bits
    for (NSUInteger index = 0; index != 6; index++) {
        NSUInteger bitIndex = setBits[index];
        [otherBitSet setBit:bitIndex];
    }
    // give the bits from the other to our first
    [bitSet setBits:otherBitSet];
    // verify those bits are one
    for (NSUInteger index = 0; index != 6; index++) {
        NSUInteger bitIndex = setBits[index];
        XCTAssertTrue([bitSet testBit:bitIndex], @"bit at index %u should be 1", index);
    }
}


@end
