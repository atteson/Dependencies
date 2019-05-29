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

mutable struct T1
    x::Int
end

g( t1::T1 ) = f( 1, n, moment = t1.x )

gnode = Dependencies.FunctionNode( g )

t1 = T1(3)

t2 = T1(3)

@assert( t1 != t2 )

@time gnode( t1 )
# 72s
@time gnode( t2 )
# 0s

delete!( gnode, t1 )
delete!( gnode, t2 )
