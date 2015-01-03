#import <Cocoa/Cocoa.h>

#include <gober/GobFile.h>
#include "GobContentsViewController.h"

@class PreviewViewController;

@interface GobViewController : NSViewController <
    GobContentsDelegate>
{
    std::shared_ptr<DF::GobFile> gob;
}

@property (nonatomic, strong) GobContentsViewController* gobContentsViewController;
@property (nonatomic, strong) PreviewViewController* previewViewController;

- (void) loadFile:(NSString*)file;

- (void) gob:(std::shared_ptr<DF::GobFile>)gob selectedFileDidChange:(NSString*)file;


@end
