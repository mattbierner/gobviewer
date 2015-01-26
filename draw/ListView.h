#import <Cocoa/Cocoa.h>

/**
    Base class for a simple tableview with a single column of content.
*/
@interface ListView : NSView <
    NSTableViewDataSource,
    NSTableViewDelegate>

@property (nonatomic, strong) NSScrollView* contentsView;
@property (nonatomic, strong) NSTableView* table;

@end
