#pragma once

#include <gober/Buffer.h>
#include <gober/Tdo.h>

namespace DF
{

class TdoFile
{
public:
    TdoFile(Buffer&& data) :
        m_data(std::move(data))
    { }
    
    Tdo CreateTdo() const;
    
    
private:
    Buffer m_data;
};

} // DF