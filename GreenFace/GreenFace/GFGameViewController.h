//
//  GFGameViewController.h
//  GreenFace
//
//  Created by Filip Kunc on 12/4/11.
//  Copyright (c) 2011 Filip Kunc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GFGameViewController : UIViewController
{
    NSString *levelName;
}

@property (readwrite, copy) NSString *levelName;

@end
