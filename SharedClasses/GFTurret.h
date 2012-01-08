//
//  GFTower.h
//  GreenFaceLevelEditor
//
//  Created by Filip Kunc on 12/24/11.
//  Copyright (c) 2011 Filip Kunc. All rights reserved.
//

#import "FPGameProtocols.h"

typedef struct 
{
    float x, y;
    BOOL isVisible;
    
} GFFireball;

@interface GFTurret : NSObject <FPGameObject>
{
    float x, y;
	BOOL isVisible;
    int animationCounter;
    int fireCounter;
    
    GFFireball *fireballs;
}

+ (void)resetTextures;

@end
