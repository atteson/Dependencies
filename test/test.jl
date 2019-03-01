using Dependencies
using Distributions
using Random

Random.seed!(1)
p = 2
T = 1000
X = ArrayTerminal( rand( Normal(), T, p ) )
betastar = rand( Normal(), 2 )
y = ArrayTerminal( X()*betastar + rand( Normal(), T ) )
XTXinvXT = ArrayNode( Float64, (p,T), (XTXinvXT, X) -> XTXinvXT[:,:] = inv(X'*X)*X', X )

@assert( ismissing( XTXinvXT.value ) )

beta = ArrayNode( Float64, (p,), (beta,XTXinvXT,y) -> beta[:] = XTXinvXT * y, XTXinvXT, y )

@assert( XTXinvXT() == inv(X.value' * X.value)*X.value' )
@assert( ismissing( beta.value ) )

@assert( !XTXinvXT.dirty )
@assert( beta.dirty )

@assert( beta() == XTXinvXT.value * y.value )

@assert( !XTXinvXT.dirty )
@assert( !beta.dirty )

y( X()*betastar + rand( Normal(), T ) )

@assert( !XTXinvXT.dirty )
@assert( beta.dirty )

@assert( beta() == XTXinvXT.value * y.value )

@assert( !XTXinvXT.dirty )
@assert( !beta.dirty )

X( rand( Normal(), T, p ) )

@assert( XTXinvXT.dirty )
@assert( beta.dirty )

@assert( beta() == XTXinvXT.value * y.value )

@assert( !XTXinvXT.dirty )
@assert( !beta.dirty )

X( rand( Normal(), T, p ) )
@time XTXinvXT();
@time beta();

@time XTXinvXT();
@time beta();

function f( x, y, z )
    for i = 1:2
        for j = 1:1000
            x[i] += y[i,j] * z[j]
        end
    end
end

beta2 = ArrayNode( Float64, (p,), f, XTXinvXT, y )

@time beta2()
@time beta2()

y( X()*betastar + rand( Normal(), T ) )
@time beta2()
@time f( beta2.value, XTXinvXT.value, y.value )

# need it to look like this:
function g()
    parametervalues = (beta2.parameters[1](), beta2.parameters[2]())
    f( beta2.value, parametervalues... )
    beta2.dirty = false
end
@time g()
@time g()
