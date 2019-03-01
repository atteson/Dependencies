module Dependencies

export ArrayNode, ArrayTerminal

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
    push!( parameter.parameterof, node )
end

function (node::ArrayNode{T})() where {T}
    if node.dirty
        if ismissing( node.value )
            node.value = zeros( T, node.size )
        end

        parametervalues = [parameter() for parameter in node.parameters]
        node.value = node.f!( node.value, parametervalues... )
        node.dirty = false
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

ArrayTerminal( value::Array ) = ArrayTerminal( ArrayNode[], value )

(t::ArrayTerminal)() = t.value

function (t::ArrayTerminal{T,N})( value::Array{T,N} ) where {T,N}
    t.value = value
    invalidate!.( t.parameterof )
end

end # module
