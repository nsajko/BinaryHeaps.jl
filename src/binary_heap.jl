# Binary heap (non-mutable)
# Extracted from DataStructures.jl — Copyright (c) 2013 Dahua Lin, MIT License.

#################################################
#
#   Ordering types for faster float comparison
#
#################################################

"""
    FasterForward()

Enables 2x faster float comparison versus `Base.Order.ForwardOrdering`,
but ordering is undefined if the data contains NaN values.
"""
struct FasterForward <: Base.Order.Ordering end
Base.Order.lt(::FasterForward, a, b) = a < b

"""
    FasterReverse()

Enables 2x faster float comparison versus `Base.Order.ReverseOrdering`,
but ordering is undefined if the data contains NaN values.
"""
struct FasterReverse <: Base.Order.Ordering end
Base.Order.lt(::FasterReverse, a, b) = a > b

#################################################
#
#   heap type and constructors
#
#################################################

"""
    BinaryHeap{T, O <: Base.Order.Ordering} <: AbstractHeap{T}
    BinaryHeap{T}(ordering::Base.Order.Ordering)
    BinaryHeap{T}(ordering::Base.Order.Ordering, xs::AbstractVector)
    BinaryHeap(ordering::Base.Order.Ordering, xs::AbstractVector{T})

Binary heap storing values of type `T` according to ordering `O`.

# Type Parameters

- `T`: Element type stored by the heap.
- `O`: Ordering type used to compare heap elements.

# Fields

- `ordering`: Ordering used to compare heap elements.
- `valtree`: One-based array storing the heap tree.

# Examples

```julia
using BinaryHeaps

h = BinaryHeap{Int}(Base.Order.Forward)
push!(h, 3)
push!(h, 1)
pop!(h) # returns 1
```
"""
mutable struct BinaryHeap{T, O <: Base.Order.Ordering} <: AbstractHeap{T}
    const ordering::O
    const valtree::Vector{T}

    function BinaryHeap{T}(ordering::Base.Order.Ordering) where {T}
        return new{T, typeof(ordering)}(ordering, Vector{T}())
    end

    function BinaryHeap{T}(ordering::Base.Order.Ordering, xs::AbstractVector) where {T}
        valtree = heapify(xs, ordering)
        return new{T, typeof(ordering)}(ordering, valtree)
    end
end

function BinaryHeap(ordering::Base.Order.Ordering, xs::AbstractVector{T}) where {T}
    return BinaryHeap{T}(ordering, xs)
end

# Constructors using singleton order types as type parameters rather than arguments
BinaryHeap{T, O}() where {T, O <: Base.Order.Ordering} = BinaryHeap{T}(O())
function BinaryHeap{T, O}(xs::AbstractVector) where {T, O <: Base.Order.Ordering}
    return BinaryHeap{T}(O(), xs)
end

# These constructors needed for BinaryMaxHeap,
# until we have https://github.com/JuliaLang/julia/pull/37822
BinaryHeap{T, DefaultReverseOrdering}() where {T} = BinaryHeap{T}(Base.Order.Reverse)
function BinaryHeap{T, DefaultReverseOrdering}(xs::AbstractVector) where {T}
    return BinaryHeap{T}(Base.Order.Reverse, xs)
end

"""
    BinaryMinHeap{T}
    BinaryMinHeap{T}()
    BinaryMinHeap{T}(xs::AbstractVector)
    BinaryMinHeap(xs::AbstractVector{T})

Alias for [`BinaryHeap`](@ref) using `Base.Order.ForwardOrdering`, so the smallest
element is at the top of the heap.

# Type Parameters

- `T`: Element type stored by the heap.
"""
const BinaryMinHeap{T} = BinaryHeap{T, Base.Order.ForwardOrdering}

"""
    BinaryMaxHeap{T}
    BinaryMaxHeap{T}()
    BinaryMaxHeap{T}(xs::AbstractVector)
    BinaryMaxHeap(xs::AbstractVector{T})

Alias for [`BinaryHeap`](@ref) using reverse ordering, so the largest element is
at the top of the heap.

# Type Parameters

- `T`: Element type stored by the heap.
"""
const BinaryMaxHeap{T} = BinaryHeap{T, DefaultReverseOrdering}

BinaryMinHeap(xs::AbstractVector{T}) where {T} = BinaryMinHeap{T}(xs)
BinaryMaxHeap(xs::AbstractVector{T}) where {T} = BinaryMaxHeap{T}(xs)

#################################################
#
#   interfaces
#
#################################################

"""
    length(h::BinaryHeap)

Returns the number of elements in heap `h`.
"""
Base.length(h::BinaryHeap) = length(h.valtree)

"""
    isempty(h::BinaryHeap)

Returns whether the heap `h` is empty.
"""
Base.isempty(h::BinaryHeap) = isempty(h.valtree)

"""
    push!(h::BinaryHeap, value)

Adds the `value` element to the heap `h`.
"""
@inline function Base.push!(h::BinaryHeap, v)
    heappush!(h.valtree, v, h.ordering)
    return h
end

"""
    first(h::BinaryHeap)

Returns the element at the top of the heap `h`.
"""
@inline Base.first(h::BinaryHeap) = h.valtree[1]

"""
    pop!(h::BinaryHeap)

Removes and returns the element at the top of the heap `h`.
"""
Base.pop!(h::BinaryHeap) = heappop!(h.valtree, h.ordering)

function Base.empty!(h::BinaryHeap)
    empty!(h.valtree)
    return h
end

function Base.sizehint!(h::BinaryHeap, n::Integer)
    sizehint!(h.valtree, n)
    return h
end
