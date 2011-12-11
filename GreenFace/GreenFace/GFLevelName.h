//
//  GFLevelName.h
//  GreenFace
//
//  Created by Filip Kunc on 12/11/11.
//  Copyright (c) 2011 Filip Kunc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GFLevelName : NSObject
{
    NSString *path;
}

@property (readonly, copy) NSString *path;

- (id)initWithName:(NSString *)aName;
- (id)initWithPath:(NSString *)aPath;

@end
