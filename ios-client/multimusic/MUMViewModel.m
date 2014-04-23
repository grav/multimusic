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
@property(nonatomic, strong) MUMSCClient *scClient;
@property(nonatomic, strong) MUMLocalClient *localClient;
@property(nonatomic, strong) MUMSPTClient *sptClient;
@end

@implementation MUMViewModel {

}

- (instancetype)init{
    if (!(self = [super init])) return nil;

    self.localClient = [MUMLocalClient new];
    self.scClient = [MUMSCClient new];
    self.sptClient = [MUMSPTClient new];

    NSArray *clients = @[self.localClient,self.scClient,self.sptClient];

    RAC(self.scClient,presentingViewController) = RACObserve(self,presentingViewController);

    RAC(self,tracks) = [[RACSignal combineLatest:[clients mapUsingBlock:^id(id<MUMClient>client) {
            return [[client getTracks] catch:^RACSignal *(NSError *error) {
                NSLog(@"Error while getting tracks from %@: %@",client,error);
                return [RACSignal return:@[]];
            }];
        }]] map:^id(RACTuple *tuple) {
       return [[tuple.first arrayByAddingObjectsFromArray:tuple.second] arrayByAddingObjectsFromArray:tuple.third];
   }];

    return self;
}


@end