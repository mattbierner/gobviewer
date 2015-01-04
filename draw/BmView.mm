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
#include <gober/Wax.h>

PACKED(struct RGB
{
    uint8_t r, g, b, a;
});

CGSize flipSize(CGSize size)
{
    return CGSizeMake(size.height, size.width);
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

@implementation BmCell

+ (BmCell*) cellForImage:(NSImage*)image flipped:(bool)flipped
{
    BmCell* cell = [[BmCell alloc] init];
    cell.image = image;
    cell.flipped = flipped;
    return cell;
}

- (id) init
{
    if (self = [super init])
    {
        self.flipped = false;
        self.image = nil;
    }
    return self;
}

@end


@implementation BmAnimation

+ (BmAnimation*) animationForImage:(NSImage*)image
{
    BmAnimation* animation = [[BmAnimation alloc] init];
    [animation.frames addObject:[BmCell cellForImage:image flipped:NO]];
    animation.frameRate = 0;
    return animation;
}

- (id) init
{
    if (self = [super init])
    {
        self.frames = [[NSMutableArray alloc] init];
    }
    return self;
}

@end


@interface BmView()

- (CGImageRef) createImage:(RGB*) data
    size:(size_t) dataSize
    width:(unsigned) width
    height:(unsigned) height;

- (void) addImage:(CGImageRef)img;

- (void) addImage:(RGB*) data
    size:(size_t) dataSize
    width:(unsigned) width
    height:(unsigned) height;

@end


@implementation BmView

- (CGRect) proportionallyScale:(CGSize)fromSize toSize:(CGSize)toSize
{
    CGPoint origin = CGPointZero;

    CGFloat width = fromSize.width;
    CGFloat height = fromSize.height;
    
    CGFloat targetWidth = toSize.width;
    CGFloat targetHeight = toSize.height;
    
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    if (!NSEqualSizes(fromSize, toSize))
    {
        float widthFactor = targetWidth / width;
        float heightFactor = targetHeight / height;

        CGFloat scaleFactor = std::min(widthFactor, heightFactor);

        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;

        if (widthFactor < heightFactor)
            origin.y = (targetHeight - scaledHeight) / 2.0;
        else if (widthFactor > heightFactor)
            origin.x = (targetWidth - scaledWidth) / 2.0;
    }
    return {origin, {scaledWidth, scaledHeight}};
}

- (id) initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect])
    {
        self.wantsLayer = YES;
        
        imageIndex = 0;
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
    NSImage* image = [[NSImage alloc] initWithCGImage:img size:CGSizeZero];
    BmAnimation* animation = [BmAnimation animationForImage:image];
    [self.animations addObject:animation];
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

- (void) loadBM:(DF::GobFile*)gob named:(const char*)filename withPal:(DF::PalFileData*)pal
{
    DF::Bm bm = DF::Bm::CreateFromFile(loadBm(gob, filename));
    size_t subCount = bm.GetCountSubBms();

    BmAnimation* animation = [[BmAnimation alloc] init];
    
    for (unsigned i = 0; i < subCount; ++i)
    {
        unsigned width = bm.GetWidth(i);
        unsigned height = bm.GetHeight(i);
        size_t imgDataSize = bm.GetDataSize(i) * 32;
        
        RGB* imgData = BmToRgb(*(bm.GetBitmap(i)), *pal);
        
        CGImageRef imgRef = [self createImage:imgData size: imgDataSize width:height height:width];
        NSImage* img = [[NSImage alloc] initWithCGImage:imgRef size:CGSizeZero];
        CGImageRelease(imgRef);
        [animation.frames addObject:[BmCell cellForImage:img flipped:NO]];
    }
    
    if (bm.IsSwitch())
    {
        animation.frameRate = 1;
    }
    else
    {
        animation.frameRate = 1.0f / bm.GetFrameRate();
    }
    
    self.animations = [NSMutableArray arrayWithObject:animation];

    animationIndex = 0;
    imageIndex = 0;
    [self update];
}

- (void) loadFme:(DF::GobFile*)gob named:(const char*)filename withPal:(DF::PalFileData*)pal
{
    DF::Cell bm = DF::Cell::CreateFromFile(loadFme(gob, filename));

    unsigned width = bm.GetWidth();
    unsigned height = bm.GetHeight();
    size_t imgDataSize = bm.GetDataSize() * 32;
    
    RGB* imgData = BmToRgb(*bm.GetBitmap(), *pal);
    
    self.animations = [NSMutableArray arrayWithCapacity:1];
    [self addImage:imgData size:imgDataSize width:height height:width];
    
    [self setFrameRate:0];
    animationIndex = 0;
    imageIndex = 0;
    [self update];
}

- (void) loadWax:(DF::GobFile*)gob named:(const char*)filename withPal:(DF::PalFileData*)pal
{
    DF::Wax w = DF::Wax::CreateFromFile(loadWax(gob, filename));
  
    self.animations = [NSMutableArray arrayWithCapacity:0];

    // Since waxes reuse a lot of image data, make a cache so we avoid creating
    // duplicate CGImages.
    std::map<std::shared_ptr<DF::Bitmap>, CGImageRef> imageDatas;
    
    for (size_t waxIndex : w.GetActions())
    {
        DF::WaxAction wax = w.GetAction(waxIndex);
    
        size_t numSeqs = wax.GetSequencesCount();
        for (size_t sequenceIndex = 0; sequenceIndex < numSeqs; ++sequenceIndex)
        {
            DF::WaxActionSequence seq = wax.GetSequence(sequenceIndex);
            
            size_t numFrames = seq.GetFramesCount();
            BmAnimation* animation = [[BmAnimation alloc] init];
            animation.frameRate = 1.0f / wax.GetFrameRate();
            
            for (size_t frame = 0; frame < numFrames; ++frame)
            {
                DF::Cell bm = seq.GetFrame(frame);
                const auto found = imageDatas.find(bm.GetBitmap());
                CGImageRef img;
                if (found != std::end(imageDatas))
                {
                    img = found->second;
                }
                else
                {
                    unsigned width = bm.GetWidth();
                    unsigned height = bm.GetHeight();
                    size_t imgDataSize = bm.GetDataSize() * 32;
                    auto bitmap = bm.GetBitmap();
                    RGB* imgData = BmToRgb(*bitmap, *pal);
                    img = [self createImage:imgData size:imgDataSize width:height height:width];
                    imageDatas[bitmap] = img;
                }
                [animation.frames addObject:
                    [BmCell cellForImage:[[NSImage alloc] initWithCGImage:img size:CGSizeZero]
                        flipped:bm.IsFlipped()]];
            }
            [self.animations addObject:animation];
        }
    }
    
    for (const auto& pair : imageDatas)
        CGImageRelease(pair.second);
    
    animationIndex = 0;
    imageIndex = 0;
    [self update];
}

- (void) setFrameRate:(NSTimeInterval)frameRate
{
    [self.animationTimer invalidate];
    if (frameRate > 0)
    {
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:frameRate
            target:self
            selector:@selector(update)
            userInfo:nil
            repeats:YES];
    }
}

- (void) drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    if ([self.animations count] == 0) return;
    
    BmAnimation* animation = [self.animations objectAtIndex:animationIndex];
    BmCell* cell = [animation.frames objectAtIndex:imageIndex];
    
    CGRect drawRect = dirtyRect;
    CGRect imageRect = [self
        proportionallyScale: cell.image.size
        toSize: drawRect.size];
   
    NSAffineTransform* rotation = [[NSAffineTransform alloc] init];
    [rotation translateXBy:NSWidth(drawRect) / 2 yBy:NSHeight(drawRect) / 2];
    [rotation rotateByDegrees:90];
    if (cell.flipped)
        [rotation scaleXBy:1.0 yBy:-1.0];
    [rotation translateXBy:-NSWidth(drawRect) / 2 yBy:-NSHeight(drawRect) / 2];
    
    NSGraphicsContext* context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];
    [rotation concat];
    [cell.image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [context restoreGraphicsState];
}

- (void) update
{
    if ([self.animations count] > 0)
    {
        NSUInteger numberFrames = [((BmAnimation*)[self.animations objectAtIndex:animationIndex]).frames count];
        ++imageIndex;
        if (imageIndex >= numberFrames)
        {
            animationIndex = (animationIndex + 1) % [self.animations count];
            imageIndex = 0;
        }
        [self setFrameRate:((BmAnimation*)[self.animations objectAtIndex:animationIndex]).frameRate];
        [self setNeedsDisplay:YES];
    }
}

@end
