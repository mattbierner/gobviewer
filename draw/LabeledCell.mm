#import "LabeledCell.h"

@implementation LabeledCell

- (id) initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect])
    {
        self.textField = [[NSTextField alloc] initWithFrame:frameRect];
        self.textField.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        self.textField.bordered = false;
        self.textField.drawsBackground = NO;
        self.textField.editable = NO;
        [self addSubview:self.textField];
    }
    
    return self;
}

@end