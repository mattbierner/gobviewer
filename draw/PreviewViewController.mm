#import "PreviewViewController.h"

#import "BmView.h"
#import "Msg.h"
#import "MsgView.h"
#import "Pal.h"
#import "PalView.h"
#import "Tdo.h"
#import "TdoView.h"

#include <gober/Msg.h>
#include <gober/MsgFile.h>
#include <gober/Tdo.h>
#include <gober/TdoFile.h>


@interface PreviewViewController ()

@end

@implementation PreviewViewController

- (void) setPreview:(NSView *)preview
{
    if (_preview == preview)
        return;
    
    if (_preview)
    {
        [self.view removeConstraints:_preview.constraints];
        [self.view replaceSubview:_preview with:preview];
    }
    else
    {
        [self.view addSubview:preview];
    }
    
    NSDictionary* views = @{
        @"main": preview
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

    _preview = preview;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.bmView = [[BmView alloc] initWithFrame:self.view.bounds];
    self.bmView.translatesAutoresizingMaskIntoConstraints = NO;

    self.palView = [[PalView alloc] init];
    self.palView.translatesAutoresizingMaskIntoConstraints = NO;

    self.msgView = [[MsgView alloc] init];
    self.msgView.translatesAutoresizingMaskIntoConstraints = NO;

    self.tdoView = [[TdoView alloc] initWithFrame:self.view.bounds];
    self.tdoView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void) loadBM:(DF::GobFile*) gob named:(const char*)filename withPal:(DF::PalFileData*)pal
{
    [self.bmView loadBM:gob named:filename withPal:pal];
    self.preview = self.bmView;
}

- (void) loadFme:(DF::GobFile*) gob named:(const char*)filename withPal:(DF::PalFileData*)pal
{
    [self.bmView loadFme:gob named:filename withPal:pal];
    self.preview = self.bmView;
}

- (void) loadWax:(DF::GobFile*) gob named:(const char*)filename withPal:(DF::PalFileData*)pal
{
    [self.bmView loadWax:gob named:filename withPal:pal];
    self.preview = self.bmView;
}

- (void) loadMsg:(DF::GobFile*)gob named:(const char*)filename
{
    std::string file(filename);
    size_t size = gob->GetFileSize(file);
    
    DF::Buffer buffer = DF::Buffer::Create(size);
    gob->ReadFile(file, buffer.GetW(0), 0, size);
    
    DF::Msg msg = DF::MsgFile(std::move(buffer)).CreateMsg();
    
    self.msgView.message = [Msg createForMsg:msg];
    self.preview = self.msgView;
}

- (void) loadTdo:(DF::GobFile*)gob named:(const char*)filename
{
    std::string file(filename);
    size_t size = gob->GetFileSize(file);
    
    DF::Buffer buffer = DF::Buffer::Create(size);
    gob->ReadFile(file, buffer.GetW(0), 0, size);
    
    Tdo* tdo = [Tdo createForTdo:DF::TdoFile(std::move(buffer)).CreateTdo()];
    tdo.pal = self.pal;
    self.tdoView.tdo = tdo;
    self.preview = self.tdoView;
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
    self.preview = self.palView;
}


@end
