#import <Cocoa/Cocoa.h>

#include "GobContentsViewController.h"

#include <gober/GobFile.h>
#include <gober/PalFile.h>

@class PreviewViewController;

@interface GobViewController : NSViewController <
    GobContentsDelegate>
{
    std::shared_ptr<DF::GobFile> gob;
        
    DF::PalFileData pal;
}

@property (nonatomic, strong) GobContentsViewController* gobContentsViewController;
@property (nonatomic, strong) PreviewViewController* previewViewController;


- (void) loadPal:(NSString*)name fromGob:(NSString*)file;

- (void) loadFile:(NSString*)file;

- (void) gob:(std::shared_ptr<DF::GobFile>)gob selectedFileDidChange:(NSString*)file;


@end
