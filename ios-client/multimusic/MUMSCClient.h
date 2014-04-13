//
// Created by Mikkel Gravgaard on 09/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUM.h"

@class SCTrack;

@interface MUMSCClient : NSObject<MUMClient>
@property (nonatomic, weak) UIViewController *presentingViewController;

- (void)playTrack:(SCTrack *)track;

- (RACSignal *)loginWithPresentingViewController:(UIViewController *)viewController;

- (RACSignal *)getStreamData:(NSString *)streamUrl;

- (RACSignal *)getJSON:(NSString *)path;

- (RACSignal *)getTracks;

- (void)stop;
@end