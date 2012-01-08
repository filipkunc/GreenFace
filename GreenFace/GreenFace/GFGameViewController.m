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
    
    gameController = [[GFGameController alloc] initWithLevelData:[NSData dataWithContentsOfFile:[levelName path]]];
    [gameController resetGame];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    [FPGame resetAllTextures];

    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];  
}

- (void)update
{
    [gameController update];
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
    
    [gameController draw];
	
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
    
    [navController popToRootViewControllerAnimated:YES];    
    [navController setNavigationBarHidden:NO animated:YES];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration 
{
    CGPoint inputAcceleration = CGPointMake(-acceleration.y, acceleration.x);
	if (fabsf(inputAcceleration.x) < 0.02f)
		inputAcceleration.x = 0.0f;
	
	inputAcceleration.y = acceleration.x - (lastAcceleration + 0.05f);
	lastAcceleration = flerpf(acceleration.x, lastAcceleration, 0.4f);
    
	[[gameController game] setInputAcceleration:inputAcceleration];
}

@end
