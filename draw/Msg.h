#import <Foundation/Foundation.h>

#include <gob/Msg.h>
#include <vector>

/**
    Objective-C wraper for a MSG object.
*/
@interface Msg : NSObject
{
    Df::Msg _msg;
    std::vector<Df::message_index_t> _keys;
}

+ (Msg*) createForMsg:(Df::Msg)msg;

- (unsigned) count;

- (unsigned) hasMessage:(unsigned)index;

- (NSString*) getMessage:(unsigned)index;

- (NSString*) getMessageAt:(unsigned)index;

@end
