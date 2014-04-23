//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMViewModel.h"
#import "MUMLocalClient.h"
#import "MUMSCClient.h"
#import "MUMSPTClient.h"
#import "NSArray+Functional.h"

@interface MUMViewModel ()
@property(nonatomic, strong, readwrite) NSArray *tracks;
@end

@implementation MUMViewModel {

}

- (instancetype)init{
    if (!(self = [super init])) return nil;

    MUMSCClient *mumscClient = [MUMSCClient new];
    RAC(mumscClient,presentingViewController) = RACObserve(self,presentingViewController);

    MUMLocalClient *localClient = [MUMLocalClient new];
    MUMSPTClient *mumsptClient = [MUMSPTClient new];
    NSArray *clients = @[mumscClient, localClient, mumsptClient];


    RAC(self,tracks) = [[RACSignal combineLatest:[clients mapUsingBlock:^id(id<MUMClient>client) {
            return [[client getTracks] catch:^RACSignal *(NSError *error) {
                NSLog(@"Error while getting tracks from %@: %@",client,error);
                return [RACSignal return:@[]];
            }];
        }]] map:^id(RACTuple *tuple) {
       return [tuple.allObjects reduceUsingBlock:^id(id aggregation, id obj) {
           return [aggregation arrayByAddingObjectsFromArray:obj];
       } initialAggregation:@[]];
    }];

    return self;
}


@end