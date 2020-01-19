//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//
//                       github.com/samisalreadytaken
//
// This project is licensed under the terms of the MIT License.
// See <README.md> or <LICENSE> for details.
//-----------------------------------------------------------------------
//
// Interpolation. Mostly sourced from 'Source SDK'
//
// Not included in 'vs_library.nut'
//
//-----------------------------------------------------------------------

IncludeScript("vs_library/vs_math2");

enum INTERPOLATE
{
	DEFAULT,
	CATMULL_ROM_NORMALIZEX,
	EASE_IN,
	EASE_OUT,
	EASE_INOUT,
	BSPLINE,
	LINEAR_INTERP,
	KOCHANEK_BARTELS,
	KOCHANEK_BARTELS_EARLY,
	KOCHANEK_BARTELS_LATE,
	SIMPLE_CUBIC,
	CATMULL_ROM,
	CATMULL_ROM_NORMALIZE,
	CATMULL_ROM_TANGENT,
	EXPONENTIAL_DECAY,
	HOLD
}

local _VEC = Vector();

function VS::Interpolator_GetKochanekBartelsParams( interpolationType, tbc )
{
	local tension, bias, continuity;
	switch ( interpolationType )
	{
		case INTERPOLATE.KOCHANEK_BARTELS:
			tension		= 0.77;
			bias		= 0.0;
			continuity	= 0.77;
			break;
		case INTERPOLATE.KOCHANEK_BARTELS_EARLY:
			tension		= 0.77;
			bias		= -1.0;
			continuity	= 0.77;
			break;
		case INTERPOLATE.KOCHANEK_BARTELS_LATE:
			tension		= 0.77;
			bias		= 1.0;
			continuity	= 0.77;
			break;
		default:
			tension = 0.0;
			bias = 0.0;
			continuity = 0.0;
			Assert( 0 );
			break;
	};

	tbc[0] = tension;
	tbc[1] = bias;
	tbc[2] = continuity;
}

function VS::Interpolator_CurveInterpolate( interpolationType, vPre, vStart, vEnd, vNext, f, vOut = _VEC )
{
	vOut.x = 0;
	vOut.y = 0;
	vOut.z = 0;

	switch ( interpolationType )
	{
		case INTERPOLATE.DEFAULT:
		case INTERPOLATE.CATMULL_ROM_NORMALIZEX:
			Catmull_Rom_Spline_NormalizeX(
				vPre,
				vStart,
				vEnd,
				vNext,
				f,
				vOut );
			break;
		case INTERPOLATE.CATMULL_ROM:
			Catmull_Rom_Spline(
				vPre,
				vStart,
				vEnd,
				vNext,
				f,
				vOut );
			break;
		case INTERPOLATE.CATMULL_ROM_NORMALIZE:
			Catmull_Rom_Spline_Normalize(
				vPre,
				vStart,
				vEnd,
				vNext,
				f,
				vOut );
			break;
		case INTERPOLATE.CATMULL_ROM_TANGENT:
			Catmull_Rom_Spline_Tangent(
				vPre,
				vStart,
				vEnd,
				vNext,
				f,
				vOut );
			break;
		case INTERPOLATE.EASE_IN:
			{
				f = sin( f * 1.5708 );
				// ignores vPre and vNext
				VectorLerp( vStart, vEnd, f, vOut );
			}
			break;
		case INTERPOLATE.EASE_OUT:
			{
				f = 1.0 - sin( f * 1.5708 + 1.5708 );
				// ignores vPre and vNext
				VectorLerp( vStart, vEnd, f, vOut );
			}
			break;
		case INTERPOLATE.EASE_INOUT:
			{
				f = SimpleSpline( f );
				// ignores vPre and vNext
				VectorLerp( vStart, vEnd, f, vOut );
			}
			break;
		case INTERPOLATE.LINEAR_INTERP:
			// ignores vPre and vNext
			VectorLerp( vStart, vEnd, f, vOut );
			break;
		case INTERPOLATE.KOCHANEK_BARTELS:
		case INTERPOLATE.KOCHANEK_BARTELS_EARLY:
		case INTERPOLATE.KOCHANEK_BARTELS_LATE:
			{
				local tbc = [-1,-1,-1];
				Interpolator_GetKochanekBartelsParams( interpolationType, tbc );
				Kochanek_Bartels_Spline_NormalizeX
				(
					tbc[0], tbc[1], tbc[2],
					vPre,
					vStart,
					vEnd,
					vNext,
					f,
					vOut
				);
			}
			break;
		case INTERPOLATE.SIMPLE_CUBIC:
			Cubic_Spline_NormalizeX(
				vPre,
				vStart,
				vEnd,
				vNext,
				f,
				vOut );
			break;
		case INTERPOLATE.BSPLINE:
			BSpline(
				vPre,
				vStart,
				vEnd,
				vNext,
				f,
				vOut );
			break;
		case INTERPOLATE.EXPONENTIAL_DECAY:
			{
				local dt = vEnd.x - vStart.x;
				if( dt > 0.0 )
				{
					local val = 1.0 - ExponentialDecay( 0.001, dt, f * dt );
					vOut.y = vStart.y + val * ( vEnd.y - vStart.y );
				}
				else
				{
					vOut.y = vStart.y;
				}
			}
			break;
		case INTERPOLATE.HOLD:
			{
				vOut.y = vStart.y;
			}
			break;
		default:
			Msg( format("Unknown interpolation type %d\n", interpolationType) );
	}

	return vOut;
}

function VS::Interpolator_CurveInterpolate_NonNormalized( interpolationType, vPre, vStart, vEnd, vNext, f, vOut = _VEC )
{
	// if( typeof vOut == "Quaternion" )
		// return Interpolator_CurveInterpolate_NonNormalizedQ( interpolationType, vPre, vStart, vEnd, vNext, f, vOut );

	vOut.x = 0;
	vOut.y = 0;
	vOut.z = 0;

	switch ( interpolationType )
	{
		case INTERPOLATE.CATMULL_ROM_NORMALIZEX:
		case INTERPOLATE.DEFAULT:
		case INTERPOLATE.CATMULL_ROM:
		case INTERPOLATE.CATMULL_ROM_NORMALIZE:
		case INTERPOLATE.CATMULL_ROM_TANGENT:
			Catmull_Rom_Spline(
				vPre,
				vStart,
				vEnd,
				vNext,
				f,
				vOut );
			break;
		case INTERPOLATE.EASE_IN:
			{
				f = sin( f * 1.5708 );
				// ignores vPre and vNext
				VectorLerp( vStart, vEnd, f, vOut );
			}
			break;
		case INTERPOLATE.EASE_OUT:
			{
				f = 1.0 - sin( f * 1.5708 + 1.5708 );
				// ignores vPre and vNext
				VectorLerp( vStart, vEnd, f, vOut );
			}
			break;
		case INTERPOLATE.EASE_INOUT:
			{
				f = SimpleSpline( f );
				// ignores vPre and vNext
				VectorLerp( vStart, vEnd, f, vOut );
			}
			break;
		case INTERPOLATE.LINEAR_INTERP:
			// ignores vPre and vNext
			VectorLerp( vStart, vEnd, f, vOut );
			break;
		case INTERPOLATE.KOCHANEK_BARTELS:
		case INTERPOLATE.KOCHANEK_BARTELS_EARLY:
		case INTERPOLATE.KOCHANEK_BARTELS_LATE:
			{
				local tbc = [-1,-1,-1];
				Interpolator_GetKochanekBartelsParams( interpolationType, tbc );
				Kochanek_Bartels_Spline
				(
					tbc[0], tbc[1], tbc[2],
					vPre,
					vStart,
					vEnd,
					vNext,
					f,
					vOut
				);
			}
			break;
		case INTERPOLATE.SIMPLE_CUBIC:
			Cubic_Spline(
				vPre,
				vStart,
				vEnd,
				vNext,
				f,
				vOut );
			break;
		case INTERPOLATE.BSPLINE:
			BSpline(
				vPre,
				vStart,
				vEnd,
				vNext,
				f,
				vOut );
			break;
		case INTERPOLATE.EXPONENTIAL_DECAY:
			{
				local dt = vEnd.x - vStart.x;
				if( dt > 0.0 )
				{
					local val = 1.0 - ExponentialDecay( 0.001, dt, f * dt );
					vOut.y = vStart.y + val * ( vEnd.y - vStart.y );
				}
				else
				{
					vOut.y = vStart.y;
				};
			}
			break;
		case INTERPOLATE.HOLD:
			{
				vOut.y = vStart.y;
			}
			break;
		default:
			Msg( format("Unknown interpolation type %d\n", interpolationType) );
	}

	return vOut;
}

//-----------------------------------------------------------------------------
// Purpose: A helper function to normalize p2.x->p1.x and p3.x->p4.x to
//  be the same length as p2.x->p3.x
// Input  : Vector p2 -
//          Vector p4 -
//          Vector p4n -
//-----------------------------------------------------------------------------
function VS::Spline_Normalize( p1, p2, p3, p4, p1n, p4n )
{
	local dt = p3.x - p2.x;

	p1n = p1;
	p4n = p4;

	if( dt != 0.0 )
	{
		if( p1.x != p2.x )
		{
			VectorLerp( p2, p1, dt / (p2.x - p1.x), p1n );
		};
		if( p4.x != p3.x )
		{
			VectorLerp( p3, p4, dt / (p4.x - p3.x), p4n );
		};
	};
}

// Interpolate a Catmull-Rom spline.
// t is a [0,1] value and interpolates a curve between p2 and p3.
function VS::Catmull_Rom_Spline( p1, p2, p3, p4, t, output = _VEC )
{
/*
	if( p1 == output ||
		p2 == output ||
		p3 == output ||
		p4 == output ) Assert(0);
*/
	// local output = out.getclass()();

	local th = t*0.5;
	local tSqr = t*th;
	local tSqrSqr = t*tSqr;
	t = th;

	output.x = 0.0;
	output.y = 0.0;
	output.z = 0.0;

	// matrix row 1
	local a = p1 * ( -tSqrSqr );	// 0.5 t^3 * [ (-1*p1) + ( 3*p2) + (-3*p3) + p4 ]
	local b = p2 * ( tSqrSqr*3 );
	local c = p3 * ( tSqrSqr*-3 );
	local d = p4 * ( tSqrSqr );

	VectorAdd( output, a, output );
	VectorAdd( output, b, output );
	VectorAdd( output, c, output );
	VectorAdd( output, d, output );

	// matrix row 2
	a = p1 * ( tSqr*2 );			// 0.5 t^2 * [ ( 2*p1) + (-5*p2) + ( 4*p3) - p4 ]
	b = p2 * ( tSqr*-5 );
	c = p3 * ( tSqr*4 );
	d = p4 * ( -tSqr );

	VectorAdd( output, a, output );
	VectorAdd( output, b, output );
	VectorAdd( output, c, output );
	VectorAdd( output, d, output );

	// matrix row 3
	a = p1 * ( -t );				// 0.5 t * [ (-1*p1) + p3 ]
	b = p3 * ( t );

	VectorAdd( output, a, output );
	VectorAdd( output, b, output );

	// matrix row 4
	VectorAdd( output, p2, output ); 								// p2

	return output;
}

// Interpolate a Catmull-Rom spline.
// Returns the tangent of the point at t of the spline
function VS::Catmull_Rom_Spline_Tangent( p1, p2, p3, p4, t, output = _VEC )
{
/*
	if( p1 == output ||
		p2 == output ||
		p3 == output ||
		p4 == output ) Assert(0);
*/
	local tOne = 1.5*t*t;
	local tTwo = 1*t;
	local tThree = 0.5;

	output.x = 0.0;
	output.y = 0.0;
	output.z = 0.0;

	// matrix row 1
	local a = p1 * ( -tOne );		// 0.5 t^3 * [ (-1*p1) + ( 3*p2) + (-3*p3) + p4 ]
	local b = p2 * ( tOne*3 );
	local c = p3 * ( tOne*-3 );
	local d = p4 * ( tOne );

	VectorAdd( output, a, output );
	VectorAdd( output, b, output );
	VectorAdd( output, c, output );
	VectorAdd( output, d, output );

	// matrix row 2
	a = p1 * ( tTwo*2 );		// 0.5 t^2 * [ ( 2*p1) + (-5*p2) + ( 4*p3) - p4 ]
	b = p2 * ( tTwo*-5 );
	c = p3 * ( tTwo*4 );
	d = p4 * ( -tTwo );

	VectorAdd( output, a, output );
	VectorAdd( output, b, output );
	VectorAdd( output, c, output );
	VectorAdd( output, d, output );

	// matrix row 3
	a = p1 * ( -tThree );			// 0.5 t * [ (-1*p1) + p3 ]
	b = p3 * ( tThree );

	VectorAdd( output, a, output );
	VectorAdd( output, b, output );

	return output;
}

// area under the curve [0..t]
function VS::Catmull_Rom_Spline_Integral( p1, p2, p3, p4, t, output = _VEC )
{
	local tt = t*t;
	local ttt = tt*t;

	local o = p2*t
	          -0.25*(p1 - p3)*tt
	          + (1.0/6.0)*(2.0*p1 - 5.0*p2 + 4.0*p3 - p4)*ttt
	          - 0.125*(p1 - 3.0*p2 + 3.0*p3 - p4)*ttt*t;
	output.x = o.x;
	output.y = o.y;
	output.z = o.z;

	return output;
}

// area under the curve [0..1]
function VS::Catmull_Rom_Spline_Integral2( p1, p2, p3, p4, t, output = _VEC )
{
	local o = ((p1*-0.25) + (p2*3.25) + (p3*3.25) - (p4*0.25)) * 0.166667;
	output.x = o.x;
	output.y = o.y;
	output.z = o.z;

	return output;
}

// Interpolate a Catmull-Rom spline.
// Normalize p2->p1 and p3->p4 to be the same length as p2->p3
function VS::Catmull_Rom_Spline_Normalize( p1, p2, p3, p4, t, output = _VEC )
{
	// Normalize p2->p1 and p3->p4 to be the same length as p2->p3
	local dt = Dist(p3,p2);

	local p1n = p1 - p2;
	local p4n = p4 - p3;

	p1n.Norm();
	p4n.Norm();

	VectorMA( p2, dt, p1n, p1n );
	VectorMA( p3, dt, p4n, p4n );

	return Catmull_Rom_Spline( p1n, p2, p3, p4n, t, output );
}

// area under the curve [0..t]
// Normalize p2->p1 and p3->p4 to be the same length as p2->p3
function VS::Catmull_Rom_Spline_Integral_Normalize( p1, p2, p3, p4, t, output = _VEC )
{
	// Normalize p2->p1 and p3->p4 to be the same length as p2->p3
	local dt = Dist(p3,p2);

	local p1n = p1 - p2;
	local p4n = p4 - p3;

	p1n.Norm();
	p4n.Norm();

	VectorMA( p2, dt, p1n, p1n );
	VectorMA( p3, dt, p4n, p4n );

	return Catmull_Rom_Spline_Integral( p1n, p2, p3, p4n, t, output );
}

// Interpolate a Catmull-Rom spline.
// Normalize p2.x->p1.x and p3.x->p4.x to be the same length as p2.x->p3.x
function VS::Catmull_Rom_Spline_NormalizeX( p1, p2, p3, p4, t, output )
{
	local p1n = Vector(), p4n = Vector();
	Spline_Normalize( p1, p2, p3, p4, p1n, p4n );
	return Catmull_Rom_Spline( p1n, p2, p3, p4n, t, output );
}

//-----------------------------------------------------------------------------
// Purpose: basic hermite spline.  t = 0 returns p1, t = 1 returns p2,
//			d1 and d2 are used to entry and exit slope of curve
// Input  :
//-----------------------------------------------------------------------------

// return Vector
function VS::Hermite_Spline( p1, p2, d1, d2, t, output = _VEC )
{
/*
	if( p1 == output ||
		p2 == output ||
		p3 == output ||
		p4 == output ) Assert(0);
*/
	local tSqr = t*t;
	local tCube = t*tSqr;

	local b1 = 2.0*tCube-3.0*tSqr+1.0;
	local b2 = 1.0 - b1; // -2*tCube+3*tSqr;
	local b3 = tCube-2*tSqr+t;
	local b4 = tCube-tSqr;

	VectorMultiply( p1, b1, output );

	VectorMA( output, b2, p2, output );
	VectorMA( output, b3, d1, output );
	VectorMA( output, b4, d2, output );

	return output;
}

// return float
function VS::Hermite_SplineF( p1, p2, d1, d2, t )
{
	local tSqr = t*t;
	local tCube = t*tSqr;

	local b1 = 2.0*tCube-3.0*tSqr+1.0;
	local b2 = 1.0 - b1; // -2*tCube+3*tSqr;
	local b3 = tCube-2*tSqr+t;
	local b4 = tCube-tSqr;

	local output = p1 * b1;
	output += p2 * b2;
	output += d1 * b3;
	output += d2 * b4;

	return output;
}

// float basis[4]
function VS::Hermite_SplineBasis( t, basis )
{
	local tSqr = t*t;
	local tCube = t*tSqr;

	basis[0] = 2.0*tCube-3.0*tSqr+1.0;
	basis[1] = 1.0 - basis[0]; // -2*tCube+3*tSqr;
	basis[2] = tCube-2*tSqr+t;
	basis[3] = tCube-tSqr;
}

//-----------------------------------------------------------------------------
// Purpose: simple three data point hermite spline.
//          t = 0 returns p1, t = 1 returns p2,
//          slopes are generated from the p0->p1 and p1->p2 segments
//          this is reasonable C1 method when there's no "p3" data yet.
// Input  :
//-----------------------------------------------------------------------------

// input Vector
function VS::Hermite_Spline3V( p0, p1, p2, t, output = _VEC )
{
	return Hermite_Spline( p1, p2, p1 - p0, p2 - p1, t, output );
}

// input float
function VS::Hermite_Spline3F( p0, p1, p2, t )
{
	return Hermite_SplineF( p1, p2, p1 - p0, p2 - p1, t );
}

// input Quaternion
function VS::Hermite_Spline3Q( q0, q1, q2, t, output = Quaternion() )
{
	// cheap, hacked version of quaternions
	local q0a = Quaternion(),
	      q1a = Quaternion();

	QuaternionAlign( q2, q0, q0a );
	QuaternionAlign( q2, q1, q1a );

	output.x = Hermite_Spline3F( q0a.x, q1a.x, q2.x, t );
	output.y = Hermite_Spline3F( q0a.y, q1a.y, q2.y, t );
	output.z = Hermite_Spline3F( q0a.z, q1a.z, q2.z, t );
	output.w = Hermite_Spline3F( q0a.w, q1a.w, q2.w, t );

	QuaternionNormalize( output );

	return output;
}

//-----------------------------------------------------------------------------
// See http://en.wikipedia.org/wiki/Kochanek-Bartels_curves
//
// Tension:    -1 = Round -> 1 = Tight
// Bias:       -1 = Pre-shoot (bias left) -> 1 = Post-shoot (bias right)
// Continuity: -1 = Box corners -> 1 = Inverted corners
//
// If T=B=C=0 it's the same matrix as Catmull-Rom.
// If T=1 & B=C=0 it's the same as Cubic.
// If T=B=0 & C=-1 it's just linear interpolation
//
// See http://news.povray.org/povray.binaries.tutorials/attachment/%3CXns91B880592482seed7@povray.org%3E/Splines.bas.txt
// for example code and descriptions of various spline types...
//-----------------------------------------------------------------------------
function VS::Kochanek_Bartels_Spline( tension, bias, continuity, p1, p2, p3, p4, t, output = _VEC )
{
/*
	if( p1 == output ||
		p2 == output ||
		p3 == output ||
		p4 == output ) Assert(0);
*/
	local ffa = ( 1.0 - tension ) * ( 1.0 + continuity ) * ( 1.0 + bias ),
	      ffb = ( 1.0 - tension ) * ( 1.0 - continuity ) * ( 1.0 - bias ),
	      ffc = ( 1.0 - tension ) * ( 1.0 - continuity ) * ( 1.0 + bias ),
	      ffd = ( 1.0 - tension ) * ( 1.0 + continuity ) * ( 1.0 - bias );

	local th = t*0.5;
	local tSqr = t*th;
	local tSqrSqr = t*tSqr;
	t = th;

	output.x = 0.0;
	output.y = 0.0;
	output.z = 0.0;

	// matrix row 1
	local a = p1 * ( tSqrSqr * -ffa );
	local b = p2 * ( tSqrSqr * ( 4.0 + ffa - ffb - ffc ) );
	local c = p3 * ( tSqrSqr * ( -4.0 + ffb + ffc - ffd ) );
	local d = p4 * ( tSqrSqr * ffd );

	VectorAdd( output, a, output );
	VectorAdd( output, b, output );
	VectorAdd( output, c, output );
	VectorAdd( output, d, output );

	// matrix row 2
	a = p1 * ( tSqr* 2 * ffa );
	b = p2 * ( tSqr * ( -6 - 2 * ffa + 2 * ffb + ffc ) );
	c = p3 * ( tSqr * ( 6 - 2 * ffb - ffc + ffd ) );
	d = p4 * ( tSqr * -ffd );

	VectorAdd( output, a, output );
	VectorAdd( output, b, output );
	VectorAdd( output, c, output );
	VectorAdd( output, d, output );

	// matrix row 3
	a = p1 * ( t * -ffa );
	b = p2 * ( t * ( ffa - ffb ) );
	c = p3 * ( t * ffb );
	// p4 unchanged

	VectorAdd( output, a, output );
	VectorAdd( output, b, output );
	VectorAdd( output, c, output );

	// matrix row 4
	// p1, p3, p4 unchanged
	// p2 is multiplied by 1 and added, so just added it directly

	VectorAdd( output, p2, output );

	return output;
}

function VS::Kochanek_Bartels_Spline_NormalizeX( tension, bias, continuity, p1, p2, p3, p4, t, output = _VEC )
{
	local p1n = Vector(), p4n = Vector();
	Spline_Normalize( p1, p2, p3, p4, p1n, p4n );
	return Kochanek_Bartels_Spline( tension, bias, continuity, p1n, p2, p3, p4n, t, output );
}

// See link at Kochanek_Bartels_Spline for info on the basis matrix used
function VS::Cubic_Spline( p1, p2, p3, p4, t, output = _VEC )
{
/*
	if( p1 == output ||
		p2 == output ||
		p3 == output ||
		p4 == output ) Assert(0);
*/
	local tSqr = t*t;
	local tSqrSqr = t*tSqr;

	output.x = 0.0;
	output.y = 0.0;
	output.z = 0.0;

	// matrix row 1
	local b = p2 * ( tSqrSqr * 2 );
	local c = p3 * ( tSqrSqr * -2 );

	VectorAdd( output, b, output );
	VectorAdd( output, c, output );

	// matrix row 2
	b = p2 * ( tSqr * -3 );
	c = p3 * ( tSqr * 3 );

	VectorAdd( output, b, output );
	VectorAdd( output, c, output );

	// matrix row 3
	// no influence
	// p4 unchanged

	// matrix row 4
	// p1, p3, p4 unchanged

	VectorAdd( output, p2, output );

	return output;
}

function VS::Cubic_Spline_NormalizeX( p1, p2, p3, p4, t, output = _VEC )
{
	local p1n = Vector(), p4n = Vector();
	Spline_Normalize( p1, p2, p3, p4, p1n, p4n );
	return Cubic_Spline( p1n, p2, p3, p4n, t, output );
}

// See link at Kochanek_Bartels_Spline for info on the basis matrix used
function VS::BSpline( p1, p2, p3, p4, t, output = _VEC )
{
/*
	if( p1 == output ||
		p2 == output ||
		p3 == output ||
		p4 == output ) Assert(0);
*/
	local oneOver6 = 0.166667;

	local th = t * oneOver6;
	local tSqr = t * th;
	local tSqrSqr = t*tSqr;
	t = th;

	output.x = 0.0;
	output.y = 0.0;
	output.z = 0.0;

	// matrix row 1
	local a = p1 * ( -tSqrSqr );
	local b = p2 * ( tSqrSqr * 3.0 );
	local c = p3 * ( tSqrSqr * -3.0 );
	local d = p4 * ( tSqrSqr );

	VectorAdd( output, a, output );
	VectorAdd( output, b, output );
	VectorAdd( output, c, output );
	VectorAdd( output, d, output );

	// matrix row 2
	a = p1 * ( tSqr * 3.0 );
	b = p2 * ( tSqr * -6.0 );
	c = p3 * ( tSqr * 3.0 );

	VectorAdd( output, a, output );
	VectorAdd( output, b, output );
	VectorAdd( output, c, output );

	// matrix row 3
	a = p1 * ( t * -3.0 );
	c = p3 * ( t * 3.0 );
	// p4 unchanged

	VectorAdd( output, a, output );
	VectorAdd( output, c, output );

	// matrix row 4
	// p1 and p3 scaled by 1.0, so done below
	a = p1 * ( oneOver6 );
	b = p2 * ( 4.0 * oneOver6 );
	c = p3 * ( oneOver6 );

	VectorAdd( output, a, output );
	VectorAdd( output, b, output );
	VectorAdd( output, c, output );

	return output;
}

function VS::BSpline_NormalizeX( p1, p2, p3, p4, t, output = _VEC )
{
	local p1n = Vector(), p4n = Vector();
	Spline_Normalize( p1, p2, p3, p4, p1n, p4n );
	return BSpline( p1n, p2, p3, p4n, t, output );
}

// See link at Kochanek_Bartels_Spline for info on the basis matrix used
function VS::Parabolic_Spline( p1, p2, p3, p4, t, output = _VEC )
{
/*
	if( p1 == output ||
		p2 == output ||
		p3 == output ||
		p4 == output ) Assert(0);
*/
	local th = t*0.5;
	local tSqr = t*th;
	t = th;

	output.x = 0.0;
	output.y = 0.0;
	output.z = 0.0;

	// matrix row 1
	// no influence from t cubed

	// matrix row 2
	local a = p1 * ( tSqr );
	local b = p2 * ( tSqr * -2.0 );
	local c = p3 * ( tSqr );

	VectorAdd( output, a, output );
	VectorAdd( output, b, output );
	VectorAdd( output, c, output );

	// matrix row 3
	local t2 = t * 2.0;
	a = p1 * (-t2 );
	b = p2 * ( t2 );
	// p4 unchanged

	VectorAdd( output, a, output );
	VectorAdd( output, b, output );

	// matrix row 4
	a = p1 * ( 0.5 );
	b = p2 * ( 0.5 );

	VectorAdd( output, a, output );
	VectorAdd( output, b, output );

	return output;
}

function VS::Parabolic_Spline_NormalizeX( p1, p2, p3, p4, t, output = _VEC )
{
	local p1n = Vector(), p4n = Vector();
	Spline_Normalize( p1, p2, p3, p4, p1n, p4n );
	return Parabolic_Spline( p1n, p2, p3, p4n, t, output );
}

//-----------------------------------------------------------------------------
// Purpose: Compress the input values for a ranged result such that from 75% to 200% smoothly of the range maps
//-----------------------------------------------------------------------------
function VS::RangeCompressor( flValue, flMin, flMax, flBase )
{
	// clamp base
	if( flBase < flMin )
		flBase = flMin;
	else if( flBase > flMax )
		flBase = flMax;;

	flValue += flBase;

	// convert to 0 to 1 value
	local flMid = (flValue - flMin) / (flMax - flMin);
	// convert to -1 to 1 value
	local flTarget = flMid * 2 - 1;

	if( fabs(flTarget) > 0.75 )
	{
		local t = (fabs(flTarget) - 0.75) / (1.25);
		if( t < 1.0 )
		{
			if( flTarget > 0 )
			{
				flTarget = Hermite_SplineF( 0.75, 1, 0.75, 0, t );
			}
			else
			{
				flTarget = -Hermite_SplineF( 0.75, 1, 0.75, 0, t );
			};
		}
		else
		{
			flTarget = (flTarget > 0) ? 1.0 : -1.0;
		};
	};

	flMid = (flTarget + 1 ) / 2.0;
	flValue = flMin * (1 - flMid) + flMax * flMid;

	flValue -= flBase;

	return flValue;
}

function VS::QAngleLerp( v1, v2, flPercent )
{
	// Avoid precision errors
	if( v1 == v2 )
		return v1;

	// Convert to quaternions
	local src  = AngleQuaternion( v1, Quaternion() );
	local dest = AngleQuaternion( v2, Quaternion() );

	// Slerp
	local result = QuaternionSlerp( src, dest, flPercent );

	// Convert to euler
	local output = QuaternionAngles( result, Vector() );

	return output;
}
