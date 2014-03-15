//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "Track.h"

@interface Track ()
@property (nonatomic, copy, readwrite) NSString *artist, *title, *filename;
@end

@implementation Track {

}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [Track directMappings];
}

+ (NSDictionary *)directMappings{
    NSArray *keyvals = @[@"filename", @"artist", @"album", @"title"];
    return [NSMutableDictionary dictionaryWithObject:keyvals forKey:keyvals];
}

- (NSString *)asString {
    return [NSString stringWithFormat:@"%@ - %@",self.artist,self.title];
}

- (NSURL *)playbackUrl
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kBaseUrl,self.filename];

    return [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding : NSUTF8StringEncoding]];
}


@end

@implementation Track (Stub)
+ (instancetype)trackWithArtist:(NSString *)artist title:(NSString *)title {
    Track *track = [Track new];
    track.artist = artist;
    track.title = title;
    track.filename = @"media/sunshine-riff.mp3";
    return track;
}
@end