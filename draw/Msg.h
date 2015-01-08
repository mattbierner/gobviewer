#import <Foundation/Foundation.h>

#include <gober/Msg.h>
#include <vector>

@interface Msg : NSObject
{
    DF::Msg _msg;
    std::vector<DF::message_index_t> _keys;
}

+ (Msg*) createForMsg:(DF::Msg)msg;

- (unsigned) count;

- (unsigned) hasMessage:(unsigned)index;

- (NSString*) getMessage:(unsigned)index;

- (NSString*) getMessageAt:(unsigned)index;

@end
