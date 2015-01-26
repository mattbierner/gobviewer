#import "ListView.h"

@implementation ListView

- (id) initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect])
    {
        self.table = [[NSTableView alloc] initWithFrame:frameRect];
        self.table.dataSource = self;
        self.table.delegate = self;
        self.table.headerView = nil;
        self.table.gridStyleMask = NSTableViewSolidHorizontalGridLineMask;
    
        NSTableColumn* col = [[NSTableColumn alloc] initWithIdentifier:@"mainCol"];
        [col setEditable:NO];
        [col setResizingMask:NSTableColumnAutoresizingMask];
        [self.table addTableColumn:col];
        
        self.contentsView = [[NSScrollView alloc] initWithFrame:self.bounds];
        self.contentsView.hasVerticalScroller = YES;
        self.contentsView.documentView = self.table;

        [self addSubview:self.contentsView];
        self.translatesAutoresizingMaskIntoConstraints  = NO;
        self.contentsView.translatesAutoresizingMaskIntoConstraints = NO;

        NSDictionary* views = @{
            @"contents": self.contentsView
        };
    
        [self addConstraints:
            [NSLayoutConstraint
                constraintsWithVisualFormat:@"V:|[contents]|"
                options:0
                metrics:nil
                views:views]];
        
        [self addConstraints:
            [NSLayoutConstraint
                constraintsWithVisualFormat:@"H:|[contents]|"
                options:0
                metrics:nil
                views:views]];

    }
    return self;
}

@end
