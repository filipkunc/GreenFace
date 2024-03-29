//
//  FPGame.h
//  IronJump
//
//  Created by Filip Kunc on 5/2/10.
//  For license see LICENSE.TXT
//

#import "FPGameProtocols.h"
#import "FPPlayer.h"
#import "FPXMLParser.h"

//#define MEASURE_FPS

void CreateVertexBuffer(void);
void DrawUsingVertexBuffer(void);
void UnbindVertexBuffer(void);
void ChangeVertexBufferIfNeeded(void);
void DestroyVertexBuffer(void);

@interface FPGame : NSObject <FPGameProtocol, FPXMLParserDelegate>
{
	NSMutableArray *gameObjects;
	FPPlayer *player;	
	
	CGPoint inputAcceleration;
	float width, height;
	
	int diamondsPicked;
	int diamondsCount;
	
	CGPoint backgroundOffset;
    float lastPlayerX;
    float lastPlayerY;
    
#ifdef MEASURE_FPS	
	NSDate *lastDate;
	int fpsCounter;
	NSString *currentFPS;
#endif
}

@property (readwrite, assign) CGPoint backgroundOffset;

+ (void)loadFontAndBackgroundIfNeeded;
+ (FPFont *)font;
+ (void)resetAllTextures;
+ (void)setBackgroundIndex:(int)index;
- (id)initWithWidth:(float)aWidth height:(float)aHeight;
- (id)initWithBinaryData:(NSData *)data width:(float)aWidth height:(float)aHeight;
- (id)initWithXMLData:(NSData *)data width:(float)aWidth height:(float)aHeight;
- (void)update;
- (void)draw;

@end
