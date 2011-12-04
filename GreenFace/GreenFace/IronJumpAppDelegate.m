//
//  IronJumpAppDelegate.m
//  IronJump
//
//  Created by Filip Kunc on 8/1/10.
//  For license see LICENSE.TXT
//


#import "IronJumpAppDelegate.h"
#import "GFLevelsViewController.h"

@implementation IronJumpAppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    levelsViewController = [[GFLevelsViewController alloc] init];
    
    navigationController = [[UINavigationController alloc] initWithRootViewController:levelsViewController];
    
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

