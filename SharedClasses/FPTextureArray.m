//
//  FPTextureArray.m
//  IronJump
//
//  Created by Filip Kunc on 6/1/10.
//  For license see LICENSE.TXT
//

#import "FPTextureArray.h"

@implementation FPTextureArray

- (id)init
{
	self = [super init];
	if (self)
	{
		textures = [[NSMutableArray alloc] init];		 
	}
	return self;
}

- (NSUInteger)count
{
	return [textures count];
}

- (void)addTexture:(NSString *)fileName
{
	FPTexture *texture = [[FPTexture alloc] initWithFile:fileName convertToAlpha:NO];
	[textures addObject:texture];
}

- (FPTexture *)textureAtIndex:(NSUInteger)index
{
	return (FPTexture *)[textures objectAtIndex:index];
}

@end
