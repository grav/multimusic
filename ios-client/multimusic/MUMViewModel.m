//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMViewModel.h"
#import "MUMLocalClient.h"
#import "MUMSCClient.h"
#import "MUMSPTClient.h"

@interface MUMViewModel ()
@property(nonatomic, strong, readwrite) NSArray *tracks;
@property(nonatomic, strong) MUMSCClient *scClient;
@property(nonatomic, strong) MUMLocalClient *localClient;
@property(nonatomic, strong) MUMSPTClient *sptClient;
@end

@implementation MUMViewModel {

}

- (instancetype)init{
    if (!(self = [super init])) return nil;

    self.localClient = [MUMLocalClient new];
    RACSignal *localTracks = [[self.localClient getTracks] catch:^RACSignal *(NSError *error) {
        NSLog(@"Error while getting tracks: %@",error);
        return [RACSignal return:@[]];
    }];

    self.scClient = [MUMSCClient new];
    RAC(self.scClient,presentingViewController) = RACObserve(self,presentingViewController);
    RACSignal *scLikes = [self.scClient getTracks];

    self.sptClient = [MUMSPTClient new];
    RACSignal *sptTracks = [self.sptClient getTracks];

    RAC(self,tracks) = [[RACSignal combineLatest:@[localTracks, scLikes, sptTracks]] map:^id(RACTuple *tuple) {
       return [[tuple.first arrayByAddingObjectsFromArray:tuple.second] arrayByAddingObjectsFromArray:tuple.third];
   }];

    return self;
}


@end