#pragma once

#include <gober/Buffer.h>
#include <gober/Tdo.h>

namespace DF
{

class TdoFile
{
public:
    Tdo CreateTdo() const;
    
private:
    Buffer m_data;
};

} // DF