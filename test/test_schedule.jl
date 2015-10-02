import ThirdWay.ActivationPoint

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
