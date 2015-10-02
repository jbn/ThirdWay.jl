import Base: +, isless

immutable ActivationPoint
    time::Float64
    order::UInt16
    jitter::Int64
end

ActivationPoint(time::Float64, order) = ActivationPoint(
    time, order, rand(Int64)
)

ActivationPoint(ap::ActivationPoint) = ActivationPoint(
    ap.time, ap.order, rand(Int64)
)

function (+)(ap::ActivationPoint, time_inc)
    ActivationPoint(ap.time + time_inc, ap.order, ap.jitter)
end

function isless(a::ActivationPoint, b::ActivationPoint)
    if a.time == b.time
        if a.order == b.order
            a.jitter < b.jitter
        else
            a.order < b.order
        end
    else
        a.time < b.time
    end
end

