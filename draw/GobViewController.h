#import <Cocoa/Cocoa.h>

#include <gober/GobFile.h>

@class BmView;

@interface GobViewController : NSViewController <
    NSTableViewDataSource,
    NSTableViewDelegate>
{
    DF::GobFile gob;
}

@property (nonatomic, strong) IBOutlet NSTableView* table;
@property (nonatomic, strong) IBOutlet BmView* preview;

- (void) loadFile:(NSString*)file;

- (NSInteger) numberOfRowsInTableView:(NSTableView*)tableView;

- (id) tableView:(NSTableView*)tableView
    objectValueForTableColumn:(NSTableColumn*)tableColumn
    row:(NSInteger)rowIndex;

- (id) tableView:(NSTableView*)tableView
    rowViewForRow:(NSInteger)rowIndex;

- (void) tableViewSelectionDidChange:(NSNotification *)notification;

@end
