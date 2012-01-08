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
#import "GFGameController.h"

@interface GFGameViewController : GLKViewController <UIAccelerometerDelegate>
{
    GFLevelName *levelName;
    
    GLint backingWidth;
    GLint backingHeight;
    
    float lastAcceleration;
    
    GFGameController *gameController;
}

@property (readwrite, retain) GFLevelName *levelName;
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

@end
