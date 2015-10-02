import ThirdWay: ActivationPoint, Event
import Base.Collections.heappop!

facts("ActivationPoint") do
    context("jitter is randomized") do
        jitters = Set([ActivationPoint(0.0, 1).jitter for _ in 1:10])

        @fact length(jitters) > 1 --> true
    end

    context("(+) increments the time") do 
        ap = ActivationPoint(0.0, 1)
        @fact (ap + 1.0).time == ap.time + 1.0 --> true
    end

    context("ordering") do 
        @fact ActivationPoint(0.0, 0) < ActivationPoint(1.0, 0) --> true
        @fact ActivationPoint(0.0, 2) > ActivationPoint(0.0, 1) --> true
        @fact ActivationPoint(5.0, 5) > ActivationPoint(3.0, 1) --> true

        @fact ActivationPoint(1.0, 1, 5) < ActivationPoint(1.0, 1, 10) --> true
    end

    context("rejittering") do 
        ap = ActivationPoint(10.0, 10)
        
        rejitters = Set([ActivationPoint(ap).jitter for _ in 1:10])

        @fact length(rejitters) > 1 --> true
    end
end

facts("Event") do
    context("uses ActivationPoint as an ordering") do
        a = Event(ActivationPoint(5.0, 5), println)
        b = Event(ActivationPoint(3.0, 3), println)

        @fact a > b --> true
    end
end

noop(env) = env

type MockCallable
    x::Int
end

Base.call(mc::MockCallable, env, sched::Schedule) = mc.x


type HelloAgent
    name::String
end

Base.call(agent::HelloAgent, env, sched) = push!(env, agent.name)

facts("Schedule") do
    context("push! onto heap ordered queue") do 
        schedule = Schedule()

        times = [1.0, 5.0, 100.0, 33.0]
        orderings = [5, 3, 1, 2]

        all_pairs = Vector{Tuple{Float64, Int64}}()
        for t in times, o in orderings
            push!(schedule, ActivationPoint(t, o)) do env, _
                push!(env, (t, o))
            end
            push!(all_pairs, (t, o))
        end
        
        env = Vector{Tuple{Float64, Int64}}()
        while !isempty(schedule)
            heappop!(schedule.queue).action(env, schedule)
        end

        @fact env --> sort(all_pairs)
    end

    context("push! works on any callable") do 
        schedule = Schedule()
        mc = MockCallable(10)
        @fact push!(schedule, mc, ActivationPoint(1.0, 0)) --> true

        @fact heappop!(schedule.queue).action("env", schedule) --> 10
    end

    context("will not schedule an item after ThirdWay.AFTER_SIMULATION") do 
        schedule = Schedule()
        @fact push!(schedule, () -> true, ActivationPoint(1000.0, 0)) --> true

        ap = ActivationPoint(ThirdWay.AFTER_SIMULATION + 1, 0)
        @fact push!(schedule, () -> true, ap) --> false
    end

    context("will not accept an event prior to EPOCH") do 
        schedule = Schedule()
        ap = ActivationPoint(ThirdWay.EPOCH - eps(ThirdWay.EPOCH), 0)
        @fact_throws ArgumentError push!(schedule, () -> true, ap)
    end

    context("will not accept an event with NaN as the time") do 
        schedule = Schedule()
        @fact_throws ArgumentError push!(schedule, ActivationPoint(NaN, 0)) do
            # pass
        end
    end

    context("will not accept an event in the past") do 
        schedule = Schedule()
        @fact push!(schedule, () -> true, ActivationPoint(5.0, 0)) --> true

        schedule.time = 10.0
        @fact_throws ArgumentError push!(schedule, ActivationPoint(5.0, 0)) do
            # pass
        end
    end

    context("can be clear!()ed") do
        schedule = Schedule()
        for i in 1:10
            push!(schedule, ActivationPoint(0.0, 0)) do env end
        end

        @fact length(schedule) --> 10
        @fact clear!(schedule) --> 10
        @fact length(schedule) --> 0
    end

    context("can be reset!()") do
        schedule = Schedule()
        schedule.time = 100.0
        schedule.steps = 100
        for i in 1:10
            push!(schedule, ActivationPoint(100.0, 0)) do env end
        end
        @fact length(schedule) --> 10

        reset!(schedule)

        @fact length(schedule) --> 0
        @fact schedule.time --> ThirdWay.BEFORE_SIMULATION
        @fact schedule.steps --> 0
    end

    context("can be copied") do 
        schedule = Schedule()

        for name in ["Alice", "Bob", "Carol", "David"]
            push!(schedule, HelloAgent(name), ActivationPoint(0.0, 1))
        end

        cloned_sched = deepcopy(schedule)

        env_a = Vector{AbstractString}()
        run!(schedule, env_a)

        env_b = Vector{AbstractString}()
        run!(cloned_sched, env_b)

        @fact env_a --> env_b
    end

    context("can be reshuffle()ed") do 
        schedule = Schedule()
        names = [randstring(5) for _ in 1:100]

        for name in names
            push!(schedule, HelloAgent(name), ActivationPoint(0.0, 1))
        end
        cloned_b = deepcopy(schedule)
        cloned_c = deepcopy(schedule)

        env_a = Vector{AbstractString}()
        run!(schedule, env_a)

        env_b = Vector{AbstractString}()
        run!(cloned_b, env_b)
        @fact env_a == env_b --> true

        env_c = Vector{AbstractString}()
        reshuffle!(cloned_c)
        run!(cloned_c, env_c)

        @fact env_a != env_c --> true
    end
end
