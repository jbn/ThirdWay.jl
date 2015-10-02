export Schedule, step!, clear!, reset!, run!, reshuffle!

import Base.Collections: heappush!, heappop!

const EPOCH              = zero(Float64)
const BEFORE_SIMULATION  = EPOCH - 1.0
const AFTER_SIMULATION   = Inf64
const EPOCH_PLUS_EPSILON = eps(EPOCH)

# For values greater than 9.007199254740991E15, the epsilon is > 1.0.
assert(eps(9.007199254740991E15) <= 1.0 && eps(9.007199254740992E15) > 1.0)
const MAXIMUM_TIME = 9.007199254740992E15 

type Schedule
    time::Float64
    steps::Int64
    queue::Vector{Event}  # Heap-sorted
end

Schedule() = Schedule(BEFORE_SIMULATION, 0, Vector{Event}())


function push!(schedule::Schedule, actionable, at::ActivationPoint)
    # You cannot schedule an action to occur at precisely the current time. 
    # For example, imagine an activated action that reschedules itself for 
    # now. Time would never progress. The same action would repeat, ad 
    # infinitum. There must be some epsilon between now and activation.
    if schedule.time == at.time && schedule.time != AFTER_SIMULATION
        at = at + eps(at.time)
    end
    
    at.time >= AFTER_SIMULATION && return false
    
    at.time < EPOCH && throw(ArgumentError("Scheduled before epoch"))

    isnan(at.time) && throw(ArgumentError("Scheduled at NaN"))

    at.time < schedule.time && throw(ArgumentError("Scheduled in past"))
    
    heappush!(schedule.queue, Event(at, actionable))
    
    true
end

function push!(action::Function, schedule::Schedule, at::ActivationPoint)
    push!(schedule, action, at)
end

function step!(schedule::Schedule, state)
    (schedule.time == AFTER_SIMULATION || isempty(schedule)) && return false
    
    next_time = schedule.queue[1].activate_at.time
    schedule.time = next_time

    while next_time == schedule.time
        event = heappop!(schedule.queue)
        event.action(state, schedule)

        if isempty(schedule)
            break
        else
            next_time = schedule.queue[1].activate_at.time
        end
    end

    schedule.steps += 1

    return true
end

function reshuffle!(schedule::Schedule)
    schedule.queue = [
        Event(ActivationPoint(event.activate_at), event.action)  # new jitter
        for event in schedule.queue
    ]
end

function run!(schedule, env) 
    isempty(schedule) && throw(ArgumentError("Schedule already exhausted"))
    while step!(schedule, env)
    end
    schedule
end

length(schedule::Schedule) = length(schedule.queue)

function show(io::IO, s::Schedule)
    print(io, "Schedule at time=$(s.time) and steps=$(s.steps) ")
    print(io, "with $(length(s)) events.")
end

function clear!(schedule::Schedule)
    n = length(schedule)
    empty!(schedule.queue)
    n
end

function reset!(schedule::Schedule)
    schedule.time = BEFORE_SIMULATION
    schedule.steps = 0
    clear!(schedule)
end

isempty(schedule::Schedule) = isempty(schedule.queue)
is_complete(schedule::Schedule) = isempty(schedule)

function merge!(schedule::Schedule, other::Schedule)
    if other.queue[1].time < schedule.time
        error("Merge over items already in the past.")
    end
    
    for item in other.queue
        heappush!(schedule.queue, item)
    end

    schedule
end
