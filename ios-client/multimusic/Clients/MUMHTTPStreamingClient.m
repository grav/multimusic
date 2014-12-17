//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMHTTPStreamingClient.h"
#import "NSArray+Functional.h"
#import "Mantle.h"
#import "HTTPStreamingTrack.h"
#import "NSURLConnection+MUMAdditions.h"
#import <AVFoundation/AVFoundation.h>

static NSString *kLibrary = @"library.json";

@interface MUMHTTPStreamingClient ()
@property(nonatomic, strong) AVPlayer* player;
@property(nonatomic, copy) NSString *hostName;
@end

@implementation MUMHTTPStreamingClient {

}

- (NSString *)name {
    return @"Web files";
}

- (instancetype)initWithHostName:(NSString *)hostName {
    if (!(self = [super init])) return nil;
    self.hostName = hostName;
    return self;
}


- (void)playTrack:(HTTPStreamingTrack *)track {
    self.player = [[AVPlayer alloc] initWithURL:[track playbackUrl]];
    [self.player play];

//    [[RACSignal interval:3 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
//        NSArray *keyPaths = @[@"rate",@"currentTime",@"status",@"error",@"currentItem"];
//        [keyPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            NSLog(@"%@: %@",obj, [self.player valueForKeyPath:obj]);
//        }];
//        NSLog(@"time in secs: %f",CMTimeGetSeconds(self.player.currentTime));
//
//
//        [@[@"playbackLikelyToKeepUp", @"playbackBufferEmpty", @"playbackBufferFull", @"accessLog", @"errorLog"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            NSLog(@"%@: %@",obj,[self.player.currentItem valueForKeyPath:obj]);
//        }];
//    }];



}


- (NSURL *)libraryUrl
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", self.hostName, kLibrary]];
}

- (RACSignal *)getTracks {
    NSURLRequest *request = [NSURLRequest requestWithURL:[self libraryUrl]];
    RACSignal *tracksSignal = [[NSURLConnection rac_sendAsynchronousJSONRequest:request]  map:^id(NSDictionary *library) {
        NSArray *tracks = library[@"tracks"];
        return [tracks mapUsingBlock:^id(NSDictionary *jsonDictionary) {
            NSError *error;
            HTTPStreamingTrack * track = [MTLJSONAdapter modelOfClass:[HTTPStreamingTrack class]
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
        return [tracks filterUsingBlock:^BOOL(HTTPStreamingTrack *track) {
            NSString *lCaseQuery = [query lowercaseString];
            NSString *searchField = [[track trackDescription] lowercaseString];
            return [searchField rangeOfString:lCaseQuery].location != NSNotFound;
        }];
    }];
}



- (void)stop {
    [self.player pause];

}

- (NSNumber *)currentTrackDuration {
    AVPlayerItem *currentItem = self.player.currentItem;
    NSCAssert(currentItem, @"");
    return @(currentItem ? CMTimeGetSeconds(currentItem.duration) : 0);
}

- (NSNumber *)elapsed {
    AVPlayerItem *currentItem = self.player.currentItem;
    NSCAssert(currentItem, @"");
    return @(currentItem ? CMTimeGetSeconds(currentItem.currentTime) : 0);
}

- (BOOL)playing {
    return self.player.rate > 0;
}


@end