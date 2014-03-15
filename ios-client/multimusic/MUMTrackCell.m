//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMTrackCell.h"
#import "Track.h"


@implementation MUMTrackCell {

}

- (void)configure:(Track *)track {
    self.textLabel.text = [track asString];
}


@end