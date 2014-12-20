//
//  BmView.m
//  gob
//
//  Created by Matt Bierner on 12/18/14.
//  Copyright (c) 2014 Matt Bierner. All rights reserved.
//

#import "BmView.h"

#include <iostream>

#include <iostream>
#include <fstream>
#include <vector>
#include <iomanip>

#include "GobFileData.h"
#include "GobFile.h"
#include "BmFile.h"
#include "Pal.h"

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


DF::BmFile parse(const char* file, const char* filename)
{
    std::ifstream fs;
    fs.open(file, std::ifstream::binary | std::ifstream::in);
    if (fs.is_open())
    {
        auto x = DF::GobFile::CreateFromFile(std::move(fs));
        
        
        std::string file(filename);
        size_t size = x.GetFileSize(file);
        uint8_t* buffer = new uint8_t[size];
        x.ReadFile(file, buffer, 0, size);
        
        return DF::BmFile::CreateFromBuffer(buffer, size);
    }
    return { };
}

struct __attribute__((packed)) RGB { uint8_t r, g, b; };


@implementation BmView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    DF::PalFile pal;
    {
        DF::GobFile gob = open("DARK.GOB");
          for (auto a : gob.GetFilenames())
            std::cout << a  << std::endl;

        
        std::string file("SEWERS.PAL");
        size_t size = gob.GetFileSize(file);
        
        uint8_t* data = new uint8_t[size];
        gob.ReadFile(file, data, 0, size);
        DF::Pal p= DF::Pal::CreateFromBuffer(data, size);

        p.GetData(reinterpret_cast<uint8_t*>(&pal), sizeof(DF::PalFile));
    }
    
    DF::BmFile bm = parse("TEXTURES.GOB", "GPZIGZ1X.BM");
    size_t size = bm.GetDataSize();
    uint8_t* data = new uint8_t[size];
    bm.GetData(data, size);
    
    size_t sizeX = bm.GetSizeX();
    size_t sizeY = bm.GetSizeY();
    size_t imgDataSize = bm.GetDataSize() * 24;
    
    RGB* imgData = new RGB[sizeX * sizeY];
    std::cout << static_cast<int>(bm.GetTransparency());

    for (unsigned x = 0; x < sizeX; ++x)
    {
        for (unsigned y = 0; y < sizeY; ++y)
        {
            uint8_t entry = data[x * sizeX + y];
            auto palColors = pal.colors[entry];
            imgData[x * sizeX + y] = {palColors.r, palColors.g, palColors.b};
        }
    }
    
    CGDataProviderRef imageData = CGDataProviderCreateWithData(NULL, imgData, imgDataSize, NULL);
    CGImageRef img = CGImageCreate(
        sizeX,
        sizeY,
        8,
        8 * 3,
        3 * sizeX,
        CGColorSpaceCreateDeviceRGB(),
        kCGBitmapByteOrder32Big,
        imageData,
        NULL,
        NO,
        kCGRenderingIntentDefault);
    
        CGContextRef ctx = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    
        CGContextDrawImage(
            ctx,
            CGRectMake(0, 0, sizeX * 4, sizeY * 4),
            img);
}

@end
