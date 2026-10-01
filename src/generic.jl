# Generic heap functions
# Extracted from DataStructures.jl — Copyright (c) 2013 Dahua Lin, MIT License.

"""
    extract_all!(h)

Return an array of heap elements in sorted order (heap head at first index).
"""
function extract_all!(h::AbstractHeap{VT}) where {VT}
    n = length(h)
    r = Vector{VT}(undef, n)
    for i in 1:n
        r[i] = pop!(h)
    end
    return r
end

"""
    extract_all_rev!(h)

Return an array of heap elements in reverse sorted order (heap head at last index).
"""
function extract_all_rev!(h::AbstractHeap{VT}) where {VT}
    n = length(h)
    r = Vector{VT}(undef, n)
    for i in 1:n
        r[n + 1 - i] = pop!(h)
    end
    return r
end

"""
    nextreme(ord, n, arr)

Return an array of the first `n` values of `arr` sorted by `ord`.
"""
function nextreme(ord::Base.Order.Ordering, n::Int, arr::AbstractVector{T}) where {T}
    Base.require_one_based_indexing(arr)
    len = length(arr)
    n = clamp(n, 0, len)
    buffer = arr[1:n]

    if n ∉ (1:(len - 1))
        if n > 0
            buffer = sort!(buffer; order = ord)
        end
        return buffer
    end

    rev = Base.Order.ReverseOrdering(ord)
    buffer = heapify!(buffer, rev)

    @inbounds for i in (n + 1):length(arr)
        xi = arr[i]
        if Base.Order.lt(rev, buffer[1], xi)
            buffer[1] = xi
            percolate_down!(buffer, 1, rev)
        end
    end

    return sort!(buffer; order = ord)
end

"""
    nlargest(n, arr; kw...)

Return the `n` largest elements of the array `arr`.
"""
function nlargest(n::Int, arr::AbstractVector; lt = isless, by = identity)
    order = Base.Order.ReverseOrdering(Base.Order.ord(lt, by, nothing))
    return nextreme(order, n, arr)
end

"""
    nsmallest(n, arr; kw...)

Return the `n` smallest elements of the array `arr`.
"""
function nsmallest(n::Int, arr::AbstractVector; lt = isless, by = identity)
    order = Base.Order.ord(lt, by, nothing)
    return nextreme(order, n, arr)
end
