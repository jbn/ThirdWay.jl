export unbiased_indmax, unbiased_indmin

#=
Agents often select an action that has the best experiential performance. 
For example, they pick the action with the minimal expected cost or the 
maximum expected reward. And, often, a vector stores the expectations. 
This representation makes it tempting to use `Base.indmax`. However, 
that function introduces a computational artifact. Given a tie, it 
selects the highest index. `unbiased_indmax` and `unbiased_indmin` 
operate without this bias. Given a tie, the both collect equal indices. 
Then, a random selection over those indices gets returned. For now, 
this requires two passes over the collection. Future reimplementations 
could do away with such a limitation, but it's good for what I need 
right now.
=#

function unbiased_indmax(xs)
    isempty(xs) && throw(ArgumentError("collection must be non-empty"))
    
    i = start(xs)
    max_i = i
    max_x, i = next(xs, i)
    tie_flag = false
    while !done(xs, i)
        last_i = i
        x, i = next(xs, i)
        
        if x > max_x
            max_x = x
            max_i = last_i
            tie_flag = false
        elseif x == max_x
            tie_flag = true
        end
    end
    
    if tie_flag
        return rand(collect(filter(x -> x[2] == max_x, enumerate(xs))))[1]
    else
        max_i
    end
end

function unbiased_indmin(xs)
    isempty(xs) && throw(ArgumentError("collection must be non-empty"))
    
    i = start(xs)
    min_i = i
    min_x, i = next(xs, i)
    tie_flag = false
    while !done(xs, i)
        last_i = i
        x, i = next(xs, i)
        
        if x < min_x
            min_x = x
            min_i = last_i
            tie_flag = false
        elseif x == min_x
            tie_flag = true
        end
    end
    
    if tie_flag
        rand(collect(filter(x -> x[2] == min_x, enumerate(xs))))[1]
    else
        min_i
    end
end

