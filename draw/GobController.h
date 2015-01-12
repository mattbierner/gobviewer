#import <Cocoa/Cocoa.h>

#include <gober/GobFile.h>
#include <gober/PalFile.h>

@class Pal;
@class PreviewViewController;

@interface GobController : NSWindowController<
    NSTableViewDataSource,
    NSTableViewDelegate>
{
    std::shared_ptr<DF::GobFile> gob;
        
    DF::PalFileData pal;
}

@property (nonatomic, strong) NSTableView* contentsTable;
@property (nonatomic, strong) NSScrollView* tableContainer;
@property (nonatomic, strong) PreviewViewController* previewViewController;
@property (nonatomic, strong) Pal* pal;

- (void) loadPal:(NSString*)name fromGob:(NSString*)file;

- (void) loadFile:(NSURL*)file;

- (void) gob:(std::shared_ptr<DF::GobFile>)gob selectedFileDidChange:(NSString*)file;

@end
