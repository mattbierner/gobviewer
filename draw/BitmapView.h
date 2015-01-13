#import <Cocoa/Cocoa.h>

/**
    Renders a proportially scaled bitmap.
*/
@interface BitmapView : NSView

/**
    Should the image be drawn horizontally flipped?
*/
@property (nonatomic) bool drawFlipped;

/**
    Image to draw.
*/
@property (nonatomic, strong) NSImage* image;

@end
