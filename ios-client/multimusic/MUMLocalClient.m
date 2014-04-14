//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMLocalClient.h"
#import "MUMConstants.h"
#import "NSArray+Functional.h"
#import "Mantle.h"
#import "LocalTrack.h"
#import <AVFoundation/AVFoundation.h>

@interface MUMLocalClient ()
@property(nonatomic, strong) AVPlayer* player;
@end

@implementation MUMLocalClient {

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
    RACSignal *tracksSignal = [[[[NSURLConnection rac_sendAsynchronousRequest:request] map:^id(RACTuple *tuple) {
        return tuple.second;
    }] map:^id(NSData *data) {
        NSError *error;
        return [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    }] map:^id(NSDictionary *library) {
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


- (void)stop {
    [self.player pause];

}
@end