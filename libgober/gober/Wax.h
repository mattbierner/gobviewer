#pragma once

#include <gober/Cell.h>
#include <gober/WaxFile.h>

#include <map>
#include <vector>

namespace DF
{


class WaxActionSequence
{
public:

private:
    std::vector<Cell> m_frames;
};

/**
*/
class WaxAction
{
    using action_views = std::array<WaxActionSequence, 32>;
    
public:
    static WaxAction CreateFromFile(const WaxFileAction& action)
    {
        action_map actions;
        for (size_t index : wax.GetActions())
            actions[index] = WaxAction::CreateFromFile(wax.GetAction(index));
        
        return Wax(std::move(actions));
    }
    
private:
    action_views m_views;
};

/**
*/
class Wax
{
    using action_map = std::map<size_t, WaxAction>;
    
public:
    static Wax CreateFromFile(const WaxFile& wax)
    {
        action_map actions;
        for (size_t index : wax.GetActions())
            actions[index] = WaxAction::CreateFromFile(wax.GetAction(index));
        
        return Wax(std::move(actions));
    }
    
    /**
        Does a given action exist?
    */
    bool HasAction(size_t index) const
    {
        return (m_actions.find(index) != std::end(m_actions));
    }
    
    /**
        Get the action associated with a given id.
    */
    WaxAction GetAction(size_t index) const { return m_actions.at(index); }
    
private:
    action_map m_actions;
    
    Wax(action_map&& actions) :
        m_actions(std::move(actions))
    { }
};

} // DF