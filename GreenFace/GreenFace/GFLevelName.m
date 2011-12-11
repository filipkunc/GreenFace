//
//  GFLevelName.m
//  GreenFace
//
//  Created by Filip Kunc on 12/11/11.
//  Copyright (c) 2011 Filip Kunc. All rights reserved.
//

#import "GFLevelName.h"

@implementation GFLevelName

@synthesize path;

- (id)initWithName:(NSString *)aName
{
    NSString *aPath = [[NSBundle mainBundle] pathForResource:aName ofType:@"greenlevel"];
    return [self initWithPath:aPath];
}

- (id)initWithPath:(NSString *)aPath
{
    self = [super init];
    if (self)
    {
        path = [aPath copy];
    }
    return self;
}

- (NSString *)description
{
    return [[path lastPathComponent] stringByDeletingPathExtension];
}

@end
