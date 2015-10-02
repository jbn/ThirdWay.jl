immutable Event 
    activate_at::ActivationPoint
    action::Callable  # Will this make things too slow?
end

isless(a::Event, b::Event) = a.activate_at < b.activate_at
