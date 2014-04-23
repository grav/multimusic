//
// Created by Mikkel Gravgaard on 23/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLConnection (MUMAdditions)

// Returns a signal that returns a tuple of response,data
// Handles errors (http status codes >= 400)
+ (RACSignal*)rac_sendAsynchronousHTTPRequest:(NSURLRequest*)request;

// Returns a signal that returns a dictionary of the json response
+ (RACSignal *)rac_sendAsynchronousJSONRequest:(NSURLRequest *)request;

@end