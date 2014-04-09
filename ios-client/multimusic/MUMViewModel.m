//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMViewModel.h"
#import "Track.h"
#import "ReactiveCocoa.h"
#import "MUMClient.h"
#import "MUMSCClient.h"

@interface MUMViewModel ()
@property(nonatomic, strong, readwrite) NSArray *tracks;
@property(nonatomic, strong) MUMSCClient *scClient;
@end

@implementation MUMViewModel {

}

- (instancetype)init {
    if (!(self = [super init])) return nil;

    self.scClient = [MUMSCClient new];

    RAC(self,tracks) = [[MUMClient new] getTracks];

    RACSignal *vcSignal = [RACObserve(self, presentingViewController) ignore:nil];

    RACSignal *racSignal = [self.scClient rac_liftSelector:@selector(loginWithPresentingViewController:) withSignalsFromArray:@[vcSignal]];

//    [racSignal takeUntil:<#(RACSignal *)signalTrigger#>]

    [racSignal subscribeNext:^(id x) {
        NSLog(@"next: %@", x);
    }                  error:^(NSError *error) {
        NSLog(@"error: %@", error);
    }              completed:^{
        NSLog(@"completed");
    }];

    return self;
}


@end