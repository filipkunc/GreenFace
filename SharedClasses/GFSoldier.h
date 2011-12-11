//
//  GFSoldier.h
//  GreenFaceLevelEditor
//
//  Created by Filip Kunc on 12/10/11.
//  Copyright (c) 2011 Filip Kunc. All rights reserved.
//

#import "FPGameProtocols.h"

@interface GFSoldier : NSObject <FPGameObject>
{
	float x, y;
	float moveX, moveY;
    
    BOOL isAttacking;
	BOOL isVisible;
    
    int moveCounter;
    int attackCounter;
    float animationCounter;
    BOOL leftOriented;
}

@property (readwrite, assign) float moveX, moveY;

+ (void)resetTextures;
- (id)initWithWidth:(float)aWidth height:(float)aHeight;
- (BOOL)collisionLeftRight:(id<FPGameProtocol>)game;
- (BOOL)collisionUpDown:(id<FPGameProtocol>)game;

@end
