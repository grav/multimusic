//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "LocalTrack.h"
#import "MUMLocalClient.h"

@interface LocalTrack ()
@property (nonatomic, copy, readwrite) NSString *artist, *title, *filename;
@end

@implementation LocalTrack {

}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{};
}

- (NSURL *)playbackUrl
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", self.client.hostName, self.filename];

    return [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding : NSUTF8StringEncoding]];
}

- (void)play {
    [self.client playTrack:self];
}

- (void)stop {
    [self.client stop];
}


- (NSString *)trackDescription
{
    if(!self.title) return [self.filename lastPathComponent];
    return [NSString stringWithFormat:@"%@ - %@",self.artist,self.title];
}

+ (UIImage *)sourceImage {
    return [UIImage imageNamed:@"disk"];
}

@end

@implementation LocalTrack (Stub)
+ (instancetype)trackWithArtist:(NSString *)artist title:(NSString *)title {
    LocalTrack *track = [LocalTrack new];
    track.artist = artist;
    track.title = title;
    track.filename = @"media/sunshine-riff.mp3";
    return track;
}
@end