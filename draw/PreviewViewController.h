#import <Cocoa/Cocoa.h>

#include <gober/GobFile.h>

@class BmView;

@interface PreviewViewController : NSViewController
{
}

@property (nonatomic, strong) IBOutlet BmView* preview;

- (void) loadBM:(DF::GobFile*)gob named:(const char*)filename;
- (void) loadFme:(DF::GobFile*)gob named:(const char*)filename;
- (void) loadWax:(DF::GobFile*)gob named:(const char*)filename;


@end
