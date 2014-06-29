//
// Created by Mikkel Gravgaard on 13/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUM.h"
#import "MUMAbstractClient.h"

@class SPPlaybackManager;
@class SpotifyTrack;


@interface MUMSpotifyClient : MUMAbstractClient<MUMClient>
@property (nonatomic, weak) UIViewController *presentingViewController;

- (instancetype)initWithStarredPlaylist;
- (instancetype)initWithPlaylistName:(NSString*)playlistName;

- (RACSignal *)playlistWithName:(NSString *)name;

- (void)playTrack:(SpotifyTrack *)track;

- (void)stop;
@end