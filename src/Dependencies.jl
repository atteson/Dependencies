module Dependencies

export FunctionNode

using Serialization
using SHA

const defaultdir = joinpath( dirname(dirname(pathof(Dependencies))), "data" )

struct FunctionNode{F1 <: Function} <: Function
    f::F1
end

FunctionNode( f::F1 ) where {F1, F2} = FunctionNode( f )

function filename( f::FunctionNode{F1}, args...; kwargs... ) where {F1}
    buf = IOBuffer()
    serialize( buf, (f, args..., kwargs...) )
    name = bytes2hex( sha256( String(take!(buf)) ) )
    return joinpath( defaultdir, name )
end

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

# will run forever if there are self-cycles
function finddiff( x1, x2, fields::AbstractVector{Symbol} = Symbol[] )
    t1 = typeof(x1)
    t2 = typeof(x2)
    if t1 != t2
        println( join( string.(fields), "." ), ": types are different" )
    end
    if isbitstype( t1 ) && x1 != x2
        println( join( string.(fields), "." ), ": values are different: $x1 and $x2" )
    end
        
    for field in fieldnames(t1)
        f1 = getproperty( x1, field )
        f2 = getproperty( x2, field )
        if f1 != f2
            finddiff( f1, f2, [fields; field] )
        end
    end
end

end # module
