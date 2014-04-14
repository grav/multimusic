//
// Created by Mikkel Gravgaard on 13/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUM.h"

@class SPPlaybackManager;


@interface MUMSPTClient : NSObject<MUMClient>
@property (nonatomic, readonly) SPPlaybackManager *playbackManager;

- (RACSignal *)loginSignal;
- (RACSignal *)playlistWithName:(NSString *)name;
@end