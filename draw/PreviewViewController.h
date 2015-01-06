#import <Cocoa/Cocoa.h>

#include <gober/GobFile.h>
#include <gober/PalFile.h>

@class BmView;
@class PalView;

@interface PreviewViewController : NSViewController
{
}

@property (nonatomic, strong) IBOutlet BmView* preview;
@property (nonatomic, strong) IBOutlet PalView* palView;


- (void) loadBM:(DF::GobFile*)gob named:(const char*)filename withPal:(DF::PalFileData*)pal;
- (void) loadFme:(DF::GobFile*)gob named:(const char*)filename withPal:(DF::PalFileData*)pal;
- (void) loadWax:(DF::GobFile*)gob named:(const char*)filename withPal:(DF::PalFileData*)pal ;

- (void) loadMsg:(DF::GobFile*)gob named:(const char*)filename;

- (void) loadPal:(DF::GobFile*)gob named:(const char*)filename;

@end
