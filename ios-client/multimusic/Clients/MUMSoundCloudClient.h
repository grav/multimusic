//
// Created by Mikkel Gravgaard on 09/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUM.h"
#import "MUMAbstractClient.h"

@class SoundCloudTrack;

@interface MUMSoundCloudClient : MUMAbstractClient<MUMClient>
@property (nonatomic, weak) UIViewController *presentingViewController;

- (void)playTrack:(SoundCloudTrack *)track;

- (RACSignal *)loginWithPresentingViewController:(UIViewController *)viewController;

- (RACSignal *)getStreamData:(NSString *)streamUrl;

- (RACSignal *)getJSON:(NSString *)path filter:(NSDictionary *)filter;

- (RACSignal *)getTracks;

- (void)stop;
@end