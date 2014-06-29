//
//  MUMAppDelegate.m
//  multimusic
//
//  Created by Mikkel Gravgaard on 09/03/14.
//  Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MUMAppDelegate.h"
#import "MUMTableViewController.h"
#import "DCIntrospect.h"
#import "MMDrawerController.h"
#import "MUMMenuViewController.h"
#import "MMDrawerVisualState.h"
#import "MUMViewModel.h"
#import "MUMSpotifyClient.h"
#import "MUMSoundCloudClient.h"
#import "MUMLocalClient.h"

@implementation MUMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupAudio];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];

    MUMViewModel *viewModel = [MUMViewModel tracklistingViewModelWithClients:@[
            [MUMLocalClient new],
//            [MUMSoundCloudClient new],
            [MUMSpotifyClient new]
    ]];

    MUMTableViewController *mainVC = [[MUMTableViewController alloc] initWithViewModel:viewModel];
    MUMMenuViewController *menuViewController = [[MUMMenuViewController alloc] initWithViewModel:viewModel];
    MMDrawerController *drawerController = [[MMDrawerController alloc] initWithCenterViewController:mainVC
                                                                           leftDrawerViewController:menuViewController];
    drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeBezelPanningCenterView;
    drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModePanningCenterView | MMCloseDrawerGestureModeTapCenterView;
    [drawerController setDrawerVisualStateBlock:[MMDrawerVisualState parallaxVisualStateBlockWithParallaxFactor:2]];
    self.window.rootViewController = drawerController;
    [self.window makeKeyAndVisible];
#if TARGET_IPHONE_SIMULATOR
    [[DCIntrospect sharedIntrospector] start];
#endif
    return YES;
}

- (void)setupAudio{
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:&setCategoryErr];
    [[AVAudioSession sharedInstance] setActive:YES error:&activationErr];
    NSCAssert(!setCategoryErr && !activationErr,@"");

}


@end