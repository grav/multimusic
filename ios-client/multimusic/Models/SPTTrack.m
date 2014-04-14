//
// Created by Mikkel Gravgaard on 13/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "SPTTrack.h"
#import "SPTrack.h"
#import "MUMSPTClient.h"

@interface SPTTrack ()
@property (nonatomic, strong) SPTrack *spTrack;
@property (nonatomic, weak) MUMSPTClient *client;
@end

@implementation SPTTrack {

}

+ (instancetype)trackWithSPTrack:(SPTrack *)spTrack client:(MUMSPTClient *)client {
    SPTTrack *track = [SPTTrack new];
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