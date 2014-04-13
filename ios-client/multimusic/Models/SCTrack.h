//
// Created by Mikkel Gravgaard on 13/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTLModel.h"
#import "MTLJSONAdapter.h"
#import "MUM.h"

@class MUMSCClient;


@interface SCTrack : MTLModel<MUMTrack,MTLJSONSerializing>
@property (nonatomic, copy, readonly) NSString *streamUrl, *artist, *title;
@property (nonatomic, weak) MUMSCClient *client;
@end