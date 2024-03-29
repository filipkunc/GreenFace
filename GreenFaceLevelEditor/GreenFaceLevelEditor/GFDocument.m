//
//  MyDocument.m
//  IronJump
//
//  Created by Filip Kunc on 4/17/10.
//  For license see LICENSE.TXT
//

#import "GFDocument.h"

@implementation GFDocument

- (id)init
{
    self = [super init];
    if (self) {
        
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		
		factories = [[NSMutableArray alloc] init];
		[factories addObject:[FPPlayer class]];
        [factories addObject:[GFSoldier class]];
		[factories addObject:[FPPlatform class]];
		[factories addObject:[FPMovablePlatform class]];
		[factories addObject:[FPElevator class]];
		[factories addObject:[FPDiamond class]];
		[factories addObject:[FPMagnet class]];
		[factories addObject:[FPSpeedPowerUp class]];
		[factories addObject:[FPTrampoline class]];
        [factories addObject:[GFTurret class]];
        [factories addObject:[GFPushButton class]];
		[factories addObject:[FPExit class]];
		activeFactory = nil;
		
		gameObjects = [[NSMutableArray alloc] init];
		selectedIndices = [[NSMutableIndexSet alloc] init];
		previousObjects = nil;
		previousIndices = nil;
        beforeActionName = nil;
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"GFDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)binaryData
{
    NSMutableArray *archivedArray = [NSMutableArray array];
	
	for (id gameObject in gameObjects)
	{
		if ([gameObject respondsToSelector:@selector(encodeWithCoder:)])
			[archivedArray addObject:gameObject];
	}
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:archivedArray];
	return data;
}

- (NSData *)xmlData
{
    FPXMLWriter *writer = [[FPXMLWriter alloc] init];
    [writer openElement:@"IronJumpLevel"];
    
    for (id<FPGameObject> gameObject in gameObjects)
    {
        if ([gameObject respondsToSelector:@selector(writeToXML:)])
        {
            NSString *elementName = NSStringFromClass([gameObject class]);
            [writer openElement:elementName];
            [gameObject writeToXML:writer];
            [writer closeElement:elementName];
        }
    }
    
    [writer closeElement:@"IronJumpLevel"];    
    NSData *data = [writer data];        
    return data;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    if ([typeName hasPrefix:@"Binary"])
        return [self binaryData];
    return [self xmlData];
}

- (BOOL)readBinaryFromData:(NSData *)data error:(NSError **)outError
{
    id unarchived = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	if (unarchived)
	{
		[gameObjects removeAllObjects];
		NSArray *unarchivedArray = (NSArray *)unarchived;		
		for (id<FPGameObject> gameObject in unarchivedArray)
		{
			if ([gameObject respondsToSelector:@selector(nextPart)])
			{
				id nextPart = [gameObject nextPart];
				[gameObjects addObject:gameObject];
				if (nextPart)
					[gameObjects addObject:nextPart];
			}
			else
			{
				[gameObjects addObject:gameObject];
			}
		}		
	}
	else
	{
		if (outError != NULL)
			*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
		return NO;
	}
    return YES;
}

- (void)parser:(FPXMLParser *)parser foundObject:(id<FPGameObject>)gameObject
{
    [gameObjects addObject:gameObject];
    if ([gameObject respondsToSelector:@selector(nextPart)])
    {
        id<FPGameObject> nextPart = [gameObject nextPart];
        if (nextPart)
            [gameObjects addObject:nextPart];
    }
}

- (BOOL)readXMLFromData:(NSData *)data error:(NSError **)outError
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    FPXMLParser *parserHelper = [[FPXMLParser alloc] init];
    [parserHelper setDelegate:self];    
    [parser setDelegate:parserHelper];
    
    BOOL succeded = [parser parse];
    if (!succeded)
    {
        *outError = [parser parserError];
        NSLog(@"parserError: %@", *outError);
    }
    
    return succeded;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    [gameObjects removeAllObjects];
    [selectedIndices removeAllIndexes];
    
    BOOL succeeded;
    
    if ([typeName hasPrefix:@"Binary"])
        succeeded = [self readBinaryFromData:data error:outError];
    else     
        succeeded = [self readXMLFromData:data error:outError];
    
    if (succeeded)
    {
        [selectedIndices removeAllIndexes];
        activeFactory = nil;
        [levelView setNeedsDisplay:YES];
        [factoryView setNeedsDisplay:YES];
    }
    return succeeded;
}

#pragma mark DataSource

@synthesize factories, gameObjects, selectedIndices;

- (id)activeFactory
{
    return activeFactory;
}

- (void)setActiveFactory:(id)anFactory
{
	if (previousObjects)
		[self afterActionWithName:@"Add New Object"];		
	
	activeFactory = anFactory;
	[factoryView setNeedsDisplay:YES];
}

- (void)selectAll:(id)sender
{
	[selectedIndices addIndexesInRange:NSMakeRange(0, [gameObjects count])];
	[levelView setNeedsDisplay:YES];
}

- (void)delete:(id)sender
{
	[self fullActionWithName:@"Delete Selected" block:^() 
     {
         NSMutableArray *nextParts = [NSMutableArray array];
         [selectedIndices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) 
          {
              id gameObject = [gameObjects objectAtIndex:idx];
              if ([gameObject respondsToSelector:@selector(nextPart)])
              {
                  id nextPart = [gameObject nextPart];
                  if (nextPart)
                      [nextParts addObject:nextPart];
              }
              if ([nextParts containsObject:gameObject])
                  [nextParts removeObject:gameObject];		
          }];
         
         __block NSUInteger diff = 0;
         [selectedIndices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) 
          {
              [gameObjects removeObjectAtIndex:idx - diff];
              diff++;
          }];
         
         [gameObjects removeObjectsInArray:nextParts];
         [selectedIndices removeAllIndexes];
         [levelView setNeedsDisplay:YES];
     }];
}

- (void)duplicateSelected:(id)sender
{
	[self fullActionWithName:@"Duplicate Selected" block:^()
     {
         NSMutableArray *duplicates = [NSMutableArray array];
         NSMutableArray *nextParts = [NSMutableArray array];
         [selectedIndices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) 
          {
              id<FPGameObject> gameObject = [gameObjects objectAtIndex:idx];
              id<FPGameObject> duplicate = [gameObject duplicateWithOffsetX:32.0f offsetY:32.0f];
              if (duplicate)
              {
                  [duplicates addObject:duplicate];
                  if ([duplicate respondsToSelector:@selector(nextPart)])
                  {
                      id nextPart = [duplicate nextPart];
                      if (nextPart)
                          [nextParts addObject:nextPart];
                  }
              }
          }];
         
         [selectedIndices removeAllIndexes];
         [gameObjects addObjectsFromArray:duplicates];		
         [selectedIndices addIndexesInRange:NSMakeRange([gameObjects count] - [duplicates count], [duplicates count])];
         [gameObjects addObjectsFromArray:nextParts];
         [selectedIndices addIndexesInRange:NSMakeRange([gameObjects count] - [nextParts count], [nextParts count])];
         [levelView setNeedsDisplay:YES];
     }];
}

- (IBAction)runGame:(id)sender
{
	[gameWindow makeKeyAndOrderFront:self];
    [gameView runGameWithLevelData:[self dataOfType:@"XML" error:NULL]];
}

#pragma mark Undo

- (GFDocument *)prepareUndoWithName:(NSString *)name
{
	NSUndoManager *undo = [self undoManager];
	GFDocument *document = [undo prepareWithInvocationTarget:self];
	if (![undo isUndoing])
		[undo setActionName:name];
	return document;
}

- (void)revertActionWithName:(NSString *)name objects:(NSMutableArray *)objects andIndices:(NSMutableIndexSet *)indices
{
    NSMutableArray *copiedObjects = [[NSMutableArray alloc] init];
    NSMutableIndexSet *copiedIndices = [[NSMutableIndexSet alloc] init];
    [self duplicateCurrentObjects:copiedObjects andIndices:copiedIndices];
    
    [gameObjects removeAllObjects];
    [gameObjects addObjectsFromArray:objects];
    [selectedIndices removeAllIndexes];
    [selectedIndices addIndexes:indices];
    
    GFDocument *document = [self prepareUndoWithName:name];
    [document revertActionWithName:name objects:copiedObjects andIndices:copiedIndices];
    
    [levelView setNeedsDisplay:YES];
}

- (void)duplicateCurrentObjects:(NSMutableArray *)currentObjects andIndices:(NSMutableIndexSet *)currentIndices
{
	[currentObjects removeAllObjects];
	
	[gameObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) 
     {
         id<FPGameObject> gameObject = (id<FPGameObject>)obj;
         id<FPGameObject> duplicate = [gameObject duplicateWithOffsetX:0.0f offsetY:0.0f];
         if (duplicate)
         {
             [currentObjects addObject:duplicate];
         }
         else // elevator end
         {
             id<FPGameObject> parentInGameObjects = [gameObject nextPart];
             id<FPGameObject> parentInOldObjects = [currentObjects objectAtIndex:[gameObjects indexOfObject:parentInGameObjects]];
             id nextPart = [parentInOldObjects nextPart];
             [currentObjects addObject:nextPart];
         }
     }];
	
	[currentIndices removeAllIndexes];
	[currentIndices addIndexes:selectedIndices];
}

- (void)beforeActionWithName:(NSString *)name
{
    NSLog(@"beforeActionWithName:%@", name);
    
	if (previousObjects || previousIndices)
		@throw [NSException exceptionWithName:@"beforeAction called twice" reason:nil userInfo:nil];
    
	previousObjects = [[NSMutableArray alloc] init];
	previousIndices = [[NSMutableIndexSet alloc] init];
    beforeActionName = name;
	[self duplicateCurrentObjects:previousObjects andIndices:previousIndices];
}

- (void)afterActionWithName:(NSString *)name
{
    NSLog(@"afterActionWithName:%@", name);
    
	GFDocument *document = [self prepareUndoWithName:name];
    [document revertActionWithName:name objects:previousObjects andIndices:previousIndices];
	
	previousObjects = nil;
	previousIndices = nil;
    beforeActionName = nil;
}

- (void)fullActionWithName:(NSString *)name block:(void (^)())action
{
    NSString *previousActionName = beforeActionName; 
    
    if (previousActionName)
    {
        [self afterActionWithName:beforeActionName];
        [[self undoManager] endUndoGrouping];
        [[self undoManager] beginUndoGrouping];
    }
    
	[self beforeActionWithName:name];	
	action();	
	[self afterActionWithName:name];
    
    if (previousActionName)
        [self beforeActionWithName:previousActionName];
}

- (void)addNewGameObject:(id<FPGameObject>)gameObject
{
	[self beforeActionWithName:@"Add New Object"];
	
	[gameObjects addObject:gameObject];
	[selectedIndices removeAllIndexes];
	[selectedIndices addIndex:[gameObjects count] - 1];
	if ([gameObject respondsToSelector:@selector(nextPart)])
	{
		id nextPart = [gameObject nextPart];
		if (nextPart)
			[gameObjects addObject:nextPart];
	}
}

- (void)beginMove
{
	NSLog(@"beginMove");
	[self beforeActionWithName:@"Move Selected"];	
}

- (void)endMoveWithPoint:(CGPoint)point
{
	NSLog(@"endMove");	
	[self afterActionWithName:@"Move Selected"];	
}

- (void)beginResizeWithHandle:(FPDragHandle)dragHandle
{
	NSLog(@"beginResize");
	[self beforeActionWithName:@"Resize Selected"];
}

- (void)endResizeWithPoint:(CGPoint)point
{
	NSLog(@"endResize");
	[self afterActionWithName:@"Resize Selected"];
}

- (void)publish:(id)sender
{
    NSString *webServerName = @"http://greenface.heroku.com";
    NSString *levelName = [[[self fileURL] lastPathComponent] stringByDeletingPathExtension];
    NSString *urlString = [NSString stringWithFormat:@"%@/Levels/%@.xml", webServerName, levelName];

    NSMutableURLRequest *post = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [post setHTTPMethod:@"POST"];    
    [post setHTTPBody:[self xmlData]];
    
    NSURLResponse *response;    
    NSError *error;
    
    NSData *result = [NSURLConnection sendSynchronousRequest:post returningResponse:&response error:&error];
    
    NSLog(@"%@", [[NSString alloc] initWithData:result encoding:NSASCIIStringEncoding]);
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:[NSString stringWithFormat:@"Level was published at\n%@", urlString]];
    [alert runModal];
}

@end
