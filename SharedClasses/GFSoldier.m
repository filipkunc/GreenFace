//
//  GFSoldier.m
//  GreenFaceLevelEditor
//
//  Created by Filip Kunc on 12/10/11.
//  Copyright (c) 2011 Filip Kunc. All rights reserved.
//

#import "GFSoldier.h"
#import "FPPlayer.h"
#import "FPTexture.h"
#import "FPTextureArray.h"

FPTextureArray *soldierTexture = nil;
FPTextureArray *attackTexture = nil;

const float soldierSize = 64.0f;

@implementation GFSoldier

@synthesize x, y, moveX, moveY, isVisible;

+ (FPTexture *)loadTextureIfNeeded
{
	if (!soldierTexture)
	{
        soldierTexture = [[FPTextureArray alloc] init];
        [soldierTexture addTexture:@"D_01.png"];
        [soldierTexture addTexture:@"D_02.png"];
        [soldierTexture addTexture:@"D_03.png"];
        [soldierTexture addTexture:@"D_04.png"];
        
        attackTexture = [[FPTextureArray alloc] init];
        [attackTexture addTexture:@"DH_01.png"];
        [attackTexture addTexture:@"DH_02.png"];
	}
	return [soldierTexture textureAtIndex:3];
}

+ (void)resetTextures
{
    soldierTexture = nil;
    attackTexture = nil;
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
        isAttacking = NO;
		isVisible = YES;
        moveCounter = 3;
        attackCounter = 0;
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
		x = aWidth / 2.0f - soldierSize / 2.0f;
		y = aHeight / 2.0f - soldierSize / 2.0f;
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
	return CGRectMake(x, y, soldierSize, soldierSize);
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
    float oldX = x;
    float oldY = y;
    
    float moveSpeed = 3.6f;
    
    FPPlayer *player = (FPPlayer *)[game player];
    CGRect playerRect = [player rect];
    
    CGRect attackRect = [self rect];
    
    attackRect.size.width -= 8.0f;
    if (leftOriented)
        attackRect.origin.x += 8.0f;
    
    BOOL isCollidingWithPlayer = NO;
    
    if (CGRectIntersectsRect(attackRect, playerRect))
        isCollidingWithPlayer = YES;
    
    if (isAttacking)
    {
        if (player.x < self.x)
            leftOriented = YES;
        else
            leftOriented = NO;
        
        animationCounter += 0.4f;
        
        if (animationCounter > 5)
        {
            if (++attackCounter >= [attackTexture count])
                attackCounter = 0;
            animationCounter = 0;  
            
            if (!isCollidingWithPlayer)
            {
                isAttacking = NO;
                attackCounter = 0;
            }
        }
    }
    else
    {
        if (!isCollidingWithPlayer)
        {
            if (!leftOriented)
                x += moveSpeed;
            else
                x -= moveSpeed;
            
            if ([self collisionLeftRight:game])
            {
                x = oldX;
                leftOriented = !leftOriented;
            }
            else
            {
                moveY = -5.0f;
                y -= moveY;
                
                float oldX2 = x;
                
                if (!leftOriented)
                    x += 20.0f;
                else
                    x -= 20.0f;        
                
                if (![self collisionUpDown:game])
                {
                    x = oldX;
                    leftOriented = !leftOriented;
                }
                else
                {
                    x = oldX2;
                }
                
                y = oldY;        
            }
        }
        
        animationCounter += 0.6f;
        
        if (animationCounter > 5)
        {
            if (++moveCounter >= [soldierTexture count])
                moveCounter = 0;
            animationCounter = 0;
            
            if (isCollidingWithPlayer)
            {
                isAttacking = YES;
                moveCounter = 3;
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
                        [self moveWithX:-intersection.size.width y:0.0f];
                        isColliding = YES;
                    }
                }
                else
                {
                    [self moveWithX:-intersection.size.width y:0.0f];
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
                        [self moveWithX:intersection.size.width y:0.0f];
                        isColliding = YES;
                    }
                }
                else
                {
                    [self moveWithX:intersection.size.width y:0.0f];
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
                
				[self moveWithX:0.0f y:intersection.size.height];
				isColliding = YES;
			}
			else if (moveY < 0.0f)
			{
				if (CGRectGetMinY(platform.rect) > CGRectGetMaxY(self.rect) - tolerance + moveY)
				{
					moveY = 0.0f;
					[self moveWithX:0.0f y:-intersection.size.height];
					isColliding = YES;
				}
			}
			else if (CGRectGetMinY(platform.rect) > CGRectGetMaxY(self.rect) - tolerance + moveY)
			{
				[self moveWithX:0.0f y:-intersection.size.height];
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
	[GFSoldier loadTextureIfNeeded];
	glPushMatrix();
    if (leftOriented)
    {
        if (isAttacking && attackCounter == 1)
            glTranslatef(x + soldierSize - 7.0f, y, 0.0f);
        else
            glTranslatef(x + soldierSize, y, 0.0f);
        glScalef(-1.0f, 1.0f, 1);
    }
    else
    {
        if (isAttacking && attackCounter == 1)
            glTranslatef(x + 7.0f, y, 0.0f);
        else
            glTranslatef(x, y, 0.0f);
        glScalef(1.0f, 1.0f, 1);
    }
    if (isAttacking)
        [[attackTexture textureAtIndex:attackCounter] draw];
    else
        [[soldierTexture textureAtIndex:moveCounter] draw];
	glPopMatrix();
    //#endif
}

- (id<FPGameObject>)duplicateWithOffsetX:(float)offsetX offsetY:(float)offsetY
{
	GFSoldier *duplicated = [[GFSoldier alloc] init];
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
