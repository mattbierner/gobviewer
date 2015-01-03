#import "BmView.h"

#include <iostream>

#include <iostream>
#include <fstream>
#include <vector>
#include <iomanip>

#include <gober/GobFileData.h>
#include <gober/GobFile.h>
#include <gober/BmFile.h>
#include <gober/FmeFile.h>
#include <gober/PalFile.h>
#include <gober/WaxFile.h>
#include <gober/Buffer.h>
#include <gober/Bm.h>
#include <gober/Cell.h>

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

RGB* BmDataToRgb(const DF::IBuffer& buffer, const DF::PalFileData& pal, bool trans)
{
    size_t size = buffer.GetDataSize();
    RGB* imgData = new RGB[size];
    RGB* dataWriter = imgData;
    
    const uint8_t* bmData = buffer.Get(0);
    const uint8_t* bmDataEnd = bmData + size;
    while (bmData < bmDataEnd)
    {
        uint8_t entry = *(bmData++);
        if (trans && entry == 0)
        {
            (*(dataWriter++)).a = 0;
        }
        else
        {
            auto palColors = pal.colors[entry];
            (*(dataWriter++)) = {palColors.r, palColors.g, palColors.b, 255};
        }
    }
    return imgData;
}

RGB* BmToRgb(const DF::Bitmap& bm, const DF::PalFileData& pal)
{
    return BmDataToRgb(bm, pal, (bm.GetTransparency() != DF::BmFileTransparency::Normal));
}

void f(void *info, const void *data, size_t size)
{
   delete[] ((RGB*)data);
}

@implementation BmView

- (id) initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect])
    {
        imageIndex = 0;

        {
            DF::GobFile gob = open("DARK.GOB");
            
            std::string file("SECBASE.PAL");
            size_t size = gob.GetFileSize(file);
            DF::Buffer buffer = DF::Buffer::Create(size);
            gob.ReadFile(file, buffer.Get(0), 0, size);
            DF::PalFile p(std::move(buffer));

            p.Read(reinterpret_cast<uint8_t*>(&pal), 0, sizeof(DF::PalFileData));
        }
        
        [NSTimer scheduledTimerWithTimeInterval:0.05//1.0f / bm.GetFrameRate()
                                 target:self
                               selector:@selector(update)
                               userInfo:nil
                                repeats:YES];
        
        [self setImageScaling:NSImageScaleProportionallyUpOrDown];
    }

    return self;
}

- (CGImageRef) createImage:(RGB*) imgData
    size:(size_t) dataSize
    width:(unsigned) width
    height:(unsigned) height
{
    CGDataProviderRef imageData = CGDataProviderCreateWithData(NULL, imgData, dataSize, f);
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
    return img;
}

- (void) addImage:(CGImageRef)img
{
    [self.images addObject:[[NSImage alloc] initWithCGImage:img size:NSZeroSize]];
}

- (void) addImage:(RGB*) imgData
    size:(size_t) imgDataSize
    width:(unsigned) width
    height:(unsigned) height
{
    CGImageRef img = [self createImage:imgData size:imgDataSize width:width height:height];
    [self addImage:img];
    CGImageRelease(img);
}

- (void) loadBM:(DF::GobFile*)gob named:(const char*)filename
{
    DF::Bm bm = loadBm(gob, filename).CreateBm();
    size_t subCount = bm.GetCountSubBms();

    self.images = [NSMutableArray arrayWithCapacity:subCount];

    for (unsigned i = 0; i < subCount; ++i)
    {
        unsigned width = bm.GetWidth(i);
        unsigned height = bm.GetHeight(i);
        size_t imgDataSize = bm.GetDataSize(i) * 32;
        
        RGB* imgData = BmToRgb(*(bm.GetBitmap(i)), pal);
        [self addImage:imgData size: imgDataSize width:height height:width];
    }
    
    imageIndex = 0;
    [self update];
}

- (void) loadFme:(DF::GobFile*)gob named:(const char*)filename
{
    DF::Cell bm = loadFme(gob, filename).CreateCell();

    unsigned width = bm.GetWidth();
    unsigned height = bm.GetHeight();
    size_t imgDataSize = bm.GetDataSize() * 32;
    
    RGB* imgData = BmToRgb(*bm.GetBitmap(), pal);
    self.images = [NSMutableArray arrayWithCapacity:1];
    [self addImage:imgData size:imgDataSize width:height height:width];
    
    imageIndex = 0;
    [self update];
}

- (void) loadWax:(DF::GobFile*)gob named:(const char*)filename
{
    DF::WaxFile w = loadWax(gob, filename);
  
    self.images = [NSMutableArray arrayWithCapacity:0];

    // Since waxes reuse a lot of image data, make a cache so we avoid creating
    // duplicate CGImages.
    std::map<size_t, CGImageRef> imageDatas;
    
    for (size_t waxIndex : w.GetActions())
    {
        DF::WaxFileWax wax = w.GetAction(waxIndex);

        unsigned numSeqs = wax.GetSequencesCount();
        for (unsigned sequenceIndex = 0; sequenceIndex < numSeqs; ++sequenceIndex)
        {
            DF::WaxFileSequence seq = wax.GetSequence(sequenceIndex);
        
            unsigned numFrames = seq.GetFramesCount();

            for (unsigned frame = 0; frame < numFrames; ++frame)
            {
                DF::FmeFile bm = seq.GetFrame(frame);
                const auto found = imageDatas.find(bm.GetDataUid());
                if (found != std::end(imageDatas))
                {
                    CGImageRef img = found->second;
                    [self addImage:img];
                }
                else
                {
                    unsigned width = bm.GetWidth();
                    unsigned height = bm.GetHeight();
                    size_t imgDataSize = bm.GetDataSize() * 32;

                    RGB* imgData = BmToRgb(bm.CreateBitmap(), pal);
                    CGImageRef img = [self createImage:imgData size: imgDataSize width:height height:width];
                    imageDatas[bm.GetDataUid()] = img;
                    [self addImage:img];
                }
            }
        }
    }
    
    for (const auto& pair : imageDatas)
        CGImageRelease(pair.second);
    
    imageIndex = 0;
    [self update];
}

- (void) update
{
    if ([self.images count] > 0)
    {
        [self setImage:[self.images objectAtIndex:imageIndex]];
        [self setFrameCenterRotation:90];
        imageIndex = (imageIndex + 1) % [self.images count];
        [self setNeedsDisplay:YES];
    }
}

@end
