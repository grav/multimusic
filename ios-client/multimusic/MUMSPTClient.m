//
// Created by Mikkel Gravgaard on 13/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMSPTClient.h"
#include "appkey.c"
#import "CocoaLibSpotify.h"
#import "NSArray+Functional.h"
#import "SPTTrack.h"
#import "SPPlaybackManager.h"


static NSString *const kSpotifyUsername = @"113192706";

static NSString *const kPlaylistName = @"My likes";

@interface MUMSPTClient () <SPSessionDelegate>
@property (nonatomic, strong) SPPlaybackManager *playbackManager;
@property (nonatomic, strong) RACSignal *loginSignal;
@property (nonatomic, strong) RACSignal *session;
@end

@implementation MUMSPTClient {

}

- (instancetype)init {
    if (!(self = [super init])) return nil;
    RAC(self,playbackManager) = [self.session map:^id(SPSession *session) {
        return [[SPPlaybackManager alloc] initWithPlaybackSession:session];
    }];
    return self;
}


- (RACSignal *)loginSignal{
    if(!_loginSignal){
        NSError *error;

        NSString *passwordFilePath = [NSString stringWithFormat:@"%@/spotify_password.txt",[[NSBundle mainBundle] resourcePath]];
        NSString *spotifyPassword = [NSString stringWithContentsOfFile:passwordFilePath encoding:NSUTF8StringEncoding error:&error];
        NSCAssert(!error,@"Error reading from %@: %@", passwordFilePath,error);

        [SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size]
       											   userAgent:@"dk.betafunk.splif"
       										   loadingPolicy:SPAsyncLoadingManual
       												   error:&error];

        NSLog(@"Logging in...");           [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];

        [SPSession sharedSession].delegate = self;
        [[SPSession sharedSession] attemptLoginWithUserName:kSpotifyUsername
                                        password:spotifyPassword];

        _loginSignal = [[self rac_signalForSelector:@selector(sessionDidLoginSuccessfully:)] replayLazily];
    }
    return _loginSignal;

}

- (RACSignal *)session{
    if(!_session){
        _session = [[self.loginSignal flattenMap:^RACStream *(id value) {
            return [self load:[SPSession sharedSession]];
        }] replayLazily];
    }
    return _session;
}

- (RACSignal *)getTracks {
    return [[[self playlistWithName:kPlaylistName] map:^id(SPPlaylist *playlist) {
        return playlist.items;
    }] map:^id(NSArray *items) {
        return [items mapUsingBlock:^id(SPPlaylistItem *playlistItem) {
            return [SPTTrack trackWithSPTrack:(SPTrack *) playlistItem.item client:self ];
        }];
    }];
}



- (void)sessionDidLoginSuccessfully:(SPSession *)aSession {
    NSLog(@"logged in");
}

- (RACSignal *)playlistWithName:(NSString *)name{
    return [[[self.session flattenMap:^id(SPSession *session) {
        return [self load:session.userPlaylists];
    }] flattenMap:^id(SPPlaylistContainer *playlistContainer) {
        return [self load:playlistContainer.flattenedPlaylists];
    }] map:^id(NSArray *playlists) {
        // TODO - do we have to go out of RAC domain here?
        return [[playlists filterUsingBlock:^BOOL(SPPlaylist *playlist) {
            return [playlist.name isEqualToString:name];
        }] firstObject];
    }];

}

- (RACSignal *)load:(id)thing{
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        [SPAsyncLoading waitUntilLoaded:thing timeout:kSPAsyncLoadingDefaultTimeout
                                   then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
                                       if(loadedItems.count==1){
                                            [subscriber sendNext:loadedItems.firstObject];
                                       } else if(loadedItems.count>1){
                                           [subscriber sendNext:loadedItems];
                                       } else {
                                           NSCAssert(notLoadedItems.count>0,@"");
                                           NSString *string = [NSString stringWithFormat:@"Could not load %@",thing];
                                           NSError *error = [NSError errorWithDomain:@"foo"
                                                                                code:-1
                                                                            userInfo:@{NSLocalizedDescriptionKey: string}];
                                           [subscriber sendError:error];
                                       }
                                   }];
        return nil;
    }];
}


- (void)playTrack:(SPTTrack *)track{
    [[self load:track.spTrack] subscribeNext:^(SPTrack *loadedTrack) {
        [self.playbackManager playTrack:loadedTrack callback:^(NSError *error) {
            NSLog(@"error playing back %@: %@",track,error);
        }];
    }];
}

- (void)stop{
    self.playbackManager.isPlaying = NO;
}

@end