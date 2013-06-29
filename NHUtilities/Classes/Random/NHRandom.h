//
//  NHRandom.h
//  NHUtilities
//
//  Created by Nicholas Hart on 6/29/13.
//  Copyright (c) 2013 Nicholas Hart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NHRandom : NSObject

+ (NHRandom *)sharedRandom;

- (void)seedWithCurrentTime;
- (NSUInteger)randomUnsignedInteger;
- (void)shuffleUnsignedIntegerArray: (NSUInteger *) array withLength: (NSUInteger) length;

@end
