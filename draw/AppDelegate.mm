#import "AppDelegate.h"

#include "GobController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

- (NSArray*) getFilesToOpenAtLaunch;

- (void) openGob:(NSURL*)path;

- (NSOpenPanel*) createFilePicker;
- (void) launchFilePicker;

- (void) addWindow:(GobController*)window;

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

- (IBAction) saveToFile:(id)sender
{
    GobController* controller = [[NSApplication sharedApplication] mainWindow].windowController;
    if (controller)
    {
        NSSavePanel* panel = [NSSavePanel savePanel];
        [panel setCanCreateDirectories:YES];
        [panel setTreatsFilePackagesAsDirectories:YES];
        
        NSInteger clicked = [panel runModal];
        if (clicked == NSFileHandlingPanelOKButton)
        {
            //[controller saveCurrentItemToFile];
        }
    }
}

- (void) openGob:(NSURL*)path
{
    GobController* window = [[GobController alloc] initWithWindowNibName:@"GobViewWindow"];
    [self addWindow:window];
    [window loadFile:path];
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

- (void) addWindow:(GobController*)window
{
    [window showWindow:NSApp];
    [self.windows addObject:window];
}

- (BOOL) validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
    SEL action = [anItem action];
    
    NSWindow* mainWindow = [[NSApplication sharedApplication] mainWindow];
    if (mainWindow)
    {
        GobController* controller = mainWindow.windowController;
      //  if (controller)
        //    return [controller validateUserInterfaceItem:anItem];
    }
    return YES;
}

@end
