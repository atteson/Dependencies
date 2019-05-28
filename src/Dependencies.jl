module Dependencies

using Base64
using Serialization

const defaultdir = joinpath( dirname(dirname(pathof(Dependencies))), "data" )

struct FunctionNode{F1 <: Function, F2 <: Function}
    f::F1
    hash::F2
    dir::String
end

FunctionNode( f::F1; hash::F2 = hash, dir::String = defaultdir ) where {F1, F2} =
    FunctionNode( f, hash, dir )

function (f::FunctionNode{F1,F2})( args... ) where {F1, F2}
    mkpath( f.dir )
    filename = joinpath( f.dir, base64encode( f.hash( (f, args...) ) ) )
    if isfile( filename )
        io = open( filename, "r" )
        object = deserialize( io )
        close( io )
    else
        object = f.f( args... )

        io = open( filename, "w" )
        serialize( io, object )
        close( io )
    end
    return object
end
    

end # module
