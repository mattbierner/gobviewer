#import "PreviewViewController.h"

#import "BmView.h"
#import "ColorMap.h"
#import "Cmp.h"
#import "CmpView.h"
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
#include <gob/Pal.h>
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
    
    self.cmpView = [[CmpView alloc] initWithFrame:self.view.bounds];
    self.cmpView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.colorMap = [[ColorMap alloc] init];
}

- (void) setColorMap:(ColorMap *)colorMap
{
    _colorMap = colorMap;
    self.bmView.colorMap = colorMap;
    self.tdoView.colorMap = colorMap;
    self.cmpView.pal = colorMap.pal;
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
    tdo.colorMap = self.colorMap;
    self.tdoView.tdo = tdo;
    self.preview = self.tdoView;
}

- (void) loadPal:(Gob*)gob named:(NSString*)filename
{
    auto buffer = [gob readFileToBuffer:filename];
    
    self.palView.pal = [Pal createForPal:Df::PalFile(std::move(buffer))];
    self.preview = self.palView;
}

- (void) loadCmp:(Gob*)gob named:(NSString*)filename
{
    auto buffer = [gob readFileToBuffer:filename];
    
    Df::CmpFile p(std::move(buffer));
    
    self.cmpView.cmp = [Cmp createForCmp:p];
    self.preview = self.cmpView;

}


@end
