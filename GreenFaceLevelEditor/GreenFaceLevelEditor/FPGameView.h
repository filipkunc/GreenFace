//
//  FPOpenGLView.h
//  IronJump
//
//  Created by Filip Kunc on 4/17/10.
//  For license see LICENSE.TXT
//

#import "NSOpenGLView+Helpers.h"
#import "GFGameController.h"

@interface FPGameView : NSOpenGLView
{
	NSTimer *timer;
	NSMutableSet *pressedKeys;
    GFGameController *gameController;
}

- (void)runGameWithLevelData:(NSData *)data;

@end
