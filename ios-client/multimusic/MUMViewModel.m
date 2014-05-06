//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMViewModel.h"
#import "MUMLocalClient.h"
#import "MUMSoundCloudClient.h"
#import "MUMSpotifyClient.h"
#import "NSArray+Functional.h"
#import "MUM.h"
#import "NSArray+MUMAdditions.h"

@interface MUMViewModel ()
@property(nonatomic, strong, readwrite) NSArray *tracks;
@property (nonatomic, readwrite) BOOL playing;
@end

@implementation MUMViewModel {

}

+ (instancetype)searchViewModelWithClients:(NSArray *)clients searchSignal:(RACSignal *)searchSignal {

    return [[MUMViewModel alloc] initWithClients:clients
                                   triggerSignal:searchSignal
                                    clientAction:^RACSignal *(id <MUMClient> client, id searchString) {
                                        return [client search:searchString];
                                    }];
}

+ (instancetype)tracklistingViewModelWithClients:(NSArray *)clients loadTrigger:(RACSignal *)loadTrigger {
    return [[MUMViewModel alloc] initWithClients:clients
                                   triggerSignal:loadTrigger
                                    clientAction:^RACSignal *(id <MUMClient> client, id _) {
                                        return [client getTracks];
                                    }];
}

- (instancetype)initWithClients:(NSArray *)clients
                  triggerSignal:(RACSignal *)triggerSignal
                   clientAction:(ClientAction)clientAction {
    if (!(self = [super init])) return nil;

    RAC(self,tracks) = [[triggerSignal flattenMap:^RACStream *(id trigger) {
        return [[RACSignal combineLatest:[clients mapUsingBlock:^id(id <MUMClient> client) {
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
        return [array sortedArrayUsingComparator:^NSComparisonResult(id<MUMTrack> obj1, id<MUMTrack> obj2) {
            return [[obj1.trackDescription lowercaseString] compare:[obj2.trackDescription lowercaseString]];
        }];
    }];

    RAC(self,playing) = [[RACSignal merge:[clients mapUsingBlock:^id(id <MUMClient> client) {
        return RACObserve(client, playing);
    }]] distinctUntilChanged];

    return self;
}

- (NSArray *)filteredTracks {
    NSString *filter = self.filter;
    return [self.tracks filterUsingBlock:^BOOL(id<MUMTrack> track) {
        return filter?[track.trackDescription rangeOfString:filter options:NSCaseInsensitiveSearch].location != NSNotFound : NO;
    }];
}


@end