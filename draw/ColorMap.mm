#import "ColorMap.h"

#import "Pal.h"

@implementation ColorMap

+ (ColorMap*) colorMapWithPal:(Pal*)pal cmp:(Cmp*)cmp
{
    ColorMap* t = [[ColorMap alloc] init];
    t.pal = pal;
    t.cmp = cmp;
    return t;
}

- (NSColor*) getColor:(NSUInteger)index
{
    return [self.pal getColor:index];
}

- (RGB) getRgb:(NSUInteger)index
{
    return [self.pal getRgb:index];
}

@end
