//
//  NSArray+NHUtilities.h
//  NHUtilities
//
//  Created by Nicholas Hart on 7/15/13.
//  Copyright (c) 2013 Nicholas Hart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (NHUtilities)

+ (NSArray *)arrayWithNumberRange: (NSRange) range;
+ (NSArray *)arrayWithObject: (id) object count: (NSUInteger) count;

- (NSArray *)shuffled;


@end
