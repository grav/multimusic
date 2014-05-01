//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MUMSoundCloudClient;
@class MUMLocalClient;
@protocol MUMClient;

typedef RACSignal * (^ClientAction)(id<MUMClient>, id);


@interface MUMViewModel : NSObject
@property(nonatomic, readonly) NSArray *tracks;
@property (nonatomic, readonly) BOOL playing;

+ (instancetype)searchViewModelWithClients:(NSArray *)clients searchSignal:(RACSignal *)searchSignal;

+ (instancetype)tracklistingViewModelWithClients:(NSArray *)clients loadTrigger:(RACSignal *)loadTrigger;

- (instancetype)initWithClients:(NSArray *)clients triggerSignal:(RACSignal *)triggerSignal clientAction:(ClientAction)clientAction;
@end