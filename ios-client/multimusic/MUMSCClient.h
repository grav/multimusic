//
// Created by Mikkel Gravgaard on 09/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUMSCClient : NSObject
- (RACSignal *)loginWithPresentingViewController:(UIViewController *)viewController;
@end