#import "Gol.h"

#include <gob/Gol.h>


@interface Gol()

+ (NSString*) getGoalDescription:(Df::Goal)goal;

@end

@implementation Gol

+ (Gol*) createForGol:(Df::Gol)gol
{
    Gol* t = [[Gol alloc] init];
    t->_gol = gol;
    return t;
}

+ (NSString*) getGoalDescription:(Df::Goal)goal
{
    switch (goal.type)
    {
    case Df::GoalType::Trigger:
        return [NSString stringWithFormat:@"Trigger:%d", goal.value];
    case Df::GoalType::Item:
        return [NSString stringWithFormat:@"Item:%d", goal.value];
    default:
        return @"Unknown";
    }
}

- (NSUInteger) count
{
    return _gol.NumberOfGoals();
}


- (NSString*) getGoalAt:(NSUInteger)index
{
    Df::Goal goal = _gol.GetGoal(index);
    NSString* description = [[self class] getGoalDescription:goal];
    return [NSString stringWithFormat:@"%lu %@", index, description];
}

@end
