# NHUtilities

This set of utilities is primarily intended for my own personal use at this point.
However, anyone interested in using it may do so freely, without any guarantees from me.
Specifically, use of this code is granted with the [MIT License](http://opensource.org/licenses/MIT).

## Classes

### NHBitSet

An Objective-C wrapper for CFBitSet.

### NHCoreDataController

A simple CoreData stack.

### NHJSONImportController

A simple way to import a blob of JSON data into CoreData

## Categories

### NSArray (NHUtilities)

```objective-c
+ (NSArray *)arrayWithNumberRange: (NSRange) range;
+ (NSArray *)arrayWithObject: (id) object count: (NSUInteger) count;
- (NSArray *)shuffled;
```
