//
// Created by Mikkel Gravgaard on 13/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTLModel.h"
#import "MTLJSONAdapter.h"
#import "MUM.h"

@class MUMSoundCloudClient;


@interface SoundCloudTrack : MTLModel<MUMTrack,MTLJSONSerializing>
@property (nonatomic, copy, readonly) NSString *streamUrl, *artist, *title, *duration;
@property (nonatomic, weak) MUMSoundCloudClient *client;

@end