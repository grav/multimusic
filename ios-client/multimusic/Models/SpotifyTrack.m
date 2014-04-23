//
// Created by Mikkel Gravgaard on 13/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "SpotifyTrack.h"
#import "SPTrack.h"
#import "MUMSpotifyClient.h"

@interface SpotifyTrack ()
@property (nonatomic, strong) SPTrack *spTrack;
@property (nonatomic, weak) MUMSpotifyClient *client;
@end

@implementation SpotifyTrack {

}

+ (instancetype)trackWithSPTrack:(SPTrack *)spTrack client:(MUMSpotifyClient *)client {
    SpotifyTrack *track = [SpotifyTrack new];
    track.spTrack = spTrack;
    track.client = client;
    return track;
}


- (NSString *)trackDescription {
    return [NSString stringWithFormat:@"%@ - %@",self.spTrack.consolidatedArtists,self.spTrack.name];
}

- (void)play {
    [self.client playTrack:self];
}

- (void)stop {
    [self.client stop];
}

+ (UIImage *)sourceImage {
    return [UIImage imageNamed:@"spotify"];
}


@end