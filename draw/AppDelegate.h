#import <Cocoa/Cocoa.h>

@class GobController;

/**
    GobViewer main application delegate.
*/
@interface AppDelegate : NSObject <
    NSApplicationDelegate,
    NSOpenSavePanelDelegate>

@property(strong) NSMutableArray* windows;

/**
*/
- (IBAction) openDocument:(id)sender;

@end
