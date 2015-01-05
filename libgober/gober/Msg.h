#pragma once

#include <map>

namespace DF
{

/**
*/
class Msg
{
    struct Message
    {
        size_t priority;
        std::string message;
    };
    
    using message_map = std::map<size_t, Message>;

public:
    Msg() { }
    
    /**
    */
    void AddMessage(size_t index, size_t priority, const std::string& message)
    {
        m_messages[index] = { priority, message };
    }

private:
    message_map m_messages;
};

} // DF