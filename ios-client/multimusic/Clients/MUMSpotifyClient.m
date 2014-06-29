//
// Created by Mikkel Gravgaard on 13/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMSpotifyClient.h"
#include "../appkey.c"
#import "CocoaLibSpotify.h"
#import "NSArray+Functional.h"
#import "SpotifyTrack.h"
#import "NSError+MUMAdditions.h"

static NSString *const kPlaylistName = @"My Top Rated";

@interface MUMSpotifyClient () <SPSessionDelegate>
@property (nonatomic, strong) SPPlaybackManager *playbackManager;
@property (nonatomic, readonly) RACSignal *session;
@property (nonatomic,readwrite) BOOL wantsPresentingViewController;
@property (nonatomic, readwrite) BOOL playing;
@end

@implementation MUMSpotifyClient {

}

- (SPPlaybackManager *)playbackManager {
    if(!_playbackManager){
        _playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
        RAC(self,playing) = [RACObserve(_playbackManager, currentTrack) map:^id(id value) {
            return @(value!=nil);
        }];
    }
    return _playbackManager;
}

- (RACSignal *)session{
    return [[RACSignal return:[SPSession sharedSession]] flattenMap:^RACStream *(SPSession *session) {
        if(session){
            return [RACSignal return:session];
        } else {
            NSError *error;

            BOOL result = [SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size]
           											   userAgent:@"dk.betafunk.splif"
           										   loadingPolicy:SPAsyncLoadingManual
           												   error:&error];
            NSCAssert(result,@"");
            // TODO - might want to handle error nicer here


            NSLog(@"Logging in...");
            session = [SPSession sharedSession];
            session.delegate = self;

            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *storedCredentials = [defaults valueForKey:@"SpotifyUsers"];
            id key = [[storedCredentials allKeys] firstObject];

            // TODO - handle case where storedCredentials is too old!
            if(key){
                NSString *pw = storedCredentials[key];
                [session attemptLoginWithUserName:key existingCredential:pw];
            } else {
                // TODO - handle case where user cancels - we'll never complete then!
                self.wantsPresentingViewController = YES;
                [[[[[self rac_signalForSelector:@selector(setPresentingViewController:)] map:^id(RACTuple *tuple) {
                    return tuple.first;
                }] ignore:nil] delay:1 ] subscribeNext:^(UIViewController *presentingVC) {
                    UIViewController *loginVC = [SPLoginViewController loginControllerForSession:session];
                    [presentingVC presentViewController:loginVC animated:YES completion:nil];
                }];
            }
            RACSignal *didSucceed = [[self rac_signalForSelector:@selector(sessionDidLoginSuccessfully:)] flattenMap:^RACStream *(RACTuple *tuple) {
                        return [self load:tuple.first];
                    }];
            RACSignal *didFail = [[self rac_signalForSelector:@selector(session:didFailToLoginWithError:)] flattenMap:^RACStream *(RACTuple *tuple) {
                return [RACSignal error:tuple.second];
            }];

            return [RACSignal merge:@[didSucceed,didFail]];
        }
    }];
}

- (void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error {
    NSLog(@"session failed login: %@",error);
}


- (RACSignal *)getTracks {
    return [[[self playlistWithName:kPlaylistName] map:^id(SPPlaylist *playlist) {
        return playlist.items;
    }] map:^id(NSArray *items) {
        return [[items mapUsingBlock:^id(SPPlaylistItem *playlistItem) {
            return [SpotifyTrack trackWithSPTrack:(SPTrack *) playlistItem.item client:self];
        }] filterUsingBlock:^BOOL(SpotifyTrack *track) {
            return track.spTrack.availability == SP_TRACK_AVAILABILITY_AVAILABLE;
        }];
    }];
}



- (void)sessionDidLoginSuccessfully:(SPSession *)aSession {
    NSLog(@"Spotify logged in");
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
                                           NSError *error = [NSError mum_errorWithDescription:string];
                                           [subscriber sendError:error];
                                       }
                                   }];
        return nil;
    }];
}


- (void)playTrack:(SpotifyTrack *)track{
    // TODO - leak
    [[self load:track.spTrack] subscribeNext:^(SPTrack *loadedTrack) {
        [self.playbackManager playTrack:loadedTrack callback:^(NSError *error) {
            if(error){
                NSLog(@"error playing back %@: %@",track,error);
            }
        }];
    }];
}


- (void)stop{
    self.playbackManager.isPlaying = NO;
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

    return [[self.session flattenMap:^RACStream *(SPSession *session) {
        SPSearch *search = [SPSearch searchWithSearchQuery:query inSession:session];
        return [self load:search];
    }] map:^id(SPSearch *search) {
        return [search.tracks mapUsingBlock:^id(id track) {
            return [SpotifyTrack trackWithSPTrack:track client:self];
        }];
    }];

}


@end