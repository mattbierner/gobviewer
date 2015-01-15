#import <Cocoa/Cocoa.h>

@class Cmp;
@class Pal;

@interface CmpView : NSView
{
    CGImageRef colorData;
}

@property (nonatomic, strong) Cmp* cmp;

@property (nonatomic, strong) Pal* pal;

@end
