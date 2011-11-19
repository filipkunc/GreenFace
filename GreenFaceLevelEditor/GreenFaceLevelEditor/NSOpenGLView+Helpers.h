//
//  NSOpenGLView+Helpers.h
//  MacRubyGame
//
//  Created by Filip Kunc on 3/25/10.
//  For license see LICENSE.TXT
//

#import "FPGraphics.h"

@interface NSOpenGLView(Helpers)

+ (NSOpenGLPixelFormat *)sharedPixelFormat;
+ (NSOpenGLContext *)sharedContext;
- (void)setupSharedContext;
- (CGSize)reshapeFlippedOrtho2D;
- (CGPoint)locationFromNSEvent:(NSEvent *)e;
- (CGRect)boundsCG;

@end