using Dependencies
using Distributions
using Random

Random.seed!(1)
p = 2
T = 1000
X = ArrayTerminal( rand( Normal(), T, p ) )
betastar = rand( Normal(), 2 )
y = ArrayTerminal( X()*betastar + rand( Normal(), T ) )
XTXinvXT = ArrayNode( Float64, (p,T), (XTXinvXT, X) -> XTXinvXT = inv(X'*X)*X', X )

@assert( ismissing( XTXinvXT.value ) )

beta = ArrayNode( Float64, (p,), (beta,XTXinvXT,y) -> beta = XTXinvXT * y, XTXinvXT, y )

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


