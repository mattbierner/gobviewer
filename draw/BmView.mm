#import "BmView.h"

#include <iostream>

#include <iostream>
#include <fstream>
#include <vector>
#include <iomanip>

#include "GobFileData.h"
#include "GobFile.h"
#include "BmFile.h"
#include "FmeFile.h"
#include "PalFile.h"
#include "WaxFile.h"
#include "Buffer.h"

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


DF::BmFile loadBm(DF::GobFile* gob, const char* filename)
{
    std::string file(filename);
    size_t size = gob->GetFileSize(file);
    DF::Buffer buffer = DF::Buffer::Create(size);
    gob->ReadFile(file, buffer.Get(0), 0, size);
    
    return DF::BmFile(std::move(buffer));
}

DF::FmeFile loadFme(DF::GobFile* gob, const char* filename)
{
    std::string file(filename);
    size_t size = gob->GetFileSize(file);
    DF::Buffer buffer = DF::Buffer::Create(size);
    gob->ReadFile(file, buffer.Get(0), 0, size);
    
    return DF::FmeFile(std::move(buffer));
}

DF::WaxFile loadWax(DF::GobFile* gob, const char* filename)
{
    std::string file(filename);
    size_t size = gob->GetFileSize(file);
    DF::Buffer buffer = DF::Buffer::Create(size);
    gob->ReadFile(file, buffer.Get(0), 0, size);
    
    return DF::WaxFile(std::move(buffer));
}

struct __attribute__((packed)) RGB { uint8_t r, g, b, a; };


RGB* BmToRgb(const DF::BmFile& bm, unsigned index, const DF::PalFileData& pal)
{
    size_t width = bm.GetWidth(index);
    size_t height = bm.GetHeight(index);
    size_t size = bm.GetDataSize(index);

    RGB* imgData = new RGB[size];

    DF::Buffer data = DF::Buffer::Create(size);
    bm.GetData(index, data.Get(0), size);
    bool trans = bm.GetTransparency() != DF::BmFileTransparency::Normal;
    for (unsigned row = 0; row < height; ++row)
    {
        for (unsigned col = 0; col < width; ++col)
        {
            uint8_t entry = data[col * height + row];
            if (trans && entry == 0)
            {
                imgData[(height - 1 - row) * width + col].a = 0;
            }
            else
            {
                auto palColors = pal.colors[entry];
                imgData[(height - 1 - row) * width + col] = {palColors.r, palColors.g, palColors.b, 255};
            }
        }
    }
    return imgData;
}

RGB* FmeToRgb(const DF::FmeFile& bm, const DF::PalFileData& pal)
{
    size_t width = bm.GetWidth();
    size_t height = bm.GetHeight();
    size_t size = bm.GetDataSize();

    RGB* imgData = new RGB[size];

    DF::Buffer data = DF::Buffer::Create(size);
    bm.Read(data.Get(0), 0, size);

    for (unsigned row = 0; row < height; ++row)
    {
        for (unsigned col = 0; col < width; ++col)
        {
            uint8_t entry = data[col * height + row];
            if (entry == 0)
            {
                imgData[(height - 1 - row) * width + col].a = 0;
            }
            else
            {
                auto palColors = pal.colors[entry];
                imgData[(height - 1 - row) * width + col] = {palColors.r, palColors.g, palColors.b, 255};
            }
        }
    }
    return imgData;
}

void f(void *info, const void *data, size_t size)
{
   delete[] ((RGB*)data);
}


@implementation BmView

- (id) initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        imageIndex = 0;
    
        {
            DF::GobFile gob = open("DARK.GOB");
            
            std::string file("SECBASE.PAL");
            size_t size = gob.GetFileSize(file);
            DF::Buffer buffer = DF::Buffer::Create(size);
            gob.ReadFile(file, buffer.Get(0), 0, size);
            DF::PalFile p(std::move(buffer));

            p.GetData(reinterpret_cast<uint8_t*>(&pal), sizeof(DF::PalFileData));
        }
        
        [self update];
        [NSTimer scheduledTimerWithTimeInterval:0.05//1.0f / bm.GetFrameRate()
                                 target:self
                               selector:@selector(update)
                               userInfo:nil
                                repeats:YES];
        
        self.imageView = [[NSImageView alloc] initWithFrame:self.bounds];

        [self.imageView setImageScaling:NSImageScaleProportionallyUpOrDown];
        [self addSubview:self.imageView];

    }
    return self;
}

- (void) loadBM:(DF::GobFile*)gob named:(const char*)filename
{
    DF::BmFile bm = loadBm(gob, filename);

    unsigned subCount = bm.GetCountSubBms();

    self.images = [NSMutableArray arrayWithCapacity:subCount];

    for (unsigned i = 0; i < subCount; ++i)
    {
        size_t width = bm.GetWidth(i);
        size_t height = bm.GetHeight(i);
        size_t imgDataSize = bm.GetDataSize(i) * 32;
        
        RGB* imgData = BmToRgb(bm, i, pal);
        
        CGDataProviderRef imageData = CGDataProviderCreateWithData(NULL, imgData, imgDataSize, f);
        CGImageRef img = CGImageCreate(
            width,
            height,
            8,
            8 * 4,
            4 * width,
            CGColorSpaceCreateDeviceRGB(),
            kCGBitmapByteOrderDefault | kCGImageAlphaLast,
            imageData,
            NULL,
            NO,
            kCGRenderingIntentDefault);
        
        CGDataProviderRelease(imageData);
        
        [self.images addObject:[[NSImage alloc] initWithCGImage:img size:NSZeroSize]];
        CGImageRelease(img);
    }
    imageIndex = 0;
    [self update];
}

- (void) loadFme:(DF::GobFile*)gob named:(const char*)filename
{
    DF::FmeFile bm = loadFme(gob, filename);

    size_t width = bm.GetWidth();
    size_t height = bm.GetHeight();
    size_t imgDataSize = bm.GetDataSize() * 32;
    
    RGB* imgData = FmeToRgb(bm, pal);
    
    CGDataProviderRef imageData = CGDataProviderCreateWithData(NULL, imgData, imgDataSize, f);
    CGImageRef img = CGImageCreate(
        width,
        height,
        8,
        8 * 4,
        4 * width,
        CGColorSpaceCreateDeviceRGB(),
        kCGBitmapByteOrderDefault | kCGImageAlphaLast,
        imageData,
        NULL,
        NO,
        kCGRenderingIntentDefault);
    
    CGDataProviderRelease(imageData);

    self.images = [NSMutableArray arrayWithObject:[[NSImage alloc] initWithCGImage:img size:NSZeroSize]];
    CGImageRelease(img);
    
    imageIndex = 0;
    [self update];
}


- (void) loadWax:(DF::GobFile*)gob named:(const char*)filename
{
    DF::WaxFile w = loadWax(gob, filename);

    DF::WaxFileWax wax = w.GetWax(0);
    
  
    self.images = [NSMutableArray arrayWithCapacity:0];

    unsigned numSeqs = wax.GetSequencesCount();
    for (unsigned sequenceIndex = 0; sequenceIndex < numSeqs; ++sequenceIndex)
    {
        DF::WaxFileSequence seq = wax.GetSequence(sequenceIndex);
    
        unsigned numFrames = seq.GetFramesCount();

        for (unsigned frame = 0; frame < numFrames; ++frame)
        {
            DF::FmeFile bm = seq.GetFrame(frame);

            size_t width = bm.GetWidth();
            size_t height = bm.GetHeight();
            size_t imgDataSize = bm.GetDataSize() * 32;

            RGB* imgData = FmeToRgb(bm, pal);
            
            CGDataProviderRef imageData = CGDataProviderCreateWithData(NULL, imgData, imgDataSize, f);
            CGImageRef img = CGImageCreate(
                width,
                height,
                8,
                8 * 4,
                4 * width,
                CGColorSpaceCreateDeviceRGB(),
                kCGBitmapByteOrderDefault | kCGImageAlphaLast,
                imageData,
                NULL,
                NO,
                kCGRenderingIntentDefault);
            
            CGDataProviderRelease(imageData);

            [self.images addObject:[[NSImage alloc] initWithCGImage:img size:NSZeroSize]];
            CGImageRelease(img);
        }
    }
    
    imageIndex = 0;
    [self update];
}



- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}


- (void) update
{
    if ([self.images count] > 0)
    {
        [self.imageView setImage:[self.images objectAtIndex:imageIndex]];
        imageIndex = (imageIndex + 1) % [self.images count];
        [self setNeedsDisplay:YES];
    }
}

@end
