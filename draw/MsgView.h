#import <Cocoa/Cocoa.h>

#import "ListView.h"

@class Msg;

/**
    Previews the contents of a MSG file.
*/
@interface MsgView : ListView

/**
    MSG to preview.
*/
@property (nonatomic, strong) Msg* message;

@end
