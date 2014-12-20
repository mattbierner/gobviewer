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
#include "PalFile.h"
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


DF::BmFile parse(const char* file, const char* filename)
{
    std::ifstream fs;
    fs.open(file, std::ifstream::binary | std::ifstream::in);
    if (fs.is_open())
    {
        auto gob = DF::GobFile::CreateFromFile(std::move(fs));
        
            
    for (auto a : gob.GetFilenames())
        std::cout << a  << std::endl;
        
        std::string file(filename);
        size_t size = gob.GetFileSize(file);
        DF::Buffer buffer = DF::Buffer::Create(size);
        gob.ReadFile(file, buffer.Get(), 0, size);
        
        return DF::BmFile(std::move(buffer));
    }
    return { };
}

struct __attribute__((packed)) RGB { uint8_t r, g, b; };


RGB* BmToRgb(const DF::BmFile& bm, const DF::PalFileData& pal)
{
    size_t index = 0;

    size_t width = bm.GetWidth(index);
    size_t height = bm.GetHeight(index);
    size_t size = bm.GetDataSize(index);

    RGB* imgData = new RGB[size];

    DF::Buffer data = DF::Buffer::Create(size);
    bm.GetData(0, data.Get(), size);

    for (unsigned row = 0; row < height; ++row)
    {
        for (unsigned col = 0; col < width; ++col)
        {
            uint8_t entry = data[col * height + row];
            auto palColors = pal.colors[entry];
            imgData[(height - 1 - row) * width + col] = {palColors.r, palColors.g, palColors.b};
        }
    }
    return imgData;
}

@implementation BmView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    DF::PalFileData pal;
    {
        DF::GobFile gob = open("DARK.GOB");
        
        for (auto a : gob.GetFilenames())
        std::cout << a  << std::endl;

        
        std::string file("SECBASE.PAL");
        size_t size = gob.GetFileSize(file);
        DF::Buffer buffer = DF::Buffer::Create(size);
        gob.ReadFile(file, buffer.Get(0), 0, size);
        DF::PalFile p(std::move(buffer));

        p.GetData(reinterpret_cast<uint8_t*>(&pal), sizeof(DF::PalFileData));
    }
    
    DF::BmFile bm = parse("TEXTURES.GOB", "ZANAV.BM");

    
    size_t width = bm.GetWidth();
    size_t height = bm.GetHeight();
    size_t imgDataSize = bm.GetDataSize() * 24;
    
    RGB* imgData = BmToRgb(bm, pal);
    
    CGDataProviderRef imageData = CGDataProviderCreateWithData(NULL, imgData, imgDataSize, NULL);
    CGImageRef img = CGImageCreate(
        width,
        height,
        8,
        8 * 3,
        3 * width,
        CGColorSpaceCreateDeviceRGB(),
        kCGBitmapByteOrderDefault,
        imageData,
        NULL,
        NO,
        kCGRenderingIntentDefault);
    
        CGContextRef ctx = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    
   // const CGFloat maskingColors[6] = { 0, 0, 0, 0, 0, 0 };
    ///CGImageRef trans = CGImageCreateWithMaskingColors(img, maskingColors);
    
    //CGContextFillRect(ctx,  CGRectMake(0, 0, width * 2, height * 2));
    
        CGContextDrawImage(
            ctx,
            CGRectMake(0, 0, width * 6, height * 6),
            img);
    
    //    CGImageRelease(trans);
            CGImageRelease(img);


}

@end
