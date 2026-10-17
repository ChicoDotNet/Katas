# SPDX-License-Identifier: MIT
# Julia's frame-structured contract tests complement the Python oracle and C checks.
using Test, Random
function complete_game(rng)
    frames = Vector{Vector{Int}}()
    rolls = Int[]
    for frame in 1:10
        first = rand(rng, 0:10)
        if frame < 10
            balls = first == 10 ? [10] : [first, rand(rng, 0:(10-first))]
        elseif first == 10
            second = rand(rng, 0:10)
            balls = [10, second, rand(rng, 0:(second == 10 ? 10 : 10-second))]
        else
            second = rand(rng, 0:(10-first))
            balls = first + second == 10 ? [first, second, rand(rng, 0:10)] : [first, second]
        end
        push!(frames,balls)
        append!(rolls,balls)
    end
    return frames, rolls
end
function valid_frames(frames)
    length(frames) == 10 || return false
    for (i,balls) in enumerate(frames)
        all(x -> 0 <= x <= 10,balls) || return false
        if i < 10
            length(balls) == (balls[1] == 10 ? 1 : 2) || return false
            sum(balls) <= 10 || return false
        else
            first = balls[1]
            if first == 10
                length(balls) == 3 || return false
                balls[2] != 10 && balls[2] + balls[3] > 10 && return false
            else
                length(balls) == (sum(balls[1:2]) == 10 ? 3 : 2) || return false
                sum(balls[1:2]) <= 10 || return false
            end
        end
    end
    true
end
# Score a semantic sequence of frames rather than the C roll-index algorithm.
function frame_score(frames)
    @assert valid_frames(frames)
    result = 0
    for frame in 1:10
        balls = frames[frame]
        if frame == 10
            result += sum(balls)
        else
            future = reduce(vcat, frames[(frame+1):end])
            if balls[1] == 10
                result += 10 + future[1] + future[2]
            elseif sum(balls) == 10
                result += 10 + future[1]
            else
                result += sum(balls)
            end
        end
    end
    result
end
function score_from_c(binary, rolls)
    payload = join(rolls,",") * "\n"
    parse(Int,strip(read(pipeline(Cmd([binary]), stdin=IOBuffer(payload)), String)))
end
function main(binary)
    rng=MersenneTwister(20261017)
    @testset "Bowling / Julia frame contracts, versus original C" begin
        for (rolls, expected) in [(fill(0,20),0),(fill(10,12),300),(repeat([9,0],10),90)]
            @test score_from_c(binary,rolls) == expected
        end
        for _ in 1:600
            frames,rolls=complete_game(rng)
            @test valid_frames(frames)
            @test 0 <= frame_score(frames) <= 300
            @test score_from_c(binary,rolls) == frame_score(frames)
            @test frame_score([copy(f) for f in frames]) == frame_score(frames)
        end
    end
    println("PASS: Julia independently checked 600 complete bowling games and three boundary games")
end
length(ARGS)==1 || error("Usage: julia bowling_julia.jl /path/to/bowling-c")
main(ARGS[1])
