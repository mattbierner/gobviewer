#import <Cocoa/Cocoa.h>

@class Msg;

/**
    Previews the contents of a MSG file.
*/
@interface MsgView : NSView <
    NSTableViewDataSource,
    NSTableViewDelegate>

@property (nonatomic, strong) NSScrollView* contentsView;
@property (nonatomic, strong) NSTableView* table;

/**
    MSG to preview.
*/
@property (nonatomic, strong) Msg* message;

@end
