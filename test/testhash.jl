using Dependencies

x0 = [rand(100) for i in 1:1000]

file = tempname()

f = open( file, "w" )
Dependencies.recursivewrite( f, x0 )
close(f)

f = open( file, "r" )
x1 = Dependencies.recursiveread( f, Vector{Vector{Float64}} )
close(f)

@assert( hash(x0) == hash(x1) )

x1[1][1] = rand()

@assert( hash(x0) != hash(x1) )

rm( file )
