//
//  GFWebLevelsViewController.h
//  GreenFace
//
//  Created by Filip Kunc on 12/5/11.
//  Copyright (c) 2011 Filip Kunc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GFWebLevelsViewController : UITableViewController <NSURLConnectionDelegate, NSXMLParserDelegate>
{
    NSMutableArray *levels;
    NSMutableData *xmlData;
    NSURLConnection *connection;
    UIActivityIndicatorView *activityIndicator;
    NSString *currentElementName;
    BOOL downloadingLevel;
    NSString *levelName;
    UIButton *downloadingButton;
}

@end
