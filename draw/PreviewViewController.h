#import <Cocoa/Cocoa.h>

#include <gober/GobFile.h>
#include <gober/PalFile.h>

@class BmView;
@class MsgView;
@class Pal;
@class PalView;
@class TdoView;

@interface PreviewViewController : NSViewController

@property (nonatomic, strong) NSView* preview;
@property (nonatomic, strong) BmView* bmView;
@property (nonatomic, strong) PalView* palView;
@property (nonatomic, strong) MsgView* msgView;
@property (nonatomic, strong) TdoView* tdoView;
@property (nonatomic, strong) Pal* pal;

- (void) loadBM:(DF::GobFile*)gob named:(const char*)filename;
- (void) loadFme:(DF::GobFile*)gob named:(const char*)filename;
- (void) loadWax:(DF::GobFile*)gob named:(const char*)filename ;

- (void) loadMsg:(DF::GobFile*)gob named:(const char*)filename;
- (void) loadTdo:(DF::GobFile*)gob named:(const char*)filename;

- (void) loadPal:(DF::GobFile*)gob named:(const char*)filename;

@end
