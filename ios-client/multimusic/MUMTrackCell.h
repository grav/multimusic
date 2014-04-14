//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LocalTrack;
@protocol MUMTrack;


@interface MUMTrackCell : UITableViewCell

- (void)configure:(id<MUMTrack>)track;

@end