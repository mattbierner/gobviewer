#import "GolView.h"

#import "Gol.h"
#import "LabeledCell.h"


@implementation GolView

- (void) setGol:(Gol*)gol
{
    _gol = gol;
    [self.table reloadData];
}

- (NSString*) getGoalText:(unsigned) index
{
    if (self.gol && index < [self.gol count])
    {
        return @"asd";//[self.gol getGoalAt:index];
    }
    else
    {
        return [NSString string];
    }
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    if (self.gol)
        return [self.gol count];
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

    cell.textField.stringValue = [self getGoalText:static_cast<unsigned>(row)];
    return cell;
}


@end
