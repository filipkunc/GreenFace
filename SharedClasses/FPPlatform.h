//
//  FPPlatform.h
//  IronJump
//
//  Created by Filip Kunc on 5/2/10.
//  For license see LICENSE.TXT
//

#import "FPGameProtocols.h"

@interface FPPlatform : NSObject <FPGameObject> 
{
	float x, y;
	int widthSegments;
	int heightSegments;
	BOOL isVisible;
}

- (id)initWithWidthSegments:(int)aWidthSegments heightSegments:(int)aHeightSegments;

@end
