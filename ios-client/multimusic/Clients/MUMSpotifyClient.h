//
// Created by Mikkel Gravgaard on 13/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUM.h"
#import "MUMAbstractClient.h"

@class SPPlaybackManager;
@class SpotifyTrack;
@class BTFSpotify;


@interface MUMSpotifyClient : MUMAbstractClient<MUMClient>

- (instancetype)initWithStarredPlaylist;
- (instancetype)initWithPlaylistName:(NSString*)playlistName;
@property (nonatomic, weak) UIViewController *presentingViewController;

- (void)playTrack:(SpotifyTrack *)track;

- (void)stop;
@end