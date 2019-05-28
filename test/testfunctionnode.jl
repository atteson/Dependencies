using Dependencies
using Random
using StatsBase

function f( seed::Int, n::Int = 1_000_000 )
    Random.seed!( seed )
    mean( rand( n ) )
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

delete!( fnode, 1, n )
