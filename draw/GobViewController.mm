#import "GobViewController.h"

#include "BmView.h"
#include "FmeFile.h"

#include <fstream>

@implementation GobViewController 

- (void) loadFile:(NSString*)file
{
    std::ifstream fs;
    fs.open([file UTF8String], std::ifstream::binary | std::ifstream::in);
    
    gob = DF::GobFile::CreateFromFile(std::move(fs));
    
    {
        std::string file("IST-GUNI.FME");
        size_t size = gob.GetFileSize(file);
        DF::Buffer buffer = DF::Buffer::Create(size);
        gob.ReadFile(file, buffer.Get(), 0, size);
    
        DF::FmeFile fme = DF::FmeFile(std::move(buffer));
        size_t width = fme.GetWidth();
        size_t height = fme.GetHeight();
        
    }
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self.table setDataSource:self];
    [self.table setDelegate:self];
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    return gob.GetFilenames().size();
}

- (id) tableView:(NSTableView*)tableView
    objectValueForTableColumn:(NSTableColumn*)tableColumn
    row:(NSInteger)rowIndex
{
    return [NSString stringWithUTF8String:gob.GetFilename(rowIndex).c_str()];
}

- (id) tableView:(NSTableView*)tableView
    rowViewForRow:(NSInteger)rowIndex
{
    NSTableCellView* cell = [tableView makeViewWithIdentifier:@"Gob" owner:self];
    if (!cell)
    {
        cell = [[NSTableCellView alloc] init];
        cell.identifier = @"Gob";
        
        std::string fileName = gob.GetFilename(rowIndex);
        cell.textField.stringValue = [NSString stringWithUTF8String:fileName.c_str()];
    }
    return cell;
}

- (void) tableViewSelectionDidChange:(NSNotification *)aNotification
{
    NSInteger selectedRow = [self.table selectedRow];
    if (selectedRow >= 0)
    {
        std::string filename = gob.GetFilename(selectedRow);
        
        switch (gob.GetFileType(filename))
        {
        case DF::FileType::Bm:
            [self.preview loadBM:&gob named:filename.c_str()];
            break;
        case DF::FileType::Fme:
            [self.preview loadFme:&gob named:filename.c_str()];
            break;
        }
    }
}


@end
