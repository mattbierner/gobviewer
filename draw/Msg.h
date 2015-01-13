#import <Foundation/Foundation.h>

#include <gob/Msg.h>
#include <vector>

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
