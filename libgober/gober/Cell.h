#pragma once

#include <gober/Bitmap.h>
#include <gober/BmFileData.h>

namespace DF
{

/**
    Single animation cell.
*/
class Cell
{
public:
    Cell(int32_t insertX, int32_t insertY, bool IsFlipped, const std::shared_ptr<Bitmap>& bitmap) :
        m_insertX(insertX),
        m_insertY(insertY),
        m_bitmap(bitmap)
    { }
    
    int32_t GetInsertX() const { return m_insertX; }
    int32_t GetInsertY() const { return m_insertY; }
    
    /**
        Is the cell flipped?
    */
    bool IsFlipped() const { return m_isFlipped; }

    /**
        Size of the a bitmap.
    */
    size_t GetDataSize() const
    {
        if (HasBitmap())
            return GetBitmap()->GetDataSize();
        else
            return 0;
    }
    
    /**
        Get the width of the image.
    */
    unsigned GetWidth() const
    {
        if (HasBitmap())
            return GetBitmap()->GetWidth();
        else
            return 0;
    }
    
    /**
        Get the height of the image.
    */
    unsigned GetHeight() const
    {
        if (HasBitmap())
            return GetBitmap()->GetHeight();
        else
            return 0;
    }
    
    /**
        Get the type of transparency of the image.
     
        @param index Sub bitmap to get transparency of.
    */
    BmFileTransparency GetTransparency() const
    {
        if (HasBitmap())
            return GetBitmap()->GetTransparency();
        else
            return BmFileTransparency::Normal;
    }
    
    /**
        Does the cell have a valid bitmap?
    */
    bool HasBitmap() const
    {
        return (m_bitmap != nullptr);
    }
    
    /**
        Get a the bitmapsthat stores the cell's data.
    */
    std::shared_ptr<Bitmap> GetBitmap() const { return m_bitmap; }

private:
    std::shared_ptr<Bitmap> m_bitmap;
    int32_t m_insertX;
    int32_t m_insertY;
    bool m_isFlipped;
};

} // DF

