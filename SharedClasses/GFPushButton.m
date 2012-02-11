//
//  GFPushButton.m
//  GreenFaceLevelEditor
//
//  Created by Filip Kunc on 2/11/12.
//  For license see LICENSE.TXT
//

#import "GFPushButton.h"
#import "FPTexture.h"
#import "FPTextureArray.h"
#import "FPPlayer.h"

FPTextureArray *pushButtonTextures = nil;

@implementation GFPushButton

@synthesize x, y, isVisible, textureIndex;

+ (FPTexture *)loadTextureIfNeeded
{
	if (!pushButtonTextures)
	{
		pushButtonTextures = [[FPTextureArray alloc] init];
		[pushButtonTextures addTexture:@"button_01.png"];
		[pushButtonTextures addTexture:@"button_02.png"];
		[pushButtonTextures addTexture:@"button_03.png"];
	}
	return [pushButtonTextures textureAtIndex:0];
}

+ (void)resetTextures
{
    pushButtonTextures = nil;
}

- (id)init
{
    self = [super init];
	if (self)
	{
		animationCounter = 0;
		textureIndex = 0;
		x = 0;
		y = 0;
        isVisible = YES;
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
	return CGRectMake(x, y + 32.0f + textureIndex * 5.0f, 64.0f, 32.0f - textureIndex * 5.0f);
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
}

- (void)updateWithGame:(id<FPGameProtocol>)game
{
    FPPlayer *player = (FPPlayer *)game.player;
    CGRect playerRect = player.rect;
    BOOL playerOnButton = NO;
	
	if (!CGRectIntersectsRect(playerRect, self.rect))
	{
		playerRect.size.height += tolerance;
		if (CGRectIntersectsRect(playerRect, self.rect))
            playerOnButton = YES;
	}
    
    if (++animationCounter > 2)
	{
        if (playerOnButton)
        {
            if (++textureIndex > 2)
                textureIndex = 2;
            else
                player.moveY = -5.0f;
        }
        else if (--textureIndex < 0)
        {
            textureIndex = 0;
        }
		animationCounter = 0;
	}
}

- (void)draw
{
	[GFPushButton loadTextureIfNeeded];
	FPTexture *texture = [pushButtonTextures textureAtIndex:textureIndex];
    [texture drawAtPoint:CGPointMake(x, y)];
}

- (id<FPGameObject>)duplicateWithOffsetX:(float)offsetX offsetY:(float)offsetY
{
	GFPushButton *duplicated = [[GFPushButton alloc] init];
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
