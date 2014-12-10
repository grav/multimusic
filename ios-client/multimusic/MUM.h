//
// Created by Mikkel Gravgaard on 13/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MUMTrack;

@protocol MUMClient
- (RACSignal *)getTracks;
- (RACSignal *)search:(NSString *)query;
@property(nonatomic, readonly) BOOL playing;
@property(nonatomic) BOOL enabled;
@property(nonatomic, readonly) NSString *name;
@optional
@property(nonatomic, weak) UIViewController *presentingViewController;
@property(nonatomic, readonly) BOOL wantsPresentingViewController;
@property(nonatomic, readonly) UIImage *logo;
@end

@protocol MUMTrack <NSObject>
@property(nonatomic, copy, readonly) NSString *trackDescription;
- (void)play;
- (void)stop;
+ (UIImage*)sourceImage;
@end