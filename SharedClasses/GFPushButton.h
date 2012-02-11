//
//  GFPushButton.h
//  GreenFaceLevelEditor
//
//  Created by Filip Kunc on 2/11/12.
//  For license see LICENSE.TXT
//

#import "FPGameProtocols.h"

@interface GFPushButton : NSObject <FPGameObject> 
{
	float x, y;
	int animationCounter;
	int textureIndex;
	BOOL isVisible;
}

@end