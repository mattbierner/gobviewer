#import "Msg.h"

@implementation Msg

+ (Msg*) createForMsg:(DF::Msg)msg
{
    Msg* msgObj = [[Msg alloc] init];
    msgObj->_msg = msg;
    msgObj->_keys = msg.GetKeys();
    return msgObj;
}

- (unsigned) count
{
    return _msg.GetNumberMessages();
}

- (unsigned) hasMessage:(unsigned)index
{
    return _msg.HasMessage(index);
}

- (NSString*) getMessage:(unsigned)index
{
    return [NSString stringWithUTF8String:_msg.GetMessage(index).c_str()];
}

- (NSString*) getMessageAt:(unsigned)index
{
    return [self getMessage:_keys[index]];
}


@end
