facts("unbiased functions") do
    context("unbiased_indmax samples over ties") do
        @fact unbiased_indmax([1,2,3,4]) --> 4
        @fact unbiased_indmax([3,2,1]) --> 1
        @fact Set([unbiased_indmax([3,4,4,3]) for _ in 1:100]) --> Set([2, 3])
    end

    context("unbiased_indmax samples over ties") do
        @fact unbiased_indmin([1,2,3,4]) --> 1
        @fact unbiased_indmin([3,2,1]) --> 3
        @fact Set([unbiased_indmin([3,4,4,3]) for _ in 1:100]) --> Set([1, 4])
    end
end