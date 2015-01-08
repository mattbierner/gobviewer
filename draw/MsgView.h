#import <Cocoa/Cocoa.h>

#import "Msg.h"

#include <vector>

@interface MsgView : NSView <
    NSTableViewDataSource,
    NSTableViewDelegate>

@property (nonatomic, strong) Msg* message;

@property (nonatomic, strong) NSScrollView* contentsView;
@property (nonatomic, strong) NSTableView* table;

@end
