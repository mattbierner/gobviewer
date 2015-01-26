#import "Msg.h"

@implementation Msg

+ (Msg*) createForMsg:(Df::Msg)msg
{
    Msg* msgObj = [[Msg alloc] init];
    msgObj->_msg = msg;
    msgObj->_keys = msg.GetKeys();
    return msgObj;
}

- (NSUInteger) count
{
    return _msg.GetNumberMessages();
}

- (unsigned) hasMessage:(NSUInteger)index
{
    return _msg.HasMessage(index);
}

- (NSString*) getMessage:(NSUInteger)index
{
    return [NSString stringWithUTF8String:_msg.GetMessage(index).c_str()];
}

- (NSString*) getMessageAt:(NSUInteger)index
{
    return [self getMessage:_keys[index]];
}

@end
