#import "GobController.h"

#import "LabeledCell.h"
#import "Pal.h" 
#import "PreviewViewController.h"

#include <iostream>

@interface GobController()
- (void) selectedFileDidChange:(NSString*)file;
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

- (void) loadFile:(NSURL*)path
{
    // TODO: move to settings
    [self loadPal:@"SECBASE.PAL" fromGob:@"DARK.GOB"];
    
    std::string filename([path.path UTF8String]);
    
    std::ifstream fs;
    fs.open(filename, std::ifstream::binary | std::ifstream::in);
    gob = std::make_shared<Df::GobFile>(Df::GobFile::CreateFromFile(std::move(fs)));
    
    self.window.title = [path.path lastPathComponent];
    [self.contentsTable reloadData];
}

- (void) selectedFileDidChange:(NSString*)file
{
    if (!gob) return;
    
    std::string filename = [file UTF8String];
    
    switch (gob->GetFileType(filename))
    {
    case Df::FileType::Bm:
        [self.previewViewController loadBM:gob.get() named:filename.c_str()];
        break;
    case Df::FileType::Fme:
        [self.previewViewController loadFme:gob.get() named:filename.c_str()];
        break;
    
    case Df::FileType::Wax:
        [self.previewViewController loadWax:gob.get() named:filename.c_str()];
        break;
    
    case Df::FileType::Msg:
        [self.previewViewController loadMsg:gob.get() named:filename.c_str()];
        break;
    
     case Df::FileType::Pal:
        [self.previewViewController loadPal:gob.get() named:filename.c_str()];
        break;
        
    case Df::FileType::Tdo:
    {
        size_t size = gob->GetFileSize(filename);
        Df::Buffer buffer = Df::Buffer::Create(size);
        gob->ReadFile(filename, buffer.GetW(0), 0, size);
        std::cout << std::string(buffer.GetObjR<char>(), size);

        [self.previewViewController loadTdo:gob.get() named:filename.c_str()];
        break;
    }
    default:
    {
        size_t size = gob->GetFileSize(filename);
        Df::Buffer buffer = Df::Buffer::Create(size);
        gob->ReadFile(filename, buffer.GetW(0), 0, size);
        std::cout << std::string(buffer.GetObjR<char>(), size);
        break;
    }
    }
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    if (gob)
        return gob->GetFilenames().size();
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
    std::string fileName = gob->GetFilename(row);
    cell.textField.stringValue = [NSString stringWithUTF8String:fileName.c_str()];
    return cell;
}

- (void) tableViewSelectionDidChange:(NSNotification *)aNotification
{
    NSInteger selectedRow = [self.contentsTable selectedRow];
    if (selectedRow >= 0)
    {
        std::string filename = gob->GetFilename(selectedRow);
        [self selectedFileDidChange:[NSString stringWithUTF8String:filename.c_str()]];
    }
}

@end
