//
//  BmView.h
//  gob
//
//  Created by Matt Bierner on 12/18/14.
//  Copyright (c) 2014 Matt Bierner. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include "PalFile.h"
#include "BmFile.h"
#include "GobFile.h"

@interface BmView : NSView
{
    unsigned imageIndex;
    
    DF::PalFileData pal;
}

@property (nonatomic, strong) NSImage* image;
@property (nonatomic, strong) NSMutableArray* images;
@property (nonatomic, strong) NSImageView* imageView;

- (id) initWithFrame:(NSRect)frame;

- (void) loadBM:(DF::GobFile*) gob named:(const char*)filename;
- (void) loadFme:(DF::GobFile*) gob named:(const char*)filename;

- (void) update;

@end
