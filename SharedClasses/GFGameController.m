//
//  GFGameController.m
//  GreenFaceLevelEditor
//
//  Created by Filip Kunc on 12/26/11.
//  Copyright (c) 2011 Filip Kunc. All rights reserved.
//

#import "GFGameController.h"

const int nextLevelMax = 45;

@implementation GFGameController

@synthesize game;

- (id)initWithLevelData:(NSData *)data
{
    self = [super init];
    if (self)
    {
        levelData = data;
        win = [[FPTexture alloc] initWithFile:@"win.png" convertToAlpha:NO];
    }
    return self;
}

- (void)resetGame
{
    game = [[FPGame alloc] initWithXMLData:levelData width:480 height:320];
    
    for (id<FPGameObject> gameObject in [game gameObjects])
	{
		if ([gameObject isMemberOfClass:[FPExit class]])
        {
            exit = gameObject;
            break;
        }
    }
    
    [FPGame setBackgroundIndex:1];
    
	nextLevelCounter = 0;
	winAnimation = 0.0f;
	victory = NO;
}

- (void)resetIfNeeded
{
    FPPlayer *player = (FPPlayer *)[game player];
    
    if (player.lives > 0)
    {
        float playerY = CGRectGetMinY([game player].rect);
        for (id<FPGameObject> gameObject in [game gameObjects])
        {
            if (gameObject.isPlatform && !gameObject.isMovable)
            {
                float gameObjectY = CGRectGetMaxY(gameObject.rect);
                if (playerY < gameObjectY)
                {
                    return;
                }
            }
        }
    }
	
	nextLevelCounter++;
	if (nextLevelCounter > nextLevelMax)
	{
		nextLevelCounter = 0;
		[self resetGame];
	}	
}

- (void)nextLevelIfNeeded
{
	if (exit.isVisible)
        return;
	
	nextLevelCounter++;
	if (nextLevelCounter > nextLevelMax)
	{
		nextLevelCounter = 0;
		
        victory = YES;
		return;		
	}
}

- (void)update
{
    if (victory)
	{
		winAnimation += 0.01f;
		if (winAnimation > 0.7f)
			winAnimation = 0.7f;
	}
	else if (game)
	{
		[self nextLevelIfNeeded];
		[self resetIfNeeded];
		[game update];	
	}
}

- (void)draw
{
    if (game)
	{
		[game draw];
		
		if (victory)
		{
			const float quad[] = 
			{
				0,		0,
				480,	0,
				0,		320,
				480,	320
			};
			
			glDisable(GL_TEXTURE_2D);
			glEnable(GL_BLEND);
			glColor4f(0, 0, 0, winAnimation);
			
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			glEnableClientState(GL_VERTEX_ARRAY);
			glVertexPointer(2, GL_FLOAT, sizeof(float) * 2, quad);	
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			
			glColor4f(1, 1, 1, 1);
			
			float winY = 300.0f - winAnimation * 280.0f;
			[win drawAtPoint:CGPointMake(120.0f, winY)];
			
			winY += 64.0f;
			
			[[FPGameAtlas sharedAtlas] removeAllTiles];
			[[FPGameAtlas sharedAtlas] addElevator:2 atPoint:CGPointMake(120.0f, winY) widthSegments:8 heightSegments:1];
			[[FPGameAtlas sharedAtlas] drawAllTiles];
		}
	}    
}

@end
