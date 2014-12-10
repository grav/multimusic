//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUM.h"
#import "MUMAbstractClient.h"

@class RACSignal;
@class HTTPStreamingTrack;


@interface MUMHTTPStreamingClient : MUMAbstractClient<MUMClient>
@property(nonatomic, copy,readonly) NSString *hostName;
- (instancetype)initWithHostName:(NSString *)hostName;
- (void)playTrack:(HTTPStreamingTrack *)track;

- (RACSignal *)getTracks;

- (void)stop;

@end