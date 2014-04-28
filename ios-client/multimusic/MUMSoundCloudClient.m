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
@property (nonatomic, readwrite) BOOL wantsPresentingViewController;
@property (nonatomic, readwrite) BOOL playing;
@end

@implementation MUMSoundCloudClient {

}

- (instancetype)init {
    if (!(self = [super init])) return nil;
    RAC(self,playing) = [[RACObserve(self, player) ignore:nil] flattenMap:^RACStream *(AVAudioPlayer *player) {
        RACSignal *startPlaying = [[player rac_signalForSelector:@selector(play)] map:^id(id value) {
            return @YES;
        }];
        return [RACSignal merge:@[startPlaying, [RACObserve(player,playing) skip:1]]];
    }];
    return self;
}


- (RACSignal *)loginSignal {
    return [[RACSignal return:[SCSoundCloud account]] flattenMap:^RACStream *(id value) {
        if(!value){
            self.wantsPresentingViewController = YES;
            return [[[[self rac_signalForSelector:@selector(setPresentingViewController:) ]  map:^id(RACTuple *tuple) {
                    return tuple.first;
                }]ignore:nil] flattenMap:^RACStream *(UIViewController *viewController) {
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

- (void)stop {
    [self.player pause];
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
        vc = [SCLoginViewController loginViewControllerWithPreparedURL:preparedURL
                                                    completionHandler:^(NSError *error){
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
    return [[self get:streamUrl] map:^id(RACTuple *tuple) {
        return tuple.second;
    }];
}

+ (NSString *)filterString:(NSDictionary *)dictionary{
    __block NSString *string = @"";
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        string = [NSString stringWithFormat:@"%@%@=%@&",string,key,[obj stringByAddingPercentEscapesUsingEncoding : NSUTF8StringEncoding]];
    }];
    return string;
}


- (RACSignal *)getJSON:(NSString *)path{
    return [self getJSON:path filter:nil];
}

- (RACSignal *)getJSON:(NSString *)path filter:(NSDictionary *)filter {

    NSString *filterString = [MUMSoundCloudClient filterString:filter];

    NSString *fullPath = [NSString stringWithFormat:@"%@%@.json?%@",kSCBaseUrl,path,filterString];
    return [[self get:fullPath] flattenMap:^id(RACTuple *tuple) {
        RACTupleUnpack(NSHTTPURLResponse *response, NSData *data) = tuple;
        if(response.statusCode>=400){
            NSString *desc = [NSString stringWithFormat:@"Got http status code %d from client %@ on request %@",response.statusCode,self,fullPath];
            NSError *error = [NSError mum_errorWithDescription:desc];
            return [RACSignal error:error];    
        }
        
        NSError *jsonError;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

        if(jsonError){
            return [RACSignal error:jsonError];
        }
        return [RACSignal return:dict];
    }];
}

- (RACSignal *)get:(NSString *)fullPath {

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
                         [subscriber sendNext:RACTuplePack(response,data)];
                         [subscriber sendCompleted];
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
    return [[self getJSON:path] map:^id(NSArray *likes) {
        return [likes mapUsingBlock:^id(NSDictionary *d) {
            return [self soundCloudTrack:d];
        }];
    }];
}

- (RACSignal *)search:(NSString *)query {
    return [[self getJSON:@"/tracks" filter:@{@"q" : query}] map:^id(NSArray *results) {
        return [results mapUsingBlock:^id(id obj) {
            return [self soundCloudTrack:obj];
        }];
    }];
}

- (SoundCloudTrack *)soundCloudTrack:(NSDictionary *)d {
    NSError *error;
    SoundCloudTrack *track = [MTLJSONAdapter modelOfClass:[SoundCloudTrack class] fromJSONDictionary:d
                                                            error:&error];
    track.client = self;
    return track;
}

@end