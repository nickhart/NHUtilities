//
//  NHBitSet.h
//  NHUtilities
//
//  Created by Nicholas Hart on 6/29/13.
//  Copyright (c) 2013 Nicholas Hart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NHBitSet : NSObject

+ (instancetype)bitSetWithNumBits: (NSUInteger) numBits;

- (instancetype)initWithNumBits: (NSUInteger) numBits;
- (BOOL)testBit: (NSUInteger) index;
- (void)setBit: (NSUInteger) index;
- (void)clearBit: (NSUInteger) index;
- (void)setBits: (NHBitSet *) bitSet;
- (NSUInteger)countBits;
- (void)clearAllBits;
- (NSArray *)arrayFromBits;

@end
