//
// Created by Mikkel Gravgaard on 13/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMSpotifyClient.h"
#import "CocoaLibSpotify.h"
#import "NSArray+Functional.h"
#import "SpotifyTrack.h"
#import "NSError+MUMAdditions.h"
#import "BTFSpotify.h"
#include "../appkey.c"

@interface MUMSpotifyClient () <SPSessionDelegate>
@property (nonatomic,readwrite) BOOL wantsPresentingViewController;
@property (nonatomic, readwrite) BOOL playing;
@property(nonatomic, copy) NSString *playlistName;
@property(nonatomic, strong) BTFSpotify *btfSpotify;
@end

@implementation MUMSpotifyClient {

}

- (instancetype)initWithStarredPlaylist{
    return [self initWithPlaylistName:nil];
}

- (instancetype)initWithPlaylistName:(NSString*)playlistName {
    if (!(self = [super init])) return nil;
    self.playlistName = playlistName;
    self.btfSpotify = [[BTFSpotify alloc] initWithAppKey:g_appkey size:g_appkey_size];
    RAC(self,wantsPresentingViewController) = [RACObserve(self.btfSpotify, wantsPresentingViewController) logNext];
    RAC(self.btfSpotify,presentingViewController) = [RACObserve(self, presentingViewController) logNext];


    RACSignal *playbackManager = RACObserve(self.btfSpotify, playbackManager);
    RAC(self,playing) = [playbackManager flattenMap:^RACStream *(SPPlaybackManager *p) {
        return [RACObserve(p, currentTrack) map:^id(id value) {
                return @(value!=nil);
            }];
    }];


    return self;
}


- (NSString *)name {
    return @"Spotify";
}




- (RACSignal *)getTracks {
    RACSignal *playlistSignal = self.playlistName ? [self.btfSpotify playlistWithName:self.playlistName] : [self.btfSpotify starredPlaylist];
    return [[playlistSignal flattenMap:^RACStream *(SPPlaylist *playlist) {
        NSArray *tracks = [playlist.items mapUsingBlock:^id(SPPlaylistItem *item) {
            return item.item;
        }];
        return [self.btfSpotify load:tracks];
    }] map:^id(NSArray *items) {
        return [[items filterUsingBlock:^BOOL(SPTrack *track) {
            return track.availability == SP_TRACK_AVAILABILITY_AVAILABLE;
        }] mapUsingBlock:^id(SPTrack *t) {
            return [SpotifyTrack trackWithSPTrack:t client:self];
        }];
    }];
}



- (void)playTrack:(SpotifyTrack *)track{
    // TODO - leak
    [[self.btfSpotify load:track.spTrack] subscribeNext:^(SPTrack *loadedTrack) {
        [self.btfSpotify.playbackManager playTrack:loadedTrack callback:^(NSError *error) {
            if(error){
                NSLog(@"error playing back %@: %@",track,error);
            }
        }];
    }];
}


- (void)stop{
    self.btfSpotify.playbackManager.isPlaying = NO;
}

- (void)session:(SPSession *)aSession didGenerateLoginCredentials:(NSString *)credential forUserName:(NSString *)userName {
    NSLog(@"didGenerateLoginCreds");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *storedCredentials = [[defaults valueForKey:@"SpotifyUsers"] mutableCopy];

    if (storedCredentials == nil)
        storedCredentials = [NSMutableDictionary dictionary];

    [storedCredentials setValue:credential forKey:userName];
    [defaults setValue:storedCredentials forKey:@"SpotifyUsers"];
}

- (RACSignal *)search:(NSString *)query {

    return [[self.btfSpotify search:query] map:^id(SPSearch *search) {
        return [search.tracks mapUsingBlock:^id(id track) {
            return [SpotifyTrack trackWithSPTrack:track client:self];
        }];
    }];

}


@end