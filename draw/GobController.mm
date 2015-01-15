#import "GobController.h"

#import "LabeledCell.h"
#import "Pal.h" 
#import "PreviewViewController.h"

#include <iostream>
#include <string>

@interface GobController()

- (void) selectedFileDidChange:(NSString*)file;

- (void) saveFile:(NSString*)filename to:(NSURL*)path;

- (void) printFile:(NSString*)filename;

@end

@implementation GobController

- (void) windowDidLoad
{
    [super windowDidLoad];
    self.window.styleMask |= NSResizableWindowMask;

    NSView* contentView = self.window.contentView;
    
    self.contentsTable = [[NSTableView alloc] initWithFrame:contentView.bounds];
    self.contentsTable.headerView = nil;
    self.contentsTable.gridStyleMask = NSTableViewSolidHorizontalGridLineMask;
    self.contentsTable.delegate = self;
    self.contentsTable.dataSource =self;
    
    NSTableColumn* col = [[NSTableColumn alloc] initWithIdentifier:@"mainCol"];
    [col setEditable:NO];
    [col setResizingMask:NSTableColumnAutoresizingMask];
    [self.contentsTable addTableColumn:col];
    
    self.tableContainer = [[NSScrollView alloc] initWithFrame:contentView.bounds];
    self.tableContainer.hasVerticalScroller = YES;
    self.tableContainer.documentView = self.contentsTable;
    [contentView addSubview:self.tableContainer];

    self.previewViewController = [[PreviewViewController alloc] init];
    [contentView addSubview:self.previewViewController.view];
    
    [self.previewViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tableContainer setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSDictionary* views = @{
        @"list": self.tableContainer,
        @"content": self.previewViewController.view
    };
    
    [contentView addConstraints:
        [NSLayoutConstraint
            constraintsWithVisualFormat:@"V:|[list]|"
            options:0
            metrics:nil
            views:views]];
    
    [contentView addConstraints:
        [NSLayoutConstraint
            constraintsWithVisualFormat:@"V:|[content]|"
            options:0
            metrics:nil
            views:views]];
    
    [contentView addConstraints:
        [NSLayoutConstraint
            constraintsWithVisualFormat:@"H:|[list(==200)][content(>=200)]|"
            options:0
            metrics:nil
            views:views]];
}

- (void) loadPal:(NSString*)name fromGob:(NSString*)gobFile
{
    self.pal = [Pal createFromGob:gobFile named:name];
    self.previewViewController.pal = self.pal;
}

- (void) setPal:(Pal *)pal
{
    _pal = pal;
    self.previewViewController.pal = pal;
}

- (Gob*) gob
{
    return _gob;
}

- (void) loadFile:(NSURL*)path
{
    // TODO: move to settings
    [self loadPal:@"SECBASE.PAL" fromGob:@"DARK.GOB"];
    
    _gob = [Gob createFromFile:path];

    self.window.title = [path.path lastPathComponent];
    [self.contentsTable reloadData];
}

- (void) selectedFileDidChange:(NSString*)file
{
    switch ([self.gob getFileType:file])
    {
    case Df::FileType::Bm:
        [self.previewViewController loadBM:self.gob named:file];
        break;
        
    case Df::FileType::Fme:
        [self.previewViewController loadFme:self.gob named:file];
        break;
    
    case Df::FileType::Wax:
        [self.previewViewController loadWax:self.gob named:file];
        break;
    
    case Df::FileType::Msg:
        [self.previewViewController loadMsg:self.gob named:file];
        break;
    
     case Df::FileType::Pal:
        [self.previewViewController loadPal:self.gob named:file];
        break;
        
    case Df::FileType::Tdo:
        [self printFile:file];
        [self.previewViewController loadTdo:self.gob named:file];
        break;
        
    default:
        [self printFile:file];
        break;
    }
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    if (self.gob)
        return [self.gob getNumberOfFiles];
    else
        return 0;
}

- (NSView*) tableView:(NSTableView*)tableView
    viewForTableColumn:(NSTableColumn *)tableColumn
    row:(NSInteger)row
{
    LabeledCell* cell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if (!cell)
    {
        cell = [[LabeledCell alloc] initWithFrame:CGRectZero];
        cell.identifier = tableColumn.identifier;
    }
    cell.textField.stringValue = [self.gob getFilename:row];
    return cell;
}

- (void) tableViewSelectionDidChange:(NSNotification *)aNotification
{
    NSInteger selectedRow = [self.contentsTable selectedRow];
    if (selectedRow >= 0)
        [self selectedFileDidChange:[self.gob getFilename:selectedRow]];
}

- (BOOL) validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)item
{
    SEL action = [item action];
    if (action == @selector(saveToFile:))
    {
        return (self.contentsTable.selectedRow >= 0);
    }
    
    return YES;
}

- (IBAction) saveToFile:(id)sender
{
    GobController* controller = [[NSApplication sharedApplication] mainWindow].windowController;
    if (controller)
    {
        NSInteger selectedRow = self.contentsTable.selectedRow;
        NSString* filename = [self.gob getFilename:selectedRow];
        
        NSSavePanel* panel = [NSSavePanel savePanel];
        panel.canCreateDirectories = YES;
        panel.delegate = self;
        panel.treatsFilePackagesAsDirectories = YES;
        panel.nameFieldStringValue = filename;
        
        NSInteger clicked = [panel runModal];
        if (clicked == NSFileHandlingPanelOKButton)
        {
            [self saveFile:filename to:panel.URL];
        }
    }
}

- (void) saveFile:(NSString*)file to:(NSURL*)path
{
    NSData* data = [self.gob readFile:file];
    [data writeToURL:path atomically:NO];
}

- (void) printFile:(NSString*)file
{
   NSData* data = [self.gob readFile:file];
   NSLog(@"%@", data);
}

@end
