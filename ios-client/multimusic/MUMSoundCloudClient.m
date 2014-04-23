//
// Created by Mikkel Gravgaard on 09/04/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMSoundCloudClient.h"
#import "SCRequest.h"
#import "SCAccount.h"
#import "SCSoundCloud.h"
#import "SCUIErrors.h"
#import "SCLoginViewController.h"
#import "NSArray+Functional.h"
#import "MTLJSONAdapter.h"
#import "SoundCloudTrack.h"
#import "NSError+MUMAdditions.h"
#import <AVFoundation/AVFoundation.h>

static NSString *const kDefaultUser = @"betafunk";
static const NSString *kSCBaseUrl = @"https://api.soundcloud.com";

@interface MUMSoundCloudClient ()
@property(nonatomic, strong) AVAudioPlayer* player;
@property (nonatomic, readonly) RACSignal *loginSignal;
@end

@implementation MUMSoundCloudClient {

}

- (RACSignal *)loginSignal {
    return [[RACSignal return:[SCSoundCloud account]] flattenMap:^RACStream *(id value) {
        if(!value){
            return [[[self rac_signalForSelector:@selector(setPresentingViewController:)] map:^id(RACTuple *tuple) {
                    return tuple.first;
                }] flattenMap:^RACStream *(UIViewController *viewController) {
                    return [self loginWithPresentingViewController:viewController];
                }];
        } else {
            return [RACSignal return:value];
        }
    }];
}


- (void)playTrack:(SoundCloudTrack *)track {
    @weakify(self)
    [[self getStreamData:[track streamUrl]] subscribeNext:^(NSData *data) {
        @strongify(self)
        NSError *error;
        self.player = [[AVAudioPlayer alloc] initWithData:data error:&error];
        [self.player play];
    }];
}

- (RACSignal *)loginWithPresentingViewController:(UIViewController *)viewController {
    if(!viewController) {
        NSString *desc = @"Not authorized, and can't show login-view!";
        NSError *error = [NSError mum_errorWithDescription:desc];
        return [RACSignal error:error];
    } else {
        RACSignal *loginSignal = [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
            [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL){
                RACSignal *s = [self loginSignalFromViewControllerWithPreparedURL:preparedURL presentingViewController:viewController];
                [s subscribe:subscriber];
            }];
            return nil;
        }];

        return loginSignal;

    }

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
                [subscriber sendNext:@YES];
                [subscriber sendCompleted];
                NSLog(@"Logged in!");
            }
        }];
        [presentingViewController presentViewController:vc animated:YES completion:nil];
        return nil;
    }];
    return loginSignal;

}


- (RACSignal *)getStreamData:(NSString*)streamUrl
{
    return [self get:streamUrl completion:^(id <RACSubscriber> subscriber, NSURLResponse *response, NSData *data) {
        [subscriber sendNext:data];
        [subscriber sendCompleted];
    }];
}

- (RACSignal *)getJSON:(NSString*)path
{
    NSString *fullPath = [NSString stringWithFormat:@"%@%@.json",kSCBaseUrl,path];
    return [self get:fullPath completion:^void(id <RACSubscriber> subscriber, NSURLResponse *response, NSData *data) {
        NSError *jsonError;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            [subscriber sendError:jsonError];
        } else {
            RACTuple *result = [RACTuple tupleWithObjectsFromArray:@[response, dict]];
            [subscriber sendNext:result];
            [subscriber sendCompleted];
        }
    }];
}

- (RACSignal *)get:(NSString *)fullPath completion:(void (^)(id <RACSubscriber> subscriber, NSURLResponse *, NSData *))completion {

    NSURL *url = [NSURL URLWithString:fullPath];
    RACSignal *responseSignal = [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        SCAccount *account = [SCSoundCloud account];
        [SCRequest performMethod:SCRequestMethodGET
                      onResource:url
                 usingParameters:nil
                     withAccount:account
          sendingProgressHandler:nil
                 responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                     if (error) {
                         [subscriber sendError:error];
                     } else {
                         completion(subscriber, response, data);
                     }

                 }];
      return nil;
    }];

    return [self.loginSignal flattenMap:^RACStream*(id value) {
        return responseSignal;
    }];
}

- (RACSignal *)getTracks {
    
    NSString *path = [NSString stringWithFormat:@"/users/%@/favorites", kDefaultUser];
    return [[[[self getJSON:path] map:^id(RACTuple *tuple) {
        return tuple.second;
    }] map:^id(NSArray *likes) {
        return [likes mapUsingBlock:^id(NSDictionary *d) {
            NSError *error;
            SoundCloudTrack *track = [MTLJSONAdapter modelOfClass:[SoundCloudTrack class] fromJSONDictionary:d error:&error];
            track.client = self;
            return track;
        }];
    }] catch:^RACSignal *(NSError *error) {
        NSLog(@"%@",error);
        return [RACSignal return:@[]];
    }];
}


- (void)stop {
    [self.player pause];
}
@end