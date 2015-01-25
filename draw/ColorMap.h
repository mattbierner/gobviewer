#import <Foundation/Foundation.h>

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

@end
