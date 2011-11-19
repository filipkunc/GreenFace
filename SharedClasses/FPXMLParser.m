//
//  FPXMLParser.m
//  IronJumpLevelEditor
//
//  Created by Filip Kunc on 9/15/10.
//  For license see LICENSE.TXT
//

#import "FPXMLParser.h"

@implementation FPXMLParser

- (id)init
{
    self = [super init];
    if (self) 
    {
        currentObject = nil;
        currentElement = nil;
        depth = 0;
        delegate = nil;
    }
    return self;
}

- (id<FPXMLParserDelegate>)delegate
{
    return delegate;
}

- (void)setDelegate:(id<FPXMLParserDelegate>)value
{
    delegate = value;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    depth++;
    
    if (depth == 2)
    {
        Class currentClass = NSClassFromString(elementName);
        currentObject = [[currentClass alloc] init];
    }
    
    currentElement = elementName;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (depth == 3)
        [currentObject parseXMLElement:currentElement value:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if (depth == 2)
        [delegate parser:self foundObject:currentObject];
    
    currentElement = nil;
    
    depth--;
}


@end
