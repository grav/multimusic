//
// Created by Mikkel Gravgaard on 23/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (MUMAdditions)
+ (instancetype)mum_errorWithDescription:(NSString*)desc;
@end