#pragma once

#include <gober/Cell.h>
#include <gober/WaxFile.h>

#include <array>
#include <map>
#include <vector>

namespace DF
{


class WaxActionSequence
{
    using action_frames = std::vector<Cell>;
public:
    static WaxActionSequence CreateFromFile(const WaxFileSequence& seq)
    {
        return {};
    }
private:
    action_frames m_frames;
};

/**
    Collection of views from different angles of a single animation.
*/
class WaxAction
{
    using action_views = std::array<WaxActionSequence, 32>;
    
public:
    static WaxAction CreateFromFile(const WaxFileAction& action)
    {
        action_views views;
        for (size_t i = 0; i < action.GetSequencesCount(); ++i)
            views[i] = WaxActionSequence::CreateFromFile(action.GetSequence(i));
        
        return WaxAction(std::move(views));
    }
    
    WaxAction() { }
    
private:
    action_views m_views;
    
    WaxAction(action_views&& views) :
        m_views(std::move(views))
    { }
};

/**
    Collection of animations for a sprite.
*/
class Wax
{
    using action_map = std::map<size_t, WaxAction>;
    
public:
    static Wax CreateFromFile(const WaxFile& wax)
    {
        action_map actions;
        for (size_t i : wax.GetActions())
            actions[i] = WaxAction::CreateFromFile(wax.GetAction(i));
        
        return Wax(std::move(actions));
    }
    
    std::vector<size_t> GetActions() const
    {
        std::vector<size_t> indicies;
        std::transform(
            std::begin(m_actions),
            std::end(m_actions),
            std::back_inserter(indicies),
            [](const auto& pair) { return pair.first; });
        return indicies;
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