//
// Created by Mikkel Gravgaard on 13/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUM.h"

@class SPPlaybackManager;
@class SpotifyTrack;


@interface MUMSpotifyClient : NSObject<MUMClient>
@property (nonatomic, weak) UIViewController *presentingViewController;

- (RACSignal *)playlistWithName:(NSString *)name;

- (void)playTrack:(SpotifyTrack *)track;

- (void)stop;
@end