//
//  GFTower.m
//  GreenFaceLevelEditor
//
//  Created by Filip Kunc on 12/24/11.
//  Copyright (c) 2011 Filip Kunc. All rights reserved.
//

#import "GFTurret.h"
#import "FPTexture.h"
#import "FPTextureArray.h"
#import "FPPlayer.h"

FPTextureArray *turretTexture = nil;
FPTexture *fireballTexture = nil;

const int maxFireballsCount = 40;
const float maxFireballDistance = 1000.0f;

@implementation GFTurret

@synthesize x, y, isVisible;

+ (FPTexture *)loadTextureIfNeeded
{
	if (!turretTexture)
    {
        turretTexture = [[FPTextureArray alloc] init];
        [turretTexture addTexture:@"T_01.png"];
        [turretTexture addTexture:@"T_02.png"];
        [turretTexture addTexture:@"T_03.png"];
        fireballTexture = [[FPTexture alloc] initWithFile:@"green.png" convertToAlpha:NO];
    }
	return [turretTexture textureAtIndex:0];
}

+ (void)resetTextures
{
    turretTexture = nil;
    fireballTexture = nil;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		x = 0;
		y = 0;
        isVisible = YES;
        animationCounter = 0;
        fireCounter = 0;
        fireballs = (GFFireball *)malloc(maxFireballsCount * sizeof(GFFireball));
        memset(fireballs, 0, maxFireballsCount * sizeof(GFFireball));
	}
	return self;
}

- (void)dealloc
{
    free(fireballs);
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
	return CGRectMake(x + 32.0f, y, 32.0f, 64.0f);
}

- (BOOL)isPlatform
{
	return YES;
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
    
    for (int i = 0; i < maxFireballsCount; i++)
    {
        if (fireballs[i].isVisible)
        {
            fireballs[i].x += offsetX;
            fireballs[i].y += offsetY;
        }
    }
}

- (void)updateWithGame:(id<FPGameProtocol>)game
{
    if (!isVisible)
        return;
    
    if (++animationCounter > 10)
    {
        if (++fireCounter >= 3)
        {
            fireCounter = 0;
            for (int i = 0; i < maxFireballsCount; i++)
            {
                if (!fireballs[i].isVisible)
                {
                    fireballs[i].x = x;
                    fireballs[i].y = y + 14.0f;
                    fireballs[i].isVisible = YES;
                    break;
                }
            }
        }
        animationCounter = 0;
    }
    
    for (int i = 0; i < maxFireballsCount; i++)
    {
        if (fireballs[i].isVisible)
        {
            CGPoint fireballLocation = CGPointMake(fireballs[i].x, fireballs[i].y);
            
            FPPlayer *player = (FPPlayer *)[game player];
            if (CGRectContainsPoint([player rect], fireballLocation))
            {
                [player hit];
                fireballs[i].isVisible = NO;
                continue;
            }            
            
            for (id<FPGameObject> gameObject in [game gameObjects])
            {
                if (![gameObject isPlatform])
                    continue;                
                
                if (CGRectContainsPoint([gameObject rect], fireballLocation))
                {
                    fireballs[i].isVisible = NO;
                    break;
                }
            }
            
            fireballs[i].x -= 6.0f;
            
            if (fabsf(fireballs[i].x - x) > maxFireballDistance)
                fireballs[i].isVisible = NO;
        }        
    }
}

- (void)draw
{
	[GFTurret loadTextureIfNeeded];
	[[turretTexture textureAtIndex:fireCounter] drawAtPoint:CGPointMake(x, y)];
    
    for (int i = 0; i < maxFireballsCount; i++)
    {
        if (fireballs[i].isVisible)
            [fireballTexture drawAtPoint:CGPointMake(fireballs[i].x, fireballs[i].y)];
    }
}

- (id<FPGameObject>)duplicateWithOffsetX:(float)offsetX offsetY:(float)offsetY
{
	GFTurret *duplicated = [[GFTurret alloc] init];
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
