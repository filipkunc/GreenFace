//
//  MyDocument.h
//  IronJump
//
//  Created by Filip Kunc on 4/17/10.
//  For license see LICENSE.TXT
//


#import <Cocoa/Cocoa.h>
#import "FPGame.h"
#import "FPPlayer.h"
#import "GFSoldier.h"
#import "FPPlatform.h"
#import "FPMovablePlatform.h"
#import "FPDiamond.h"
#import "FPElevator.h"
#import "FPTrampoline.h"
#import "FPExit.h"
#import "FPMagnet.h"
#import "FPSpeedPowerUp.h"
#import "GFTurret.h"
#import "GFPushButton.h"
#import "FPFactoryView.h"
#import "FPLevelView.h"
#import "FPGameView.h"
#import "FPXMLParser.h"

@interface GFDocument : NSDocument <FPFactoryViewDataSource, FPLevelViewDataSource, FPXMLParserDelegate>
{
	NSMutableArray *factories;
	__weak id activeFactory;
    
    NSString *beforeActionName;
	NSMutableArray *previousObjects;
	NSMutableIndexSet *previousIndices;
	
	NSMutableArray *gameObjects;
	NSMutableIndexSet *selectedIndices;
	
	IBOutlet FPFactoryView *factoryView;
	IBOutlet FPLevelView *levelView;
	IBOutlet NSWindow *gameWindow;
	IBOutlet FPGameView *gameView;
}

- (void)selectAll:(id)sender;
- (void)delete:(id)sender;
- (void)duplicateSelected:(id)sender;
- (IBAction)runGame:(id)sender;
- (IBAction)publish:(id)sender;
- (GFDocument *)prepareUndoWithName:(NSString *)name;
- (void)duplicateCurrentObjects:(NSMutableArray *)currentObjects andIndices:(NSMutableIndexSet *)currentIndices;
- (void)revertActionWithName:(NSString *)name objects:(NSMutableArray *)objects andIndices:(NSMutableIndexSet *)indices;
- (void)beforeActionWithName:(NSString *)name;
- (void)afterActionWithName:(NSString *)name;
- (void)fullActionWithName:(NSString *)name block:(void (^)())action;

@end
