//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMViewModel.h"
#import "MUMHTTPStreamingClient.h"
#import "NSArray+Functional.h"

@interface MUMViewModel ()
@property(nonatomic, strong, readwrite) NSArray *tracks;
@property (nonatomic, readwrite) BOOL playing;
@property (nonatomic, readwrite) NSArray *clients;
@end

@implementation MUMViewModel {

}

+ (instancetype)searchViewModelWithClients:(NSArray *)clients {

    return [[MUMViewModel alloc] initWithClients:clients
                                    clientAction:^RACSignal *(id <MUMClient> client, id searchString) {
                return [client search:searchString];
            }];
}

+ (instancetype)tracklistingViewModelWithClients:(NSArray *)clients {
    return [[MUMViewModel alloc] initWithClients:clients clientAction:^RACSignal *(id <MUMClient> client, id _) {
        return [client getTracks];
    }];
}

- (instancetype)initWithClients:(NSArray *)clients clientAction:(ClientAction)clientAction {
    if (!(self = [super init])) return nil;
    self.clients = clients;

    RACSignal *triggerSignal = [self rac_signalForSelector:@selector(reload:)];

    RAC(self,tracks) = [[[triggerSignal flattenMap:^RACStream *(id trigger) {
        NSArray *enabledClients = [clients filterUsingBlock:^BOOL(id <MUMClient> client) {
            return client.enabled;
        }];
        if(enabledClients.count==0) return [RACSignal return:@[]];

        return [[RACSignal combineLatest:[enabledClients mapUsingBlock:^id(id <MUMClient> client) {
            return [clientAction(client, trigger) catch:^RACSignal *(NSError *error) {
                NSLog(@"Error while getting tracks from %@: %@", client, error);
                return [RACSignal return:@[]];
            }];
        }]] map:^id(RACTuple *tuple) {
            return [tuple.allObjects reduceUsingBlock:^id(id aggregation, id obj) {
                return [aggregation arrayByAddingObjectsFromArray:obj];
            }                      initialAggregation:@[]];
        }];
    }] map:^id(NSArray *array) {
        return [array sortedArrayUsingComparator:^NSComparisonResult(id <MUMTrack> obj1, id <MUMTrack> obj2) {
            return [[obj1.trackDescription lowercaseString] compare:[obj2.trackDescription lowercaseString]];
        }];
    }] deliverOn:[RACScheduler mainThreadScheduler]];

    RAC(self,playing) = [[RACSignal merge:[clients mapUsingBlock:^id(id <MUMClient> client) {
        return RACObserve(client, playing);
    }]] distinctUntilChanged];

    return self;
}

- (void)reload:(id)_ {
}


@end