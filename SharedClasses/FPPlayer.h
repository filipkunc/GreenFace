//
//  FPPlayer.h
//  IronJump
//
//  Created by Filip Kunc on 5/2/10.
//  For license see LICENSE.TXT
//

#import "FPGameProtocols.h"

#if TARGET_OS_IPHONE

enum
{
	NSUpArrowFunctionKey        = 0xF700,
	NSDownArrowFunctionKey      = 0xF701,
	NSLeftArrowFunctionKey      = 0xF702,
	NSRightArrowFunctionKey     = 0xF703,
};

#endif

extern const float tolerance;
extern const float maxSpeed;
extern const float upSpeed;
extern const float maxFallSpeed;
extern const float acceleration;
extern const float deceleration;
extern const float changeDirectionSpeed;
extern const int maxSpeedUpCount;

@interface FPPlayer : NSObject <FPGameObject>
{
	float x, y;
	float moveX, moveY;
	BOOL jumping;

	int speedUpCounter;	
	float alpha;
	BOOL isVisible;
    
    int moveCounter;
    int jumpCounter;
    int deathCounter;
    float animationCounter;
    BOOL leftOriented;
    int lives;
    int damageCounter;
}

@property (readwrite, assign) float moveX, moveY, alpha;
@property (readwrite, assign) int speedUpCounter;
@property (readonly) BOOL falling;
@property (readwrite, assign) int lives;

+ (void)resetTextures;
- (id)initWithWidth:(float)aWidth height:(float)aHeight;
- (BOOL)collisionLeftRight:(id<FPGameProtocol>)game;
- (BOOL)collisionUpDown:(id<FPGameProtocol>)game;
- (void)drawSpeedUp;
- (void)hit;

@end
