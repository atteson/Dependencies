module Dependencies

using Base64
using Serialization

const defaultdir = joinpath( dirname(dirname(pathof(Dependencies))), "data" )

struct FunctionNode{F1 <: Function, F2 <: Function} <: Function
    f::F1
    hash::F2
    dir::String
end

FunctionNode( f::F1; hash::F2 = hash, dir::String = defaultdir ) where {F1, F2} =
    FunctionNode( f, hash, dir )

filename( f::FunctionNode{F1, F2}, args... ) where {F1, F2} =
    joinpath( f.dir, base64encode( f.hash( (f, args...) ) ) )

function (f::FunctionNode{F1, F2})( args... ) where {F1, F2}
    file = filename( f, args... )
    if isfile( file )
        io = open( file, "r" )
        object = deserialize( io )
        close( io )
    else
        object = f.f( args... )

        io = open( file, "w" )
        serialize( io, object )
        close( io )
    end
    return object
end

function Base.delete!( f::FunctionNode, args... )
    file = filename( f, args... )
    if isfile( file )
        rm( file )
    end
end

end # module
