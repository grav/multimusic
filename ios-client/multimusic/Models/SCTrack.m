//
// Created by Mikkel Gravgaard on 13/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "SCTrack.h"
#import "MUMSCClient.h"


@implementation SCTrack {

}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"title":@"title",
            @"artist":@"user.username",
            @"streamUrl":@"stream_url"
    };
}

- (void)play {
    [self.client playTrack:self];
}

- (void)stop {
    [self.client stop];
}

- (NSString *)trackDescription {
    return [NSString stringWithFormat:@"%@ - %@",self.artist,self.title];
}

@end