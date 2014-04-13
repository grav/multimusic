//
// Created by Mikkel Gravgaard on 13/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MUMTrack;

@protocol MUMClient
- (RACSignal *)getTracks;
@end

@protocol MUMTrack <NSObject>
@property(nonatomic, copy, readonly) NSString *trackDescription;
- (void)play;
- (void)stop;
@end