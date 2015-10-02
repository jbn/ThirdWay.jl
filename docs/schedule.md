`ActivationPoint`
===

An event occurs at an `ActivationPoint`. I define the ordering on this type similarly to MASON. If different events occur at the same `time`,
lower `order`'s give higher priorities. But, if events share the same `time` *and* the same `order`, then `jitter` orders them. This provides the shuffling operation. 
It may be faster to collect and shuffle, as MASON does. In particular, there may be a lot of cache misses for the random number generator's state. But, it requires no memory allocation for intermediary collections. And, it allows for replays over a simulation with *the same ordering*. If that is not desired, call reshuffle!(schedule).


`Event`
===
The `Schedule` manages `Event`s. The event's `action` runs when the the schedule reaches the `activate_at` `ActivationPoint`. The `action` conforms to `call(T, env, scheduler::Schedule)`. Unlike MASON, the scheduler is not part of the environment. 

Anonymous Function Warning
---

Anonymous functions are useful in a lot of cases. However, they are dangerous when not idempotent. A `deepcopy` on a lambda may not do what you think it should do. Take care when using lambdas.


`Schedule`
===
My `Schedule` is a Julian semi-port of MASON's [`Schedule`](https://github.com/eclab/mason/blob/master/mason/sim/engine/Schedule.java). Semantically, that is an absurd statement. In simpler terms, the schedule executes agents at declared times in the simulation.
