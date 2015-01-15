#import <Cocoa/Cocoa.h>

#include <gob/CmpFileData.h>

/**
    Objective-C PAL file wrapper.
*/
@interface Cmp : NSObject
{
    Df::CmpFileData _cmp;
}

/**
    Create a Cmp from a gob.
*/
+ (Cmp*) createFromGob:(NSString*)gob named:(NSString*)name;

/**
    Create a Cmp from some data.
*/
+ (Cmp*) createForCmp:(Df::CmpFileData)Cmp;

/**
    @TODO: remove
*/
- (Df::CmpFileData) getData;

@end
