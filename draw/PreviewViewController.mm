#import "PreviewViewController.h"

#import "BmView.h"
#import "PalView.h"

#include <gober/MsgFile.h>
#include <gober/Msg.h>


@interface PreviewViewController ()

@end

@implementation PreviewViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    {
        self.preview = [[BmView alloc] initWithFrame:self.view.bounds];
        self.preview.translatesAutoresizingMaskIntoConstraints = NO;
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
    {
        self.palView = [[PalView alloc] init];
        [self.view addSubview:self.palView];
    }
    
    {
        self.msgView = [[NSTextView alloc] init];
        [self.view addSubview:self.msgView];
    }
}

- (void) loadBM:(DF::GobFile*) gob named:(const char*)filename withPal:(DF::PalFileData*)pal
{
    [self.preview loadBM:gob named:filename withPal:pal];
}

- (void) loadFme:(DF::GobFile*) gob named:(const char*)filename withPal:(DF::PalFileData*)pal
{
    [self.preview loadFme:gob named:filename withPal:pal];
}

- (void) loadWax:(DF::GobFile*) gob named:(const char*)filename withPal:(DF::PalFileData*)pal
{
    [self.preview loadWax:gob named:filename withPal:pal];
}

- (void) loadMsg:(DF::GobFile*)gob named:(const char*)filename
{
    std::string file(filename);
    size_t size = gob->GetFileSize(file);
    
    DF::Buffer buffer = DF::Buffer::Create(size);
    gob->ReadFile(file, buffer.GetW(0), 0, size);
    
    DF::Msg msg = DF::MsgFile(std::move(buffer)).CreateMsg();
    
    [self.msgView setString:[NSString stringWithUTF8String:msg.GetMessage(0).c_str()]];
    self.msgView.frame = self.preview.frame;
}

- (void) loadPal:(DF::GobFile*)gob named:(const char*)filename
{
    std::string file(filename);
    size_t size = gob->GetFileSize(file);
    DF::Buffer buffer = DF::Buffer::Create(size);
    gob->ReadFile(file, buffer.GetW(0), 0, size);

    DF::PalFileData pal;
    DF::PalFile p(std::move(buffer));
    p.Read(reinterpret_cast<uint8_t*>(&pal), 0, sizeof(DF::PalFileData));
    
    self.palView.pal = [Pal createForPal:pal];
    self.palView.frame = self.preview.frame;
    [self.palView setNeedsDisplay:YES];
}


@end
