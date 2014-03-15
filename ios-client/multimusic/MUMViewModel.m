//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMViewModel.h"
#import "Track.h"
#import "ReactiveCocoa.h"
#import "MUMClient.h"

@interface MUMViewModel ()
@property(nonatomic, strong, readwrite) NSArray *tracks;
@end

@implementation MUMViewModel {

}

- (instancetype)init {
    if (!(self = [super init])) return nil;
    RAC(self,tracks) = [[MUMClient new] getTracks];
    return self;
}


@end