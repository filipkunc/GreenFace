//
//  GFGameViewController.m
//  GreenFace
//
//  Created by Filip Kunc on 12/4/11.
//  Copyright (c) 2011 Filip Kunc. All rights reserved.
//

#import "GFGameViewController.h"
#import "FPGame.h"

@implementation GFGameViewController

@synthesize levelName, context = _context;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormatNone;
    
    [self setupGL];
    
    self.preferredFramesPerSecond = 60;
}

- (void)viewDidUnload
{    
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    [FPGame resetAllTextures];
    
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 30.0)];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    win = [[FPTexture alloc] initWithFile:@"win.png" convertToAlpha:NO];
    
    [self resetGame];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    [FPGame resetAllTextures];

    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];  
}

- (void)resetGame
{
	NSString *path = [[NSBundle mainBundle] pathForResource:levelName ofType:@"greenlevel"];
	NSData *data = [NSData dataWithContentsOfFile:path];
    
    game = [[FPGame alloc] initWithXMLData:data width:480 height:320];
    
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
	
	nextLevelCounter++;
	if (nextLevelCounter > 30)
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
	if (nextLevelCounter > 30)
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

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [FPGame loadFontAndBackgroundIfNeeded];
    
    backingWidth = rect.size.width;
    backingHeight = rect.size.height;
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	glOrthof(0, backingWidth, 0, backingHeight, -1.0f, 1.0f);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
	glTranslatef(0, backingHeight, 0);
	glScalef(1, -1, 1);
	
	glPushMatrix();
		
    glClearColor(101.0f / 255.0f, 97.0f / 255.0f, 85.0f / 255.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT);
    
	if (game)
	{
		[game draw];
		
		if (victory)
		{
			const float quad[] = 
			{
				0,				0,
				backingWidth,	0,
				0,				backingHeight,
				backingWidth,	backingHeight
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
	
	glPopMatrix();
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (BOOL)wantsFullScreenLayout
{
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UINavigationController *navController = self.navigationController;
        
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    [navController  popToRootViewControllerAnimated:YES];    
    [navController setNavigationBarHidden:NO animated:YES];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration 
{
    CGPoint inputAcceleration = CGPointMake(-acceleration.y, acceleration.x);
	if (fabsf(inputAcceleration.x) < 0.02f)
		inputAcceleration.x = 0.0f;
	
	inputAcceleration.y = acceleration.x - (lastAcceleration + 0.05f);
	lastAcceleration = flerpf(acceleration.x, lastAcceleration, 0.4f);
    
	[game setInputAcceleration:inputAcceleration];
}

@end
