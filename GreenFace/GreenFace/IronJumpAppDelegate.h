//
//  IronJumpAppDelegate.h
//  IronJump
//
//  Created by Filip Kunc on 8/1/10.
//  For license see LICENSE.TXT
//


#import <UIKit/UIKit.h>

@class GFLevelsViewController;
@class GFWebLevelsViewController;

@interface IronJumpAppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow *window;
    UINavigationController *navigationController;
    GFLevelsViewController *levelsViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

