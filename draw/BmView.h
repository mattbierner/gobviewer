#import <Cocoa/Cocoa.h>

#include <gober/Common.h>
#include <gober/BmFile.h>
#include <gober/GobFile.h>
#include <gober/PalFile.h>


PACKED(struct RGB
{
    uint8_t r, g, b, a;
});


@interface BmView : NSImageView
{
    unsigned imageIndex;
    
    DF::PalFileData pal;
}

@property (nonatomic, strong) NSMutableArray* images;

- (id) initWithFrame:(NSRect)frameRect;

- (CGImageRef) createImage:(RGB*) data
    size:(size_t) dataSize
    width:(unsigned) width
    height:(unsigned) height;

- (void) addImage:(CGImageRef)img;

- (void) addImage:(RGB*) data
    size:(size_t) dataSize
    width:(unsigned) width
    height:(unsigned) height;

- (void) loadBM:(DF::GobFile*) gob named:(const char*)filename;
- (void) loadFme:(DF::GobFile*) gob named:(const char*)filename;
- (void) loadWax:(DF::GobFile*) gob named:(const char*)filename;

- (void) update;

@end
