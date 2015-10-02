module ThirdWay

import Base: +, isempty, isless, length, merge!, push!, show
import Base: Callable, call

include("activation_point.jl")
include("event.jl")
include("schedule.jl")

end
