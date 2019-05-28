using Serialization

x0 = [rand(100) for i in 1:1000]

file = tempname()

f = open( file, "w" )
serialize( f, x0 )
close(f)

f = open( file, "r" )
x1 = deserialize( f )
close(f)

@assert( hash(x0) == hash(x1) )

x1[1][1] = rand()

@assert( hash(x0) != hash(x1) )

rm( file )
