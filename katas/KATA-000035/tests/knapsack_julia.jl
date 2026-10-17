# SPDX-License-Identifier: MIT
# Independently computed meet-in-the-middle optimum (not Fortran's DP).
using Test, Random
function halves(items, capacity)
    choices = Tuple{Int,Int}[]
    for mask in 0:((1 << length(items))-1)
        weight=0; value=0
        for (i,(w,v)) in enumerate(items)
            if mask & (1 << (i-1)) != 0
                weight += w
                value += v
            end
        end
        weight <= capacity && push!(choices,(weight,value))
    end
    choices
end
function meet_middle(items,capacity)
    pivot=length(items) ÷ 2
    lhs=halves(items[1:pivot],capacity)
    rhs=sort(halves(items[(pivot+1):end],capacity),by=first)
    weights=first.(rhs)
    prefix=Int[]
    best=0
    for (_,v) in rhs
        best=max(best,v); push!(prefix,best)
    end
    optimum=0
    for (w,v) in lhs
        j=searchsortedlast(weights,capacity-w)
        if j>0
            optimum=max(optimum,v+prefix[j])
        end
    end
    optimum
end
function score_fortran(binary, cases)
    lines=[string(length(cases))]
    for (cap, items) in cases
        push!(lines,"$(cap) $(length(items))")
        append!(lines,["$(w) $(v)" for (w,v) in items])
    end
    output=split(strip(read(pipeline(Cmd([binary]),stdin=IOBuffer(join(lines,"\n")*"\n")),String)),'\n')
    parse.(Int,output)
end
function main(binary)
    rng=MersenneTwister(20261017)
    cases=[(10,[(5,10),(4,40),(6,30),(4,50)]),(0,[(0,3),(0,4)])]
    for _ in 1:500
        items=[(rand(rng,0:25),rand(rng,0:2000)) for _ in 1:rand(rng,0:17)]
        push!(cases,(rand(rng,0:80),items))
    end
    got=score_fortran(binary,cases)
    @testset "Julia meet-in-the-middle vs Fortran dynamic programming" begin
        @test length(got)==length(cases)
        for (i,(cap,items)) in enumerate(cases)
            @test got[i]==meet_middle(items,cap)
        end
        @test meet_middle([(0,3),(0,4)],0)==7
    end
    println("PASS: Julia meet-in-the-middle validated $(length(cases)) Fortran knapsack scenarios")
end
length(ARGS)==1 || error("Usage: julia knapsack_julia.jl /path/to/fortran-cli")
main(ARGS[1])
