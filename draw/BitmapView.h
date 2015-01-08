#import <Cocoa/Cocoa.h>

@interface BitmapView : NSView

@property (nonatomic) bool drawFlipped;
@property (nonatomic, strong) NSImage* image;

@end
