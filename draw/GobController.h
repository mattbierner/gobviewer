#import <Cocoa/Cocoa.h>

#include <gober/GobFile.h>
#include <gober/PalFile.h>

@class Pal;
@class PreviewViewController;

/**
    Displays the contents of a GOB file.
*/
@interface GobController : NSWindowController<
    NSTableViewDataSource,
    NSTableViewDelegate>
{
    std::shared_ptr<DF::GobFile> gob;
}

@property (nonatomic, strong) NSTableView* contentsTable;
@property (nonatomic, strong) NSScrollView* tableContainer;
@property (nonatomic, strong) PreviewViewController* previewViewController;

/**
    Palette used to render images.
*/
@property (nonatomic, strong) Pal* pal;

- (void) loadPal:(NSString*)name fromGob:(NSString*)file;

- (void) loadFile:(NSURL*)file;

@end
