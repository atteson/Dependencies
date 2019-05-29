module Dependencies

using Printf
using Serialization

const defaultdir = joinpath( dirname(dirname(pathof(Dependencies))), "data" )

struct FunctionNode{F1 <: Function} <: Function
    f::F1
end

FunctionNode( f::F1 ) where {F1, F2} = FunctionNode( f )

filename( f::FunctionNode{F1}, args...; kwargs... ) where {F1} =
    joinpath( defaultdir, @sprintf( "%0x", hash( (f, args..., kwargs...) ) ) )

function (f::FunctionNode{F1})( args...; kwargs... ) where {F1}
    file = filename( f, args...; kwargs... )
    if isfile( file )
        io = open( file, "r" )
        object = deserialize( io )
        close( io )
    else
        object = f.f( args...; kwargs... )

        io = open( file, "w" )
        serialize( io, object )
        close( io )
    end
    return object
end

function Base.delete!( f::FunctionNode, args...; kwargs... )
    file = filename( f, args...; kwargs... )
    if isfile( file )
        rm( file )
    end
end

getinstance( ::Type{FunctionNode{F1}} ) where {F1} = FunctionNode( F1.instance )

end # module
