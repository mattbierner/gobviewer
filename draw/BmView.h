#import <Cocoa/Cocoa.h>

#include "BitmapView.h"

#include <gober/Common.h>
#include <gober/BmFile.h>
#include <gober/GobFile.h>
#include <gober/PalFile.h>

/**
*/
@interface BmCell : NSObject

@property (nonatomic, strong) NSImage* image;
@property (nonatomic) bool flipped;

+ (BmCell*) cellForImage:(NSImage*)image flipped:(bool)flipped;

- (id) init;

@end

/**
*/
@interface BmAnimation : NSObject

@property (nonatomic, strong) NSMutableArray* frames;
@property (nonatomic) NSTimeInterval frameRate;

+ (BmAnimation*) animationForImage:(NSImage*)image;

- (id) init;

@end

/**
*/
@interface BmView : BitmapView
{
    unsigned imageIndex;
    unsigned animationIndex;
}

@property (nonatomic, strong) NSMutableArray* animations;
@property (nonatomic, strong) NSTimer* animationTimer;

- (id) initWithFrame:(NSRect)frameRect;

- (void) loadBM:(DF::GobFile*)gob named:(const char*)filename withPal:(DF::PalFileData*)pal;
- (void) loadFme:(DF::GobFile*)gob named:(const char*)filename withPal:(DF::PalFileData*)pal;
- (void) loadWax:(DF::GobFile*)gob named:(const char*)filename withPal:(DF::PalFileData*)pal;

- (void) setFrameRate:(NSTimeInterval)frameRate;

- (void) update;

@end
