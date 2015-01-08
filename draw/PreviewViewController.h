#import <Cocoa/Cocoa.h>

#include <gober/GobFile.h>
#include <gober/PalFile.h>

@class BmView;
@class PalView;
@class MsgView;

@interface PreviewViewController : NSViewController
{
}

@property (nonatomic, strong) NSView* preview;
@property (nonatomic, strong) BmView* bmView;
@property (nonatomic, strong) PalView* palView;
@property (nonatomic, strong) MsgView* msgView;


- (void) loadBM:(DF::GobFile*)gob named:(const char*)filename withPal:(DF::PalFileData*)pal;
- (void) loadFme:(DF::GobFile*)gob named:(const char*)filename withPal:(DF::PalFileData*)pal;
- (void) loadWax:(DF::GobFile*)gob named:(const char*)filename withPal:(DF::PalFileData*)pal ;

- (void) loadMsg:(DF::GobFile*)gob named:(const char*)filename;

- (void) loadPal:(DF::GobFile*)gob named:(const char*)filename;

@end
