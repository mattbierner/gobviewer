#import "AppDelegate.h"

#include "GobController.h"
#include "Pal.h"

@interface AppDelegate ()

- (NSArray*) getFilesToOpenAtLaunch;

- (void) openGob:(NSURL*)path;

- (NSOpenPanel*) createFilePicker;
- (void) launchFilePicker;

- (void) addWindow:(GobController*)window;

- (void) loadInitialPal;

- (NSString*) promptForPal:(NSURL*)gobPath;

@end


@implementation AppDelegate

- (void) setPal:(Pal *)pal
{
    _pal = pal;
    for (GobController* window in self.windows)
    {
        window.pal = pal;
    }
}

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

- (void) loadInitialPal
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* palPath = [defaults objectForKey:@"palPath"];
    NSString* palName = [defaults objectForKey:@"palName"];
    
    if (palPath && palName)
        self.pal = [Pal createFromGob:palPath named:palName];
    
    while (self.pal == nil)
        [self loadPal:nil];
}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // NSString* appDomain = [[NSBundle mainBundle] bundleIdentifier];
    // [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];

    self.windows = [[NSMutableArray alloc] init];
    
    [self loadInitialPal];
    
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
    window.pal = self.pal;
    
    [self addWindow:window];
    [window loadFile:path];

    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:path];
}

- (BOOL) application:(NSApplication*)app openFile:(NSString*)filename
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

- (NSString*) promptForPal:(NSURL*)gobPath
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:[NSString stringWithFormat:@"Select PAL in %@", gobPath.lastPathComponent]];
    [alert addButtonWithTitle:@"Ok"];
    [alert addButtonWithTitle:@"Cancel"];

    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 20)];
    [input setStringValue:@""];

    [alert setAccessoryView:input];
    NSInteger clicked = [alert runModal];
    if (clicked == NSAlertFirstButtonReturn)
        return input.stringValue;
    return [NSString string];
}

- (IBAction) loadPal:(id)sender
{
    NSOpenPanel* panel = [self createFilePicker];
    panel.title = @"Select GOB for PAL";
    
    NSInteger clicked = [panel runModal];
    if (clicked == NSFileHandlingPanelOKButton)
    {
        NSURL* path = [panel URL];
        NSString* palName = [self promptForPal:path];
        if (palName.length > 0)
        {
            self.pal = [Pal createFromGob:path.path named:palName];
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:path.path forKey:@"palPath"];
            [defaults setObject:palName forKey:@"palName"];
        }
    }
}

@end
