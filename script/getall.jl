using Dependencies
using Serialization
using Models
using HMMs
using Brobdingnag

criterion( model ) = HMMs.likelihood(model.model)[end]

objects = Dict{String,Any}()
for file in readdir( Dependencies.defaultdir )
    io = open( joinpath( Dependencies.defaultdir, file ), "r" )
    objects[file] = deserialize( io )
    close( io )
end

statecount( ::HMMs.HMM{N} ) where {N} = N
statecount( m::Models.AbstractModel ) = statecount( Models.rootmodel( m ) )

sum(statecount.(values(objects)).==4)
for (k,v) in objects
    if statecount(v) == 4
        rm( joinpath( Dependencies.defaultdir, k ) )
    end
end
