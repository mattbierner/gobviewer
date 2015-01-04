#import "PreviewViewController.h"

#import "BmView.h"

@interface PreviewViewController ()

@end

@implementation PreviewViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.preview = [[BmView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.preview];
    
    NSDictionary* views = @{
        @"main": self.preview
    };

    [self.view
        addConstraints:[NSLayoutConstraint
            constraintsWithVisualFormat:@"V:|[main]|"
            options:0
            metrics:nil
            views:views]];
    
    [self.view
        addConstraints:[NSLayoutConstraint
            constraintsWithVisualFormat:@"H:|[main]|"
            options:0
            metrics:nil
            views:views]];
}

- (void) loadBM:(DF::GobFile*) gob named:(const char*)filename withPal:(DF::PalFileData*)pal;
{
    [self.preview loadBM:gob named:filename withPal:pal];
}

- (void) loadFme:(DF::GobFile*) gob named:(const char*)filename withPal:(DF::PalFileData*)pal;
{
    [self.preview loadFme:gob named:filename withPal:pal];
}

- (void) loadWax:(DF::GobFile*) gob named:(const char*)filename withPal:(DF::PalFileData*)pal;
{
    [self.preview loadWax:gob named:filename withPal:pal];
}

@end
