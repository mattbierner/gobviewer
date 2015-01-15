#import <Cocoa/Cocoa.h>

#include <gob/GobFile.h>
#include <gob/PalFile.h>

@class BmView;
@class Cmp;
@class CmpView;
@class Gob;
@class MsgView;
@class Pal;
@class PalView;
@class TdoView;

@interface PreviewViewController : NSViewController

@property (nonatomic, strong) NSView* preview;
@property (nonatomic, strong) BmView* bmView;
@property (nonatomic, strong) CmpView* cmpView;
@property (nonatomic, strong) PalView* palView;
@property (nonatomic, strong) MsgView* msgView;
@property (nonatomic, strong) TdoView* tdoView;

@property (nonatomic, strong) Pal* pal;
@property (nonatomic, strong) Cmp* cmp;

- (void) loadBM:(Gob*)gob named:(NSString*)filename;
- (void) loadFme:(Gob*)gob named:(NSString*)filename;
- (void) loadWax:(Gob*)gob named:(NSString*)filename;

- (void) loadMsg:(Gob*)gob named:(NSString*)filename;
- (void) loadTdo:(Gob*)gob named:(NSString*)filename;

- (void) loadPal:(Gob*)gob named:(NSString*)filename;
- (void) loadCmp:(Gob*)gob named:(NSString*)filename;

@end
