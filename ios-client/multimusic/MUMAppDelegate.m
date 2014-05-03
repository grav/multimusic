//
//  MUMAppDelegate.m
//  multimusic
//
//  Created by Mikkel Gravgaard on 09/03/14.
//  Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "MUMAppDelegate.h"
#import "MUMTableViewController.h"
#import "DCIntrospect.h"
#import "SCSoundCloud.h"
#import "MMDrawerController.h"
#import "MUMMenuViewController.h"
#import "MMDrawerVisualState.h"

@implementation MUMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [SCSoundCloud  setClientID:@"7cc559f59cdc1b30f4b2eca5f17513dc"
                        secret:@"4c37a785c05debd2caf185559f0d22ce"
                   redirectURL:[NSURL URLWithString:@"multimusic://soundcloud/callback"]];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];

    MMDrawerController *drawerController = [[MMDrawerController alloc] initWithCenterViewController:[MUMTableViewController new]
                                                                     leftDrawerViewController:[MUMMenuViewController new]];
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

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

}

@end