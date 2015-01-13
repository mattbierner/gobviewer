#import <Cocoa/Cocoa.h>

#include <gob/GobFile.h>
#include <gob/PalFile.h>

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

- (void) loadBM:(Df::GobFile*)gob named:(const char*)filename;
- (void) loadFme:(Df::GobFile*)gob named:(const char*)filename;
- (void) loadWax:(Df::GobFile*)gob named:(const char*)filename ;

- (void) loadMsg:(Df::GobFile*)gob named:(const char*)filename;
- (void) loadTdo:(Df::GobFile*)gob named:(const char*)filename;

- (void) loadPal:(Df::GobFile*)gob named:(const char*)filename;

@end
