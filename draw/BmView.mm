#import "BmView.h"

#import "Bitmap.h"
#import "DfColor.h"
#import "Pal.h"

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


DF::BmFile loadBm(DF::GobFile* gob, const char* filename)
{
    std::string file(filename);
    size_t size = gob->GetFileSize(file);
    DF::Buffer buffer = DF::Buffer::Create(size);
    gob->ReadFile(file, buffer.GetW(0), 0, size);
    
    return DF::BmFile(std::move(buffer));
}

DF::FmeFile loadFme(DF::GobFile* gob, const char* filename)
{
    std::string file(filename);
    size_t size = gob->GetFileSize(file);
    DF::Buffer buffer = DF::Buffer::Create(size);
    gob->ReadFile(file, buffer.GetW(0), 0, size);
    
    return DF::FmeFile(std::move(buffer));
}

DF::WaxFile loadWax(DF::GobFile* gob, const char* filename)
{
    std::string file(filename);
    size_t size = gob->GetFileSize(file);
    DF::Buffer buffer = DF::Buffer::Create(size);
    gob->ReadFile(file, buffer.GetW(0), 0, size);
    
    return DF::WaxFile(std::move(buffer));
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

- (void) addImage:(CGImageRef)img;

@end


@implementation BmView

- (id) initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect])
    {
        imageIndex = 0;
    }

    return self;
}

- (void) addImage:(CGImageRef)img
{
    NSImage* image = [[NSImage alloc] initWithCGImage:img size:CGSizeZero];
    BmAnimation* animation = [BmAnimation animationForImage:image];
    [self.animations addObject:animation];
}

- (void) loadBM:(DF::GobFile*)gob named:(const char*)filename
{
    DF::Bm bm = DF::Bm::CreateFromFile(loadBm(gob, filename));
    size_t subCount = bm.GetCountSubBms();

    BmAnimation* animation = [[BmAnimation alloc] init];
    
    for (unsigned i = 0; i < subCount; ++i)
    {
        Bitmap* bitmap = [Bitmap createForBitmap:bm.GetBitmap(i) pal:self.pal];
        NSImage* img = [bitmap getImage];
        [animation.frames addObject:[BmCell cellForImage:img flipped:NO]];
    }
    
    animation.frameRate = (bm.IsSwitch() ? 1 : 1.0 / bm.GetFrameRate());
    self.animations = [NSMutableArray arrayWithObject:animation];

    animationIndex = 0;
    imageIndex = 0;
    [self update];
}

- (void) loadFme:(DF::GobFile*)gob named:(const char*)filename
{
    DF::Cell bm = DF::Cell::CreateFromFile(loadFme(gob, filename));

    Bitmap* bitmap = [Bitmap createForBitmap:bm.GetBitmap() pal:self.pal];
    
    NSImage* image = [bitmap getImage];
    BmAnimation* animation = [BmAnimation animationForImage:image];
    self.animations = [NSMutableArray arrayWithObject:animation];
    
    animationIndex = 0;
    imageIndex = 0;
    [self update];
}

- (void) loadWax:(DF::GobFile*)gob named:(const char*)filename
{
    DF::Wax w = DF::Wax::CreateFromFile(loadWax(gob, filename));
  
    self.animations = [NSMutableArray arrayWithCapacity:0];

    // Since waxes reuse a lot of image data, make a cache so we avoid creating
    // duplicate CGImages.
    std::map<std::shared_ptr<DF::Bitmap>, NSImage*> imageDatas;
    
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
                auto bitmap = bm.GetBitmap();
                const auto found = imageDatas.find(bitmap);
                NSImage* img = nil;
                if (found != std::end(imageDatas))
                {
                    img = found->second;
                }
                else
                {
                    Bitmap* bitmapObj = [Bitmap createForBitmap:bitmap pal:self.pal];
                    img = [bitmapObj getImage];
                    imageDatas[bitmap] = img;
                }
                [animation.frames addObject:
                    [BmCell cellForImage:img flipped:bm.IsFlipped()]];
            }
            [self.animations addObject:animation];
        }
    }
    
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
        
        BmAnimation* animation = [self.animations objectAtIndex:animationIndex];
        BmCell* cell = [animation.frames objectAtIndex:imageIndex];
        self.image = cell.image;
        self.drawFlipped = cell.flipped;
    
        [self setNeedsDisplay:YES];
    }
    else
    {
        self.image = nil;
    }
}

@end
