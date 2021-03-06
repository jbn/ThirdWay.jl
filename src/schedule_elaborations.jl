export RepeatingAction, stop!, schedule_repeating!
export SequenceOfActions, ShuffledActions, TentativeAction, NoAction

type RepeatingAction
    interval::Float64
    order::Int64
    actionable
    
    function RepeatingAction(interval, order, actionable)
        if interval <= 0 
            throw(ArgumentError("Interval must be a positive number."))
        end
        
        new(interval, order, actionable)
    end
end

RepeatingAction(action::Function, interval, order) = RepeatingAction(
    interval, order, action
)

stop!(repeating::RepeatingAction) = repeating.interval = -1

function Base.call(repeating::RepeatingAction, env, schedule::Schedule)
    if repeating.interval > 0
        repeating.actionable(env, schedule)
        
        schedule_once_in!(
            schedule, repeating, repeating.interval, repeating.order
        )
    end
end

function schedule_repeating!(schedule::Schedule, action, 
                             starting_at=1.0, interval=1.0, order=1)
    repeating = RepeatingAction(interval, order, action)
    schedule_once!(
        schedule, 
        repeating,
        starting_at,
        order
    )
    repeating
end

function schedule_repeating!(action::Function, schedule::Schedule, 
                             starting_at=1.0, interval=1.0, order=1)
    schedule_repeating!(schedule, action, starting_at, interval, order)
end

type SequenceOfActions
    actions
    
    function SequenceOfActions(actions::AbstractVector)
        new(Vector(actions))
    end
end

function Base.call(seq::SequenceOfActions, env, schedule::Schedule)
    for action in seq.actions
        action(env, schedule)
    end
end

type ShuffledActions
    actions
    
    function ShuffledActions(actions::AbstractVector)
        new(Vector(actions))
    end
end

function Base.call(seq::ShuffledActions, env, schedule::Schedule)
    shuffle!(seq.actions)
    for action in seq.actions
        action(env, schedule)
    end
end

immutable NoAction
end

function Base.call(::NoAction, env, schedule::Schedule)
end

type TentativeAction
    actionable
end

function Base.call(tentative::TentativeAction, env, schedule::Schedule)
    tentative.actionable(env, schedule)
end

stop!(tentative::TentativeAction) = tentative.actionable = NoAction()

