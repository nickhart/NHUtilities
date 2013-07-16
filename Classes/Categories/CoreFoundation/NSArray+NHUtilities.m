//
//  NSArray+NHUtilities.m
//  NHUtilities
//
//  Created by Nicholas Hart on 7/15/13.
//  Copyright (c) 2013 Nicholas Hart. All rights reserved.
//

#import "NSArray+NHUtilities.h"

@implementation NSArray (NHUtilities)

+ (NSArray *)arrayWithNumberRange: (NSRange) range {
    NSMutableArray * result = nil;
    NSUInteger end = (range.location + range.length);
    NSParameterAssert(range.location < end); // in case we wrap alert--we probably don't ever want this...
    if (range.location < end) {
        result = [NSMutableArray arrayWithCapacity:range.length];
        for (NSUInteger index = range.location; index < (range.location + range.length); index++) {
            [result addObject:[NSNumber numberWithUnsignedInteger:index]];
        }
    }
    return result;
}

+ (NSArray *)arrayWithObject: (id) object count: (NSUInteger) count {
    NSMutableArray * result = nil;
    NSParameterAssert(object);
    if (object) {
        result = [NSMutableArray arrayWithCapacity:count];
        for (NSUInteger index = 0; index != count; index++) {
            [result addObject:object];
        }
    }
    return result;
}

- (NSArray *)shuffled {
    NSUInteger count = [self count];
    NSMutableArray * result = [self mutableCopy];
    for (NSUInteger index = 1; index < count; index++) {
        NSUInteger randomIndex = arc4random() % count;
        NSNumber * randomValue = result[randomIndex];
        result[randomIndex] = result[index];
        result[index] = randomValue;
    }
    return result;
}

@end
