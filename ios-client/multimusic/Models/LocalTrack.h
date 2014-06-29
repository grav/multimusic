//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mantle.h"
#import "MUM.h"

@class MUMLocalClient;

@interface LocalTrack : MTLModel  <MTLJSONSerializing,MUMTrack>
@property (nonatomic, copy, readonly) NSString *filename, *artist, *album, *title;
@property (nonatomic, weak) MUMLocalClient *client;

+ (UIImage *)sourceImage;

- (NSURL *)playbackUrl;
@end

@interface LocalTrack (Stub)
+ (instancetype)trackWithArtist:(NSString *)artist title:(NSString *)title;


@end