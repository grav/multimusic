//
// Created by Mikkel Gravgaard on 23/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "NSURLConnection+MUMAdditions.h"
#import "NSError+MUMAdditions.h"


@implementation NSURLConnection (MUMAdditions)
+ (RACSignal*)rac_sendAsynchronousHTTPRequest:(NSURLRequest *)request {
    return [[self rac_sendAsynchronousRequest:request] flattenMap:^id(RACTuple *tuple) {
            RACTupleUnpack(NSHTTPURLResponse *response, NSData *data) = tuple;
            if(response.statusCode>=400){
                NSString *desc = [NSString stringWithFormat:@"Got http status code %d on request %@",response.statusCode,request];
                NSError *error = [NSError mum_errorWithDescription:desc];
                return [RACSignal error:error];
            }
        return [RACSignal return:tuple];
    }];
}

+ (RACSignal*)rac_sendAsynchronousJSONRequest:(NSURLRequest *)request {
    return [[self rac_sendAsynchronousHTTPRequest:request] flattenMap:^RACStream *(RACTuple *tuple) {
        RACTupleUnpack(NSHTTPURLResponse *response,NSData *data) = tuple;
        NSError *jsonError;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if(jsonError){
            return [RACSignal error:jsonError];
        }
        return [RACSignal return:dict];
    }];
}

@end