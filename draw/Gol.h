#import <Foundation/Foundation.h>

#include <gob/Gol.h>

@interface Gol : NSObject
{
    Df::Gol _gol;
}

+ (Gol*) createForGol:(Df::Gol)gol;

- (NSUInteger) count;

@end
