//
// Created by Mikkel Gravgaard on 26/07/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPPlaybackManager;


@interface BTFSpotify : NSObject
@property (nonatomic, readonly) SPPlaybackManager *playbackManager;
@property(nonatomic, readonly) BOOL wantsPresentingViewController;
@property (nonatomic, weak) UIViewController *presentingViewController;

- (RACSignal *)starredPlaylist;

- (RACSignal *)playlistWithName:(NSString *)name;

- (RACSignal *)load:(id)thing;
@end