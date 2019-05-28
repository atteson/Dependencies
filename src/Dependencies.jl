module Dependencies

recursivewrite( io::IO, x::Float64 ) = write( io, x )

function recursivewrite( io::IO, v::Array{T,N} ) where {T,N}
    sizes = size( v )
    for i in 1:N
        write( io, sizes[i] )
    end
    for i = 1:prod(sizes)
        recursivewrite( io, v[i] )
    end
end

recursiveread( io::IO, t::Type{Float64} ) = read( io, t )

function recursiveread( io::IO, ::Type{Array{T,N}} ) where {T,N}
    sizes = Int[]
    for i in 1:N
        push!( sizes, Base.read( io, Int ) )
    end
    v = T[]
    for i = 1:prod(sizes)
        push!( v, recursiveread( io, T ) )
    end
    return v
end

end # module
