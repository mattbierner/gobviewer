#import "GobViewController.h"

#import "GobContentsViewController.h"
#import "PreviewViewController.h"
#include <gober/MsgFile.h>

#include <iostream>

DF::GobFile open(const char* file)
{
    std::ifstream fs;
    fs.open(file, std::ifstream::binary | std::ifstream::in);
    if (fs.is_open())
    {
        return DF::GobFile::CreateFromFile(std::move(fs));
    }
    return { };
}


@implementation GobViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.gobContentsViewController = [[GobContentsViewController alloc] init];
    self.gobContentsViewController.delegate = self;
    [self.gobContentsViewController viewGob:gob];
    [self.view addSubview:self.gobContentsViewController.view];

    self.previewViewController = [[PreviewViewController alloc] init];
    [self.view addSubview:self.previewViewController.view];
    
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary* views = @{
        @"list": self.gobContentsViewController.view,
        @"content": self.previewViewController.view
    };
    
    [self.view addConstraints:
        [NSLayoutConstraint
            constraintsWithVisualFormat:@"V:|[list]|"
            options:0
            metrics:nil
            views:views]];
    
    [self.view addConstraints:
        [NSLayoutConstraint
            constraintsWithVisualFormat:@"V:|[content]|"
            options:0
            metrics:nil
            views:views]];
    
    [self.view addConstraints:
        [NSLayoutConstraint
            constraintsWithVisualFormat:@"H:|[list(>=200)][content(>=200)]|"
            options:0
            metrics:nil
            views:views]];
}

- (void) loadPal:(NSString*)name fromGob:(NSString*)gobFile
{
    DF::GobFile gob = open([gobFile UTF8String]);
    
    std::string file([name UTF8String]);
    size_t size = gob.GetFileSize(file);
    DF::Buffer buffer = DF::Buffer::Create(size);
    gob.ReadFile(file, buffer.GetW(0), 0, size);
    DF::PalFile p(std::move(buffer));
    p.Read(reinterpret_cast<uint8_t*>(&pal), 0, sizeof(DF::PalFileData));
}

- (void) loadFile:(NSString*)file
{
    std::ifstream fs;
    fs.open([file UTF8String], std::ifstream::binary | std::ifstream::in);
    gob = std::make_shared<DF::GobFile>(DF::GobFile::CreateFromFile(std::move(fs)));
    [self.gobContentsViewController viewGob:gob];
}

- (void) gob:(std::shared_ptr<DF::GobFile>)gobFile selectedFileDidChange:(NSString*)file
{
    std::string filename = [file UTF8String];
    switch (gobFile->GetFileType(filename))
    {
    case DF::FileType::Bm:
        [self.previewViewController loadBM:gobFile.get() named:filename.c_str() withPal:&pal];
        break;
    case DF::FileType::Fme:
        [self.previewViewController loadFme:gobFile.get() named:filename.c_str() withPal:&pal];
        break;
    
    case DF::FileType::Wax:
        [self.previewViewController loadWax:gobFile.get() named:filename.c_str() withPal:&pal];
        break;
    
    case DF::FileType::Msg:
        [self.previewViewController loadMsg:gobFile.get() named:filename.c_str()];
        break;
    
    default:
    {
        size_t size = gobFile->GetFileSize(filename);
        DF::Buffer buffer = DF::Buffer::Create(size);
        gobFile->ReadFile(filename, buffer.GetW(0), 0, size);
        std::cout << std::string(buffer.GetObjR<char>(), size);
        break;
    }
    }
}

@end
