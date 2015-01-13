#import <Cocoa/Cocoa.h>

/**
    Programatic table cell with a text field.
*/
@interface LabeledCell : NSView

/**
    Textfield in the cell.
*/
@property (nonatomic, strong) NSTextField* textField;

@end
