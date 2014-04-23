//
// Created by Mikkel Gravgaard on 23/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "NSError+MUMAdditions.h"


@implementation NSError (MUMAdditions)
+ (instancetype)mum_errorWithDescription:(NSString *)desc {
    return [NSError errorWithDomain:@"somedomain" code:-1 userInfo:@{NSLocalizedDescriptionKey:desc}];
}

@end