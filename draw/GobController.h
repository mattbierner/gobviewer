#import <Cocoa/Cocoa.h>

#import "Gob.h"

@class Pal;
@class PreviewViewController;

/**
    Displays the contents of a GOB file.
*/
@interface GobController : NSWindowController<
    NSTableViewDataSource,
    NSTableViewDelegate,
    NSUserInterfaceValidations,
    NSApplicationDelegate,
    NSOpenSavePanelDelegate>
{
    Gob* _gob;
}

@property (nonatomic, strong) NSTableView* contentsTable;
@property (nonatomic, strong) NSScrollView* tableContainer;
@property (nonatomic, strong) PreviewViewController* previewViewController;

/**
    Gob being viewed.
*/
@property (nonatomic, readonly) Gob* gob;

/**
    Palette used to render images.
*/
@property (nonatomic, strong) Pal* pal;

/**
*/
- (IBAction) saveToFile:(id)sender;

- (void) loadPal:(NSString*)name fromGob:(NSString*)file;

- (void) loadFile:(NSURL*)file;

@end
