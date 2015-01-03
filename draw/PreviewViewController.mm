#import "PreviewViewController.h"

#import "BmView.h"

@interface PreviewViewController ()

@end

@implementation PreviewViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void) loadBM:(DF::GobFile*) gob named:(const char*)filename
{
    [self.preview loadBM:gob named:filename];
}

- (void) loadFme:(DF::GobFile*) gob named:(const char*)filename
{
    [self.preview loadFme:gob named:filename];
}

- (void) loadWax:(DF::GobFile*) gob named:(const char*)filename
{
    [self.preview loadWax:gob named:filename];
}

@end
