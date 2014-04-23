//
// Created by Mikkel Gravgaard on 13/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUM.h"

@class SPTrack;
@class MUMSpotifyClient;


@interface SpotifyTrack : NSObject<MUMTrack>
@property (nonatomic, readonly) SPTrack *spTrack;

+ (instancetype)trackWithSPTrack:(SPTrack *)track client:(MUMSpotifyClient *)client;



@end