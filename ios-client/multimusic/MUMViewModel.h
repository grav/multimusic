//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MUMSCClient;
@class MUMLocalClient;


@interface MUMViewModel : NSObject
@property(nonatomic, readonly) NSArray *tracks;
@property (nonatomic, weak) UIViewController *presentingViewController;
@end