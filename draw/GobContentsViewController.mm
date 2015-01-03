#import "GobContentsViewController.h"

#include <gober/FmeFile.h>

#include <fstream>

@implementation GobContentsViewController 

- (void) viewGob:(std::shared_ptr<DF::GobFile>)file;
{
    gob = file;
    [self.table reloadData];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.table setDataSource:self];
    [self.table setDelegate:self];
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    if (gob)
        return gob->GetFilenames().size();
    else
        return 0;
}

- (id) tableView:(NSTableView*)tableView
    objectValueForTableColumn:(NSTableColumn*)tableColumn
    row:(NSInteger)rowIndex
{
    return [NSString stringWithUTF8String:gob->GetFilename(rowIndex).c_str()];
}

- (NSView*) tableView:(NSTableView*)tableView
    viewForTableColumn:(NSTableColumn *)tableColumn
    row:(NSInteger)row
{
    NSTableCellView* cell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if (!cell)
    {
        cell = [[NSTableCellView alloc] init];
        cell.identifier = tableColumn.identifier;
    }

    std::string fileName = gob->GetFilename(row);
    cell.textField.stringValue = [NSString stringWithUTF8String:fileName.c_str()];
    cell.textField.preferredMaxLayoutWidth = cell.textField.bounds.size.width;

    return cell;
}

- (void) tableViewSelectionDidChange:(NSNotification *)aNotification
{
    NSInteger selectedRow = [self.table selectedRow];
    if (selectedRow >= 0)
    {
        std::string filename = gob->GetFilename(selectedRow);
        if (self.delegate)
        {
            [self.delegate gob:gob selectedFileDidChange:[NSString stringWithUTF8String:filename.c_str()]];
        }
    }
}


@end
