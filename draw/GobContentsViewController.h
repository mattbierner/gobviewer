#import <Cocoa/Cocoa.h>

#include <gober/GobFile.h>

/**
*/
@protocol GobContentsDelegate

- (void) gob:(std::shared_ptr<DF::GobFile>)gob selectedFileDidChange:(NSString*)filename;

@end

/**
*/
@interface GobContentsViewController : NSViewController <
    NSTableViewDataSource,
    NSTableViewDelegate>
{
    std::shared_ptr<DF::GobFile> gob;
}

@property (nonatomic, strong) IBOutlet NSTableView* table;

@property (nonatomic, weak) id<GobContentsDelegate> delegate;


- (void) viewGob:(std::shared_ptr<DF::GobFile>)file;

- (NSInteger) numberOfRowsInTableView:(NSTableView*)tableView;

- (NSView*) tableView:(NSTableView*)tableView
    viewForTableColumn:(NSTableColumn *)tableColumn
    row:(NSInteger)row;

- (void) tableViewSelectionDidChange:(NSNotification *)notification;

@end
