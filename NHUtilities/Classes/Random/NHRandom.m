//
//  NHRandom.m
//  NHUtilities
//
//  Created by Nicholas Hart on 6/29/13.
//  Copyright (c) 2013 Nicholas Hart. All rights reserved.
//

#import "NHRandom.h"

@implementation NHRandom

+ (NHRandom *)sharedRandom {
    static NHRandom * globalRandom = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        globalRandom = [[NHRandom alloc] init];
        [globalRandom seedWithCurrentTime];
    });
    return globalRandom;
}

- (void)seedWithCurrentTime {
    NSDate * currentDate = [NSDate date];
    // we are building a 48 bit uint from two 32 bit uints (well, ok... technically they're doubles, but the time interval should fit into 32 bits in our lifetimes...
    uint64_t highData = (((uint32_t)[currentDate timeIntervalSince1970]) << 16);
    uint64_t lowData = (uint32_t)[currentDate timeIntervalSinceReferenceDate];
    uint64_t seedData =  highData ^ lowData; // combine high and low, xor-ing the overlapping middle 16 bits.
    ushort seedDataBytes[3];
    memccpy(&seedData, seedDataBytes, sizeof(ushort), 3);
    seed48(seedDataBytes);
}

- (NSUInteger)randomUnsignedInteger {
    return (mrand48() & 0xffffffff);
}

- (void)shuffleUnsignedIntegerArray: (NSUInteger *) array withLength: (NSUInteger) length {
    NSParameterAssert(array);
    NSParameterAssert(length);
    if (array && length) {
        for (NSUInteger index = 1; index < length; index++) {
            NSUInteger randomIndex = [self randomUnsignedInteger] % length;
            NSUInteger randomValue = array[randomIndex];
            array[randomIndex] = array[index];
            array[index] = randomValue;
        }
    }
}

@end
