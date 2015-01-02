#import "GobViewWindowController.h"

#import "GobViewController.h"

@interface GobViewWindowController ()

@end

@implementation GobViewWindowController

- (void) windowDidLoad
{
    [super windowDidLoad];
    [self.window.contentView addSubview:self.gobViewController.view];
    self.gobViewController.view.frame = ((NSView*)self.window.contentView).bounds;
}

- (void) loadGob:(NSURL*)path
{
    [self.gobViewController loadFile:path.path];
}

@end
