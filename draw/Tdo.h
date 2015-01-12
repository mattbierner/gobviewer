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
    Create the Scenekit geometry associated with an object.
*/
- (SCNGeometry*) createObject:(NSUInteger)index;

/**
    Get an array of all geometry associated with the object.
*/
- (NSArray*) createObjects;


@end
