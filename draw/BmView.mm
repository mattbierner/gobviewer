#import "BmView.h"

#import "Bitmap.h"
#import "Cmp.h"
#import "DfColor.h"
#import "Gob.h"
#import "Pal.h"

#include <iostream>

#include <iostream>
#include <fstream>
#include <vector>
#include <iomanip>

#include <gob/GobFileData.h>
#include <gob/GobFile.h>
#include <gob/BmFile.h>
#include <gob/FmeFile.h>
#include <gob/PalFile.h>
#include <gob/WaxFile.h>
#include <gob/Buffer.h>
#include <gob/Bm.h>
#include <gob/Cell.h>
#include <gob/Wax.h>

@interface BmView()


+ (Df::BmFile) loadBm:(Gob*)gob named:(NSString*)filename;

+ (Df::FmeFile) loadFme:(Gob*)gob named:(NSString*)filename;

+ (Df::WaxFile) loadWax:(Gob*)gob named:(NSString*)filename;

@end

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

+ (Df::BmFile) loadBm:(Gob*)gob named:(NSString*)filename
{
    auto buffer = [gob readFileToBuffer:filename];
    return Df::BmFile(std::move(buffer));
}

+ (Df::FmeFile) loadFme:(Gob*)gob named:(NSString*)filename;
{
    auto buffer = [gob readFileToBuffer:filename];
    return Df::FmeFile(std::move(buffer));
}

+ (Df::WaxFile) loadWax:(Gob*)gob named:(NSString*)filename;
{
    auto buffer = [gob readFileToBuffer:filename];
    return Df::WaxFile(std::move(buffer));
}

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

- (void) loadBM:(Gob*)gob named:(NSString*)filename
{
    auto bmFile = [[self class] loadBm:gob named:filename];
    Df::Bm bm = Df::Bm::CreateFromFile(bmFile);
    
    size_t subCount = bm.GetCountSubBms();
    BmAnimation* animation = [[BmAnimation alloc] init];
    
    for (unsigned i = 0; i < subCount; ++i)
    {
        Bitmap* bitmap = [Bitmap createForBitmap:bm.GetBitmap(i) pal:self.pal cmp:self.cmp];
        NSImage* img = [bitmap getImage];
        [animation.frames addObject:[BmCell cellForImage:img flipped:NO]];
    }
    
    animation.frameRate = (bm.IsSwitch() ? 1 : 1.0 / bm.GetFrameRate());
    self.animations = [NSMutableArray arrayWithObject:animation];

    animationIndex = 0;
    imageIndex = 0;
    [self update];
}

- (void) loadFme:(Gob*)gob named:(NSString*)filename
{
    auto fmeFile = [[self class] loadFme:gob named:filename];
    Df::Cell bm = Df::Cell::CreateFromFile(fmeFile);

    Bitmap* bitmap = [Bitmap createForBitmap:bm.GetBitmap() pal:self.pal cmp:self.cmp];
    
    NSImage* image = [bitmap getImage];
    BmAnimation* animation = [BmAnimation animationForImage:image];
    self.animations = [NSMutableArray arrayWithObject:animation];
    
    animationIndex = 0;
    imageIndex = 0;
    [self update];
}

- (void) loadWax:(Gob*)gob named:(NSString*)filename
{
    auto waxFile = [[self class] loadWax:gob named:filename];
    Df::Wax w = Df::Wax::CreateFromFile(waxFile);
  
    self.animations = [NSMutableArray arrayWithCapacity:0];

    // Since waxes reuse a lot of image data, make a cache so we avoid creating
    // duplicate CGImages.
    std::map<std::shared_ptr<Df::Bitmap>, NSImage*> imageDatas;
    
    for (size_t waxIndex : w.GetActions())
    {
        Df::WaxAction wax = w.GetAction(waxIndex);
    
        size_t numSeqs = wax.GetSequencesCount();
        for (size_t sequenceIndex = 0; sequenceIndex < numSeqs; ++sequenceIndex)
        {
            Df::WaxActionSequence seq = wax.GetSequence(sequenceIndex);
            
            size_t numFrames = seq.GetFramesCount();
            BmAnimation* animation = [[BmAnimation alloc] init];
            animation.frameRate = 1.0f / wax.GetFrameRate();
            
            for (size_t frame = 0; frame < numFrames; ++frame)
            {
                Df::Cell bm = seq.GetFrame(frame);
                auto bitmap = bm.GetBitmap();
                const auto found = imageDatas.find(bitmap);
                NSImage* img = nil;
                if (found != std::end(imageDatas))
                {
                    img = found->second;
                }
                else
                {
                    Bitmap* bitmapObj = [Bitmap createForBitmap:bitmap pal:self.pal cmp:self.cmp];
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
