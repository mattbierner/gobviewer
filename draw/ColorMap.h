#import <Cocoa/Cocoa.h>

#import "DfColor.h"

@class Cmp;
@class Pal;


@interface ColorMap : NSObject

/**
    Color palette.
*/
@property (nonatomic, strong) Pal* pal;

/**
    Color light level mapping.
*/
@property (nonatomic, strong) Cmp* cmp;


/**
    Create a color map from a given pal and cmp.
*/
+ (ColorMap*) colorMapWithPal:(Pal*)pal cmp:(Cmp*)cmp;

/**
    Lookup a color in the palette by index.
*/
- (NSColor*) getColor:(NSUInteger)index;

- (RGB) getRgb:(NSUInteger)index;

@end
