//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMTrackCell.h"
#import "LocalTrack.h"
#import "MUM.h"


@implementation MUMTrackCell {

}

- (void)configure:(id <MUMTrack>)track {
    self.imageView.image = [[track class] sourceImage];
    self.textLabel.text = track.trackDescription;

}

@end