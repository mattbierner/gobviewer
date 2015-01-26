#import "MsgView.h"

#import "LabeledCell.h"
#import "Msg.h"

@interface MsgView()

- (NSString*) getMessageText:(unsigned) index;

@end


@implementation MsgView

- (void) setMessage:(Msg*)msg
{
    _message = msg;
    [self.table reloadData];
}

- (NSString*) getMessageText:(unsigned) index
{
    if (self.message && index < [self.message count])
    {
        return [self.message getMessageAt:index];
    }
    else
    {
        return [NSString string];
    }
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    if (self.message)
        return [self.message count];
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

    cell.textField.stringValue = [self getMessageText:static_cast<unsigned>(row)];
    return cell;
}

@end
