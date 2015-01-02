#import <Cocoa/Cocoa.h>

@class GobViewController;

@interface AppDelegate : NSObject <
    NSApplicationDelegate,
    NSOpenSavePanelDelegate>
{
}
@property(strong) NSMutableArray* windows;


- (IBAction) openDocument:(id)sender;

/* NSOpenSavePanelDelegate */
- (BOOL) panel:(id)sender shouldShowFilename:(NSString *)filename;

@end

