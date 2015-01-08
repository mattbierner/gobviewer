#import "GobController.h"

#import "PreviewViewController.h"
#include <gober/MsgFile.h>

#include <iostream>

DF::GobFile open(const char* file)
{
    std::ifstream fs;
    fs.open(file, std::ifstream::binary | std::ifstream::in);
    if (fs.is_open())
    {
        return DF::GobFile::CreateFromFile(std::move(fs));
    }
    return { };
}

@interface GobFileCell : NSView
@property (nonatomic, strong) NSTextField* textField;
@end


@implementation GobFileCell

- (id) initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect])
    {
        self.textField = [[NSTextField alloc] initWithFrame:self.bounds];
        self.textField.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        self.textField.bordered = false;
        [self addSubview:self.textField];
    }
    
    return self;
}

@end

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
    [self.contentsTable addTableColumn:col];
    
    self.tableContainer = [[NSScrollView alloc] initWithFrame:contentView.bounds];
    [self.tableContainer setHasVerticalScroller:YES];
    [self.tableContainer setDocumentView:self.contentsTable];
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
    DF::GobFile gob = open([gobFile UTF8String]);
    
    std::string file([name UTF8String]);
    size_t size = gob.GetFileSize(file);
    DF::Buffer buffer = DF::Buffer::Create(size);
    gob.ReadFile(file, buffer.GetW(0), 0, size);
    DF::PalFile p(std::move(buffer));
    p.Read(reinterpret_cast<uint8_t*>(&pal), 0, sizeof(DF::PalFileData));
}

- (void) loadFile:(NSURL*)path
{
    [self loadPal:@"SECBASE.PAL" fromGob:@"DARK.GOB"];
    
    std::string filename([path.path UTF8String]);
    
    std::ifstream fs;
    fs.open(filename, std::ifstream::binary | std::ifstream::in);
    gob = std::make_shared<DF::GobFile>(DF::GobFile::CreateFromFile(std::move(fs)));
    
    [self.contentsTable reloadData];
}

- (void) selectedFileDidChange:(NSString*)file
{
    if (!gob) return;
    
    std::string filename = [file UTF8String];
    switch (gob->GetFileType(filename))
    {
    case DF::FileType::Bm:
        [self.previewViewController loadBM:gob.get() named:filename.c_str() withPal:&pal];
        break;
    case DF::FileType::Fme:
        [self.previewViewController loadFme:gob.get() named:filename.c_str() withPal:&pal];
        break;
    
    case DF::FileType::Wax:
        [self.previewViewController loadWax:gob.get() named:filename.c_str() withPal:&pal];
        break;
    
    case DF::FileType::Msg:
        [self.previewViewController loadMsg:gob.get() named:filename.c_str()];
        break;
    
     case DF::FileType::Pal:
        [self.previewViewController loadPal:gob.get() named:filename.c_str()];
        break;
    
    
    default:
    {
        size_t size = gob->GetFileSize(filename);
        DF::Buffer buffer = DF::Buffer::Create(size);
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
    GobFileCell* cell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if (!cell)
    {
        cell = [[GobFileCell alloc] initWithFrame:CGRectZero];
        cell.identifier = tableColumn.identifier;
    }
    std::string fileName = gob->GetFilename(row);
    cell.textField.stringValue = [NSString stringWithUTF8String:fileName.c_str()];
    //cell.textField.preferredMaxLayoutWidth = cell.textField.bounds.size.width;
    //[cell setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
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
