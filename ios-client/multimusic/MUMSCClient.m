//
// Created by Mikkel Gravgaard on 09/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMSCClient.h"
#import "SCRequest.h"
#import "SCAccount.h"
#import "SCSoundCloud.h"
#import "SCUIErrors.h"
#import "SCLoginViewController.h"
#import "MUMConstants.h"

static const NSString *kSCBaseUrl = @"http://api.soundcloud.com/";

@interface MUMSCClient ()
@end

@implementation MUMSCClient {

}

- (RACSignal *)loginWithPresentingViewController:(UIViewController *)viewController {
    RACSignal *loginSignal = [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL){
            RACSignal *s = [self loginSignalFromViewControllerWithPreparedURL:preparedURL presentingViewController:viewController];
            [s subscribe:subscriber];
        }];
        return nil;
    }];

    return loginSignal;
}

- (RACSignal *)loginSignalFromViewControllerWithPreparedURL:(NSURL *)preparedURL
                                   presentingViewController:(UIViewController *)presentingViewController {
    RACSignal *loginSignal = [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        UIViewController *vc;
        @weakify(vc)
        vc = [SCLoginViewController loginViewControllerWithPreparedURL:preparedURL
                                                    completionHandler:^(NSError *error){
            @strongify(vc)
            [vc dismissViewControllerAnimated:YES completion:nil];
            if (SC_CANCELED(error)) {
                [subscriber sendError:error];
            } else if (error) {
                [subscriber sendError:error];
                NSLog(@"Ooops, something went wrong: %@", [error localizedDescription]);
            } else {
                [subscriber sendCompleted];
                NSLog(@"Done!");
            }
        }];
        [presentingViewController presentViewController:vc animated:YES completion:nil];
        return nil;
    }];
    return [loginSignal replayLazily];

}


- (RACSignal *)scGet:(NSString*)path
{
    NSString *fullPath = [NSString stringWithFormat:@"%@%@",kSCBaseUrl,path];
    NSURL *url = [NSURL URLWithString:fullPath];
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        [SCRequest performMethod:SCRequestMethodGET
                               onResource:url
                          usingParameters:nil
                              withAccount:[SCSoundCloud account]
                   sendingProgressHandler:nil
                          responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                                // Handle the response
                                if (error) {
                                    [subscriber sendError:error];
                                } else {
                                    RACTuple *result = [RACTuple tupleWithObjectsFromArray:@[response,data]];
                                    [subscriber sendNext:result];
                                    [subscriber sendCompleted];
                                }
      }];
      return nil;
    }];
}
@end