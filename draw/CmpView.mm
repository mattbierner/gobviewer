#import "CmpView.h"

#import "Cmp.h"

@interface CmpView()
- (void) updateImage;
@end


@implementation CmpView

- (void) dealloc
{
    if (colorData)
        CGImageRelease(colorData);
}

- (void) setCmp:(Cmp*)cmp
{
    _cmp = cmp;
    [self updateImage];
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
    
    if (self.cmp)
    {
        if (self.pal)
            colorData = [self.cmp createImageForPal:self.pal];
        else
            colorData = [self.cmp createImage];
    }
    [self setNeedsDisplay:YES];
}

- (void) drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    if (!colorData) return;
    
    NSGraphicsContext* context = [NSGraphicsContext currentContext];
    
    [NSGraphicsContext saveGraphicsState];
    [context setImageInterpolation: NSImageInterpolationNone];
    
    CGContextDrawImage(
        context.CGContext,
        dirtyRect,
        colorData);
    
    [NSGraphicsContext restoreGraphicsState];
}

@end
