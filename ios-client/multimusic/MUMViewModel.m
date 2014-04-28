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
@property (nonatomic, readwrite) BOOL playing;
@end

@implementation MUMViewModel {

}

- (instancetype)init{
    if (!(self = [super init])) return nil;

    NSArray *clients = @[
            [MUMLocalClient new],
            [MUMSoundCloudClient new],
            [MUMSpotifyClient new]
    ];


    // Adding to vc queue
    NSArray *clientSignals = [[clients filterUsingBlock:^BOOL(NSObject *client) {
        return [client respondsToSelector:@selector(wantsPresentingViewController)];
    }] mapUsingBlock:^id(id<MUMClient> client) {
        return [[RACObserve(client, wantsPresentingViewController) ignore:@NO] mapReplace:client];
    }];

    RAC(self,clientsWantingViewController) = [[RACSignal merge:clientSignals] scanWithStart:@[]
                                                                                     reduce:^id(id running, id client) {
                                                                                         return [running arrayByAddingObject:client];
                                                                                     }];

    // Removing from queue
    RACSignal *presentingVCSignal = [RACObserve(self, presentingViewController) ignore:nil];

    // TODO - combine this with adding to the queue
    @weakify(self)
    [presentingVCSignal subscribeNext:^(id viewController) {
        @strongify(self)
        id <MUMClient> client = self.clientsWantingViewController.lastObject;
        NSCAssert(!client.presentingViewController,@"client already has the presenting vc?");
        [self.clientsWantingViewController enumerateObjectsUsingBlock:^(id <MUMClient> c, NSUInteger idx, BOOL *stop) {
            c.presentingViewController = nil;
        }];
        client.presentingViewController = viewController;
        self.clientsWantingViewController = [self.clientsWantingViewController arrayByRemovingLastObject];
    }];

    RAC(self,tracks) = [[RACSignal combineLatest:[clients mapUsingBlock:^id(id<MUMClient>client) {
            return [[client search:@"sunshine"] catch:^RACSignal *(NSError *error) {
                NSLog(@"Error while getting tracks from %@: %@",client,error);
                return [RACSignal return:@[]];
            }];
        }]] map:^id(RACTuple *tuple) {
       return [tuple.allObjects reduceUsingBlock:^id(id aggregation, id obj) {
           return [aggregation arrayByAddingObjectsFromArray:obj];
       } initialAggregation:@[]];
    }];

    RAC(self,playing) = [RACSignal merge:[clients mapUsingBlock:^id(id<MUMClient> client) {
        return RACObserve(client,playing);
    }]];

    return self;
}

@end