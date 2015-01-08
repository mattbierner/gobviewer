#import "BitmapView.h"

#include <algorithm>

CGSize flipSize(CGSize size)
{
    return CGSizeMake(size.height, size.width);
}

CGRect proportionallyScale(CGSize fromSize, CGSize toSize)
{
    CGPoint origin = CGPointZero;

    CGFloat width = fromSize.width;
    CGFloat height = fromSize.height;
    
    CGFloat targetWidth = toSize.width;
    CGFloat targetHeight = toSize.height;
    
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    if (!NSEqualSizes(fromSize, toSize))
    {
        float widthFactor = targetWidth / width;
        float heightFactor = targetHeight / height;

        CGFloat scaleFactor = std::min(widthFactor, heightFactor);

        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;

        if (widthFactor < heightFactor)
            origin.y = (targetHeight - scaledHeight) / 2.0;
        else if (widthFactor > heightFactor)
            origin.x = (targetWidth - scaledWidth) / 2.0;
    }
    return {origin, {scaledWidth, scaledHeight}};
}


@implementation BitmapView

- (id) initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect])
    {
        self.wantsLayer = YES;
    }

    return self;
}

- (void) drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    if (self.image == nil) return;
    
    CGRect drawRect = dirtyRect;
    CGRect imageRect = proportionallyScale(self.image.size, flipSize(drawRect.size));
    
    imageRect = CGRectInset(imageRect, 10, 10);
    imageRect.origin.x += NSWidth(drawRect) / 2 - NSHeight(drawRect) / 2;
    imageRect.origin.y += NSHeight(drawRect) / 2 - NSWidth(drawRect) / 2;
    
    NSAffineTransform* rotation = [[NSAffineTransform alloc] init];
    [rotation translateXBy:NSWidth(drawRect) / 2 yBy:NSHeight(drawRect) / 2];
    [rotation rotateByDegrees:90];
    if (self.drawFlipped)
        [rotation scaleXBy:1.0 yBy:-1.0];
    [rotation translateXBy:-NSWidth(drawRect) / 2 yBy:-NSHeight(drawRect) / 2];
    
    NSGraphicsContext* context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];
    [rotation concat];
    [self.image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [context restoreGraphicsState];
}

@end
