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

+ (instancetype)searchViewModelWithClients:(NSArray *)clients searchDisplayDelegate:(id <UISearchDisplayDelegate>)delegate;

+ (instancetype)tracklistingViewModelWithClients:(NSArray *)clients;

- (instancetype)initWithClients:(NSArray *)clients triggerSignal:(RACSignal *)triggerSignal clientAction:(ClientAction)clientAction;
@end