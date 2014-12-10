//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mantle.h"
#import "MUM.h"

@class MUMHTTPStreamingClient;

@interface HTTPStreamingTrack : MTLModel  <MTLJSONSerializing,MUMTrack>
@property (nonatomic, copy, readonly) NSString *filename, *artist, *album, *title;
@property (nonatomic, weak) MUMHTTPStreamingClient *client;

+ (UIImage *)sourceImage;

- (NSURL *)playbackUrl;
@end

@interface HTTPStreamingTrack (Stub)
+ (instancetype)trackWithArtist:(NSString *)artist title:(NSString *)title;


@end