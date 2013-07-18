//
//  NHCommon.h
//  NHUtilities
//
//  Created by Nicholas Hart on 7/17/13.
//  Copyright (c) 2013 Nicholas Hart. All rights reserved.
//

#ifdef DEBUG
#define DLog(...) NSLog(@"%s(%p) %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__])
#define DFLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#define ALog(...) {NSLog(@"%s(%p) %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__]); [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lineNumber:__LINE__ description:__VA_ARGS__];}
#define AFLog(...) {NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__]); if [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lineNumber:__LINE__ description:__VA_ARGS__];}
#define nh_observeValueForKeyPathOnMainThread(keyPath, object, change, context) if (![NSThread isMainThread]) { ALog(@"KVO triggered off the main thread"); }
#else
#define DLog(...) do { } while (0)
#define DFLog(...) do { } while (0)
#ifndef NS_BLOCK_ASSERTIONS
#define NS_BLOCK_ASSERTIONS
#endif
#define ALog(...) NSLog(@"%s(%p) %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__])
#define AFLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#define nh_observeValueForKeyPathOnMainThread(keyPath, object, change, context) if (![NSThread isMainThread]) {dispatch_async(dispatch_get_main_queue(), ^{[self observeValueForKeyPath:keyPath ofObject:object change:change context:context];}); return;}
#endif

#define NHRectCenter(rect) CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
#define NHAssert(condition, ...) do { if (!(condition)) { ALog(__VA_ARGS__); }} while(0)
#define NHFAssert(condition, ...) do { if (!(condition)) { AFLog(__VA_ARGS__); }} while(0)

#define DFLOG_NOT_IMPLEMENTED()         DFLog(@"not implemented")
