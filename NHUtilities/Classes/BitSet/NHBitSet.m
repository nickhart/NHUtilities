//
//  NHBitSet.m
//  NHUtilities
//
//  Created by Nicholas Hart on 6/29/13.
//  Copyright (c) 2013 Nicholas Hart. All rights reserved.
//

#import "NHBitSet.h"

@interface NHBitSet ()

@property (nonatomic, readonly) CFMutableBitVectorRef bitsRef;
@property (nonatomic, readonly) NSUInteger numBits;

@end

@implementation NHBitSet {
    CFMutableBitVectorRef _bitsRef;
    NSUInteger _numBits;
}

+ (instancetype)bitSetWithNumBits: (NSUInteger) numBits {
    return [[NHBitSet alloc] initWithNumBits:numBits];
}

- (instancetype)initWithNumBits: (NSUInteger) numBits {
    NSParameterAssert(numBits);
    if (numBits && (self = [super init])) {
        _bitsRef = CFBitVectorCreateMutable(CFAllocatorGetDefault(), numBits);
        _numBits = numBits;
    }
    return self;
}

- (void)dealloc {
    CFRelease(_bitsRef);
}

- (BOOL)testBit: (NSUInteger) index {
    NSParameterAssert(index < _numBits);
    if (index < _numBits) {
        return CFBitVectorGetBitAtIndex(_bitsRef, (CFIndex)index) ? YES : NO;
    }
    return NO;
}

- (void)setBit: (NSUInteger) index {
    NSParameterAssert(index < _numBits);
    if (index < _numBits) {
        CFBitVectorSetBitAtIndex(_bitsRef, (CFIndex)index, (CFBit)1);
    }
}

- (void)clearBit: (NSUInteger) index {
    NSParameterAssert(index < _numBits);
    if (index < _numBits) {
        CFBitVectorSetBitAtIndex(_bitsRef, (CFIndex)index, (CFBit)0);
    }
}

- (void)setBits: (NHBitSet *) bitSet {
    NSParameterAssert(bitSet != nil);
    NSParameterAssert(bitSet.numBits == _numBits);
    if (bitSet && bitSet.numBits == _numBits) {
        // XXXNH: there may be a more efficient way to do this, but I don't see a CF API to OR the two bitsets.
        CFIndex startBit = CFBitVectorGetFirstIndexOfBit(bitSet.bitsRef, CFRangeMake(0, _numBits), 1);
        CFIndex endBit = CFBitVectorGetLastIndexOfBit(bitSet.bitsRef, CFRangeMake(startBit, _numBits), 1);
        for (CFIndex index = startBit; index <= endBit; ++index) {
            if (CFBitVectorGetBitAtIndex(bitSet.bitsRef, index) == (CFBit)1) {
                CFBitVectorSetBitAtIndex(_bitsRef, index, (CFBit)1);
            }
        }
    }
}

- (NSUInteger)countBits {
    NSParameterAssert(_bitsRef && _numBits);
    return (NSUInteger)CFBitVectorGetCountOfBit(_bitsRef, CFRangeMake(0, _numBits), 1);
}

- (void)clearAllBits {
    NSParameterAssert(_bitsRef && _numBits);
    CFBitVectorSetBits(_bitsRef, CFRangeMake(0, _numBits), 0);
}

- (NSArray *)arrayFromBits {
    NSParameterAssert(_bitsRef && _numBits);
    NSMutableArray * result = [NSMutableArray arrayWithCapacity:[self countBits]];
    CFIndex startBit = CFBitVectorGetFirstIndexOfBit(_bitsRef, CFRangeMake(0, _numBits), 1);
    CFIndex endBit = CFBitVectorGetLastIndexOfBit(_bitsRef, CFRangeMake(startBit, _numBits), 1);
    for (CFIndex index = startBit; index <= endBit; ++index) {
        if (CFBitVectorGetBitAtIndex(_bitsRef, index) == (CFBit)1) {
            [result addObject:[NSNumber numberWithUnsignedInteger:index]];
        }
    }
    return result;
}

@end
