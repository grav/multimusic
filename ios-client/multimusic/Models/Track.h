//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mantle.h"
#import "MUMConstants.h"

@interface Track : MTLModel  <MTLJSONSerializing>
@property (nonatomic, copy, readonly) NSString *filename, *artist, *album, *title;

- (NSString *)asString;
- (NSURL *)playbackUrl;
@end

@interface Track (Stub)
+ (instancetype)trackWithArtist:(NSString *)artist title:(NSString *)title;


@end