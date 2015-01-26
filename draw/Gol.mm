#import "Gol.h"

@implementation Gol

+ (Gol*) createForGol:(Df::Gol)gol
{
    Gol* t = [[Gol alloc] init];
    t->_gol = gol;
    return t;
}

- (NSUInteger) count
{
    return _gol.NumberOfGoals();
}

@end
