//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//-----------------------------------------------------------------------
//
// Advanced math. Mostly sourced from the Source Engine
//
// Not included in 'vs_library.nut'
//
//-----------------------------------------------------------------------

// if already included
if( "AngleQuaternion" in ::VS )
	return;;

const FLT_EPSILON = 1.19209290E-07;;
const FLT_MAX = 1.E+37;;
const FLT_MIN = 1.E-37;;

local vec3_origin = Vector();

class ::Quaternion
{
	x = 0.0;
	y = 0.0;
	z = 0.0;
	w = 0.0;

	constructor( _x = 0.0, _y = 0.0, _z = 0.0, _w = 0.0 )
	{
		x = _x;
		y = _y;
		z = _z;
		w = _w;
	}
}

local Fmt = format;
local Quaternion = Quaternion;

function Quaternion::_add(d):(Quaternion) { return Quaternion( x+d.x,y+d.y,z+d.z,w+d.w ) }
function Quaternion::_sub(d):(Quaternion) { return Quaternion( x-d.x,y-d.y,z-d.z,w-d.w ) }
function Quaternion::_mul(d):(Quaternion) { return Quaternion( x*d,y*d,z*d,w*d ) }
function Quaternion::_div(d):(Quaternion) { return Quaternion( x/d,y/d,z/d,w/d ) }
function Quaternion::_unm() :(Quaternion) { return Quaternion( -x,-y,-z,-w ) }
function Quaternion::_typeof() { return "Quaternion" }
function Quaternion::_tostring():(Fmt) { return Fmt("Quaternion(%g, %g, %g, %g)",x,y,z,w) }


class ::matrix3x4_t
{
	//-----------------------------------------------------------------------------
	// Creates a matrix where the X axis = forward
	// the Y axis = left, and the Z axis = up
	//-----------------------------------------------------------------------------
	constructor( xAxis = vec3_origin, yAxis = vec3_origin, zAxis = vec3_origin, vecOrigin = vec3_origin )
	{
		Init();

		m[0][0] = xAxis.x; m[0][1] = yAxis.x; m[0][2] = zAxis.x; m[0][3] = vecOrigin.x;
		m[1][0] = xAxis.y; m[1][1] = yAxis.y; m[1][2] = zAxis.y; m[1][3] = vecOrigin.y;
		m[2][0] = xAxis.z; m[2][1] = yAxis.z; m[2][2] = zAxis.z; m[2][3] = vecOrigin.z;
	}

	function Init()
	{
		m =	[
				[ 0.0, 0.0, 0.0, 0.0 ],
				[ 0.0, 0.0, 0.0, 0.0 ],
				[ 0.0, 0.0, 0.0, 0.0 ]
			];
	}

	function _typeof() { return "matrix3x4_t" }

	m = null;
}

function matrix3x4_t::_cloned( src )
{
	Init();
	::VS.MatrixCopy( src, this );
}

function matrix3x4_t::_tostring() : (Fmt)
{
	local m = m;
	return Fmt( "[ (%g, %g, %g), (%g, %g, %g), (%g, %g, %g), (%g, %g, %g) ]", m[0][0], m[0][1], m[0][2], m[1][0], m[1][1], m[1][2], m[2][0], m[2][1], m[2][2], m[0][3], m[1][3], m[2][3] );
}


class ::VMatrix extends matrix3x4_t
{
	constructor( xAxis = vec3_origin, yAxis = vec3_origin, zAxis = vec3_origin, vecOrigin = vec3_origin )
	{
		matrix3x4_t.constructor( xAxis, yAxis, zAxis, vecOrigin );
	}

	function Init()
	{
		matrix3x4_t.Init();
		m.resize(4);
		m[3] = [ 0.0, 0.0, 0.0, 1.0 ];
	}

	function Identity()
	{
		m[0][0] = 1.0; m[0][1] = 0.0; m[0][2] = 0.0; m[0][3] = 0.0;
		m[1][0] = 0.0; m[1][1] = 1.0; m[1][2] = 0.0; m[1][3] = 0.0;
		m[2][0] = 0.0; m[2][1] = 0.0; m[2][2] = 1.0; m[2][3] = 0.0;
		m[3][0] = 0.0; m[3][1] = 0.0; m[3][2] = 0.0; m[3][3] = 1.0;
	}

	function _typeof() { return "VMatrix" }
}

function VMatrix::_cloned( src )
{
	Init();
	::VS.MatrixCopy( src, this );
	src = src.m;
	m[3][0] = src[3][0];
	m[3][1] = src[3][1];
	m[3][2] = src[3][2];
	m[3][3] = src[3][3];
}

function VMatrix::_tostring() : (Fmt)
{
	local m = m;
	return Fmt( "[ (%g, %g, %g), (%g, %g, %g), (%g, %g, %g), (%g, %g, %g) ]", m[0][0], m[0][1], m[0][2], m[0][3], m[1][0], m[1][1], m[1][2], m[1][3], m[2][0], m[2][1], m[2][2], m[2][3], m[3][0], m[3][1], m[3][2], m[3][3] );
}


local _VEC = Vector();
local _QUAT = Quaternion();
local Vector = Vector;
local matrix3x4_t = matrix3x4_t;
local VMatrix = VMatrix;
local array = array;
local max = max;
local min = min;
local fabs = fabs;
local sqrt = sqrt;
local sin = sin;
local cos = cos;
local asin = asin;
local acos = acos;
local atan2 = atan2;
local VectorAdd = VS.VectorAdd;
local VectorSubtract = VS.VectorSubtract;
local Line = DebugDrawLine;

function VS::InvRSquared(v):(max)
{
	return 1.0 / max( 1.0, v.LengthSqr() );
}

function VS::a_swap( a1, i1, a2, i2 )
{
	local t = a1[i1];
	a1[i1] = a2[i2];
	a2[i2] = t;
}

local a_swap = VS.a_swap;

// matrix, int, vector
function VS::MatrixRowDotProduct( in1, row, in2 )
{
	in1 = in1.m;
	return in1[row][0] * in2.x + in1[row][1] * in2.y + in1[row][2] * in2.z;
}

function VS::MatrixColumnDotProduct( in1, col, in2 )
{
	in1 = in1.m;
	return in1[0][col] * in2.x + in1[1][col] * in2.y + in1[2][col] * in2.z;
}

function VS::DotProductAbs( in1, in2 ):(fabs)
{
	return fabs(in1.x*in2.x) + fabs(in1.y*in2.y) + fabs(in1.z*in2.z);
}
/*
function VS::DotProductAbsV()

// array X array
function VS::DotProduct( tmp, out[3] )
{
	return tmp[0]*out[0] + tmp[1]*out[1] + tmp[2]*out[2];
}

// vector X array
function VS::DotProductV( tmp, out[3] )
{
	return tmp.x*out[0] + tmp.y*out[1] + tmp.z*out[2];
}
*/

// transform in1 by the matrix in2
function VS::VectorTransform( in1, in2, out = _VEC )
{
	in2 = in2.m;

	// out[0] = DotProductV(in1, in2[0]) + in2[0][3];
	local x = in1.x*in2[0][0] + in1.y*in2[0][1] + in1.z*in2[0][2] + in2[0][3];
	local y = in1.x*in2[1][0] + in1.y*in2[1][1] + in1.z*in2[1][2] + in2[1][3];
	local z = in1.x*in2[2][0] + in1.y*in2[2][1] + in1.z*in2[2][2] + in2[2][3];

	out.x = x;
	out.y = y;
	out.z = z;

	return out;
}

// assuming the matrix is orthonormal, transform in1 by the transpose (also the inverse in this case) of in2.
function VS::VectorITransform( in1, in2, out = _VEC )
{
	in2 = in2.m;

	local in1t0 = in1.x - in2[0][3];
	local in1t1 = in1.y - in2[1][3];
	local in1t2 = in1.z - in2[2][3];

	local x = in1t0 * in2[0][0] + in1t1 * in2[1][0] + in1t2 * in2[2][0];
	local y = in1t0 * in2[0][1] + in1t1 * in2[1][1] + in1t2 * in2[2][1];
	local z = in1t0 * in2[0][2] + in1t1 * in2[1][2] + in1t2 * in2[2][2];

	out.x = x;
	out.y = y;
	out.z = z;

	return out;
}

local VectorITransform = ::VS.VectorITransform;
local VectorTransform = ::VS.VectorTransform;

// assume in2 is a rotation (matrix3x4_t) and rotate the input vector
function VS::VectorRotate( in1, in2, out = _VEC )
{
	in2 = in2.m;

	// out.x = DotProductV( in1, in2[0] );
	local x = in1.x*in2[0][0] + in1.y*in2[0][1] + in1.z*in2[0][2];
	local y = in1.x*in2[1][0] + in1.y*in2[1][1] + in1.z*in2[1][2];
	local z = in1.x*in2[2][0] + in1.y*in2[2][1] + in1.z*in2[2][2];

	out.x = x;
	out.y = y;
	out.z = z;

	return out;
}

local VectorRotate = VS.VectorRotate;

// assume in2 is a rotation (QAngle) and rotate the input vector
function VS::VectorRotate2( in1, in2, out = _VEC ):(matrix3x4_t,VectorRotate)
{
	local matRotate = matrix3x4_t();
	AngleMatrix( in2, null, matRotate );
	VectorRotate( in1, matRotate, out );

	return out;
}

// assume in2 is a rotation (Quaternion) and rotate the input vector
function VS::VectorRotate3( in1, in2, out = _VEC ):(Quaternion)
{
//	local matRotate = matrix3x4_t();
//	QuaternionMatrix( in2, matRotate );
//	VectorRotate( in1, matRotate, out );

	// rotation ( q * v ) * q^-1

	// q^-1
	// QuaternionConjugate
	local conjugate = Quaternion();
	conjugate.x = -in2.x;
	conjugate.y = -in2.y;
	conjugate.z = -in2.z;
	conjugate.w = in2.w;

	// q*v
	// QuaternionMult
	local qv = Quaternion();
	qv.x =  in2.y * in1.z - in2.z * in1.y + in2.w * in1.x;
	qv.y = -in2.x * in1.z + in2.z * in1.x + in2.w * in1.y;
	qv.z =  in2.x * in1.y - in2.y * in1.x + in2.w * in1.z;
	qv.w = -in2.x * in1.x - in2.y * in1.y - in2.z * in1.z;

	out.x =  qv.x * conjugate.w + qv.y * conjugate.z - qv.z * conjugate.y + qv.w * conjugate.x;
	out.y = -qv.x * conjugate.z + qv.y * conjugate.w + qv.z * conjugate.x + qv.w * conjugate.y;
	out.z =  qv.x * conjugate.y - qv.y * conjugate.x + qv.z * conjugate.w + qv.w * conjugate.z;

	return out;
}

// rotate by the inverse of the matrix
function VS::VectorIRotate( in1, in2, out = _VEC )
{
	in2 = in2.m;

	local x = in1.x*in2[0][0] + in1.y*in2[1][0] + in1.z*in2[2][0];
	local y = in1.x*in2[0][1] + in1.y*in2[1][1] + in1.z*in2[2][1];
	local z = in1.x*in2[0][2] + in1.y*in2[1][2] + in1.z*in2[2][2];

	out.x = x;
	out.y = y;
	out.z = z;

	return out;
}

local VectorIRotate = VS.VectorIRotate;
local VectorVectors = VS.VectorVectors;

function VS::VectorMatrix( forward, matrix ) : ( Vector, VectorVectors )
{
	local right = Vector(), up = Vector();
	VectorVectors( forward, right, up );

	matrix = matrix.m;

	// MatrixSetColumn( forward, 0, matrix );
	matrix[0][0] = forward.x;
	matrix[1][0] = forward.y;
	matrix[2][0] = forward.z;

	// MatrixSetColumn( -right, 1, matrix );
	matrix[0][1] = -right.x;
	matrix[1][1] = -right.y;
	matrix[2][1] = -right.z;

	// MatrixSetColumn( up, 2, matrix );
	matrix[0][2] = up.x;
	matrix[1][2] = up.y;
	matrix[2][2] = up.z;
}

function VS::VectorMA( start, scale, direction, dest = _VEC )
{
	dest.x = start.x + scale * direction.x;
	dest.y = start.y + scale * direction.y;
	dest.z = start.z + scale * direction.z;

	return dest;
}

function VS::QuaternionsAreEqual( a, b, tolerance = 0.0 ):(fabs)
{
	return ( fabs( a.x - b.x ) <= tolerance &&
	         fabs( a.y - b.y ) <= tolerance &&
	         fabs( a.z - b.z ) <= tolerance &&
	         fabs( a.w - b.w ) <= tolerance );
}

//-----------------------------------------------------------------------------
// Make sure the quaternion is of unit length
//-----------------------------------------------------------------------------
function VS::QuaternionNormalize(q):(sqrt)
{
	local iradius, radius = q.x*q.x + q.y*q.y + q.z*q.z + q.w*q.w;

	if( radius ) // > FLT_EPSILON && ((radius < 1.0 - 4*FLT_EPSILON) || (radius > 1.0 + 4*FLT_EPSILON))
	{
		radius = sqrt(radius);
		iradius = 1.0/radius;
		q.w *= iradius;
		q.z *= iradius;
		q.y *= iradius;
		q.x *= iradius;
	};

	return radius;
}

//-----------------------------------------------------------------------------
// make sure quaternions are within 180 degrees of one another, if not, reverse q
//-----------------------------------------------------------------------------
function VS::QuaternionAlign( p, q, qt = _QUAT )
{
	// a = dot(p-q)
	// b = dot(p+q)
	local a = (p.x-q.x)*(p.x-q.x)+(p.y-q.y)*(p.y-q.y)+
	          (p.z-q.z)*(p.z-q.z)+(p.w-q.w)*(p.w-q.w),
	      b = (p.x+q.x)*(p.x+q.x)+(p.y+q.y)*(p.y+q.y)+
	          (p.z+q.z)*(p.z+q.z)+(p.w+q.w)*(p.w+q.w);

	if( a > b )
	{
		qt.x = -q.x;
		qt.y = -q.y;
		qt.z = -q.z;
		qt.w = -q.w;
	}
	else if( qt != q )
	{
		qt.x = q.x;
		qt.y = q.y;
		qt.z = q.z;
		qt.w = q.w;
	};;

	return qt;
}

local QuaternionNormalize = VS.QuaternionNormalize;
local QuaternionAlign = VS.QuaternionAlign;

//-----------------------------------------------------------------------------
// qt = p * q
//-----------------------------------------------------------------------------
function VS::QuaternionMult( p, q, qt = _QUAT ):(Quaternion,QuaternionAlign)
{
	if( p == qt )
	{
		local p2 = Quaternion(p.x,p.y,p.z,p.w);
		QuaternionMult( p2, q, qt );
		return qt;
	};

	// decide if one of the quaternions is backwards
	local q2 = QuaternionAlign( p, q );

	qt.x =  p.x * q2.w + p.y * q2.z - p.z * q2.y + p.w * q2.x;
	qt.y = -p.x * q2.z + p.y * q2.w + p.z * q2.x + p.w * q2.y;
	qt.z =  p.x * q2.y - p.y * q2.x + p.z * q2.w + p.w * q2.z;
	qt.w = -p.x * q2.x - p.y * q2.y - p.z * q2.z + p.w * q2.w;

	return qt;
}

local QuaternionMult = VS.QuaternionMult;

function VS::QuaternionConjugate( p, q )
{
	q.x = -p.x;
	q.y = -p.y;
	q.z = -p.z;
	q.w = p.w;
}

//-----------------------------------------------------------------------------
// qt = p * ( s * q )
//-----------------------------------------------------------------------------
function VS::QuaternionMA( p, s, q, qt = _QUAT ):(Quaternion,QuaternionNormalize,QuaternionMult)
{
	local q1 = Quaternion();
	QuaternionScale( q, s, q1 );
	local p1 = QuaternionMult( p, q1 );
	QuaternionNormalize( p1 );

	qt.x = p1.x;
	qt.y = p1.y;
	qt.z = p1.z;
	qt.w = p1.w;

	return qt;
}

function VS::QuaternionAdd( p, q, qt = _QUAT ):(Quaternion,QuaternionAlign)
{
	// decide if one of the quaternions is backwards
	local q2 = QuaternionAlign( p, q );

	// is this right???
	qt.x = p.x + q2.x;
	qt.y = p.y + q2.y;
	qt.z = p.z + q2.z;
	qt.w = p.w + q2.w;

	return qt;
}

function VS::QuaternionDotProduct( p, q )
{
	return p.x * q.x + p.y * q.y + p.z * q.z + p.w * q.w;
}

function VS::QuaternionInvert( p, q )
{
	// QuaternionConjugate
	q.x = -p.x;
	q.y = -p.y;
	q.z = -p.z;
	q.w = p.w;

	// QuaternionDotProduct
	local magnitudeSqr = p.x*p.x + p.y*p.y + p.z*p.z + p.w*p.w;

	if( magnitudeSqr )
	{
		local inv = 1.0 / magnitudeSqr;
		q.x *= inv;
		q.y *= inv;
		q.z *= inv;
		q.w *= inv;

		return;
	};

	Assert( magnitudeSqr );
}

//-----------------------------------------------------------------------------
// Do a piecewise addition of the quaternion elements. This actually makes little
// mathematical sense, but it's a cheap way to simulate a slerp.
// nlerp
//-----------------------------------------------------------------------------
function VS::QuaternionBlendNoAlign( p, q, t, qt = _QUAT ):(QuaternionNormalize)
{
	local sclp = 1.0 - t,
	      sclq = t;

	// 0.0 returns p, 1.0 return q.

	qt.x = sclp * p.x + sclq * q.x;
	qt.y = sclp * p.y + sclq * q.y;
	qt.z = sclp * p.z + sclq * q.z;
	qt.w = sclp * p.w + sclq * q.w;

	QuaternionNormalize( qt );

	return qt;
}

local QuaternionBlendNoAlign = VS.QuaternionBlendNoAlign;

function VS::QuaternionBlend( p, q, t, qt = _QUAT ):(Quaternion,QuaternionAlign)
{
	// decide if one of the quaternions is backwards
	local q2 = QuaternionAlign( p, q );
	QuaternionBlendNoAlign( p, q2, t, qt );
	return qt;
}

function VS::QuaternionIdentityBlend( p, t, qt = _QUAT ):(QuaternionNormalize)
{
	local sclp = 1.0 - t;

	qt.x = p.x * sclp;
	qt.y = p.y * sclp;
	qt.z = p.z * sclp;

	if( qt.w < 0.0 )
	{
		qt.w = p.w * sclp - t;
	}
	else
	{
		qt.w = p.w * sclp + t;
	};

	QuaternionNormalize( qt );

	return qt;
}

//-----------------------------------------------------------------------------
// Quaternion sphereical linear interpolation
//-----------------------------------------------------------------------------
function VS::QuaternionSlerpNoAlign( p, q, t, qt = _QUAT ):(sin,acos)
{
	local omega, cosom, sinom, sclp, sclq;

	// 0.0 returns p, 1.0 return q.

	// QuaternionDotProduct
	cosom = p.x*q.x + p.y*q.y + p.z*q.z + p.w*q.w;

	if( (1.0 + cosom) > 0.000001 )
	{
		if( (1.0 - cosom) > 0.000001 )
		{
			omega = acos( cosom );
			sinom = sin( omega );
			sclp = sin( (1.0 - t)*omega ) / sinom;
			sclq = sin( t*omega ) / sinom;
		}
		else
		{
			// TODO: add short circuit for cosom == 1.0?
			sclp = 1.0 - t;
			sclq = t;
		};

		qt.x = sclp * p.x + sclq * q.x;
		qt.y = sclp * p.y + sclq * q.y;
		qt.z = sclp * p.z + sclq * q.z;
		qt.w = sclp * p.w + sclq * q.w;
	}
	else
	{
		// Assert( qt != q );

		// qt.x = -q.y;
		// qt.y = q.x;
		// qt.z = -q.w;
		// qt.w = q.z;
		sclp = sin( (1.0 - t) * 1.5708 );
		sclq = sin( t * 1.5708 );

		qt.x = sclp * p.x + sclq * qt.x;
		qt.y = sclp * p.y + sclq * qt.y;
		qt.z = sclp * p.z + sclq * qt.z;
		qt.w = q.z;
	};

	return qt;
}

local QuaternionSlerpNoAlign = VS.QuaternionSlerpNoAlign;

function VS::QuaternionSlerp( p, q, t, qt = _QUAT ):(Quaternion,QuaternionAlign,QuaternionSlerpNoAlign)
{
	// 0.0 returns p, 1.0 return q.

	// decide if one of the quaternions is backwards
	local q2 = QuaternionAlign( p, q );

	QuaternionSlerpNoAlign( p, q2, t, qt );

	return qt;
}

//-----------------------------------------------------------------------------
// Purpose: Returns the angular delta between the two normalized quaternions in degrees.
//-----------------------------------------------------------------------------
function VS::QuaternionAngleDiff( p, q ):(Quaternion,QuaternionMult,min,sqrt,asin)
{
// #if(1){
	// this code path is here for 2 reasons:
	// 1 - acos maps 1-epsilon to values much larger than epsilon (vs asin, which maps epsilon to itself)
	//     this means that in floats, anything below ~0.05 degrees truncates to 0
	// 2 - normalized quaternions are frequently slightly non-normalized due to float precision issues,
	//     and the epsilon off of normalized can be several percents of a degree
	local qInv = Quaternion(),
	      diff = Quaternion();

	// QuaternionConjugate( q, qInv );
	qInv.x = -q.x;
	qInv.y = -q.y;
	qInv.z = -q.z;
	qInv.w = q.w;

	QuaternionMult( p, qInv, diff );

	// Note if the quaternion is slightly non-normalized the square root below may be more than 1,
	// the value is clamped to one otherwise it may result in asin() returning an undefined result.
	local sinang = min( 1.0, sqrt(diff.x * diff.x + diff.y * diff.y + diff.z * diff.z) );
	local angle = asin(sinang) * 114.591559026; // RAD2DEG * 2.0
	return angle;
/* #}else{
	local q2 = Quaternion();
	QuaternionAlign( p, q, q2 );
	local cosom = p.x * q2.x + p.y * q2.y + p.z * q2.z + p.w * q2.w;
	if( cosom > -1.0 )
	{
		if( cosom < 1.0 )
		{
			local omega = 2 * fabs( acos( cosom ) );
			return 57.29577951*omega; // RAD2DEG
		}
		return 0.0;
	}
	return 180.0;
}*/
}

function VS::QuaternionScale( p, t, q ) : (Vector,min,sqrt,sin,asin)
{
if(0){
	local p0 = Quaternion();
	local q = Quaternion();
	p0.Init( 0.0, 0.0, 0.0, 1.0 );

	// slerp in "reverse order" so that p doesn't get realigned
	QuaternionSlerp( p, p0, 1.0 - fabs( t ), q );
	if(t < 0.0)
	{
		q.w = -q.w;
	}
} else {
	local r;

	// FIXME: this isn't overly sensitive to accuracy, and it may be faster to
	// use the cos part (w) of the quaternion (sin(omega)*N,cos(omega)) to figure the new scale.

	local qv = Vector(p.x,p.y,p.z);
	local sinom = sqrt( qv.Dot(qv) );

	sinom = min( sinom, 1.0 );

	local sinsom = sin( asin( sinom ) * t );

	t = sinsom / (sinom + FLT_EPSILON);
	local tmp = VectorMultiply( qv, t );
	q.x = tmp.x;
	q.y = tmp.y;
	q.z = tmp.z;

	// rescale rotation
	r = 1.0 - sinsom * sinsom;

	// Assert( r >= 0 );
	if(r < 0.0)
		r = 0.0;
	r = sqrt( r );

	// keep sign of rotation
	if(p.w < 0)
		q.w = -r;
	else
		q.w = r;
}
}

// QAngle , QAngle , Vector, float
function VS::RotationDeltaAxisAngle( srcAngles, destAngles, deltaAxis, deltaAngle ) : (Quaternion)
{
	local srcQuat = Quaternion(),
	      destQuat = Quaternion(),
	      srcQuatInv = Quaternion(),
	      out = Quaternion();
	AngleQuaternion( srcAngles, srcQuat );
	AngleQuaternion( destAngles, destQuat );
	QuaternionScale( srcQuat, -1, srcQuatInv );
	QuaternionMult( destQuat, srcQuatInv, out );

	QuaternionNormalize( out );
	QuaternionAxisAngle( out, deltaAxis, deltaAngle );
}

// QAngle , QAngle , Vector, float
function VS::RotationDelta( srcAngles, destAngles, out ) : ( matrix3x4_t, Vector )
{
	local src = matrix3x4_t(),
	      srcInv = matrix3x4_t(),
	      dest = matrix3x4_t(),
	      xform = matrix3x4_t();

	AngleMatrix( srcAngles, null, src );
	AngleMatrix( destAngles, null, dest );
	// xform = src(-1) * dest
	MatrixInvert( src, srcInv );
	ConcatTransforms( dest, srcInv, xform );

	// xformAngles
	MatrixAngles( dest, out );
}

//-----------------------------------------------------------------------------
// Purpose: Generates Euler angles given a left-handed orientation matrix. The
//			columns of the matrix contain the forward, left, and up vectors.
// Input  : matrix - Left-handed orientation matrix.
//          angles[PITCH, YAW, ROLL]. Receives right-handed counterclockwise
//               rotations in degrees around Y, Z, and X respectively.
//-----------------------------------------------------------------------------
// QAngle
function VS::MatrixAngles( matrix, angles = _VEC, position = null ):(sqrt,atan2)
{
	matrix = matrix.m;

	if( position )
	{
		// MatrixGetColumn( matrix, 3, position );
		position.x = matrix[0][3];
		position.y = matrix[1][3];
		position.z = matrix[2][3];
	};

	//
	// Extract the basis vectors from the matrix. Since we only need the Z
	// component of the up vector, we don't get X and Y.
	//
	local forward0 = matrix[0][0];
	local forward1 = matrix[1][0];
	local forward2 = matrix[2][0];

	local left0    = matrix[0][1];
	local left1    = matrix[1][1];
	local left2    = matrix[2][1];

	local up0      = null;
	local up1      = null;
	local up2      = matrix[2][2];

	local xyDist = sqrt( forward0 * forward0 + forward1 * forward1 );

	// enough here to get angles?
	if( xyDist > 0.001 )
	{
		// (yaw)	y = ATAN( forward[1], forward[0] );		-- in our space, forward is the X axis
		angles.y = 57.29577951*atan2( forward1, forward0 ); // RAD2DEG

		// (pitch)	x = ATAN( -forward[2], sqrt(forward[0]*forward[0]+forward[1]*forward[1]) );
		angles.x = 57.29577951*atan2( -forward2, xyDist );

		// (roll)	z = ATAN( left[2], up[2] );
		angles.z = 57.29577951*atan2( left2, up2 );
	}
	else	// forward is mostly Z, gimbal lock-
	{
		// (yaw)	y = ATAN( -left[0], left[1] );			-- forward is mostly z, so use right for yaw
		angles.y = 57.29577951*atan2( -left0, left1 );

		// (pitch)	x = ATAN( -forward[2], sqrt(forward[0]*forward[0]+forward[1]*forward[1]) );
		angles.x = 57.29577951*atan2( -forward2, xyDist );

		// Assume no roll in this case as one degree of freedom has been lost (i.e. yaw == roll)
		angles.z = 0;
	};

	return angles;
}

function VS::MatrixQuaternionFast( matrix, q )
{
	matrix = matrix.m;
	local trace;
	if ( matrix[2][2] < 0.0 )
	{
		if ( matrix[0][0] > matrix[1][1] )
		{
			trace = 1.0 + matrix[0][0] - matrix[1][1] - matrix[2][2];
			q.x = trace;
			q.y = matrix[0][1] + matrix[1][0];
			q.z = matrix[0][2] + matrix[2][0];
			q.w = matrix[2][1] - matrix[1][2];
		}
		else
		{
			trace = 1.0 - matrix[0][0] + matrix[1][1] - matrix[2][2];
			q.x = matrix[0][1] + matrix[1][0];
			q.y = trace;
			q.z = matrix[2][1] + matrix[1][2];
			q.w = matrix[0][2] - matrix[2][0];
		}
	}
	else
	{
		if ( matrix[0][0] < -matrix[1][1] )
		{
			trace = 1.0 - matrix[0][0] - matrix[1][1] + matrix[2][2];
			q.x = matrix[0][2] + matrix[2][0];
			q.y = matrix[2][1] + matrix[1][2];
			q.z = trace;
			q.w = matrix[1][0] - matrix[0][1]
		}
		else
		{
			trace = 1.0 + matrix[0][0] + matrix[1][1] + matrix[2][2];
			q.x = matrix[2][1] - matrix[1][2];
			q.y = matrix[0][2] - matrix[2][0];
			q.z = matrix[1][0] - matrix[0][1];
			q.w = trace;
		}
	};
	local f = 0.5 / sqrt( trace );
	q.x *= f;
	q.y *= f;
	q.z *= f;
	q.w *= f;
}

local MatrixAngles = VS.MatrixAngles;
local MatrixQuaternionFast = VS.MatrixQuaternionFast;

function VS::QuaternionMatrix( q, pos, matrix )
{
	matrix = matrix.m;

// Original code
// This should produce the same code as below with optimization, but looking at the assmebly,
// it doesn't.  There are 7 extra multiplies in the release build of this, go figure.
// #if(1){
	matrix[0][0] = 1.0 - 2.0 * q.y * q.y - 2.0 * q.z * q.z;
	matrix[1][0] = 2.0 * q.x * q.y + 2.0 * q.w * q.z;
	matrix[2][0] = 2.0 * q.x * q.z - 2.0 * q.w * q.y;

	matrix[0][1] = 2.0 * q.x * q.y - 2.0 * q.w * q.z;
	matrix[1][1] = 1.0 - 2.0 * q.x * q.x - 2.0 * q.z * q.z;
	matrix[2][1] = 2.0 * q.y * q.z + 2.0 * q.w * q.x;

	matrix[0][2] = 2.0 * q.x * q.z + 2.0 * q.w * q.y;
	matrix[1][2] = 2.0 * q.y * q.z - 2.0 * q.w * q.x;
	matrix[2][2] = 1.0 - 2.0 * q.x * q.x - 2.0 * q.y * q.y;

	matrix[0][3] = 0.0;
	matrix[1][3] = 0.0;
	matrix[2][3] = 0.0;
/* #}else{
   float wx, wy, wz, xx, yy, yz, xy, xz, zz, x2, y2, z2;
    // precalculate common multiplitcations
    x2 = q.x + q.x;
	y2 = q.y + q.y;
    z2 = q.z + q.z;
    xx = q.x * x2;
	xy = q.x * y2;
	xz = q.x * z2;
    yy = q.y * y2;
	yz = q.y * z2;
	zz = q.z * z2;
    wx = q.w * x2;
	wy = q.w * y2;
	wz = q.w * z2;
    matrix[0][0] = 1.0 - (yy + zz);
    matrix[0][1] = xy - wz;
	matrix[0][2] = xz + wy;
    matrix[0][3] = 0.0;
    matrix[1][0] = xy + wz;
	matrix[1][1] = 1.0 - (xx + zz);
    matrix[1][2] = yz - wx;
	matrix[1][3] = 0.0;
    matrix[2][0] = xz - wy;
	matrix[2][1] = yz + wx;
    matrix[2][2] = 1.0 - (xx + yy);
	matrix[2][3] = 0.0;
#} */

	if(pos)
	{
		matrix[0][3] = pos.x;
		matrix[1][3] = pos.y;
		matrix[2][3] = pos.z;
	};
}

//-----------------------------------------------------------------------------
// Purpose: Converts a quaternion into engine angles
// Input  : *quaternion - q3 + q0.i + q1.j + q2.k
//          *outAngles - PITCH, YAW, ROLL
//-----------------------------------------------------------------------------
function VS::QuaternionAngles2( q, angles = _VEC ):(asin,atan2)
{
/*# if(1){
	// FIXME: doing it this way calculates too much data, needs to do an optimized version...
	local matrix = matrix3x4_t();
	QuaternionMatrix( q, matrix );
	MatrixAngles( matrix, angles );
#}else{ */
	local m11 = ( 2.0 * q.w * q.w ) + ( 2.0 * q.x * q.x ) - 1.0,
	      m12 = ( 2.0 * q.x * q.y ) + ( 2.0 * q.w * q.z ),
	      m13 = ( 2.0 * q.x * q.z ) - ( 2.0 * q.w * q.y ),
	      m23 = ( 2.0 * q.y * q.z ) + ( 2.0 * q.w * q.x ),
	      m33 = ( 2.0 * q.w * q.w ) + ( 2.0 * q.z * q.z ) - 1.0;
	// FIXME: this code has a singularity near PITCH +-90
	angles.y = 57.29577951*atan2(m12, m11);
	angles.x = 57.29577951*asin(-m13); // RAD2DEG
	angles.z = 57.29577951*atan2(m23, m33);
//#}
	return angles;
}

local QuaternionMatrix = ::VS.QuaternionMatrix;

function VS::QuaternionAngles( q, angles = _VEC ):(matrix3x4_t,QuaternionMatrix,MatrixAngles)
{
	// FIXME: doing it this way calculates too much data, needs to do an optimized version...
	local matrix = matrix3x4_t();
	QuaternionMatrix( q, null, matrix );
	MatrixAngles( matrix, angles );

	return angles;
}

//-----------------------------------------------------------------------------
// Purpose: Converts a quaternion to an axis / angle in degrees
//          (exponential map)
//-----------------------------------------------------------------------------
function VS::QuaternionAxisAngle( q, axis ):(acos)
{
	local angle = acos(q.w)*114.591559026; // RAD2DEG * 2.0

	// AngleNormalize
	if( angle > 180 )
		angle -= 360;

	axis.x = q.x;
	axis.y = q.y;
	axis.z = q.z;
	axis.Norm();

	return angle;
}

//-----------------------------------------------------------------------------
// Purpose: Converts an exponential map (ang/axis) to a quaternion
//-----------------------------------------------------------------------------
function VS::AxisAngleQuaternion( axis, angle, q = _QUAT ):(sin,cos)
{
	angle = angle * 0.008726646; // DEG2RAD / 2.0

	local sa = sin(angle),
	      ca = cos(angle);

	q.x = axis.x * sa;
	q.y = axis.y * sa;
	q.z = axis.z * sa;
	q.w = ca;

	return q;
}

//-----------------------------------------------------------------------------
// Purpose: Converts engine-format euler angles to a quaternion
// Input  : angles - Right-handed Euler angles in degrees as follows:
//              [0]: PITCH: Clockwise rotation around the Y axis.
//              [1]: YAW:	Counterclockwise rotation around the Z axis.
//              [2]: ROLL:	Counterclockwise rotation around the X axis.
//          *outQuat - quaternion of form (i,j,k,real)
//-----------------------------------------------------------------------------
function VS::AngleQuaternion( angles, outQuat = _QUAT ):(sin,cos)
{
	local ay = angles.y * 0.008726646, // DEG2RAD / 2
	      ax = angles.x * 0.008726646,
	      az = angles.z * 0.008726646;

	local sy = sin(ay),
	      cy = cos(ay),

	      sp = sin(ax),
	      cp = cos(ax),

	      sr = sin(az),
	      cr = cos(az);

	local srXcp = sr * cp, crXsp = cr * sp;
	outQuat.x = srXcp*cy-crXsp*sy; // X
	outQuat.y = crXsp*cy+srXcp*sy; // Y

	local crXcp = cr * cp, srXsp = sr * sp;
	outQuat.z = crXcp*sy-srXsp*cy; // Z
	outQuat.w = crXcp*cy+srXsp*sy; // W (real component)

	return outQuat;
}

local AngleQuaternion = VS.AngleQuaternion;

function VS::MatrixQuaternion( mat, q = _QUAT ):(AngleQuaternion,MatrixAngles)
{
	local angles = MatrixAngles( mat );
	AngleQuaternion( angles, q );
	return q;
}

//-----------------------------------------------------------------------------
// Purpose: Converts a basis to a quaternion
//-----------------------------------------------------------------------------
function VS::BasisToQuaternion( vecForward, vecRight, vecUp, q = _QUAT ):(matrix3x4_t,fabs,MatrixQuaternionFast)
{
	Assert( fabs( vecForward.LengthSqr() - 1.0 ) < 1.e-3 );
	Assert( fabs( vecRight.LengthSqr() - 1.0 ) < 1.e-3 );
	Assert( fabs( vecUp.LengthSqr() - 1.0 ) < 1.e-3 );

	// local vecLeft = vecRight;
	local vecLeft = vecRight * -1.0;

	// FIXME: Don't know why, but this doesn't match at all with other result
	// so we can't use this super-fast way.
	/*
	// Find the trace of the matrix:
	local flTrace = vecForward.x + vecLeft.y + vecUp.z + 1.0;
	if( flTrace > 1.e-6 )
	{
		float flSqrtTrace = sqrt( flTrace );
		float s = 0.5 / flSqrtTrace;
		q.x = ( vecUp.y - vecLeft.z ) * s;
		q.y = ( vecForward.z - vecUp.x ) * s;
		q.z = ( vecLeft.x - vecForward.y ) * s;
		q.w = 0.5 * flSqrtTrace;
	}
	else
	{
		if(( vecForward.x > vecLeft.y ) && ( vecForward.x > vecUp.z ) )
		{
			float flSqrtTrace = sqrt( 1.0 + vecForward.x - vecLeft.y - vecUp.z );
			float s = 0.5 / flSqrtTrace;
			q.x = 0.5 * flSqrtTrace;
			q.y = ( vecForward.y + vecLeft.x ) * s;
			q.z = ( vecUp.x + vecForward.z ) * s;
			q.w = ( vecUp.y - vecLeft.z ) * s;
		}
		else if( vecLeft.y > vecUp.z )
		{
			float flSqrtTrace = sqrt( 1.0 + vecLeft.y - vecForward.x - vecUp.z );
			float s = 0.5 / flSqrtTrace;
			q.x = ( vecForward.y + vecLeft.x ) * s;
			q.y = 0.5 * flSqrtTrace;
			q.z = ( vecUp.y + vecLeft.z ) * s;
			q.w = ( vecForward.z - vecUp.x ) * s;
		}
		else
		{
			float flSqrtTrace = sqrt( 1.0 + vecUp.z - vecForward.x - vecLeft.y );
			float s = 0.5 / flSqrtTrace;
			q.x = ( vecUp.x + vecForward.z ) * s;
			q.y = ( vecUp.y + vecLeft.z ) * s;
			q.z = 0.5 * flSqrtTrace;
			q.w = ( vecLeft.x - vecForward.y ) * s;
		}
	}
	QuaternionNormalize( q );
	*/

	// Version 2: Go through angles

	local mat = matrix3x4_t( vecForward, vecLeft, vecUp );

	// mat -> QAng -> Quat
	// local angles = Vector();
	// MatrixAngles( mat, angles );
	// AngleQuaternion( angles, q );

	MatrixQuaternionFast( mat, q );

	// Assert( fabs(q.x - q2.x) < 1.e-3 );
	// Assert( fabs(q.y - q2.y) < 1.e-3 );
	// Assert( fabs(q.z - q2.z) < 1.e-3 );
	// Assert( fabs(q.w - q2.w) < 1.e-3 );

	return q;
}

//-----------------------------------------------------------------------------
// Purpose: converts engine euler angles into a matrix
// Input  : vec3_t angles - PITCH, YAW, ROLL
// Output : *matrix - left-handed column matrix
//          the basis vectors for the rotations will be in the columns as follows:
//          matrix[][0] is forward
//          matrix[][1] is left
//          matrix[][2] is up
//-----------------------------------------------------------------------------
function VS::AngleMatrix( angles, position, matrix ):(sin,cos)
{
	local ay = 0.01745329*angles.y, // DEG2RAD
	      ax = 0.01745329*angles.x,
	      az = 0.01745329*angles.z;

	local sy = sin(ay),
	      cy = cos(ay),

	      sp = sin(ax),
	      cp = cos(ax),

	      sr = sin(az),
	      cr = cos(az);

	matrix = matrix.m;
	// matrix = (YAW * PITCH) * ROLL
	matrix[0][0] = cp*cy;
	matrix[1][0] = cp*sy;
	matrix[2][0] = -sp;

	local crcy = cr*cy,
	      crsy = cr*sy,
	      srcy = sr*cy,
	      srsy = sr*sy;

	matrix[0][1] = sp*srcy-crsy;
	matrix[1][1] = sp*srsy+crcy;
	matrix[2][1] = sr*cp;

	matrix[0][2] = (sp*crcy+srsy);
	matrix[1][2] = (sp*crsy-srcy);
	matrix[2][2] = cr*cp;

	matrix[0][3] = 0.0;
	matrix[1][3] = 0.0;
	matrix[2][3] = 0.0;

	if( position )
	{
		// MatrixSetColumn( position, 3, matrix );
		matrix[0][3] = position.x;
		matrix[1][3] = position.y;
		matrix[2][3] = position.z;
	};
}

function VS::AngleIMatrix( angles, position, matrix ):(sin,cos,VectorRotate)
{
	local ay = 0.01745329*angles.y, // DEG2RAD
	      ax = 0.01745329*angles.x,
	      az = 0.01745329*angles.z;

	local sy = sin(ay),
	      cy = cos(ay),

	      sp = sin(ax),
	      cp = cos(ax),

	      sr = sin(az),
	      cr = cos(az);

	matrix = matrix.m;
	// matrix = (YAW * PITCH) * ROLL
	matrix[0][0] = cp*cy;
	matrix[0][1] = cp*sy;
	matrix[0][2] = -sp;

	matrix[1][0] = sr*sp*cy+cr*-sy;
	matrix[1][1] = sr*sp*sy+cr*cy;
	matrix[1][2] = sr*cp;

	matrix[2][0] = (cr*sp*cy+-sr*-sy);
	matrix[2][1] = (cr*sp*sy+-sr*cy);
	matrix[2][2] = cr*cp;

	matrix[0][3] = 0.0;
	matrix[1][3] = 0.0;
	matrix[2][3] = 0.0;

	if( position )
	{
		local vecTranslation = VectorRotate( position, matrix ) * -1.0;
		// MatrixSetColumn( vecTranslation, 3, matrix );
		matrix[0][3] = vecTranslation.x;
		matrix[1][3] = vecTranslation.y;
		matrix[2][3] = vecTranslation.z;
	};
}

local AngleMatrix = VS.AngleMatrix;
local AngleIMatrix = VS.AngleIMatrix;

// Matrix is right-handed x=forward, y=left, z=up.  Valve uses left-handed convention for vectors in the game code (forward, right, up)
function VS::MatrixVectors( matrix, pForward, pRight, pUp )
{
	matrix = matrix.m;

	// MatrixGetColumn( matrix, 0, pForward );
	pForward.x = matrix[0][0];
	pForward.y = matrix[1][0];
	pForward.z = matrix[2][0];

	// MatrixGetColumn( matrix, 1, pRight );
	pRight.x = matrix[0][1];
	pRight.y = matrix[1][1];
	pRight.z = matrix[2][1];

	// MatrixGetColumn( matrix, 2, pUp );
	pUp.x = matrix[0][2];
	pUp.y = matrix[1][2];
	pUp.z = matrix[2][2];

	// VectorMultiply( pRight, -1.0, pRight );
	pRight.x *= -1.0;
	pRight.y *= -1.0;
	pRight.z *= -1.0;
}

function VS::MatricesAreEqual( src1, src2, flTolerance ):(fabs)
{
	src1 = src1.m;
	src2 = src2.m;

	for( local i = 0; i < 3; ++i )
	{
		for( local j = 0; j < 4; ++j )
		{
			if( fabs( src1[i][j] - src2[i][j] ) > flTolerance )
				return false;
		}
	}
	return true;
}

function VS::MatrixCopy( src, dst )
{
	src = src.m;
	dst = dst.m;

	dst[0][0] = src[0][0];
	dst[0][1] = src[0][1];
	dst[0][2] = src[0][2];
	dst[0][3] = src[0][3];

	dst[1][0] = src[1][0];
	dst[1][1] = src[1][1];
	dst[1][2] = src[1][2];
	dst[1][3] = src[1][3];

	dst[2][0] = src[2][0];
	dst[2][1] = src[2][1];
	dst[2][2] = src[2][2];
	dst[2][3] = src[2][3];
}

// NOTE: This is just the transpose not a general inverse
function VS::MatrixInvert( in1, out ):(a_swap)
{
	in1 = in1.m;
	out = out.m;

	if( in1 == out )
	{
		a_swap(out[0],1,out[1],0);
		a_swap(out[0],2,out[2],0);
		a_swap(out[1],2,out[2],1);
	}
	else
	{
		// transpose the matrix
		out[0][0] = in1[0][0];
		out[0][1] = in1[1][0];
		out[0][2] = in1[2][0];

		out[1][0] = in1[0][1];
		out[1][1] = in1[1][1];
		out[1][2] = in1[2][1];

		out[2][0] = in1[0][2];
		out[2][1] = in1[1][2];
		out[2][2] = in1[2][2];
	};

	// now fix up the translation to be in the other space
	local tmp0 = in1[0][3];
	local tmp1 = in1[1][3];
	local tmp2 = in1[2][3];

	// -DotProduct( tmp, out[0] );
	out[0][3] = -(tmp0*out[0][0] + tmp1*out[0][1] + tmp2*out[0][2]);
	out[1][3] = -(tmp0*out[1][0] + tmp1*out[1][1] + tmp2*out[1][2]);
	out[2][3] = -(tmp0*out[2][0] + tmp1*out[2][1] + tmp2*out[2][2]);
}

function VS::MatrixInverseGeneral( src, dst ) : ( array, fabs )
{
	local iRow, i, j, iTemp, iTest;
	local mul, fTest, fLargest;

	local mat = array( 4 );
	for ( local i = 4; i--; )
		mat[i] = array( 8, 0.0 );

	local rowMap = array( 4, 0 ), iLargest;
	local pOut, pRow, pScaleRow;

	// How it's done.
	// AX = I
	// A = this
	// X = the matrix we're looking for
	// I = identity

	src = src.m;

	// Setup AI
	for( i = 0; i < 4; i++ )
	{
		local pIn = src[i];
		pOut = mat[i];

		pOut[0] = pIn[0];
		pOut[1] = pIn[1];
		pOut[2] = pIn[2];
		pOut[3] = pIn[3];
		pOut[4] = 0.0;
		pOut[5] = 0.0;
		pOut[6] = 0.0;
		pOut[7] = 0.0;
		pOut[i+4] = 1.0;

		rowMap[i] = i;
	}

	// Use row operations to get to reduced row-echelon form using these rules:
	// 1. Multiply or divide a row by a nonzero number.
	// 2. Add a multiple of one row to another.
	// 3. Interchange two rows.

	for(iRow=0; iRow < 4; iRow++)
	{
		// Find the row with the largest element in this column.
		fLargest = 0.00001;
		iLargest = -1;
		for(iTest=iRow; iTest < 4; iTest++)
		{
			fTest = fabs(mat[rowMap[iTest]][iRow]);
			if(fTest > fLargest)
			{
				iLargest = iTest;
				fLargest = fTest;
			}
		}

		// They're all too small.. sorry.
		if(iLargest == -1)
			return false;

		// Swap the rows.
		iTemp = rowMap[iLargest];
		rowMap[iLargest] = rowMap[iRow];
		rowMap[iRow] = iTemp;

		pRow = mat[rowMap[iRow]];

		// Divide this row by the element.
		mul = 1.0 / pRow[iRow];
			pRow[0] *= mul;
			pRow[1] *= mul;
			pRow[2] *= mul;
			pRow[3] *= mul;
			pRow[4] *= mul;
			pRow[5] *= mul;
			pRow[6] *= mul;
			pRow[7] *= mul;

		pRow[iRow] = 1.0; // Preserve accuracy...

		// Eliminate this element from the other rows using operation 2.
		for(i=0; i < 4; i++)
		{
			if(i == iRow)
				continue;

			pScaleRow = mat[rowMap[i]];

			// Multiply this row by -(iRow*the element).
			mul = -pScaleRow[iRow];
				pScaleRow[0] += pRow[0] * mul;
				pScaleRow[1] += pRow[1] * mul;
				pScaleRow[2] += pRow[2] * mul;
				pScaleRow[3] += pRow[3] * mul;
				pScaleRow[4] += pRow[4] * mul;
				pScaleRow[5] += pRow[5] * mul;
				pScaleRow[6] += pRow[6] * mul;
				pScaleRow[7] += pRow[7] * mul;

			pScaleRow[iRow] = 0.0; // Preserve accuracy...
		}
	}

	dst = dst.m;

	// The inverse is on the right side of AX now (the identity is on the left).
	for(i=0; i < 4; i++)
	{
		local pIn = mat[rowMap[i]];
		pOut = dst[i];
			pOut[0] = pIn[0 + 4];
			pOut[1] = pIn[1 + 4];
			pOut[2] = pIn[2 + 4];
			pOut[3] = pIn[3 + 4];
	}

	return true;
}

function VS::MatrixGetColumn( in1, column, out = _VEC )
{
	in1 = in1.m;

	out.x = in1[0][column];
	out.y = in1[1][column];
	out.z = in1[2][column];

	return out;
}

function VS::MatrixSetColumn( in1, column, out )
{
	out = out.m;

	out[0][column] = in1.x;
	out[1][column] = in1.y;
	out[2][column] = in1.z;
}

function VS::MatrixScaleBy( flScale, out )
{
	out = out.m;

	out[0][0] *= flScale;
	out[1][0] *= flScale;
	out[2][0] *= flScale;
	out[0][1] *= flScale;
	out[1][1] *= flScale;
	out[2][1] *= flScale;
	out[0][2] *= flScale;
	out[1][2] *= flScale;
	out[2][2] *= flScale;
}

function VS::MatrixScaleByZero( out )
{
	out = out.m;

	out[0][0] = 0.0;
	out[1][0] = 0.0;
	out[2][0] = 0.0;
	out[0][1] = 0.0;
	out[1][1] = 0.0;
	out[2][1] = 0.0;
	out[0][2] = 0.0;
	out[1][2] = 0.0;
	out[2][2] = 0.0;
}

function VS::SetIdentityMatrix( matrix )
{
	// SetScaleMatrix( 1.0, 1.0, 1.0, matrix );

	matrix = matrix.m;

	matrix[0][0] = 1.0; matrix[0][1] = 0.0; matrix[0][2] = 0.0; matrix[0][3] = 0.0;
	matrix[1][0] = 0.0; matrix[1][1] = 1.0; matrix[1][2] = 0.0; matrix[1][3] = 0.0;
	matrix[2][0] = 0.0; matrix[2][1] = 0.0; matrix[2][2] = 1.0; matrix[2][3] = 0.0;
}

//-----------------------------------------------------------------------------
// Builds a scale matrix
//-----------------------------------------------------------------------------
function VS::SetScaleMatrix( x, y, z, dst )
{
	dst = dst.m;

	dst[0][0] = x;   dst[0][1] = 0.0; dst[0][2] = 0.0; dst[0][3] = 0.0;
	dst[1][0] = 0.0; dst[1][1] = y;   dst[1][2] = 0.0; dst[1][3] = 0.0;
	dst[2][0] = 0.0; dst[2][1] = 0.0; dst[2][2] = z;   dst[2][3] = 0.0;
}

//-----------------------------------------------------------------------------
// Compute a matrix that has the correct orientation but which has an origin at
// the center of the bounds
//-----------------------------------------------------------------------------
function VS::ComputeCenterMatrix( origin, angles, mins, maxs, matrix ):(VectorRotate,AngleMatrix)
{
	local centroid = (mins + maxs)*0.5;
	AngleMatrix( angles, null, matrix );

	local worldCentroid = VectorRotate( centroid, matrix ) + origin;

	// MatrixSetColumn( worldCentroid, 3, matrix );
	matrix = matrix.m;
	matrix[0][3] = worldCentroid.x;
	matrix[1][3] = worldCentroid.y;
	matrix[2][3] = worldCentroid.z;
}

function VS::ComputeCenterIMatrix( origin, angles, mins, maxs, matrix ):(VectorRotate,AngleIMatrix)
{
	local centroid = (mins + maxs)*-0.5;
	AngleIMatrix( angles, null, matrix );

	// For the translational component here, note that the origin in world space
	// is T = R * C + O, (R = rotation matrix, C = centroid in local space, O = origin in world space)
	// The IMatrix translation = - transpose(R) * T = -C - transpose(R) * 0
	local localOrigin = VectorRotate( origin, matrix );
	centroid -= localOrigin;

	// MatrixSetColumn( centroid, 3, matrix );
	matrix = matrix.m;
	matrix[0][3] = centroid.x;
	matrix[1][3] = centroid.y;
	matrix[2][3] = centroid.z;
}

//-----------------------------------------------------------------------------
// Compute a matrix which is the absolute value of another
//-----------------------------------------------------------------------------
function VS::ComputeAbsMatrix( in1, out ):(fabs)
{
	in1 = in1.m;
	out = out.m;

	out[0][0] = fabs(in1[0][0]);
	out[0][1] = fabs(in1[0][1]);
	out[0][2] = fabs(in1[0][2]);
	out[1][0] = fabs(in1[1][0]);
	out[1][1] = fabs(in1[1][1]);
	out[1][2] = fabs(in1[1][2]);
	out[2][0] = fabs(in1[2][0]);
	out[2][1] = fabs(in1[2][1]);
	out[2][2] = fabs(in1[2][2]);
}

function VS::ConcatRotations( in1, in2, out )
{
	// Assert( in1 != out );
	// Assert( in2 != out );

	in1 = in1.m;
	in2 = in2.m;
	out = out.m;

	out[0][0] = in1[0][0] * in2[0][0] + in1[0][1] * in2[1][0] + in1[0][2] * in2[2][0];
	out[0][1] = in1[0][0] * in2[0][1] + in1[0][1] * in2[1][1] + in1[0][2] * in2[2][1];
	out[0][2] = in1[0][0] * in2[0][2] + in1[0][1] * in2[1][2] + in1[0][2] * in2[2][2];

	out[1][0] = in1[1][0] * in2[0][0] + in1[1][1] * in2[1][0] + in1[1][2] * in2[2][0];
	out[1][1] = in1[1][0] * in2[0][1] + in1[1][1] * in2[1][1] + in1[1][2] * in2[2][1];
	out[1][2] = in1[1][0] * in2[0][2] + in1[1][1] * in2[1][2] + in1[1][2] * in2[2][2];

	out[2][0] = in1[2][0] * in2[0][0] + in1[2][1] * in2[1][0] + in1[2][2] * in2[2][0];
	out[2][1] = in1[2][0] * in2[0][1] + in1[2][1] * in2[1][1] + in1[2][2] * in2[2][1];
	out[2][2] = in1[2][0] * in2[0][2] + in1[2][1] * in2[1][2] + in1[2][2] * in2[2][2];
}

// matrix3x4_t multiply
function VS::ConcatTransforms( in1, in2, out )
{
	in1 = in1.m;
	in2 = in2.m;
	out = out.m;

	local m00 = in1[0][0] * in2[0][0] + in1[0][1] * in2[1][0] + in1[0][2] * in2[2][0];
	local m01 = in1[0][0] * in2[0][1] + in1[0][1] * in2[1][1] + in1[0][2] * in2[2][1];
	local m02 = in1[0][0] * in2[0][2] + in1[0][1] * in2[1][2] + in1[0][2] * in2[2][2];
	local m03 = in1[0][0] * in2[0][3] + in1[0][1] * in2[1][3] + in1[0][2] * in2[2][3];

	local m10 = in1[1][0] * in2[0][0] + in1[1][1] * in2[1][0] + in1[1][2] * in2[2][0];
	local m11 = in1[1][0] * in2[0][1] + in1[1][1] * in2[1][1] + in1[1][2] * in2[2][1];
	local m12 = in1[1][0] * in2[0][2] + in1[1][1] * in2[1][2] + in1[1][2] * in2[2][2];
	local m13 = in1[1][0] * in2[0][3] + in1[1][1] * in2[1][3] + in1[1][2] * in2[2][3];

	local m20 = in1[2][0] * in2[0][0] + in1[2][1] * in2[1][0] + in1[2][2] * in2[2][0];
	local m21 = in1[2][0] * in2[0][1] + in1[2][1] * in2[1][1] + in1[2][2] * in2[2][1];
	local m22 = in1[2][0] * in2[0][2] + in1[2][1] * in2[1][2] + in1[2][2] * in2[2][2];
	local m23 = in1[2][0] * in2[0][3] + in1[2][1] * in2[1][3] + in1[2][2] * in2[2][3];

	out[0][0] = m00;
	out[0][1] = m01;
	out[0][2] = m02;
	out[0][3] = m03;

	out[1][0] = m10;
	out[1][1] = m11;
	out[1][2] = m12;
	out[1][3] = m13;

	out[2][0] = m20;
	out[2][1] = m21;
	out[2][2] = m22;
	out[2][3] = m23;
}

// VMatrix multiply
function VS::MatrixMultiply( in1, in2, out )
{
	in1 = in1.m;
	in2 = in2.m;
	out = out.m;

	local m00 = in1[0][0] * in2[0][0] + in1[0][1] * in2[1][0] + in1[0][2] * in2[2][0] + in1[0][3] * in2[3][0];
	local m01 = in1[0][0] * in2[0][1] + in1[0][1] * in2[1][1] + in1[0][2] * in2[2][1] + in1[0][3] * in2[3][1];
	local m02 = in1[0][0] * in2[0][2] + in1[0][1] * in2[1][2] + in1[0][2] * in2[2][2] + in1[0][3] * in2[3][2];
	local m03 = in1[0][0] * in2[0][3] + in1[0][1] * in2[1][3] + in1[0][2] * in2[2][3] + in1[0][3] * in2[3][3];

	local m10 = in1[1][0] * in2[0][0] + in1[1][1] * in2[1][0] + in1[1][2] * in2[2][0] + in1[1][3] * in2[3][0];
	local m11 = in1[1][0] * in2[0][1] + in1[1][1] * in2[1][1] + in1[1][2] * in2[2][1] + in1[1][3] * in2[3][1];
	local m12 = in1[1][0] * in2[0][2] + in1[1][1] * in2[1][2] + in1[1][2] * in2[2][2] + in1[1][3] * in2[3][2];
	local m13 = in1[1][0] * in2[0][3] + in1[1][1] * in2[1][3] + in1[1][2] * in2[2][3] + in1[1][3] * in2[3][3];

	local m20 = in1[2][0] * in2[0][0] + in1[2][1] * in2[1][0] + in1[2][2] * in2[2][0] + in1[2][3] * in2[3][0];
	local m21 = in1[2][0] * in2[0][1] + in1[2][1] * in2[1][1] + in1[2][2] * in2[2][1] + in1[2][3] * in2[3][1];
	local m22 = in1[2][0] * in2[0][2] + in1[2][1] * in2[1][2] + in1[2][2] * in2[2][2] + in1[2][3] * in2[3][2];
	local m23 = in1[2][0] * in2[0][3] + in1[2][1] * in2[1][3] + in1[2][2] * in2[2][3] + in1[2][3] * in2[3][3];

	local m30 = in1[3][0] * in2[0][0] + in1[3][1] * in2[1][0] + in1[3][2] * in2[2][0] + in1[3][3] * in2[3][0];
	local m31 = in1[3][0] * in2[0][1] + in1[3][1] * in2[1][1] + in1[3][2] * in2[2][1] + in1[3][3] * in2[3][1];
	local m32 = in1[3][0] * in2[0][2] + in1[3][1] * in2[1][2] + in1[3][2] * in2[2][2] + in1[3][3] * in2[3][2];
	local m33 = in1[3][0] * in2[0][3] + in1[3][1] * in2[1][3] + in1[3][2] * in2[2][3] + in1[3][3] * in2[3][3];

	out[0][0] = m00;
	out[0][1] = m01;
	out[0][2] = m02;
	out[0][3] = m03;

	out[1][0] = m10;
	out[1][1] = m11;
	out[1][2] = m12;
	out[1][3] = m13;

	out[2][0] = m20;
	out[2][1] = m21;
	out[2][2] = m22;
	out[2][3] = m23;

	out[3][0] = m30;
	out[3][1] = m31;
	out[3][2] = m32;
	out[3][3] = m33;
}

/*
function VS::MatrixRotate( dst, vAxisOfRot, angleDegrees )
{
	local tmpRot = VMatrix();
	MatrixBuildRotationAboutAxis( vAxisOfRot, angleDegrees, tmpRot );
	MatrixMultiply( dst, tmpRot, dst );
}

function VS::MatrixTranslate( dst, vecTranslation )
{
	local matTranslation = VMatrix();
	MatrixSetColumn( vecTranslation, 3, matTranslation );
	MatrixMultiply( dst, matTranslation, dst );
}
*/

//-----------------------------------------------------------------------------
// Purpose: Builds the matrix for a counterclockwise rotation about an arbitrary axis.
//
//         | ax2 + (1 - ax2)cosQ        axay(1 - cosQ) - azsinQ     azax(1 - cosQ) + aysinQ |
// Ra(Q) = | axay(1 - cosQ) + azsinQ    ay2 + (1 - ay2)cosQ         ayaz(1 - cosQ) - axsinQ |
//         | azax(1 - cosQ) - aysinQ    ayaz(1 - cosQ) + axsinQ     az2 + (1 - az2)cosQ     |
//
// Input  :
//          Vector vAxisOrRot -
//          float angle -
//          matrix3x4_t mat -
//-----------------------------------------------------------------------------
function VS::MatrixBuildRotationAboutAxis( vAxisOfRot, angleDegrees, dst ) : ( sin, cos )
{
	local radians = angleDegrees * 0.01745329; // DEG2RAD
	local fSin = sin( radians ),
	      fCos = cos( radians );

	local axisXSquared = vAxisOfRot.x * vAxisOfRot.x,
	      axisYSquared = vAxisOfRot.y * vAxisOfRot.y,
	      axisZSquared = vAxisOfRot.z * vAxisOfRot.z;

	dst = dst.m;

	dst[0][0] = axisXSquared + (1.0 - axisXSquared) * fCos;
	dst[1][0] = vAxisOfRot.x * vAxisOfRot.y * (1.0 - fCos) + vAxisOfRot.z * fSin;
	dst[2][0] = vAxisOfRot.z * vAxisOfRot.x * (1.0 - fCos) - vAxisOfRot.y * fSin;

	dst[0][1] = vAxisOfRot.x * vAxisOfRot.y * (1.0 - fCos) - vAxisOfRot.z * fSin;
	dst[1][1] = axisYSquared + (1.0 - axisYSquared) * fCos;
	dst[2][1] = vAxisOfRot.y * vAxisOfRot.z * (1.0 - fCos) + vAxisOfRot.x * fSin;

	dst[0][2] = vAxisOfRot.z * vAxisOfRot.x * (1.0 - fCos) + vAxisOfRot.y * fSin;
	dst[1][2] = vAxisOfRot.y * vAxisOfRot.z * (1.0 - fCos) - vAxisOfRot.x * fSin;
	dst[2][2] = axisZSquared + (1.0 - axisZSquared) * fCos;

	dst[0][3] = 0.0;
	dst[1][3] = 0.0;
	dst[2][3] = 0.0;
}

//-----------------------------------------------------------------------------
// Builds a rotation matrix that rotates one direction vector into another
//
// Input  : matrix
//          Vector
//          Vector
//-----------------------------------------------------------------------------
function VS::MatrixBuildRotation( dst, initialDirection, finalDirection ) : ( Vector, fabs, acos )
{
	local angle = initialDirection.Dot( finalDirection );
	// Assert( IsFinite(angle) );

	local axis = Vector();

	// No rotation required
	if( angle - 1.0 > -1.e-3 )
	{
		// parallel case
		SetIdentityMatrix(dst);
		return;
	}
	else if( angle + 1.0 < 1.e-3 )
	{
		// antiparallel case, pick any axis in the plane
		// perpendicular to the final direction. Choose the direction (x,y,z)
		// which has the minimum component of the final direction, use that
		// as an initial guess, then subtract out the component which is
		// parallel to the final direction
		local idx = "x";
		if( fabs(finalDirection.y) < fabs(finalDirection[idx]) )
			idx = "y";
		if( fabs(finalDirection.z) < fabs(finalDirection[idx]) )
			idx = "z";

		axis[idx] = 1.0;

		VectorMA( axis, -(axis.Dot(finalDirection)), finalDirection, axis );
		axis.Norm();
		angle = 180.0;
	}
	else
	{
		axis = initialDirection.Cross(finalDirection);
		axis.Norm();
		angle = acos(angle) * 57.29577951; // RAD2DEG
	};

	MatrixBuildRotationAboutAxis( axis, angle, dst );

/*#ifdef _DEBUG
	local test = Vector();
	Vector3DMultiply( initialDirection, test, dst );
	test -= finalDirection;
	Assert( test.LengthSqr() < 1e-3 );
#endif*/
}

//-----------------------------------------------------------------------------
// Matrix/vector multiply
//
// Input  : matrix
//          Vector
//          Vector
//-----------------------------------------------------------------------------
function VS::Vector3DMultiply( src1, src2, dst )
{
	src1 = src1.m;
	local x = src1[0][0] * src2.x + src1[0][1] * src2.y + src1[0][2] * src2.z;
	local y = src1[1][0] * src2.x + src1[1][1] * src2.y + src1[1][2] * src2.z;
	local z = src1[2][0] * src2.x + src1[2][1] * src2.y + src1[2][2] * src2.z;

	dst.x = x;
	dst.y = y;
	dst.z = z;
}

//-----------------------------------------------------------------------------
// Vector3DMultiplyProjective treats src2 as if it's a direction
// and does the perspective divide at the end
//
// Input  : VMatrix
//          Vector
//          Vector
//-----------------------------------------------------------------------------
function VS::Vector3DMultiplyProjective( src1, src2, dst )
{
	src1 = src1.m;
	local invw = 1.0 / ( src1[3][0] * src2.x + src1[3][1] * src2.y + src1[3][2] * src2.z );
	local x = invw   * ( src1[0][0] * src2.x + src1[0][1] * src2.y + src1[0][2] * src2.z );
	local y = invw   * ( src1[1][0] * src2.x + src1[1][1] * src2.y + src1[1][2] * src2.z );
	local z = invw   * ( src1[2][0] * src2.x + src1[2][1] * src2.y + src1[2][2] * src2.z );

	dst.x = x;
	dst.y = y;
	dst.z = z;
}

//-----------------------------------------------------------------------------
// Vector3DMultiplyPositionProjective treats src2 as if it's a point
// and does the perspective divide at the end
//
// Input  : VMatrix
//          Vector
//          Vector
//-----------------------------------------------------------------------------
function VS::Vector3DMultiplyPositionProjective( src1, src2, dst )
{
	src1 = src1.m;
	local invw = 1.0  / ( src1[3][0] * src2.x + src1[3][1] * src2.y + src1[3][2] * src2.z + src1[3][3] );
	local x    = invw * ( src1[0][0] * src2.x + src1[0][1] * src2.y + src1[0][2] * src2.z + src1[0][3] );
	local y    = invw * ( src1[1][0] * src2.x + src1[1][1] * src2.y + src1[1][2] * src2.z + src1[1][3] );
	local z    = invw * ( src1[2][0] * src2.x + src1[2][1] * src2.y + src1[2][2] * src2.z + src1[2][3] );

	dst.x = x;
	dst.y = y;
	dst.z = z;
}

//-----------------------------------------------------------------------------
// Transforms a AABB into another space; which will inherently grow the box.
//-----------------------------------------------------------------------------
function VS::TransformAABB( transform, vecMinsIn, vecMaxsIn, vecMinsOut, vecMaxsOut ):(Vector,fabs,VectorAdd,VectorSubtract,VectorTransform)
{
	local localCenter = (vecMinsIn + vecMaxsIn) * 0.5;

	local localExtents = vecMaxsIn - localCenter;

	local worldCenter = VectorTransform( localCenter, transform );

	transform = transform.m;

	local worldExtents = Vector( fabs(localExtents.x*transform[0][0]) +
	                             fabs(localExtents.y*transform[0][1]) +
	                             fabs(localExtents.z*transform[0][2]),

	                             fabs(localExtents.x*transform[1][0]) +
	                             fabs(localExtents.y*transform[1][1]) +
	                             fabs(localExtents.z*transform[1][2]),

	                             fabs(localExtents.x*transform[2][0]) +
	                             fabs(localExtents.y*transform[2][1]) +
	                             fabs(localExtents.z*transform[2][2]) );

	VectorSubtract( worldCenter, worldExtents, vecMinsOut );
	VectorAdd( worldCenter, worldExtents, vecMaxsOut );
}

//-----------------------------------------------------------------------------
// Uses the inverse transform of in1
//-----------------------------------------------------------------------------
function VS::ITransformAABB( transform, vecMinsIn, vecMaxsIn, vecMinsOut, vecMaxsOut ):(Vector,fabs,VectorAdd,VectorSubtract,VectorITransform)
{
	local worldCenter = (vecMinsIn + vecMaxsIn) * 0.5;

	local worldExtents = vecMaxsIn - worldCenter;

	local localCenter = VectorITransform( worldCenter, transform );

	transform = transform.m;

	local localExtents = Vector( fabs( worldExtents.x * transform[0][0] ) +
	                             fabs( worldExtents.y * transform[1][0] ) +
	                             fabs( worldExtents.z * transform[2][0] ),

	                             fabs( worldExtents.x * transform[0][1] ) +
	                             fabs( worldExtents.y * transform[1][1] ) +
	                             fabs( worldExtents.z * transform[2][1] ),

	                             fabs( worldExtents.x * transform[0][2] ) +
	                             fabs( worldExtents.y * transform[1][2] ) +
	                             fabs( worldExtents.z * transform[2][2] ) );

	VectorSubtract( localCenter, localExtents, vecMinsOut );
	VectorAdd( localCenter, localExtents, vecMaxsOut );
}

//-----------------------------------------------------------------------------
// Rotates a AABB into another space; which will inherently grow the box.
// (same as TransformAABB, but doesn't take the translation into account)
//-----------------------------------------------------------------------------
function VS::RotateAABB( transform, vecMinsIn, vecMaxsIn, vecMinsOut, vecMaxsOut ):(Vector,fabs,VectorAdd,VectorSubtract,VectorRotate)
{
	local localCenter = (vecMinsIn + vecMaxsIn) * 0.5;

	local localExtents = vecMaxsIn - localCenter;

	local newCenter = VectorRotate( localCenter, transform );

	transform = transform.m;

	local newExtents = Vector( fabs(localExtents.x*transform[0][0]) +
	                           fabs(localExtents.y*transform[0][1]) +
	                           fabs(localExtents.z*transform[0][2]),

	                           fabs(localExtents.x*transform[1][0]) +
	                           fabs(localExtents.y*transform[1][1]) +
	                           fabs(localExtents.z*transform[1][2]),

	                           fabs(localExtents.x*transform[2][0]) +
	                           fabs(localExtents.y*transform[2][1]) +
	                           fabs(localExtents.z*transform[2][2]) );

	VectorSubtract( newCenter, newExtents, vecMinsOut );
	VectorAdd( newCenter, newExtents, vecMaxsOut );
}

//-----------------------------------------------------------------------------
// Uses the inverse transform of in1
//-----------------------------------------------------------------------------
function VS::IRotateAABB( transform, vecMinsIn, vecMaxsIn, vecMinsOut, vecMaxsOut ):(Vector,fabs,VectorAdd,VectorSubtract,VectorIRotate)
{
	local oldCenter = (vecMinsIn + vecMaxsIn) * 0.5;

	local oldExtents = vecMaxsIn - oldCenter;

	local newCenter = VectorIRotate( oldCenter, transform );

	transform = transform.m;

	local newExtents = Vector( fabs( oldExtents.x * transform[0][0] ) +
	                           fabs( oldExtents.y * transform[1][0] ) +
	                           fabs( oldExtents.z * transform[2][0] ),

	                           fabs( oldExtents.x * transform[0][1] ) +
	                           fabs( oldExtents.y * transform[1][1] ) +
	                           fabs( oldExtents.z * transform[2][1] ),

	                           fabs( oldExtents.x * transform[0][2] ) +
	                           fabs( oldExtents.y * transform[1][2] ) +
	                           fabs( oldExtents.z * transform[2][2] ) );

	VectorSubtract( newCenter, newExtents, vecMinsOut );
	VectorAdd( newCenter, newExtents, vecMaxsOut );
}

//
// Get the vertices of a rotated box.
//
// +z
// ^   +y
// |  /
// | /
//    ----> +x
//
//    3-------7
//   /|      /|
//  / |     / |
// 1--2----5  6
// | /     | /
// |/      |/
// 0-------4
//
function VS::GetBoxVertices( origin, angles, mins, maxs, pVerts ) : ( matrix3x4_t, Vector, VectorAdd, VectorRotate )
{
	local rotation = matrix3x4_t();
	AngleMatrix( angles, null, rotation );

	//for ( local i = 8; i--; )
	//{
	//	local v = pVerts[i];
	//	v.x = ( i & 0x1 ) ? maxs.x : mins.x;
	//	v.y = ( i & 0x2 ) ? maxs.y : mins.y;
	//	v.z = ( i & 0x4 ) ? maxs.z : mins.z;
	//	VectorRotate( v, rotation, v );
	//	VectorAdd( v, origin, v );
	//}

	local v;
	v = pVerts[0];
	v.x = mins.x;
	v.y = mins.y;
	v.z = mins.z;
	VectorRotate( v, rotation, v );
	VectorAdd( v, origin, v );
	v = pVerts[1];
	v.x = maxs.x;
	v.y = mins.y;
	v.z = mins.z;
	VectorRotate( v, rotation, v );
	VectorAdd( v, origin, v );
	v = pVerts[2];
	v.x = mins.x;
	v.y = maxs.y;
	v.z = mins.z;
	VectorRotate( v, rotation, v );
	VectorAdd( v, origin, v );
	v = pVerts[3];
	v.x = maxs.x;
	v.y = maxs.y;
	v.z = mins.z;
	VectorRotate( v, rotation, v );
	VectorAdd( v, origin, v );
	v = pVerts[4];
	v.x = mins.x;
	v.y = mins.y;
	v.z = maxs.z;
	VectorRotate( v, rotation, v );
	VectorAdd( v, origin, v );
	v = pVerts[5];
	v.x = maxs.x;
	v.y = mins.y;
	v.z = maxs.z;
	VectorRotate( v, rotation, v );
	VectorAdd( v, origin, v );
	v = pVerts[6];
	v.x = mins.x;
	v.y = maxs.y;
	v.z = maxs.z;
	VectorRotate( v, rotation, v );
	VectorAdd( v, origin, v );
	v = pVerts[7];
	v.x = maxs.x;
	v.y = maxs.y;
	v.z = maxs.z;
	VectorRotate( v, rotation, v );
	VectorAdd( v, origin, v );
}


//-----------------------------------------------------------------------------
// Build a perspective matrix.
// zNear and zFar are assumed to be positive.
// You end up looking down positive Z, X is to the right, Y is up.
// X range: [0..1]
// Y range: [0..1]
// Z range: [0..1]
//-----------------------------------------------------------------------------
function VS::MatrixBuildPerspective( dst, fovX, fovY, zNear, zFar ) : ( tan, VMatrix )
{
	// memset( dst.Base(), 0, sizeof( dst ) );
	local m = dst.m;
	MatrixScaleByZero( dst );
	m[3][0] = 0.0; m[3][1] = 0.0; m[3][2] = 0.0; m[3][3] = 0.0;

	local width  = tan( fovX * 0.008726646 );	// DEG2RAD * 0.5
	local height = tan( fovY * 0.008726646 );	// DEG2RAD * 0.5
	local zz = zFar / ( zNear - zFar );
	m[0][0]  = 1.0 / width;
	m[1][1]  = 1.0 / height;
	m[2][2] = -zz;
	m[3][2] = 1.0;
	m[2][3] = zNear * zz;

	// negate X and Y so that X points right, and Y points up.
	local negateXY = VMatrix();
	SetIdentityMatrix( negateXY );
	m = negateXY.m;
	m[0][0] = -1.0;
	m[1][1] = -1.0;
	MatrixMultiply( negateXY, dst, dst );

	local addW = VMatrix();
	SetIdentityMatrix( addW );
	m = addW.m;
	m[0][3] = 1.0;
	m[1][3] = 1.0;
	m[2][3] = 0.0;
	MatrixMultiply( addW, dst, dst );

	local scaleHalf = VMatrix();
	SetIdentityMatrix( scaleHalf );
	m = scaleHalf.m;
	m[0][0] = 0.5;
	m[1][1] = 0.5;
	MatrixMultiply( scaleHalf, dst, dst );
}

/*
function VS::MatrixBuildPerspectiveX( dst, flFovX, flAspect, flZNear, flZFar )
{
	local flWidthScale = 1.0 / tan( flFovX * DEG2RAD );
	local flHeightScale = flAspect * flWidthScale;

	dst = dst.m;

	dst[0][0] = flWidthScale;
	dst[0][1] = 0.0;
	dst[0][2] = 0.0;
	dst[0][3] = 0.0;

	dst[1][0] = 0.0;
	dst[1][1] = flHeightScale;
	dst[1][2] = 0.0;
	dst[1][3] = 0.0;

	local zz = flZFar / ( flZNear - flZFar );
	dst[2][0] = 0.0;
	dst[2][1] = 0.0;
	dst[2][2] = zz;
	dst[2][3] = flZNear * zz;

	dst[3][0] = 0.0;
	dst[3][1] = 0.0;
	dst[3][2] = -1.0;
	dst[3][3] = 0.0;
}
*/

function VS::ComputeViewMatrix( pWorldToView, origin, forward, left, up ) : ( Vector, matrix3x4_t, VMatrix )
{
	local m;
	local transform = matrix3x4_t();

	// AngleMatrix( angles, origin, transform );
	MatrixSetColumn( forward, 0, transform );
	MatrixSetColumn( left, 1, transform );
	MatrixSetColumn( up, 2, transform );
	MatrixSetColumn( origin, 3, transform );

	local matRotate = VMatrix();
	MatrixCopy( transform, matRotate );

	local matRotateZ = VMatrix();
	MatrixBuildRotationAboutAxis( Vector(0,0,1), -90, matRotateZ );
	MatrixMultiply( matRotate, matRotateZ, matRotate );

	local matRotateX = VMatrix();
	MatrixBuildRotationAboutAxis( Vector(1,0,0), 90, matRotateX );
	MatrixMultiply( matRotate, matRotateX, matRotate );

	MatrixCopy( matRotate, transform );

	// local invTransform = matrix3x4_t();
	MatrixInvert( transform, transform );

	MatrixCopy( transform, pWorldToView );
}

function VS::ScreenToWorld( x, y, origin, forward, right, up, fov, flAspect, zFar ) : (Vector, VMatrix)
{
	// FIXME: why is this offset?
	x += 0.25;
	y -= 0.25;

	local vecScreen = Vector( 2.0 * x - 1.0, 1.0 - 2.0 * y, 1.0 );

	local viewToProj = VMatrix();
	MatrixBuildPerspective( viewToProj, fov, CalcFovY( fov, flAspect ), 1.0, zFar );

	// AngleVectors( angles, forward, right, up );

	local worldToView = VMatrix();
	ComputeCameraVariables(
		origin,
		forward,
		right * -1.0,
		up * -1.0,
		worldToView );

	local worldToProj = viewToProj; // VMatrix();
	MatrixMultiply( viewToProj, worldToView, worldToProj );

	local screenToWorld = worldToView; // VMatrix();
	MatrixInverseGeneral( worldToProj, screenToWorld );

	local worldPos = Vector();
	Vector3DMultiplyPositionProjective( screenToWorld, vecScreen, worldPos );

	return worldPos;
}

//-----------------------------------------------------------------------------
// Computes Y fov from an X fov and a screen aspect ratio
//-----------------------------------------------------------------------------
function VS::CalcFovY( flFovX, flAspect ) : ( tan, atan )
{
	if ( flFovX < 1.0 || flFovX > 179.0)
		flFovX = 90.0;

	local val = atan( tan( 0.008726646 * flFovX ) / flAspect );		// DEG2RAD * 0.5
	val = 114.591559026*val;	// RAD2DEG * 2.0
	return val;
}

function VS::CalcFovX( flFovY, flAspect ) : ( tan, atan )
{
	return 114.591559026 * atan( tan( 0.008726646* flFovY ) * flAspect );	// DEG2RAD * 0.5 , RAD2DEG * 2.0
}

function VS::ComputeCameraVariables( vecOrigin, pVecForward, pVecRight, pVecUp, pMatCamInverse )
{
	pMatCamInverse = pMatCamInverse.m;

	pMatCamInverse[0][0] = pVecRight.x;
	pMatCamInverse[1][0] = pVecUp.x;
	pMatCamInverse[2][0] = pVecForward.x;
	pMatCamInverse[3][0] = 0.0;

	pMatCamInverse[0][1] = pVecRight.y;
	pMatCamInverse[1][1] = pVecUp.y;
	pMatCamInverse[2][1] = pVecForward.y;
	pMatCamInverse[3][1] = 0.0;

	pMatCamInverse[0][2] = pVecRight.z;
	pMatCamInverse[1][2] = pVecUp.z;
	pMatCamInverse[2][2] = pVecForward.z;
	pMatCamInverse[3][2] = 0.0;

	pMatCamInverse[0][3] = -pVecRight.Dot( vecOrigin );
	pMatCamInverse[1][3] = -pVecUp.Dot( vecOrigin );
	pMatCamInverse[2][3] = -pVecForward.Dot( vecOrigin );
	pMatCamInverse[3][3] = 1.0;
}

local initFrustumDraw = function() : (vec3_origin)
{
	local Vector = Vector;
	local VMatrix = VMatrix;
	local Line = DebugDrawLine;
	local Vector3DMultiplyPositionProjective = VS.Vector3DMultiplyPositionProjective;
	local MatrixInverseGeneral = VS.MatrixInverseGeneral;
	local MatrixBuildPerspective = VS.MatrixBuildPerspective;
	local CalcFovY = VS.CalcFovY;

	local startWorldSpace = Vector(), endWorldSpace = Vector();

	local draw = function( startLocalSpace, endLocalSpace, mat, r, g, b, z, t ) :
		( Vector, Vector3DMultiplyPositionProjective, Line, startWorldSpace, endWorldSpace )
	{
		Vector3DMultiplyPositionProjective( mat, startLocalSpace, startWorldSpace );
		Vector3DMultiplyPositionProjective( mat, endLocalSpace, endWorldSpace );

		return Line( startWorldSpace, endWorldSpace, r, g, b, z, t );
	}

	local v000 = vec3_origin;
	local v001 = Vector( 0.0, 0.0, 1.0 );
	local v011 = Vector( 0.0, 1.0, 1.0 );
	local v010 = Vector( 0.0, 1.0, 0.0 );
	local v010 = Vector( 0.0, 1.0, 0.0 );
	local v100 = Vector( 1.0, 0.0, 0.0 );
	local v101 = Vector( 1.0, 0.0, 1.0 );
	local v111 = Vector( 1.0, 1.0, 1.0 );
	local v110 = Vector( 1.0, 1.0, 0.0 );
	local frustum = [
		v000, v001,
		v001, v011,
		v011, v010,
		v010, v000,
		v100, v101,
		v101, v111,
		v111, v110,
		v110, v100,
		v000, v100,
		v001, v101,
		v011, v111,
		v010, v110
	];

	local matViewToWorld = VMatrix();

	function VS::DrawFrustum( matWorldToView, r, g, b, z, t ) : ( MatrixInverseGeneral, draw, frustum, matViewToWorld )
	{
		MatrixInverseGeneral( matWorldToView, matViewToWorld );

		draw( frustum[0], frustum[1], matViewToWorld, r, g, b, z, t );
		draw( frustum[2], frustum[3], matViewToWorld, r, g, b, z, t );
		draw( frustum[4], frustum[5], matViewToWorld, r, g, b, z, t );
		draw( frustum[6], frustum[7], matViewToWorld, r, g, b, z, t );
		draw( frustum[8], frustum[9], matViewToWorld, r, g, b, z, t );
		draw( frustum[10], frustum[11], matViewToWorld, r, g, b, z, t );
		draw( frustum[12], frustum[13], matViewToWorld, r, g, b, z, t );
		draw( frustum[14], frustum[15], matViewToWorld, r, g, b, z, t );
		draw( frustum[16], frustum[17], matViewToWorld, r, g, b, z, t );
		draw( frustum[18], frustum[19], matViewToWorld, r, g, b, z, t );
		draw( frustum[20], frustum[21], matViewToWorld, r, g, b, z, t );
		draw( frustum[22], frustum[23], matViewToWorld, r, g, b, z, t );
	}

	local DrawFrustum = VS.DrawFrustum;

	function VS::DrawViewFrustum( vecOrigin, vecForward, vecRight, vecUp,
		flFovX, flFovY, zNear, zFar, r, g, b, z, time ) :
			( VMatrix, MatrixBuildPerspective, CalcFovY, ComputeCameraVariables, MatrixMultiply, DrawFrustum )
	{
		local mat = VMatrix();
		MatrixBuildPerspective( mat, flFovX, flFovY, zNear, zFar ); // matPerspective

		local matInvCam = VMatrix();
		ComputeCameraVariables( vecOrigin, vecForward, vecRight, vecUp, matInvCam );

		MatrixMultiply( mat, matInvCam, mat ); // matWorldToView

		return DrawFrustum( mat, r, g, b, z, time );
	}
}

function VS::DrawFrustum( matrix, r, g, b, z, t ) : (initFrustumDraw)
{
	initFrustumDraw();
	return DrawFrustum( matrix, r, g, b, z, t );
}

function VS::DrawViewFrustum( vecOrigin, vecForward, vecRight, vecUp,
		flFovX, flFovY, zNear, zFar, r, g, b, z, time ) : (initFrustumDraw)
{
	initFrustumDraw();
	return DrawViewFrustum( vecOrigin, vecForward, vecRight, vecUp,
		flFovX, flFovY, zNear, zFar, r, g, b, z, time );
}

local initBoxDraw = function() : (vec3_origin)
{
	local Box = DebugDrawBox;
	local Line = DebugDrawLine;
	local Vector = Vector;
	local matrix3x4_t = matrix3x4_t;
	local GetBoxVertices = VS.GetBoxVertices;
	local verts = [ Vector(), Vector(), Vector(), Vector(),
			Vector(), Vector(), Vector(), Vector() ];

	//-----------------------------------------------------------------------
	// Draws an oriented box at the origin.
	// Specify mins and maxs in local space.
	//-----------------------------------------------------------------------
	function VS::DrawBoxAngles( origin, mins, maxs, angles, r, g, b, z, time ) : ( verts, GetBoxVertices, Line )
	{
		GetBoxVertices( origin, angles, mins, maxs, verts );
		local v0 = verts[0], v1 = verts[1], v2 = verts[2], v3 = verts[3];
		local v4 = verts[4], v5 = verts[5], v6 = verts[6], v7 = verts[7];

		Line( v0, v1, r, g, b, z, time );
		Line( v0, v2, r, g, b, z, time );
		Line( v1, v3, r, g, b, z, time );
		Line( v2, v3, r, g, b, z, time );

		Line( v0, v4, r, g, b, z, time );
		Line( v1, v5, r, g, b, z, time );
		Line( v2, v6, r, g, b, z, time );
		Line( v3, v7, r, g, b, z, time );

		Line( v5, v7, r, g, b, z, time );
		Line( v5, v4, r, g, b, z, time );
		Line( v4, v6, r, g, b, z, time );
		Line( v7, v6, r, g, b, z, time );
	}

	//-----------------------------------------------------------------------
	// Draw bounds of an entity
	//-----------------------------------------------------------------------
	function VS::DrawEntityBounds( ent, r, g, b, z, time ) : ( Box )
	{
		local origin = ent.GetOrigin();
		local angles = ent.GetAngles();
		local mins = ent.GetBoundingMins();
		local maxs = ent.GetBoundingMaxs();

		if ( !angles.x && !angles.y && !angles.z )
		{
			Box( origin, mins, maxs, r, g, b, 0, time );
		}
		else
		{
			DrawBoxAngles( origin, mins, maxs, angles, r, g, b, z, time );
		}
	}
}

function VS::DrawBoxAngles( origin, mins, maxs, angles, r, g, b, z, time ) : ( initBoxDraw )
{
	initBoxDraw();
	return DrawBoxAngles( origin, mins, maxs, angles, r, g, b, z, time );
}

function VS::DrawEntityBounds( ent, r, g, b, z, time ) : ( initBoxDraw )
{
	initBoxDraw();
	return DrawEntityBounds( ent, r, g, b, z, time );
}

function VS::DrawSphere( vCenter, flRadius, nTheta, nPhi, r, g, b, z, time ) : ( array, Vector, sin, cos, Line )
{
	// Make one more coordinate because (u,v) is discontinuous.
	++nTheta;

	// local nIndices = ( nTheta - 1 ) * 4 * ( nPhi - 1 );
	local pVerts = array( nPhi * nTheta );

	local i, j, c = 0;
	for ( i = 0; i < nPhi; ++i )
	{
		for ( j = 0; j < nTheta; ++j )
		{
			local u = j / ( nTheta - 1 ).tofloat();
			local v = i / ( nPhi - 1 ).tofloat();
			local theta = 6.28318548 * u;	// 2 * PI
			local phi = 3.14159265 * v;		// PI
			local sp = flRadius * sin(phi);

			pVerts[c++] = ( Vector(
				vCenter.x + ( sp * cos(theta) ),
				vCenter.y + ( sp * sin(theta) ),
				vCenter.z + ( flRadius * cos(phi) ) ) );
		}
	}

	for ( i = 0; i < nPhi - 1; ++i )
	{
		for ( j = 0; j < nTheta - 1; ++j )
		{
			local idx = nTheta * i + j;

			Line( pVerts[idx], pVerts[idx+nTheta], r, g, b, z, time );
			Line( pVerts[idx], pVerts[idx+1], r, g, b, z, time );
		}
	}
}

local initCapsule = function()
{
	local Line = DebugDrawLine;
	local Vector = Vector;
	local matrix3x4_t = matrix3x4_t;

	local g_capsuleVertPositions = [
		[ -0.01, -0.01, 1.0 ],	[ 0.51, 0.0, 0.86 ],	[ 0.44, 0.25, 0.86 ],	[ 0.25, 0.44, 0.86 ],
		[ -0.01, 0.51, 0.86 ],	[ -0.26, 0.44, 0.86 ],	[ -0.45, 0.25, 0.86 ],	[ -0.51, 0.0, 0.86 ],
		[ -0.45, -0.26, 0.86 ],	[ -0.26, -0.45, 0.86 ],	[ -0.01, -0.51, 0.86 ],	[ 0.25, -0.45, 0.86 ],
		[ 0.44, -0.26, 0.86 ],	[ 0.86, 0.0, 0.51 ],	[ 0.75, 0.43, 0.51 ],	[ 0.43, 0.75, 0.51 ],
		[ -0.01, 0.86, 0.51 ],	[ -0.44, 0.75, 0.51 ],	[ -0.76, 0.43, 0.51 ],	[ -0.87, 0.0, 0.51 ],
		[ -0.76, -0.44, 0.51 ],	[ -0.44, -0.76, 0.51 ],	[ -0.01, -0.87, 0.51 ],	[ 0.43, -0.76, 0.51 ],
		[ 0.75, -0.44, 0.51 ],	[ 1.0, 0.0, 0.01 ],		[ 0.86, 0.5, 0.01 ],	[ 0.49, 0.86, 0.01 ],
		[ -0.01, 1.0, 0.01 ],	[ -0.51, 0.86, 0.01 ],	[ -0.87, 0.5, 0.01 ],	[ -1.0, 0.0, 0.01 ],
		[ -0.87, -0.5, 0.01 ],	[ -0.51, -0.87, 0.01 ],	[ -0.01, -1.0, 0.01 ],	[ 0.49, -0.87, 0.01 ],
		[ 0.86, -0.51, 0.01 ],	[ 1.0, 0.0, -0.02 ],	[ 0.86, 0.5, -0.02 ],	[ 0.49, 0.86, -0.02 ],
		[ -0.01, 1.0, -0.02 ],	[ -0.51, 0.86, -0.02 ],	[ -0.87, 0.5, -0.02 ],	[ -1.0, 0.0, -0.02 ],
		[ -0.87, -0.5, -0.02 ],	[ -0.51, -0.87, -0.02 ],[ -0.01, -1.0, -0.02 ],	[ 0.49, -0.87, -0.02 ],
		[ 0.86, -0.51, -0.02 ],	[ 0.86, 0.0, -0.51 ],	[ 0.75, 0.43, -0.51 ],	[ 0.43, 0.75, -0.51 ],
		[ -0.01, 0.86, -0.51 ],	[ -0.44, 0.75, -0.51 ],	[ -0.76, 0.43, -0.51 ],	[ -0.87, 0.0, -0.51 ],
		[ -0.76, -0.44, -0.51 ],[ -0.44, -0.76, -0.51 ],[ -0.01, -0.87, -0.51 ],[ 0.43, -0.76, -0.51 ],
		[ 0.75, -0.44, -0.51 ],	[ 0.51, 0.0, -0.87 ],	[ 0.44, 0.25, -0.87 ],	[ 0.25, 0.44, -0.87 ],
		[ -0.01, 0.51, -0.87 ],	[ -0.26, 0.44, -0.87 ],	[ -0.45, 0.25, -0.87 ],	[ -0.51, 0.0, -0.87 ],
		[ -0.45, -0.26, -0.87 ],[ -0.26, -0.45, -0.87 ],[ -0.01, -0.51, -0.87 ],[ 0.25, -0.45, -0.87 ],
		[ 0.44, -0.26, -0.87 ],	[ 0.0, 0.0, -1.0 ]
	];

	local g_capsuleLineIndices = [ -1,
		14,		0,	4,	16,	28,	40,	52,	64,	73,	70,	58,	46,	34,	22,	10,		-1,
		14,		0,	1,	13,	25,	37,	49,	61,	73,	67,	55,	43,	31,	19,	7,		-1,
		12,		61,	62,	63,	64,	65,	66,	67,	68,	69,	70,	71,	72,				-1,
		12,		49,	50,	51,	52,	53,	54,	55,	56,	57,	58,	59,	60,				-1,
		12,		37,	38,	39,	40,	41,	42,	43,	44,	45,	46,	47,	48,				-1,
		12,		25,	26,	27,	28,	29,	30,	31,	32,	33,	34,	35,	36,				-1,
		12,		13,	14,	15,	16,	17,	18,	19,	20,	21,	22,	23,	24,				-1,
		12,		1,	2,	3,	4,	5,	6,	7,	8,	9,	10,	11,	12,				-1
	];

	local g_capsuleVerts = array(74);
	local matCapsuleRotationSpace = matrix3x4_t();
	VectorMatrix( Vector(0,0,1), matCapsuleRotationSpace );

	//-----------------------------------------------------------------------
	// Draws a capsule at world origin.
	//-----------------------------------------------------------------------
	function VS::DrawCapsule( start, end, radius, r, g, b, z, time ) : ( g_capsuleVertPositions, g_capsuleLineIndices, g_capsuleVerts, matCapsuleRotationSpace, Line, Vector, matrix3x4_t )
	{
		local vecCapsuleCoreNormal = start - end;
		local vecLen = end - start;
		vecCapsuleCoreNormal.Norm();

		local matCapsuleSpace = matrix3x4_t();
		VectorMatrix( vecCapsuleCoreNormal, matCapsuleSpace );

		for ( local i = 0; i < 74; ++i )
		{
			local vert = Vector( g_capsuleVertPositions[i][0], g_capsuleVertPositions[i][1], g_capsuleVertPositions[i][2] );

			VectorRotate( vert, matCapsuleRotationSpace, vert );
			VectorRotate( vert, matCapsuleSpace, vert );

			vert *= radius;

			if ( g_capsuleVertPositions[i][2] > 0 )
			{
				vert += vecLen;
			};
			g_capsuleVerts[i] = vert + start;
		}

		local i = 0;
		while ( i < 117 )
		{
			local i0 = g_capsuleLineIndices[i];
			if ( i0 == -1 )
			{
				i += 2;
				continue;
			};

			local i1 = g_capsuleLineIndices[++i];
			if ( i1 == -1 )
			{
				i += 2;
				if ( i > 116 )
					break;
				continue;
			};

			local v0 = g_capsuleVerts[ i0 ]
			local v1 = g_capsuleVerts[ i1 ]
			Line( v0, v1, r, g, b, z, time )
		}
	}
}

function VS::DrawCapsule( start, end, radius, r, g, b, z, time ) : ( initCapsule )
{
	initCapsule();
	return DrawCapsule( start, end, radius, r, g, b, z, time );
}


return; //=========================================================================

class ::cplane_t
{
	normal = null;
	dist = 0.0;
	type = 0;			// for fast side tests
	signbits = 0;		// signx + (signy<<1) + (signz<<1)
	pad = array( 2, 0 );
}

local SignbitsForPlane = function( out )
{
	local bits = 0;
	local normal = out.normal;

	// for fast box on planeside test
	if ( normal.x < 0.0 )
		bits = bits | 1; //1<<0;
	if ( normal.y < 0.0 )
		bits = bits | 2; //1<<1;
	if ( normal.z < 0.0 )
		bits = bits | 4; //1<<2;

	return bits;
}

// 0-2 are axial planes
const PLANE_X			= 0;;
const PLANE_Y			= 1;;
const PLANE_Z			= 2;;
// 3-5 are non-axial planes snapped to the nearest
const PLANE_ANYX		= 3;;
const PLANE_ANYY		= 4;;
const PLANE_ANYZ		= 5;;
// Frustum plane indices.
const FRUSTUM_RIGHT		= 0;;
const FRUSTUM_LEFT		= 1;;
const FRUSTUM_TOP		= 2;;
const FRUSTUM_BOTTOM	= 3;;
const FRUSTUM_NEARZ		= 4;;
const FRUSTUM_FARZ		= 5;;
const FRUSTUM_NUMPLANES	= 6;;

class ::Frustum_t
{
	constructor()
	{
		for ( local i = 6; i--; )
		{
			m_Plane[i] = cplane_t();
			m_AbsNormal[i] = Vector();
		}
	}

	function SetPlane( i, nType, vecNormal, dist ) : ( SignbitsForPlane )
	{
		local plane = m_Plane[i];
		plane.normal = vecNormal;
		plane.dist = dist;
		plane.type = nType;
		plane.signbits = SignbitsForPlane( plane );
		local normal = m_AbsNormal[i];
		normal.x = fabs( vecNormal.x );
		normal.y = fabs( vecNormal.y );
		normal.z = fabs( vecNormal.z );
	}

	m_Plane = array(6);
	m_AbsNormal = array(6);
}

//-----------------------------------------------------------------------------
// Generate a frustum based on perspective view parameters
//-----------------------------------------------------------------------------
function VS::GeneratePerspectiveFrustum( origin, angles, flZNear, flZFar, flFovX, flAspectRatio, frustum )
{
	local vecForward = Vector(), vecRight = Vector(), vecUp = Vector();
	AngleVectors( angles, vecForward, vecRight, vecUp );
	local flFovY = CalcFovY( flFovX, flAspectRatio );
	local flIntercept = origin.Dot( forward );

	// Setup the near and far planes.
	frustum.SetPlane( FRUSTUM_FARZ, PLANE_ANYZ, -forward, -flZFar - flIntercept );
	frustum.SetPlane( FRUSTUM_NEARZ, PLANE_ANYZ, forward, flZNear + flIntercept );

	flFovX *= 0.5;
	flFovY *= 0.5;

	local flTanX = tan( DEG2RAD*( flFovX ) );
	local flTanY = tan( DEG2RAD*( flFovY ) );

	local normalPos = Vector(), normalNeg = Vector();

	VectorMA( right, flTanX, forward, normalPos );
	VectorMA( normalPos, -2.0, right, normalNeg );

	normalPos.Norm();
	normalNeg.Norm();

	frustum.SetPlane( FRUSTUM_LEFT, PLANE_ANYZ, normalPos, normalPos.Dot( origin ) );
	frustum.SetPlane( FRUSTUM_RIGHT, PLANE_ANYZ, normalNeg, normalNeg.Dot( origin ) );

	VectorMA( up, flTanY, forward, normalPos );
	VectorMA( normalPos, -2.0, up, normalNeg );

	normalPos.Norm();
	normalNeg.Norm();

	frustum.SetPlane( FRUSTUM_BOTTOM, PLANE_ANYZ, normalPos, normalPos.Dot( origin ) );
	frustum.SetPlane( FRUSTUM_TOP, PLANE_ANYZ, normalNeg, normalNeg.Dot( origin ) );
}
