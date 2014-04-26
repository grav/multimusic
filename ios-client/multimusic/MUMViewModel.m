//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMViewModel.h"
#import "MUMLocalClient.h"
#import "MUMSoundCloudClient.h"
#import "MUMSpotifyClient.h"
#import "NSArray+Functional.h"
#import "NSArray+MUMAdditions.h"

@interface MUMViewModel ()
@property(nonatomic, strong, readwrite) NSArray *tracks;
@property (nonatomic, strong) NSArray *clientsWantingViewController;
@end

@implementation MUMViewModel {

}

- (instancetype)init{
    if (!(self = [super init])) return nil;

    self.clientsWantingViewController = @[];

    MUMSoundCloudClient *soundCloudClient = [MUMSoundCloudClient new];

    MUMLocalClient *localClient = [MUMLocalClient new];

    MUMSpotifyClient *spotifyClient = [MUMSpotifyClient new];

    NSArray *clients = @[soundCloudClient, localClient, spotifyClient];

    [clients enumerateObjectsUsingBlock:^(id<MUMClient> client, NSUInteger idx, BOOL *stop) {
        if([((NSObject*)client) respondsToSelector:@selector(wantsPresentingViewController)]){
            @weakify(self)
            [[RACObserve(client, wantsPresentingViewController) ignore:@NO] subscribeNext:^(id x) {
                @strongify(self)
                self.clientsWantingViewController = [self.clientsWantingViewController arrayByAddingObject:client];
            }];
        }
    }];

    RAC(self,tracks) = [[RACSignal combineLatest:[clients mapUsingBlock:^id(id<MUMClient>client) {
            return [[client getTracks] catch:^RACSignal *(NSError *error) {
                NSLog(@"Error while getting tracks from %@: %@",client,error);
                return [RACSignal return:@[]];
            }];
        }]] map:^id(RACTuple *tuple) {
       return [tuple.allObjects reduceUsingBlock:^id(id aggregation, id obj) {
           return [aggregation arrayByAddingObjectsFromArray:obj];
       } initialAggregation:@[]];
    }];

    RACSignal *presentingVCSignal = [RACObserve(self, presentingViewController) ignore:nil];

    [presentingVCSignal subscribeNext:^(id viewController) {
        id <MUMClient> client = self.clientsWantingViewController.lastObject;
        if(client.presentingViewController) return;
        [self.clientsWantingViewController enumerateObjectsUsingBlock:^(id <MUMClient> c, NSUInteger idx, BOOL *stop) {
            c.presentingViewController = nil;
        }];
        client.presentingViewController = viewController;
        self.clientsWantingViewController = [self.clientsWantingViewController arrayByRemovingLastObject];
    }];

    return self;
}

@end