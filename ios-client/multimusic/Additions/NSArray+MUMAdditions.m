//
// Created by Mikkel Gravgaard on 26/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "NSArray+MUMAdditions.h"


@implementation NSArray (MUMAdditions)
- (instancetype)arrayByRemovingLastObject {
    NSMutableArray *array = [self mutableCopy];
    [array removeLastObject];
    return [NSArray arrayWithArray:array];
}
@end