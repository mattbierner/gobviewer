#import <Cocoa/Cocoa.h>

@class Pal;

/**
    GobViewer main application delegate.
*/
@interface AppDelegate : NSObject <
    NSApplicationDelegate,
    NSOpenSavePanelDelegate>

@property (nonatomic, strong) NSMutableArray* windows;

@property (nonatomic, strong) Pal* pal;

/**
    Action to open a new Gob file.
*/
- (IBAction) openDocument:(id)sender;

/**
    Action to select the Pal used to render images.
*/
- (IBAction) loadPal:(id)sender;

@end
