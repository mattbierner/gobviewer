#import "PalView.h"

@interface PalView()
- (void) updateImage;
@end


@implementation PalView

- (void) dealloc
{
    if (colorData)
        CGImageRelease(colorData);
}

- (void) setPal:(Pal*)pal
{
    _pal = pal;
    [self updateImage];
}

- (void) updateImage
{
    if (colorData)
    {
        CGImageRelease(colorData);
        colorData = {};
    }
    
    if (self.pal)
        colorData = [self.pal createImage];
    
    [self setNeedsDisplay:YES];
}

- (void) drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    if (!colorData) return;
    
    NSGraphicsContext* context = [NSGraphicsContext currentContext];
    CGContextDrawImage(
        context.CGContext,
        dirtyRect,
        colorData);
}

@end
