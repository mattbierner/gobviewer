#import <Cocoa/Cocoa.h>

#include "BitmapView.h"

#include <gob/GobFile.h>

@class Cmp;
@class Gob;
@class Pal;

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

/**
    Color map used to render images.
*/
@property (nonatomic, strong) Cmp* cmp;

/**
    Palette used to render images.
*/
@property (nonatomic, strong) Pal* pal;

- (void) loadBM:(Gob*)gob named:(NSString*)filename;
- (void) loadFme:(Gob*)gob named:(NSString*)filename;
- (void) loadWax:(Gob*)gob named:(NSString*)filename;

- (void) setFrameRate:(NSTimeInterval)frameRate;

- (void) update;

@end
