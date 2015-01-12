#import <Foundation/Foundation.h>

#include <gober/Tdo.h>

@class SCNGeometry;
@class Pal;

/**
    Objective-C 3DO file wrapper.
*/
@interface Tdo : NSObject
{
    DF::Tdo _tdo;
}

@property (nonatomic, strong) Pal* pal;

+ (Tdo*) createForTdo:(DF::Tdo)tdo;

- (id) initWithTdo:(DF::Tdo)tdo;

/**
*/
- (SCNGeometry*) createObject:(NSUInteger)index;

/**
*/
- (NSArray*) createObjects;


@end
