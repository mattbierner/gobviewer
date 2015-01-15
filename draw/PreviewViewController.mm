#import "PreviewViewController.h"

#import "BmView.h"
#import "Cmp.h"
#import "Gob.h"
#import "Msg.h"
#import "MsgView.h"
#import "Pal.h"
#import "PalView.h"
#import "Tdo.h"
#import "TdoView.h"

#include <gob/CmpFile.h>
#include <gob/Msg.h>
#include <gob/MsgFile.h>
#include <gob/Tdo.h>
#include <gob/TdoFile.h>


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

- (void) setPal:(Pal*)pal
{
    _pal = pal;
    self.bmView.pal = pal;
    self.tdoView.pal = pal;
}

- (void) setCmp:(Cmp*)cmp
{
    _cmp = cmp;
    self.bmView.cmp = cmp;
}

- (void) loadBM:(Gob*)gob named:(NSString*)filename
{
    [self.bmView loadBM:gob named:filename];
    self.preview = self.bmView;
}

- (void) loadFme:(Gob*)gob named:(NSString*)filename
{
    [self.bmView loadFme:gob named:filename];
    self.preview = self.bmView;
}

- (void) loadWax:(Gob*)gob named:(NSString*)filename
{
    [self.bmView loadWax:gob named:filename];
    self.preview = self.bmView;
}

- (void) loadMsg:(Gob*)gob named:(NSString*)filename
{
    auto buffer = [gob readFileToBuffer:filename];
    
    Df::Msg msg = Df::MsgFile(std::move(buffer)).CreateMsg();
    
    self.msgView.message = [Msg createForMsg:msg];
    self.preview = self.msgView;
}

- (void) loadTdo:(Gob*)gob named:(NSString*)filename
{
    auto buffer = [gob readFileToBuffer:filename];

    auto tdoFile = Df::TdoFile(std::move(buffer)).CreateTdo();
    Tdo* tdo = [Tdo createForTdo:tdoFile];
    tdo.pal = self.pal;
    self.tdoView.tdo = tdo;
    self.preview = self.tdoView;
}

- (void) loadPal:(Gob*)gob named:(NSString*)filename
{
    auto buffer = [gob readFileToBuffer:filename];

    Df::PalFileData pal;
    Df::PalFile p(std::move(buffer));
    p.Read(reinterpret_cast<uint8_t*>(&pal), 0, sizeof(Df::PalFileData));
    
    self.palView.pal = [Pal createForPal:pal];
    self.preview = self.palView;
}

- (void) loadCmp:(Gob*)gob named:(NSString*)filename
{
    auto buffer = [gob readFileToBuffer:filename];
    auto size = buffer.GetDataSize();
    
    Df::CmpFileData pal;
    Df::CmpFile p(std::move(buffer));
    p.Read(reinterpret_cast<uint8_t*>(&pal), 0, sizeof(Df::PalFileData));
    1;
}


@end
