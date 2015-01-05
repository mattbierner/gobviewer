#import "GobViewWindowController.h"

#import "GobViewController.h"

@interface GobViewWindowController ()

@end

@implementation GobViewWindowController

- (void) windowDidLoad
{
    [super windowDidLoad];
    NSView* contentView = self.window.contentView;
    
    [contentView addSubview:self.gobViewController.view];
    [self.gobViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary* views = @{
        @"main": self.gobViewController.view
    };

    [contentView
        addConstraints:[NSLayoutConstraint
            constraintsWithVisualFormat:@"V:|[main]|"
            options:0
            metrics:nil
            views:views]];
    
    [contentView
        addConstraints:[NSLayoutConstraint
            constraintsWithVisualFormat:@"H:|[main]|"
            options:0
            metrics:nil
            views:views]];
}

- (void) loadGob:(NSURL*)path
{
    [self.gobViewController loadPal:@"SECBASE.PAL" fromGob:@"DARK.GOB"];
    [self.gobViewController loadFile:path.path];
}

- (BOOL) validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
    return YES;
}

@end
