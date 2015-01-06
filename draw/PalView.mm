#import "PalView.h"

@implementation PalView

struct RGBA { CGFloat r, g, b, a; };

- (void) upateForPal:(DF::PalFileData)data
{
        CGFloat locations[256];
        for (unsigned i = 0; i < 256; ++i)
            locations[i] = i / 255.0f;
        
        RGBA components[256];
        for (unsigned i = 0; i < 256; ++i)
        {
            auto entry = data.colors[i];
            components[i] = { entry.r / 255.0f, entry.g / 255.0f, entry.b / 255.0f, 1.0f };
        }

        gradient = CGGradientCreateWithColorComponents(
            CGColorSpaceCreateDeviceRGB(),
            &(components[0].r),
            locations,
            256);
    
    [self setNeedsDisplay:YES];
}

- (void) dealloc
{
    CGGradientRelease(gradient);
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    NSGraphicsContext* context = [NSGraphicsContext currentContext];
    CGContextDrawLinearGradient(
        context.CGContext,
        gradient,
        CGPointMake(CGRectGetMidX(dirtyRect), CGRectGetMinY(dirtyRect)),
        CGPointMake(CGRectGetMidX(dirtyRect), CGRectGetMaxY(dirtyRect)),
        kCGGradientDrawsBeforeStartLocation);
}

@end
