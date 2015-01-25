#import <Foundation/Foundation.h>

#include <gob/Tdo.h>

@class SCNGeometry;
@class ColorMap;

/**
    Objective-C 3DO file wrapper.
*/
@interface Tdo : NSObject
{
    Df::Tdo _tdo;
}

@property (nonatomic, strong) ColorMap* colorMap;

+ (Tdo*) createForTdo:(Df::Tdo)tdo;

- (id) initWithTdo:(Df::Tdo)tdo;

/**
    Create the Scenekit geometry associated with an object.
*/
- (SCNGeometry*) createObject:(NSUInteger)index;

/**
    Get an array of all geometry associated with the object.
*/
- (NSArray*) createObjects;

@end
