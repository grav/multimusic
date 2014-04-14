//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUM.h"

@class RACSignal;
@class LocalTrack;


@interface MUMLocalClient : NSObject<MUMClient>
- (void)playTrack:(LocalTrack *)track;

- (RACSignal *)getTracks;

- (void)stop;
@end