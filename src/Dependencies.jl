module Dependencies

using Serialization

const defaultdir = joinpath( dirname(dirname(pathof(Dependencies))), "data" )

struct FunctionNode{F1 <: Function, F2 <: Function}
    f::F1
    hash::F2
    dir::String
end

FunctionNode( f::F1; hash::F2 = hash, dir::String = defaultdir ) where {F1 <: Function, F2 <: Function} =
    FunctionNode( f, hash, dir )

function (f::FunctionNode{F1,F2})( args... )
    filename = joinpath( f.dir, f.hash( (f, args...) ) )
    if isfile( filename )
        return readrecursive( 
    

end # module
