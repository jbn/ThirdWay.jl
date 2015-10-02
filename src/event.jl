
immutable Event 
    activate_at::ActivationPoint
    action  # A DataType that implements Base.call(T, env, sched)
end

isless(a::Event, b::Event) = a.activate_at < b.activate_at
