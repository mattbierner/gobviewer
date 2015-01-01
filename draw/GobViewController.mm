#import "GobViewController.h"

#import "GobContentsViewController.h"
#import "PreviewViewController.h"

@implementation GobViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setAutoresizingMask:NSViewHeightSizable];
    
    self.gobContentsViewController = [[GobContentsViewController alloc] init];
    self.gobContentsViewController.delegate = self;
    [self.gobContentsViewController viewGob:gob];
    [self addSplitViewItem:[NSSplitViewItem splitViewItemWithViewController:self.gobContentsViewController]];
    
    self.previewViewController = [[PreviewViewController alloc] init];
    [self addSplitViewItem:[NSSplitViewItem splitViewItemWithViewController:self.previewViewController]];
}

- (void) loadFile:(NSString*)file
{
    std::ifstream fs;
    fs.open([file UTF8String], std::ifstream::binary | std::ifstream::in);
    gob = std::make_shared<DF::GobFile>(DF::GobFile::CreateFromFile(std::move(fs)));
}

- (void) gob:(std::shared_ptr<DF::GobFile>)gobFile selectedFileDidChange:(NSString*)file
{
    std::string filename = [file UTF8String];
    switch (gobFile->GetFileType(filename))
    {
    case DF::FileType::Bm:
        [self.previewViewController loadBM:gobFile.get() named:filename.c_str()];
        break;
    case DF::FileType::Fme:
        [self.previewViewController loadFme:gobFile.get() named:filename.c_str()];
        break;
    
    case DF::FileType::Wax:
        [self.previewViewController loadWax:gobFile.get() named:filename.c_str()];
        break;
        
    default: break;
    }
}

@end
