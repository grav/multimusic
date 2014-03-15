//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;


@interface MUMClient : NSObject
- (RACSignal *)getTracks;
@end