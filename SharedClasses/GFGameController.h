//
//  GFGameController.h
//  GreenFaceLevelEditor
//
//  Created by Filip Kunc on 12/26/11.
//  Copyright (c) 2011 Filip Kunc. All rights reserved.
//

#import "FPMath.h"
#import "FPTextureAtlas.h"
#import "FPFont.h"
#import "FPGame.h"
#import "FPExit.h"
#import "FPElevator.h"

@interface GFGameController : NSObject
{
    NSData *levelData;
    
    FPTexture *win;
	float winAnimation;
	BOOL victory;
	
	FPGame *game;
    id<FPGameObject> exit;
	
	int nextLevelCounter;    
}

@property (readonly) FPGame *game;

- (id)initWithLevelData:(NSData *)data;
- (void)resetGame;
- (void)update;
- (void)draw;

@end
