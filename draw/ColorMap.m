#import "ColorMap.h"

@implementation ColorMap

+ (ColorMap*) colorMapWithPal:(Pal*)pal cmp:(Cmp*)cmp
{
    ColorMap* t = [[ColorMap alloc] init];
    t.pal = pal;
    t.cmp = cmp;
    return t;
}

@end
