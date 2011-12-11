//
//  GFGameViewController.h
//  GreenFace
//
//  Created by Filip Kunc on 12/4/11.
//  Copyright (c) 2011 Filip Kunc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "GFLevelName.h"
#import "FPMath.h"
#import "FPTextureAtlas.h"
#import "FPFont.h"
#import "FPGame.h"
#import "FPExit.h"

@interface GFGameViewController : GLKViewController <UIAccelerometerDelegate>
{
    GFLevelName *levelName;
    
    GLint backingWidth;
    GLint backingHeight;
    
    FPTexture *win;
	float winAnimation;
	BOOL victory;
	
	FPGame *game;
    id<FPGameObject> exit;
	
	int nextLevelCounter;
    float lastAcceleration;
}

@property (readwrite, retain) GFLevelName *levelName;
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;
- (void)resetGame;

@end
