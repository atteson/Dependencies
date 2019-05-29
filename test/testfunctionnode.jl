using Dependencies
using Random
using StatsBase

function f( seed::Int, n::Int = 1_000_000; moment::Int = 1 )
    Random.seed!( seed )
    mean( rand( n ).^moment )
end

n = 1_000_000_000
@time f( 1, n )
@time f( 1, n )
# 5.5s

fnode = Dependencies.FunctionNode( f )

@time fnode( 1, n )
# 5.8s
@time fnode( 1, n )
# 0.0s

@time fnode( 1, n, moment=2 )
# 16.3s
@time fnode( 1, n, moment=2 )
# 0.0s

delete!( fnode, 1, n )
delete!( fnode, 1, n, moment=2 )

@assert( !isfile( Dependencies.filename( fnode, 1, n ) ) )
@assert( !isfile( Dependencies.filename( fnode, 1, n, moment=2 ) ) )
