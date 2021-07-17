//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//-----------------------------------------------------------------------
//
// Interpolation. Mostly sourced from the Source Engine
//
// Not included in 'vs_library.nut'
//
//-----------------------------------------------------------------------

if( !("VectorTransform" in VS) )
	Assert(0,"vs_math2 not found");;

// if already included
if( "Catmull_Rom_Spline" in VS )
	return;;

local QuaternionAlign = VS.QuaternionAlign;
local QuaternionNormalize = VS.QuaternionNormalize;
local AngleQuaternion = VS.AngleQuaternion;
local QuaternionAngles = VS.QuaternionAngles;
local QuaternionSlerp = VS.QuaternionSlerp;
local VectorMA = VS.VectorMA;
local VectorLerp = VS.VectorLerp;
local ExponentialDecay = VS.ExponentialDecay;

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

function VS::Interpolator_CurveInterpolate( interpolationType, vPre, vStart, vEnd, vNext, f, vOut ):(sin,VectorLerp,ExponentialDecay)
{
	vOut.x = vOut.y = vOut.z = 0.0;

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
				f = sin( f * 1.57079633 ); // PI / 2
				// ignores vPre and vNext
				VectorLerp( vStart, vEnd, f, vOut );
			}
			break;
		case INTERPOLATE.EASE_OUT:
			{
				f = 1.0 - sin( f * 1.57079633 + 1.57079633 ); // PI / 2
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
				local tbc = [null,null,null];
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
}

function VS::Interpolator_CurveInterpolate_NonNormalized( interpolationType, vPre, vStart, vEnd, vNext, f, vOut )
	: ( sin, VectorLerp, ExponentialDecay )
{
	vOut.x = vOut.y = vOut.z = 0.0;

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
				f = sin( f * 1.57079633 ); // PI / 2
				// ignores vPre and vNext
				VectorLerp( vStart, vEnd, f, vOut );
			}
			break;
		case INTERPOLATE.EASE_OUT:
			{
				f = 1.0 - sin( f * 1.57079633 + 1.57079633 ); // PI / 2
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
}

//-----------------------------------------------------------------------------
// Purpose: A helper function to normalize p2.x->p1.x and p3.x->p4.x to
//  be the same length as p2.x->p3.x
// Input  : Vector p2 -
//          Vector p4 -
//          Vector p4n -
//-----------------------------------------------------------------------------
function VS::Spline_Normalize( p1, p2, p3, p4, p1n, p4n ) : ( VectorLerp )
{
	local dt = p3.x - p2.x;

	p1n.x = p1.x;
	p1n.y = p1.y;
	p1n.z = p1.z;

	p4n.x = p4.x;
	p4n.y = p4.y;
	p4n.z = p4.z;

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

local Spline_Normalize = VS.Spline_Normalize;

// Interpolate a Catmull-Rom spline.
// t is a [0,1] value and interpolates a curve between p2 and p3.
function VS::Catmull_Rom_Spline( p1, p2, p3, p4, t, output )
{
	//         p1     p2    p3    p4
	//
	// t^3     -1     +3    -3    +1     /
	// t^2     +2     -5     4    -1    /
	// t^1     -1      0     1     0   /  2
	// t^0      0      2     0     0  /

	local th = t*0.5;
	local t2 = t*th;
	local t3 = t*t2;

	local a = -t3 + 2.0 * t2 - th;
	local b = 3.0 * t3 - 5.0 * t2 + 1.0;
	local c = -3.0 * t3 + 4.0 * t2 + th;
	local d = t3 - t2;

	output.x = a * p1.x + b * p2.x + c * p3.x + d * p4.x;
	output.y = a * p1.y + b * p2.y + c * p3.y + d * p4.y;
	output.z = a * p1.z + b * p2.z + c * p3.z + d * p4.z;
}

local Catmull_Rom_Spline = VS.Catmull_Rom_Spline;

// Interpolate a Catmull-Rom spline.
// Returns the tangent of the point at t of the spline
function VS::Catmull_Rom_Spline_Tangent( p1, p2, p3, p4, t, output )
{
	local t3 = 1.5 * t * t; // 3.0 * t * t * 0.5;
	// local t2 = 2.0 * t * 0.5;
	// local th = 0.5;

	local a = -t3 + 2.0 * t - 0.5;
	local b = 3.0 * t3 - 5.0 * t;
	local c = -3.0 * t3 + 4.0 * t + 0.5;
	local d = t3 - t;

	output.x = a * p1.x + b * p2.x + c * p3.x + d * p4.x;
	output.y = a * p1.y + b * p2.y + c * p3.y + d * p4.y;
	output.z = a * p1.z + b * p2.z + c * p3.z + d * p4.z;
}

// area under the curve [0..t]
function VS::Catmull_Rom_Spline_Integral( p1, p2, p3, p4, t, output )
{
	local tt = t*t;
	local ttt = tt*t;

	local o = p2*t
	          -0.25*(p1 - p3)*tt
	          + 0.166667*(2.0*p1 - 5.0*p2 + 4.0*p3 - p4)*ttt
	          - 0.125*(p1 - 3.0*p2 + 3.0*p3 - p4)*ttt*t;
	output.x = o.x;
	output.y = o.y;
	output.z = o.z;
}

// area under the curve [0..1]
function VS::Catmull_Rom_Spline_Integral2( p1, p2, p3, p4, t, output )
{
	local o = ((p1*-0.25) + (p2*3.25) + (p3*3.25) - (p4*0.25)) * 0.166667;
	output.x = o.x;
	output.y = o.y;
	output.z = o.z;
}

// Interpolate a Catmull-Rom spline.
// Normalize p2->p1 and p3->p4 to be the same length as p2->p3
function VS::Catmull_Rom_Spline_Normalize( p1, p2, p3, p4, t, output ) : ( VectorMA, Catmull_Rom_Spline )
{
	// Normalize p2->p1 and p3->p4 to be the same length as p2->p3
	local dt = (p3-p2).Length();

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
function VS::Catmull_Rom_Spline_Integral_Normalize( p1, p2, p3, p4, t, output ) : (VectorMA)
{
	// Normalize p2->p1 and p3->p4 to be the same length as p2->p3
	local dt = (p3-p2).Length();

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
function VS::Catmull_Rom_Spline_NormalizeX( p1, p2, p3, p4, t, output ) :
	( Vector, Spline_Normalize, Catmull_Rom_Spline )
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
function VS::Hermite_Spline( p1, p2, d1, d2, t, output )
{
	local t2 = t*t;
	local t3 = t*t2;

	local b1 = 2.0 * t3 - 3.0 * t2 + 1.0;
	local b2 = 1.0 - b1; // -2.0 * t3 + 3.0 * t2;
	local b3 = t3 - 2.0 * t2 + t;
	local b4 = t3 - t2;

	output.x = b1 * p1.x + b2 * p2.x + b3 * d1.x + b4 * d2.x;
	output.y = b1 * p1.y + b2 * p2.y + b3 * d1.y + b4 * d2.y;
	output.z = b1 * p1.z + b2 * p2.z + b3 * d1.z + b4 * d2.z;
}

// return float
function VS::Hermite_SplineF( p1, p2, d1, d2, t )
{
	local t2 = t*t;
	local t3 = t*t2;

	local b1 = 2.0 * t3 - 3.0 * t2 + 1.0;
	// local b2 = 1.0 - b1; // -2.0 * t3 + 3.0 * t2;
	// local b3 = t3 - 2.0 * t2 + t;
	// local b4 = t3 - t2;

	return b1 * p1 + (1.0 - b1) * p2 + (t3 - 2.0 * t2 + t) * d1 + (t3 - t2) * d2;
}

// float basis[4]
function VS::Hermite_SplineBasis( t, basis )
{
	local t2 = t*t;
	local t3 = t*t2;

	basis[0] = 2.0 * t3 - 3.0 * t2 + 1.0;
	basis[1] = 1.0 - basis[0]; // -2.0 * t3 + 3.0 * t2;
	basis[2] = t3 - 2.0 * t2 + t;
	basis[3] = t3 - t2;
}

local Hermite_Spline = VS.Hermite_Spline;
local Hermite_SplineF = VS.Hermite_SplineF;

//-----------------------------------------------------------------------------
// Purpose: simple three data point hermite spline.
//          t = 0 returns p1, t = 1 returns p2,
//          slopes are generated from the p0->p1 and p1->p2 segments
//          this is reasonable C1 method when there's no "p3" data yet.
// Input  :
//-----------------------------------------------------------------------------

// input Vector
function VS::Hermite_Spline3V( p0, p1, p2, t, output ) : ( Hermite_Spline )
{
	return Hermite_Spline( p1, p2, p1 - p0, p2 - p1, t, output );
}

// input float
function VS::Hermite_Spline3F( p0, p1, p2, t ) : ( Hermite_SplineF )
{
	return Hermite_SplineF( p1, p2, p1 - p0, p2 - p1, t );
}

local Hermite_Spline3F = VS.Hermite_Spline3F;

// input Quaternion
function VS::Hermite_Spline3Q( q0, q1, q2, t, output )
	: ( Quaternion, QuaternionAlign, QuaternionNormalize, Hermite_Spline3F )
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
function VS::Kochanek_Bartels_Spline( tension, bias, continuity, p1, p2, p3, p4, t, output )
{
	local ffa = ( 1.0 - tension ) * ( 1.0 + continuity ) * ( 1.0 + bias );
	local ffb = ( 1.0 - tension ) * ( 1.0 - continuity ) * ( 1.0 - bias );
	local ffc = ( 1.0 - tension ) * ( 1.0 - continuity ) * ( 1.0 + bias );
	local ffd = ( 1.0 - tension ) * ( 1.0 + continuity ) * ( 1.0 - bias );

	//        p1      p2         p3       p4
	//
	// t^3    -A    4+A-B-C   -4+B+C-D     D     /
	// t^2   +2A  -6-2A+2B+C  6-2B-C+D    -D    /
	// t^1    -A     A-B         B         0   /  2
	// t^0     0      2          0         0  /

	// NOTE: Valve's original code (33 add, 46 mul, 91 mov):
	//
	// out = 0
	//
	// FA = p1*t3*m[0][0]
	// FB = p2*t3*m[0][1]
	// FC = p3*t3*m[0][2]
	// FD = p4*t3*m[0][3]
	//
	// out += FA + FB + FC + FD
	//
	// FA = p1*t2*m[1][0]
	// FB = p2*t2*m[1][1]
	// FC = p3*t2*m[1][2]
	// FD = p4*t2*m[1][3]
	//
	// out += FA + FB + FC + FD
	//
	// FA = p1*t1*m[2][0]
	// FB = p2*t1*m[2][1]
	// FC = p3*t1*m[2][2]
	// FD = p4*t1*m[2][3]
	//
	// out += FA + FB + FC + FD
	//
	// FA = p1*m[3][0]
	// FB = p2*m[3][1]
	// FC = p3*m[3][2]
	// FD = p4*m[3][3]
	//

	// Optimised version (13 add, 19 mul, 33 mov):
	//
	// FA = p1 * ( t3*m[0][0] + t2*m[1][0] + t1*m[2][0] + m[3][0] )
	// FB = p2 * ( t3*m[0][1] + t2*m[1][1] + t1*m[2][1] + m[3][1] )
	// FC = p3 * ( t3*m[0][2] + t2*m[1][2] + t1*m[2][2] + m[3][2] )
	// FD = p4 * ( t3*m[0][3] + t2*m[1][3] + t1*m[2][3] + m[3][3] )
	//
	// out = FA + FB + FC + FD
	//

	local th = t*0.5;
	local t2 = t*th;
	local t3 = t*t2;

	local a = t3 * -ffa + t2 * 2.0 * ffa - th * ffa;
	local b = t3 * (4.0 + ffa - ffb - ffc) + t2 * (-6.0 - 2.0 * ffa + 2.0 * ffb + ffc) + th * (ffa - ffb) + 1.0;
	local c = t3 * (-4.0 + ffb + ffc - ffd) + t2 * (6.0 - 2.0 * ffb - ffc + ffd) + th * ffb;
	local d = t3 * ffd - t2 * ffd;

	output.x = a * p1.x + b * p2.x + c * p3.x + d * p4.x;
	output.y = a * p1.y + b * p2.y + c * p3.y + d * p4.y;
	output.z = a * p1.z + b * p2.z + c * p3.z + d * p4.z;
}

local Kochanek_Bartels_Spline = VS.Kochanek_Bartels_Spline;

function VS::Kochanek_Bartels_Spline_NormalizeX( tension, bias, continuity, p1, p2, p3, p4, t, output )
	: ( Vector, Spline_Normalize, Kochanek_Bartels_Spline )
{
	local p1n = Vector(), p4n = Vector();
	Spline_Normalize( p1, p2, p3, p4, p1n, p4n );
	return Kochanek_Bartels_Spline( tension, bias, continuity, p1n, p2, p3, p4n, t, output );
}

// See link at Kochanek_Bartels_Spline for info on the basis matrix used
function VS::Cubic_Spline( p1, p2, p3, p4, t, output )
{
	local t2 = t*t;
	local t3 = t*t2;

	// local a = 0;
	local b = t3 * 2.0 - t2 * 3.0 + 1.0;
	local c = t3 * -2.0 + t2 * 3.0;
	// local d = 0;

	output.x = b * p2.x + c * p3.x;
	output.y = b * p2.y + c * p3.y;
	output.z = b * p2.z + c * p3.z;
}

local Cubic_Spline = VS.Cubic_Spline;

function VS::Cubic_Spline_NormalizeX( p1, p2, p3, p4, t, output ) : ( Vector, Spline_Normalize, Cubic_Spline )
{
	local p1n = Vector(), p4n = Vector();
	Spline_Normalize( p1, p2, p3, p4, p1n, p4n );
	return Cubic_Spline( p1n, p2, p3, p4n, t, output );
}

// See link at Kochanek_Bartels_Spline for info on the basis matrix used
function VS::BSpline( p1, p2, p3, p4, t, output )
{
	local th = t*0.166667;
	local t2 = t*th;
	local t3 = t*t2;

	local a = -t3 + t2 * 3.0 - th * 3.0 + 0.166667;
	local b = t3 * 3.0 - t2 * 6.0 + 0.666668; // 4.0 * 0.166667;
	local c = t3 * -3.0 + t2 * 3.0 + th * 3.0 + 0.166667;
	// local d = t3;

	output.x = a * p1.x + b * p2.x + c * p3.x + t3 * p4.x;
	output.y = a * p1.y + b * p2.y + c * p3.y + t3 * p4.y;
	output.z = a * p1.z + b * p2.z + c * p3.z + t3 * p4.z;
}

local BSpline = VS.BSpline;

function VS::BSpline_NormalizeX( p1, p2, p3, p4, t, output ) : ( Vector, Spline_Normalize, BSpline )
{
	local p1n = Vector(), p4n = Vector();
	Spline_Normalize( p1, p2, p3, p4, p1n, p4n );
	return BSpline( p1n, p2, p3, p4n, t, output );
}

// See link at Kochanek_Bartels_Spline for info on the basis matrix used
function VS::Parabolic_Spline( p1, p2, p3, p4, t, output )
{
	local th = t*0.5;
	local t2 = t*th;

	local a = t2 - t + 0.5;
	local b = t2 * -2.0 + t + 0.5;
	// local c = t2;
	// local d = 0;

	output.x = a * p1.x + b * p2.x + t2 * p3.x;
	output.y = a * p1.y + b * p2.y + t2 * p3.y;
	output.z = a * p1.z + b * p2.z + t2 * p3.z;
}

local Parabolic_Spline = VS.Parabolic_Spline;

function VS::Parabolic_Spline_NormalizeX( p1, p2, p3, p4, t, output ) : ( Vector, Spline_Normalize, Parabolic_Spline )
{
	local p1n = Vector(), p4n = Vector();
	Spline_Normalize( p1, p2, p3, p4, p1n, p4n );
	return Parabolic_Spline( p1n, p2, p3, p4n, t, output );
}

//-----------------------------------------------------------------------------
// Purpose: Compress the input values for a ranged result such that from 75% to 200% smoothly of the range maps
//-----------------------------------------------------------------------------
function VS::RangeCompressor( flValue, flMin, flMax, flBase ) : ( fabs, Hermite_SplineF )
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

	local fAbs = fabs(flTarget);

	if( fAbs > 0.75 )
	{
		local t = (fAbs - 0.75) / (1.25);
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

// QAngle, slerp
function VS::InterpolateAngles( v1, v2, flPercent, out ) :
	( Vector, Quaternion, AngleQuaternion, QuaternionAngles, QuaternionSlerp )
{
	// Avoid precision errors
	if( v1 == v2 )
		return v1;

	// Convert to quaternions
	local src = Quaternion();
	AngleQuaternion( v1, src );
	local dest = Quaternion();
	AngleQuaternion( v2, dest );

	// Slerp
	local result = QuaternionSlerp( src, dest, flPercent );

	// Convert to euler
	QuaternionAngles( result, out );
	return out;
}
