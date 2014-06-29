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
@property (nonatomic, readonly) NSArray *clients;

+ (instancetype)searchViewModelWithClients:(NSArray *)clients;

+ (instancetype)tracklistingViewModelWithClients:(NSArray *)clients;

- (instancetype)initWithClients:(NSArray *)clients clientAction:(ClientAction)clientAction;

- (void)reload:(id)_;
@end