//
//  IronJumpAppDelegate.m
//  IronJump
//
//  Created by Filip Kunc on 8/1/10.
//  For license see LICENSE.TXT
//


#import "IronJumpAppDelegate.h"
#import "GFLevelsViewController.h"
#import "GFWebLevelsViewController.h"

@implementation IronJumpAppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    tabBarController = [[UITabBarController alloc] init];
    
    levelsViewController = [[GFLevelsViewController alloc] init];
    webLevelsViewController = [[GFWebLevelsViewController alloc] init];
    
    navigationController = [[UINavigationController alloc] initWithRootViewController:levelsViewController];
    navigationController.navigationBar.translucent = YES;
    
    //[tabBarController setViewControllers:[NSArray arrayWithObjects:navigationController, webLevelsViewController, nil]];
    
    [window addSubview:[navigationController view]];
    [window makeKeyAndVisible];    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application 
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application 
{

}


- (void)applicationWillResignActive:(UIApplication *)application 
{

}

@end

