//
// Created by Mikkel Gravgaard on 13/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "SPTTrack.h"
#import "SPTrack.h"

@interface SPTTrack ()
@property (nonatomic, strong) SPTrack *spTrack;
@end

@implementation SPTTrack {

}

+ (instancetype)trackWithSPTrack:(SPTrack *)spTrack {
    SPTTrack *track = [SPTTrack new];
    track.spTrack = spTrack;
    return track;
}


- (NSString *)trackDescription {
    return [NSString stringWithFormat:@"%@ - %@",self.spTrack.consolidatedArtists,self.spTrack.name];
}

- (void)play {
//    [SPAsyncLoading waitUntilLoaded:self.spTrack timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *tracks, NSArray *notLoadedTracks) {
//        [self.playbackManager playTrack:track callback:^(NSError *error) {
//            [self.activityView stopAnimating];
//            if (error) {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Play Track"
//                                                                message:[error localizedDescription]
//                                                               delegate:nil
//                                                      cancelButtonTitle:@"OK"
//                                                      otherButtonTitles:nil];
//                [alert show];
//            }
//
//        }];
//    }];
    NSLog(@"TO BE IMPLEMENTED");
}

- (void)stop {
    NSLog(@"TO BE IMPLEMENTED");
}


@end