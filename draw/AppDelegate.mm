#import "AppDelegate.h"

#include "GobViewController.h"
#include "GobViewWindowController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

- (NSArray*) getFilesToOpenAtLaunch;

- (void) openGob:(NSURL*)path;

- (NSOpenPanel*) createFilePicker;
- (void) launchFilePicker;

- (void) addWindow:(GobViewWindowController*)window;

@end


@implementation AppDelegate

- (NSArray*) getFilesToOpenAtLaunch
{
    NSArray* args = [[NSProcessInfo processInfo] arguments];
    NSMutableArray* files = [NSMutableArray array];
    
    if ([args count] > 1)
    {
        for (unsigned i = 1; i < [args count]; ++i)
        {
            NSString* arg = [args objectAtIndex:i];
            if ([arg hasPrefix:@"-"])
            {
                ++i;
            }
            else
            {
                [files addObject:arg];
            }
        }
    }
    return files;
}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.windows = [[NSMutableArray alloc] init];
    
    for (NSString* file in [self getFilesToOpenAtLaunch])
    {
        [self openGob: [NSURL URLWithString:file]];
    }
}

- (void) applicationWillTerminate:(NSNotification *)aNotification
{
}

- (IBAction) openDocument:(id)sender
{
    [self launchFilePicker];
}

- (void) openGob:(NSURL*)path
{
    GobViewWindowController* window = [[GobViewWindowController alloc] initWithWindowNibName:@"GobViewWindow"];
    [self addWindow:window];
    [window loadGob:path];
}

- (NSOpenPanel*) createFilePicker
{
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    panel.delegate = self;
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setTreatsFilePackagesAsDirectories:YES];
    return panel;
}

- (void) launchFilePicker
{
    NSOpenPanel* panel = [self createFilePicker];
    NSInteger clicked = [panel runModal];
    if (clicked == NSFileHandlingPanelOKButton)
    {
        [self openGob:[panel URL]];
    }
}

- (BOOL) panel:(id)sender shouldShowFilename:(NSString*)filename
{
    BOOL isDir = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:filename isDirectory:&isDir];
    if (isDir)
        return YES;
    
    NSString* ext = [filename pathExtension];
    return ([ext caseInsensitiveCompare:@"GOB"] == NSOrderedSame);
}

- (void) addWindow:(GobViewWindowController*)window
{
    [window showWindow:NSApp];
    [self.windows addObject:window];
}

@end
