//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMLocalClient.h"
#import "NSArray+Functional.h"
#import "Mantle.h"
#import "LocalTrack.h"
#import "NSURLConnection+MUMAdditions.h"
#import <AVFoundation/AVFoundation.h>

static NSString *kBaseUrl = @"http://localhost:8000/";
static NSString *kLibrary = @"library.json";

@interface MUMLocalClient ()
@property(nonatomic, strong) AVPlayer* player;
@property (nonatomic, readwrite) BOOL playing;
@end

@implementation MUMLocalClient {

}

- (NSString *)name {
    return @"Local files";
}

- (instancetype)init {
    if (!(self = [super init])) return nil;
    RAC(self,playing) = [[RACObserve(self, player) ignore:nil] flattenMap:^RACStream *(AVPlayer *player) {
        return [RACObserve(player,rate) map:^id(NSNumber *rate) {
                return @(rate.floatValue>0);
            }];
    }];
    return self;
}


- (void)playTrack:(LocalTrack *)track {
    self.player = [[AVPlayer alloc] initWithURL:[track playbackUrl]];
    [self.player play];

}


+ (NSURL *)libraryUrl
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kBaseUrl, kLibrary]];
}

- (RACSignal *)getTracks {
    NSURLRequest *request = [NSURLRequest requestWithURL:[MUMLocalClient libraryUrl]];
    RACSignal *tracksSignal = [[NSURLConnection rac_sendAsynchronousJSONRequest:request]  map:^id(NSDictionary *library) {
        NSArray *tracks = library[@"tracks"];
        return [tracks mapUsingBlock:^id(NSDictionary *jsonDictionary) {
            NSError *error;
            LocalTrack * track = [MTLJSONAdapter modelOfClass:[LocalTrack class]
                                           fromJSONDictionary:jsonDictionary
                                                        error:&error];
            track.client = self;
            return track;
        }];
    }];

    return tracksSignal;
}

- (RACSignal *)search:(NSString *)query {
    return [[self getTracks] map:^id(NSArray *tracks) {
        return [tracks filterUsingBlock:^BOOL(LocalTrack *track) {
            NSString *lCaseQuery = [query lowercaseString];
            NSString *searchField = [[track trackDescription] lowercaseString];
            return [searchField rangeOfString:lCaseQuery].location != NSNotFound;
        }];
    }];
}



- (void)stop {
    [self.player pause];

}

+ (NSString *)server {
    return kBaseUrl;
}

@end