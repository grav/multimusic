//
// Created by Mikkel Gravgaard on 15/03/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMClient.h"
#import "RACSignal.h"
#import "NSURLConnection+RACSupport.h"
#import "MUMConstants.h"
#import "ReactiveCocoa.h"
#import "NSArray+Functional.h"
#import "Mantle.h"
#import "Track.h"

@implementation MUMClient {

}

+ (NSURL *)libraryUrl
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kBaseUrl, kLibrary]];
}

- (RACSignal *)getTracks {
    NSURLRequest *request = [NSURLRequest requestWithURL:[MUMClient libraryUrl]];
    RACSignal *tracksSignal = [[[[NSURLConnection rac_sendAsynchronousRequest:request] map:^id(RACTuple *tuple) {
        return tuple.second;
    }] map:^id(NSData *data) {
        NSError *error;
        return [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    }] map:^id(NSDictionary *library) {
        NSArray *tracks = library[@"tracks"];
        return [tracks mapUsingBlock:^id(NSDictionary *jsonDictionary) {
            NSError *error;
            return [MTLJSONAdapter modelOfClass:[Track class] fromJSONDictionary:jsonDictionary error:&error];
        }];
    }];



    return tracksSignal;
}


@end