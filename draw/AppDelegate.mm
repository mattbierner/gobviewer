#import "AppDelegate.h"

#include "GobViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.gobViewController = [[GobViewController alloc] initWithNibName:@"GobViewController" bundle:nil];
    [self.gobViewController loadFile:@"TEXTURES.GOB"];

    [self.window.contentView addSubview:self.gobViewController.view];
    self.gobViewController.view.frame = ((NSView*)self.window.contentView).bounds;
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
