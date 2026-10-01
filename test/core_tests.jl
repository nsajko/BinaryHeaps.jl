# Tests extracted from DataStructures.jl
# Copyright (c) 2013 Dahua Lin, MIT License.

using BinaryHeaps
using Test

@testset "BinaryHeaps.jl" begin
    @testset "BinaryHeaps" begin
        @testset "make heap" begin
            vs = [4, 1, 3, 2, 16, 9, 10, 14, 8, 7]
            vs2 = collect(enumerate(vs))
            ordering = Base.Order.By(last)

            @testset "construct heap" begin
                BinaryHeap{Int, Base.ForwardOrdering}()
                BinaryHeap{Int, Base.ForwardOrdering}(vs)

                BinaryHeap{Int, Base.ReverseOrdering}()
                BinaryHeap{Int, Base.ReverseOrdering}(vs)

                BinaryMinHeap{Int}()
                BinaryMinHeap{Int}(vs)
                BinaryMinHeap(vs)

                BinaryMaxHeap{Int}()
                BinaryMaxHeap{Int}(vs)
                BinaryMaxHeap(vs)

                BinaryHeap{eltype(vs2)}(ordering)
                BinaryHeap{eltype(vs2)}(ordering, vs2)
                BinaryHeap(ordering, vs2)

                @test true
            end

            @testset "Type Aliases" begin
                @test BinaryMaxHeap{Int}() isa BinaryMaxHeap{Int}
                @test BinaryMinHeap{Int}() isa BinaryMinHeap{Int}
            end

            @testset "implicit conversion" begin
                @test BinaryHeap{Float64, Base.ForwardOrdering}(vs) isa
                    BinaryHeap{Float64, Base.ForwardOrdering}
                @test BinaryMinHeap{Float64}(vs) isa BinaryMinHeap{Float64}
                @test BinaryMaxHeap{Float64}(vs) isa BinaryMaxHeap{Float64}
                @test BinaryHeap{Tuple{Int, Float64}}(ordering, vs2) isa
                    BinaryHeap{Tuple{Int, Float64}}
            end

            @testset "confirm heap" begin
                @test isheap([1, 2, 3, 4, 7, 9, 10, 14, 8, 16])
                @test isheap([16, 14, 10, 8, 7, 3, 9, 1, 4, 2], Base.Reverse)

                @test !isheap([16, 14, 10, 8, 7, 3, 9, 1, 4, 2])
                @test !isheap([1, 2, 3, 4, 7, 9, 10, 14, 8, 16], Base.Reverse)
                @test !isheap([15, 2, 3, 4, 7, 9, 10, 14, 8, 16])
                @test !isheap([15, 2, 3, 4, 7, 9, 10, 14, 8, 16], Base.Reverse)
            end

            @testset "make min heap" begin
                h = BinaryMinHeap(vs)

                @test length(h) == 10
                @test !isempty(h)
                @test first(h) == 1
                @test isheap([1, 2, 3, 4, 7, 9, 10, 14, 8, 16])
                @test sizehint!(h, 100) === h
            end

            @testset "make max heap" begin
                h = BinaryMaxHeap(vs)

                @test length(h) == 10
                @test !isempty(h)
                @test first(h) == 16
                @test isheap([16, 14, 10, 8, 7, 3, 9, 1, 4, 2], Base.Reverse)
                @test sizehint!(h, 100) === h
            end

            @testset "make custom ordering heap" begin
                h = BinaryHeap(ordering, vs2)

                @test length(h) == 10
                @test !isempty(h)
                @test first(h) == (2, 1)
                @test isheap(
                    [
                        (2, 1), (4, 2), (3, 3), (1, 4), (10, 7), (6, 9), (7, 10),
                        (8, 14), (9, 8), (5, 16),
                    ],
                    ordering
                )
                @test sizehint!(h, 100) === h
            end

            @testset "extract all" begin
                @test sort(vs) == extract_all!(BinaryMinHeap(vs))
                @test reverse(sort(vs)) == extract_all_rev!(BinaryMinHeap(vs))
            end

            @testset "push!" begin
                @testset "push! hmin" begin
                    hmin = BinaryMinHeap{Int}()
                    @test length(hmin) == 0
                    @test isempty(hmin)

                    ss = Any[
                        [4],
                        [1, 4],
                        [1, 4, 3],
                        [1, 2, 3, 4],
                        [1, 2, 3, 4, 16],
                        [1, 2, 3, 4, 16, 9],
                        [1, 2, 3, 4, 16, 9, 10],
                        [1, 2, 3, 4, 16, 9, 10, 14],
                        [1, 2, 3, 4, 16, 9, 10, 14, 8],
                        [1, 2, 3, 4, 7, 9, 10, 14, 8, 16],
                    ]

                    for i in 1:length(vs)
                        push!(hmin, vs[i])
                        @test length(hmin) == i
                        @test !isempty(hmin)
                        @test isequal(hmin.valtree, ss[i])
                    end

                    @testset "pop! hmin" begin
                        @test isequal(
                            extract_all!(hmin),
                            [1, 2, 3, 4, 7, 8, 9, 10, 14, 16]
                        )
                        @test isempty(hmin)
                    end
                end

                @testset "push! hmax" begin
                    hmax = BinaryMaxHeap{Int}()
                    @test length(hmax) == 0
                    @test isempty(hmax)

                    ss = Any[
                        [4],
                        [4, 1],
                        [4, 1, 3],
                        [4, 2, 3, 1],
                        [16, 4, 3, 1, 2],
                        [16, 4, 9, 1, 2, 3],
                        [16, 4, 10, 1, 2, 3, 9],
                        [16, 14, 10, 4, 2, 3, 9, 1],
                        [16, 14, 10, 8, 2, 3, 9, 1, 4],
                        [16, 14, 10, 8, 7, 3, 9, 1, 4, 2],
                    ]

                    for i in 1:length(vs)
                        push!(hmax, vs[i])
                        @test length(hmax) == i
                        @test !isempty(hmax)
                        @test isequal(hmax.valtree, ss[i])
                    end

                    @testset "pop! hmax" begin
                        @test isequal(
                            extract_all!(hmax),
                            [16, 14, 10, 9, 8, 7, 4, 3, 2, 1]
                        )
                        @test isempty(hmax)
                    end
                end

                @testset "push! custom ordering" begin
                    heap = BinaryHeap{Tuple{Int, Int}}(ordering)
                    @test length(heap) == 0
                    @test isempty(heap)

                    ss = Any[
                        [(1, 4)],
                        [(2, 1), (1, 4)],
                        [(2, 1), (1, 4), (3, 3)],
                        [(2, 1), (4, 2), (3, 3), (1, 4)],
                        [(2, 1), (4, 2), (3, 3), (1, 4), (5, 16)],
                        [(2, 1), (4, 2), (3, 3), (1, 4), (5, 16), (6, 9)],
                        [(2, 1), (4, 2), (3, 3), (1, 4), (5, 16), (6, 9), (7, 10)],
                        [
                            (2, 1), (4, 2), (3, 3), (1, 4), (5, 16), (6, 9), (7, 10),
                            (8, 14),
                        ],
                        [
                            (2, 1), (4, 2), (3, 3), (1, 4), (5, 16), (6, 9), (7, 10),
                            (8, 14), (9, 8),
                        ],
                        [
                            (2, 1), (4, 2), (3, 3), (1, 4), (10, 7), (6, 9), (7, 10),
                            (8, 14), (9, 8), (5, 16),
                        ],
                    ]

                    for i in 1:length(vs2)
                        push!(heap, vs2[i])
                        @test length(heap) == i
                        @test !isempty(heap)
                        @test isequal(heap.valtree, ss[i])
                    end

                    @testset "pop! custom ordering" begin
                        @test isequal(
                            extract_all!(heap),
                            sort(vs2; order = ordering)
                        )
                        @test isempty(heap)
                    end
                end
            end
        end

        @testset "hybrid push! and pop!" begin
            h = BinaryMinHeap{Int}()

            @testset "push1" begin
                push!(h, 5)
                push!(h, 10)
                @test isequal(h.valtree, [5, 10])
            end

            @testset "pop1" begin
                @test pop!(h) == 5
                @test isequal(h.valtree, [10])
            end

            @testset "push2" begin
                push!(h, 7)
                push!(h, 2)
                @test isequal(h.valtree, [2, 10, 7])
            end

            @testset "pop2" begin
                @test pop!(h) == 2
                @test isequal(h.valtree, [7, 10])
            end
        end

        @testset "nlargest and nsmallest" begin
            ss = [
                100, 103, -12, -109, 67, 4, 65, -52, -97, -32, -24, 114, -128,
                102, -56, -17, -41, 25, -30, -84, 26, -84, 48, 49, -5, -38, 28,
                114, -54, 96, -55, 67, 74, 127, -61, 124, 11, -7, 93, -51, 110,
                -106, -84, -90, -18, -12, -116, 21, 115, 50,
            ]
            square = x -> x^2

            for n in -1:(length(ss) + 1)
                r = 1:min(n, length(ss))

                @test nlargest(n, ss) == sort(ss; rev = true)[r]
                @test nsmallest(n, ss) == sort(ss)[r]

                @test nlargest(n, ss; by = square) ==
                    sort(ss; by = square, rev = true)[r]
                @test nsmallest(n, ss; by = square) == sort(ss; by = square)[r]

                @test nlargest(n, ss) == nextreme(FasterReverse(), n, ss)
                @test nsmallest(n, ss) == nextreme(FasterForward(), n, ss)
            end
        end

        @testset "nlargest and nsmallest: type stability" begin
            arrs = let a = [9, 8], b = Memory{Float32}(undef, 2)
                b .= a
                Any[a, b, (@view a[1:2]), (@view b[1:2])]
            end
            for nex in (nlargest, nsmallest)
                for a in arrs
                    @test (@inferred nex(1, a)) isa AbstractVector{eltype(a)}
                end
            end
        end

        @testset "push! type conversion" begin # issue 399
            h = BinaryMinHeap{Float64}()
            push!(h, 3.0)
            push!(h, 5)
            push!(h, Rational(4, 8))
            push!(h, Complex(10.1, 0.0))

            @test isequal(h.valtree, [0.5, 5.0, 3.0, 10.1])
        end

        @testset "empty!" begin
            vs = [4, 1, 3, 2, 16, 9, 10, 14, 8, 7]
            vs2 = collect(enumerate(vs))
            ordering = Base.Order.By(last)

            for h in
                (BinaryMinHeap(vs), BinaryMaxHeap(vs), BinaryHeap(ordering, vs2))
                @test length(h) == length(vs)
                @test !isempty(h)
                ret = empty!(h)
                @test ret === h
                @test length(ret) == 0
                @test isempty(ret)
            end
        end
    end

    @testset "Low-level heap operations" begin
        @testset "heapify! and heappop!" begin
            xs = heapify!([v for v in 10:-1:1])
            @test issorted([heappop!(xs) for _ in 1:10])
        end

        @testset "heapify/issorted" begin
            xs = heapify(10:-1:1)
            @test issorted([heappop!(xs) for _ in 1:10])
        end

        @testset "heappush!" begin
            xs = Vector{Int}()
            for v in [4, 1, 3, 2, 16, 9, 10, 14, 8, 7]
                heappush!(xs, v)
            end
            @test issorted([heappop!(xs) for _ in 1:10])
        end

        @testset "isheap" begin
            @test isheap([1, 2, 3], Base.Order.Forward)
            @test !isheap([1, 2, 3], Base.Order.Reverse)
        end

        @testset "percolate_down!" begin
            @testset "Basic percolate down" begin
                xs = [10, 2, 3, 4, 5]
                BinaryHeaps.percolate_down!(xs, 1, 10, Base.Order.Forward)
                @test xs == [2, 4, 3, 10, 5]
            end

            @testset "Element in correct position" begin
                xs = [1, 2, 3, 4, 5]
                BinaryHeaps.percolate_down!(xs, 1, 1, Base.Order.Forward)
                @test xs == [1, 2, 3, 4, 5]
            end

            @testset "Reverse ordering" begin
                xs = [1, 5, 4, 3, 2]
                BinaryHeaps.percolate_down!(xs, 1, 1, Base.Order.Reverse)
                @test xs == [5, 3, 4, 1, 2]
            end

            @testset "Custom length" begin
                xs = [10, 2, 3, 4, 5]
                BinaryHeaps.percolate_down!(xs, 1, 10, Base.Order.Forward, 3)
                @test xs == [2, 10, 3, 4, 5]
            end

            @testset "Without explicit x parameter" begin
                xs = [10, 2, 3, 4, 5]
                BinaryHeaps.percolate_down!(xs, 1, Base.Order.Forward)
                @test xs == [2, 4, 3, 10, 5]

                xs = [10, 2, 3, 4, 5]
                BinaryHeaps.percolate_down!(xs, 1)
                @test xs == [2, 4, 3, 10, 5]
            end

            @testset "From middle position" begin
                xs = [2, 0, 3, 4, 5]
                BinaryHeaps.percolate_down!(xs, 2, 10, Base.Order.Forward)
                @test xs == [2, 4, 3, 10, 5]
            end
        end

        @testset "percolate_up!" begin
            @testset "Basic percolate up" begin
                xs = [1, 2, 3, 4, 0]
                BinaryHeaps.percolate_up!(xs, 5, 0, Base.Order.Forward)
                @test xs == [0, 1, 3, 4, 2]
            end

            @testset "Element in correct position" begin
                xs = [1, 2, 3, 4, 5]
                BinaryHeaps.percolate_up!(xs, 5, 5, Base.Order.Forward)
                @test xs == [1, 2, 3, 4, 5]
            end

            @testset "Reverse ordering" begin
                xs = [5, 4, 3, 2, 10]
                BinaryHeaps.percolate_up!(xs, 5, 10, Base.Order.Reverse)
                @test xs == [10, 5, 3, 2, 4]
            end

            @testset "Percolate to root" begin
                xs = [2, 3, 4, 5, 1]
                BinaryHeaps.percolate_up!(xs, 5, 1, Base.Order.Forward)
                @test xs == [1, 2, 4, 5, 3]
            end

            @testset "Without explicit x parameter" begin
                xs = [1, 2, 3, 4, 0]
                BinaryHeaps.percolate_up!(xs, 5, Base.Order.Forward)
                @test xs == [0, 1, 3, 4, 2]

                xs = [1, 2, 3, 4, 0]
                BinaryHeaps.percolate_up!(xs, 5)
                @test xs == [0, 1, 3, 4, 2]
            end

            @testset "From middle position" begin
                xs = [1, 5, 3, 10, 8]
                BinaryHeaps.percolate_up!(xs, 4, 0, Base.Order.Forward)
                @test xs == [0, 1, 3, 5, 8]
            end
        end
    end

    @testset "eltype" begin
        h = BinaryMinHeap{Float64}()
        @test eltype(h) == Float64
        @test eltype(typeof(h)) == Float64
    end
end
