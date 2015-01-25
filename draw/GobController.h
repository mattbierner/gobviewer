#import <Cocoa/Cocoa.h>

#import "Gob.h"

@class Cmp;
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

@property (nonatomic, strong) NSTableView* contentsTable;
@property (nonatomic, strong) NSScrollView* tableContainer;
@property (nonatomic, strong) PreviewViewController* previewViewController;

/**
    Gob being viewed.
*/
@property (nonatomic, readonly) Gob* gob;

/**
    Color map used to render images.
*/
@property (nonatomic, strong) Cmp* cmp;

/**
    Palette used to render images.
*/
@property (nonatomic, strong) Pal* pal;

/**
    Save the selected file as an individual file.
*/
- (IBAction) saveToFile:(id)sender;

/**
    Save the entire gob to a directory.
*/
- (IBAction) saveGob:(id)sender;


- (void) loadPal:(NSString*)name fromGob:(NSString*)file;

- (void) loadFile:(NSURL*)file;

@end
