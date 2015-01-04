#import <Cocoa/Cocoa.h>

#include <gober/GobFile.h>
#include <gober/PalFile.h>

@class BmView;

@interface PreviewViewController : NSViewController
{
}

@property (nonatomic, strong) IBOutlet BmView* preview;

- (void) loadBM:(DF::GobFile*)gob named:(const char*)filename withPal:(DF::PalFileData*)pal;
- (void) loadFme:(DF::GobFile*)gob named:(const char*)filename withPal:(DF::PalFileData*)pal;
- (void) loadWax:(DF::GobFile*)gob named:(const char*)filename withPal:(DF::PalFileData*)pal ;

@end
