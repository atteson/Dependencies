module Dependencies

abstract type AbstractArrayNode{T,N} end

mutable struct ArrayNode{T,N} <: AbstractArrayNode{T,N}
    f!::Function
    parameters::Vector{AbstractArrayNode}
    size::NTuple{N,Int}
    
    parameterof::Vector{ArrayNode}
    value::Union{Array{T,N},Missing}
    dirty::Bool
end

function ArrayNode( T, size::NTuple{N,Int}, f::Function, parameters::AbstractArrayNode... ) where {N}
    node = ArrayNode{T,N}( f, AbstractArrayNode[parameters...], size, ArrayNode[], missing, true )
    for parameter in parameters
        setparameterof!( node, parameter )
    end
    return node
end

function setparameterof!( node::ArrayNode, parameter::AbstractArrayNode )
    push!( parameter.parameterof( node ) )
end

function (node::ArrayNode{T})() where {T}
    if node.value == missing
        node.value = zeros( T, node.size )
        parametervalues = get.( node.parameters )
        value = node.f!( node.value, parametervalues... )
    end
    return node.value
end

function invalidate!( node::ArrayNode )
    node.dirty = true
    invalidate!.( node.parameterof )
end

mutable struct ArrayTerminal{T,N} <: AbstractArrayNode{T,N}
    parameterof::Vector{ArrayNode}
    value::Union{Array{T,N},Missing}
end

Terminal( value::Array{T,N} ) where {T,N} = Terminal( AbstractArrayNode{T,N}[], value::Array{T,N} )

(t::ArrayTerminal)() = t.value

function (t::ArrayTerminal{T,N})( value::Array{T,N} ) where {T,N}
    t.value = value
    for parameterof in t.parametersof
        invalidate!( parameterof )
    end
end

end # module
