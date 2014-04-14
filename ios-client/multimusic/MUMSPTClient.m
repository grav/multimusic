//
// Created by Mikkel Gravgaard on 13/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMSPTClient.h"
#include "appkey.c"
#import "CocoaLibSpotify.h"
#import "NSArray+Functional.h"


static NSString *const kSpotifyUsername = @"113192706";

@implementation MUMSPTClient {

}


- (RACSignal *)getTracks {

    
    NSError *error;

    NSString *passwordFilePath = [NSString stringWithFormat:@"%@/spotify_password.txt",[[NSBundle mainBundle] resourcePath]];
    NSString *spotifyPassword = [NSString stringWithContentsOfFile:passwordFilePath encoding:NSUTF8StringEncoding error:&error];
    NSCAssert(!error,@"Error reading from %@: %@", passwordFilePath,error);
    NSLog(@"Logging in...");
    [[SPSession sharedSession] attemptLoginWithUserName:kSpotifyUsername
                                    password:spotifyPassword];

    return [[[[self rac_signalForSelector:@selector(sessionDidLoginSuccessfully:)] map:^id(id value) {
        return [self playlistWithName:@"My likes"];
    }] flatten] map:^id(SPPlaylist *playlist) {
        return playlist.items;
    }];
}
- (void)sessionDidLoginSuccessfully:(SPSession *)aSession {
    NSLog(@"logged in");
}

- (RACSignal *)playlistWithName:(NSString *)name{

    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        SPPlaylistContainer *playlistContainer = [[SPSession sharedSession] userPlaylists];
        [SPAsyncLoading waitUntilLoaded:@[playlistContainer,playlistContainer.flattenedPlaylists] timeout:10 then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
            NSArray *playlists = [playlistContainer.flattenedPlaylists filterUsingBlock:^BOOL(SPPlaylist *playlist) {
                return [playlist.name isEqualToString:name];
            }];
            if(playlists.count>0){
                [subscriber sendNext:playlists.firstObject];
            } else {
                NSString *desc = [NSString stringWithFormat:@"No playlist named '%@'",name];
                NSError *error = [NSError errorWithDomain:@"betafunk"
                                                     code:-1 
                                                 userInfo:@{NSLocalizedDescriptionKey: desc}];
                [subscriber sendError:error];
            }
        }];
        return nil;
    }];

}

@end