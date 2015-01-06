#import <Cocoa/Cocoa.h>

@class GobController;

@interface AppDelegate : NSObject <
    NSApplicationDelegate,
    NSOpenSavePanelDelegate,
    NSUserInterfaceValidations>

@property(strong) NSMutableArray* windows;

/**
*/
- (IBAction) openDocument:(id)sender;

/**
*/
- (IBAction) saveToFile:(id)sender;

// NSOpenSavePanelDelegate
- (BOOL) panel:(id)sender
    shouldShowFilename:(NSString*)filename;

@end

