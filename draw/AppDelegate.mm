#import "AppDelegate.h"

#include "GobController.h"

@interface AppDelegate ()

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

- (IBAction) openDocument:(id)sender
{
    [self launchFilePicker];
}

- (void) openGob:(NSURL*)path
{
    GobController* window = [[GobController alloc] initWithWindowNibName:@"GobViewWindow"];
    [self addWindow:window];
    [window loadFile:path];
    
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:path];
}

- (BOOL) application:(NSApplication*)app openFile:(NSString *)filename
{
    [self openGob:[NSURL URLWithString:filename]];
    return YES;
}

- (NSOpenPanel*) createFilePicker
{
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    panel.delegate = self;
    panel.canChooseFiles = YES;
    panel.canChooseDirectories = NO;
    panel.allowsMultipleSelection = NO;
    panel.treatsFilePackagesAsDirectories = YES;
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

@end
