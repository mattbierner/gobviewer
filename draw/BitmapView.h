#import <Cocoa/Cocoa.h>

/**
    Draws a proportially scaled bitmap.
*/
@interface BitmapView : NSView

@property (nonatomic) bool drawFlipped;
@property (nonatomic, strong) NSImage* image;

@end
