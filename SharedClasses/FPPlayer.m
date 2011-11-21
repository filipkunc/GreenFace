//
//  FPPlayer.m
//  IronJump
//
//  Created by Filip Kunc on 5/2/10.
//  For license see LICENSE.TXT
//

#import "FPPlayer.h"
#import "FPTexture.h"
#import "FPTextureArray.h"

FPTextureArray *playerTexture = nil;
FPTextureArray *jumpTexture = nil;

#if !TARGET_OS_IPHONE
FPTexture *speedTexture = nil;
#endif

const float tolerance = 3.0f;
const float maxSpeed = 5.8f;
const float speedPowerUp = 1.5f;
const float upSpeed = 7.0f;
const float maxFallSpeed = -15.0f;
const float acceleration = 1.1f;
const float deceleration = 1.1f * 0.2f;
const float changeDirectionSpeed = 3.0f;
const int maxSpeedUpCount = 60 * 6; // 60 FPS * 6 sec
const float playerSize = 64.0f;

@implementation FPPlayer

@synthesize x, y, moveX, moveY, speedUpCounter, isVisible, rotation, alpha;

+ (FPTexture *)loadTextureIfNeeded
{
	if (!playerTexture)
	{
        playerTexture = [[FPTextureArray alloc] init];
        [playerTexture addTexture:@"W_01.png"];
        [playerTexture addTexture:@"W_02.png"];
        [playerTexture addTexture:@"W_03.png"];
        [playerTexture addTexture:@"W_04.png"];
		jumpTexture = [[FPTextureArray alloc] init];
        [jumpTexture addTexture:@"WJ_01.png"];
        [jumpTexture addTexture:@"WJ_02.png"];
#if !TARGET_OS_IPHONE
        speedTexture = [[FPTexture alloc] initWithFile:@"speed.png" convertToAlpha:NO];
#endif
	}
	return [playerTexture textureAtIndex:0];
}

- (id)init
{
	self = [super init];
	if (self)
	{
		x = 0.0f;
		y = 0.0f;
		moveX = 0.0f;
		moveY = 0.0f;
		jumping = NO;
		speedUpCounter = 0;
		alpha = 1.0f;
        isVisible = YES;
        moveCounter = 0;
        jumpCounter = 0;
        animationCounter = 0;
        leftOriented = NO;
	}
	return self;
}

- (id)initWithWidth:(float)aWidth height:(float)aHeight
{
	self = [self init];
	if (self)
	{
		x = aWidth / 2.0f - playerSize / 2.0f;
		y = aHeight / 2.0f - playerSize / 2.0f;
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeFloat:x forKey:@"x"];
	[aCoder encodeFloat:y forKey:@"y"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [self init];
	if (self)
	{
		x = [aDecoder decodeFloatForKey:@"x"];
		y = [aDecoder decodeFloatForKey:@"y"];
	}
	return self;
}

- (CGRect)rect
{
	return CGRectMake(x, y, playerSize, playerSize);
}

- (BOOL)isPlatform
{
	return NO;
}

- (BOOL)isMovable
{
	return NO;
}

- (BOOL)isTransparent
{
	return YES;
}

- (void)moveWithX:(float)offsetX y:(float)offsetY
{
	x += offsetX;
	y += offsetY;
}

- (void)updateWithGame:(id<FPGameProtocol>)game
{	
	CGPoint inputAcceleration = [game inputAcceleration];
	BOOL moveLeftOrRight = NO;
	
	if (speedUpCounter > 0)
	{
		if (++speedUpCounter > maxSpeedUpCount)
		{
			speedUpCounter = 0;			
		}
	}
    
    float currentMaxSpeed = speedUpCounter > 0 ? maxSpeed * speedPowerUp : maxSpeed;
	
	if (inputAcceleration.x < 0.0f)
	{
		if (moveX < 0.0f)
			moveX += fabsf(inputAcceleration.x) * acceleration * changeDirectionSpeed;
		moveX += fabsf(inputAcceleration.x) * acceleration;
		if (moveX > currentMaxSpeed)
			moveX = currentMaxSpeed;
		
		moveLeftOrRight = YES;
        leftOriented = YES;
	}
	else if (inputAcceleration.x > 0.0f)
	{
		if (moveX > 0.0f)
			moveX -= fabsf(inputAcceleration.x) * acceleration * changeDirectionSpeed;
		moveX -= fabsf(inputAcceleration.x) * acceleration;
		if (moveX < -currentMaxSpeed)
			moveX = -currentMaxSpeed;
		
		moveLeftOrRight = YES;
        leftOriented = NO;
	}
	
	if (!jumping && inputAcceleration.y > 0.0f)
	{
		if (moveY < upSpeed)
			moveY = upSpeed;
		jumping = YES;
	}
	
	if (!moveLeftOrRight)
	{
		if (fabsf(moveX) < deceleration)
			moveX = 0.0f;
		else if (moveX > 0.0f)
			moveX -= deceleration;
		else if (moveX < 0.0f)
			moveX += deceleration;
	}	
	
	moveY -= deceleration;
	if (moveY < maxFallSpeed)
		moveY = maxFallSpeed;
	jumping = YES;
	
	[game moveWorldWithX:moveX y:0.0f];
	if ([self collisionLeftRight:game])
		moveX = 0.0f;
    [game moveWorldWithX:0.0f y:moveY];
	[self collisionUpDown:game];
	rotation -= moveX * 3.0f;
	
	alpha += 0.07f;
	if (alpha > M_PI)
		alpha -= M_PI;

    float moveSpeed = fabsf(moveX);
    
    if (jumping)
    {
        animationCounter++;
        
        if (animationCounter > 10)
        {
            if (++jumpCounter >= [jumpTexture count])
            {
                jumpCounter = (int)[jumpTexture count] - 1;
                animationCounter = 10;
            }
        }
    }
    else
    {
        jumpCounter = 0;
        animationCounter += MAX(moveSpeed / maxSpeed, 0.6f);
        
        if (animationCounter > 5)
        {
            if (!moveLeftOrRight && moveSpeed < 3.5f)
            {
                if (++moveCounter >= [playerTexture count])
                {
                    moveCounter = (int)[playerTexture count] - 1;
                    animationCounter = 6;
                }
                else
                {
                    animationCounter = 0;
                }            
            }
            else
            {
                if (++moveCounter >= [playerTexture count])
                    moveCounter = 0;
                animationCounter = 0;
            }
        }
    }
}


- (BOOL)collisionLeftRight:(id<FPGameProtocol>)game
{
	BOOL isColliding = NO;
	
	for (id<FPGameObject> platform in [game gameObjects])
	{
		if (platform.isPlatform)
		{
			CGRect intersection = CGRectIntersection(platform.rect, self.rect);
			if (CGRectIsEmptyWithTolerance(intersection))
				continue;
			
			if (CGRectGetMinX(platform.rect) > CGRectGetMinX(self.rect))
			{
                if (platform.isMovable)
                {
                    [platform moveWithX:intersection.size.width y:0.0f];
                    if ([platform collisionLeftRight:game])
                    {
                        [platform moveWithX:-intersection.size.width y:0.0f];
                        [game moveWorldWithX:intersection.size.width y:0.0f];
                        isColliding = YES;
                    }
                }
                else
                {
                    [game moveWorldWithX:intersection.size.width y:0.0f];
                    isColliding = YES;
                }					
			}
			else if (CGRectGetMaxX(platform.rect) < CGRectGetMaxX(self.rect))
			{
                if (platform.isMovable)
                {
                    [platform moveWithX:-intersection.size.width y:0.0f];
                    if ([platform collisionLeftRight:game])
                    {
                        [platform moveWithX:intersection.size.width y:0.0f];
                        [game moveWorldWithX:-intersection.size.width y:0.0f];
                        isColliding = YES;
                    }
                }
                else
                {
                    [game moveWorldWithX:-intersection.size.width y:0.0f];
                    isColliding = YES;
                }
            }
		}
	}
	
	return isColliding;
}

- (BOOL)collisionUpDown:(id<FPGameProtocol>)game
{
	BOOL isColliding = NO;
	
	for (id<FPGameObject> platform in [game gameObjects])
	{
		if (platform.isPlatform)
		{
			CGRect intersection = CGRectIntersection(platform.rect, self.rect);
			if (CGRectIsEmptyWithTolerance(intersection))
				continue;
			
			if (CGRectGetMaxY(platform.rect) < CGRectGetMaxY(self.rect))
			{
				if (moveY > 0.0f)
					moveY = 0.0f;

				[game moveWorldWithX:0.0f y:-intersection.size.height];
				isColliding = YES;
			}
			else if (moveY < 0.0f)
			{
				if (CGRectGetMinY(platform.rect) > CGRectGetMaxY(self.rect) - tolerance + moveY)
				{
					moveY = 0.0f;
					jumping = NO;
					[game moveWorldWithX:0.0f y:intersection.size.height];
					isColliding = YES;
				}
			}
			else if (CGRectGetMinY(platform.rect) > CGRectGetMaxY(self.rect) - tolerance + moveY)
			{
				jumping = NO;
				[game moveWorldWithX:0.0f y:intersection.size.height];
				isColliding = YES;
			}
		}
	}
	
	return isColliding;
}

- (void)draw
{
//#if TARGET_OS_IPHONE
//	[[FPGameAtlas sharedAtlas] addPlayerAtPoint:CGPointMake(x, y) rotation:rotation];
//#else
	[FPPlayer loadTextureIfNeeded];
	glPushMatrix();
    if (leftOriented)
    {
        glTranslatef(x + playerSize, y, 0.0f);
        glScalef(-1.0f, 1.0f, 1);
    }
    else
    {
        glTranslatef(x, y, 0.0f);
        glScalef(1.0f, 1.0f, 1);
    }
    if (jumping)
        [[jumpTexture textureAtIndex:jumpCounter] draw];
    else
        [[playerTexture textureAtIndex:moveCounter] draw];
	glPopMatrix();
//#endif
}

- (void)drawSpeedUp
{
	if (speedUpCounter <= 0)
		return;	
	
	glColor4f(1, 1, 1, fabsf(sinf(alpha)) * 0.3f + 0.1f);
	CGPoint point = CGPointMake(x - playerSize / 2.0f, y - playerSize / 2.0f);
    
    glPushMatrix();
    glTranslatef(point.x, point.y, 0.0f);
    glScalef(2.0f, 2.0f, 1.0f);
	
#if TARGET_OS_IPHONE
	[[FPGameAtlas sharedAtlas] addSpeedEffectAtPoint:CGPointZero];
	[[FPGameAtlas sharedAtlas] drawAllTiles];
#else
	[speedTexture drawAtPoint:CGPointZero];
#endif
    
    glPopMatrix();
}

- (id<FPGameObject>)duplicateWithOffsetX:(float)offsetX offsetY:(float)offsetY
{
	FPPlayer *duplicated = [[FPPlayer alloc] init];
	[duplicated moveWithX:x + offsetX y:y + offsetY];
	return duplicated;
}

- (void)parseXMLElement:(NSString *)elementName value:(NSString *)value
{
    if ([elementName isEqualToString:@"x"])
        x = [value floatValue];
    else if ([elementName isEqualToString:@"y"])
        y = [value floatValue];
}

- (void)writeToXML:(FPXMLWriter *)writer
{
    [writer writeElementWithName:@"x" floatValue:x];
    [writer writeElementWithName:@"y" floatValue:y];
}


@end
