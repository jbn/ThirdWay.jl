`ActivationPoint`

An event occurs at an `ActivationPoint`. I define the ordering on this type similarly to MASON. If different events occur at the same `time`,
lower `order`'s give higher priorities. But, if events share the same `time` *and* the same `order`, then `jitter` orders them. This provides the shuffling operation. 
It may be faster to collect and shuffle, as MASON does. In particular, there may be a lot of cache misses for the random number generator's state. But, it requires no memory allocation for intermediary collections. And, it allows for replays over a simulation with *the same ordering*. If that is not desired, call reshuffle!(schedule).