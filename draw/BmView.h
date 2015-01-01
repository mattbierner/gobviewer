#import <Cocoa/Cocoa.h>

#include <gober/PalFile.h>
#include <gober/BmFile.h>
#include <gober/GobFile.h>


struct __attribute__((packed)) RGB { uint8_t r, g, b, a; };


@interface BmView : NSView
{
    unsigned imageIndex;
    
    DF::PalFileData pal;
}

@property (nonatomic, strong) NSImage* image;
@property (nonatomic, strong) NSMutableArray* images;
@property (nonatomic, strong) NSImageView* imageView;

- (id) initWithFrame:(NSRect)frame;

- (void) addImage:(RGB*) data
    size:(size_t) dataSize
    width:(unsigned) width
    height:(unsigned) height;

- (void) loadBM:(DF::GobFile*) gob named:(const char*)filename;
- (void) loadFme:(DF::GobFile*) gob named:(const char*)filename;
- (void) loadWax:(DF::GobFile*) gob named:(const char*)filename;

- (void) update;

@end
