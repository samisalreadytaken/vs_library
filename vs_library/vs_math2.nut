//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//
//                       github.com/samisalreadytaken
//
// This project is licensed under the terms of the MIT License.
// See <README.md> or <LICENSE> for details.
//-----------------------------------------------------------------------
//
// Advanced math. Mostly sourced from 'Source SDK'
//
// Not included in 'vs_library.nut'
//
//-----------------------------------------------------------------------

const FLT_EPSILON = 1.19209290E-07;;
const FLT_MAX = 1.E+37;;
const FLT_MIN = 1.E-37;;

class::Quaternion
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
/*
	function Init( _x = 0.0, _y = 0.0, _z = 0.0, _w = 0.0 )
	{
		constructor(_x,_y,_z,_w);
	}
*/
	function _add(d) { return::Quaternion( x+d.x,y+d.y,z+d.z,w+d.w ) }
	function _sub(d) { return::Quaternion( x-d.x,y-d.y,z-d.z,w-d.w ) }
	function _mul(d) { return::Quaternion( x*d,y*d,z*d,w*d ) }
	function _div(d) { return::Quaternion( x/d,y/d,z/d,w/d ) }
	function _unm()  { return::Quaternion( -x,-y,-z,-w ) }
	function _typeof() { return "Quaternion" }
	function _tostring() { return "Quaternion("+x+","+y+","+z+","+w+")" }
}

class::matrix3x4
{
	//-----------------------------------------------------------------------------
	// Creates a matrix where the X axis = forward
	// the Y axis = left, and the Z axis = up
	//-----------------------------------------------------------------------------
	constructor( xAxis =::Vector(), yAxis =::Vector(), zAxis =::Vector(), vecOrigin =::Vector() )
	{
		Init();

		m_flMatVal[0][0] = xAxis.x; m_flMatVal[0][1] = yAxis.x; m_flMatVal[0][2] = zAxis.x; m_flMatVal[0][3] = vecOrigin.x;
		m_flMatVal[1][0] = xAxis.y; m_flMatVal[1][1] = yAxis.y; m_flMatVal[1][2] = zAxis.y; m_flMatVal[1][3] = vecOrigin.y;
		m_flMatVal[2][0] = xAxis.z; m_flMatVal[2][1] = yAxis.z; m_flMatVal[2][2] = zAxis.z; m_flMatVal[2][3] = vecOrigin.z;
	}

	function Init()
	{
		m_flMatVal    =::array(3);
		m_flMatVal[0] =::array(4,0);
		m_flMatVal[1] =::array(4,0);
		m_flMatVal[2] =::array(4,0);
	}

	function _typeof() { return "matrix3x4_t" }
	function _tostring() { return "matrix3x4_t" }

	m_flMatVal = null;
}

// matrix4x4
// class VMatrix{}

local _VEC =::Vector();
local _QUAT =::Quaternion();

function VS::InvRSquared( v )
{
	return 1.0 / max( 1.0, v.LengthSqr() );
}

function VS::a_swap( a1, i1, a2, i2 )
{
	local t = a1[i1];
	a1[i1] = a2[i2];
	a2[i2] = t;
}

// matrix, int, vector
function VS::MatrixRowDotProduct( in1, row, in2 )
{
	in1 = in1.m_flMatVal;
	return in1[row][0] * in2.x + in1[row][1] * in2.y + in1[row][2] * in2.z;
}

function VS::MatrixColumnDotProduct( in1, col, in2 )
{
	in1 = in1.m_flMatVal;
	return in1[0][col] * in2.x + in1[1][col] * in2.y + in1[2][col] * in2.z;
}

function VS::DotProductAbs( in1, in2 )
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
	// Assert( in1 != out );
	in2 = in2.m_flMatVal;

	// out[0] = DotProductV(in1, in2[0]) + in2[0][3];
	out.x = in1.x*in2[0][0] + in1.y*in2[0][1] + in1.z*in2[0][2] + in2[0][3];
	out.y = in1.x*in2[1][0] + in1.y*in2[1][1] + in1.z*in2[1][2] + in2[1][3];
	out.z = in1.x*in2[2][0] + in1.y*in2[2][1] + in1.z*in2[2][2] + in2[2][3];

	return out;
}

// assuming the matrix is orthonormal, transform in1 by the transpose (also the inverse in this case) of in2.
function VS::VectorITransform( in1, in2, out = _VEC )
{
	in2 = in2.m_flMatVal;

	local in1t = [ in1.x - in2[0][3],
	               in1.y - in2[1][3],
	               in1.z - in2[2][3] ];

	out.x = in1t[0] * in2[0][0] + in1t[1] * in2[1][0] + in1t[2] * in2[2][0];
	out.y = in1t[0] * in2[0][1] + in1t[1] * in2[1][1] + in1t[2] * in2[2][1];
	out.z = in1t[0] * in2[0][2] + in1t[1] * in2[1][2] + in1t[2] * in2[2][2];

	return out;
}

// assume in2 is a rotation (matrix3x4) and rotate the input vector
function VS::VectorRotate( in1, in2, out = _VEC )
{
	// Assert( in1 != out );
	in2 = in2.m_flMatVal;

	// out.x = DotProductV( in1, in2[0] );
	out.x = in1.x*in2[0][0] + in1.y*in2[0][1] + in1.z*in2[0][2];
	out.y = in1.x*in2[1][0] + in1.y*in2[1][1] + in1.z*in2[1][2];
	out.z = in1.x*in2[2][0] + in1.y*in2[2][1] + in1.z*in2[2][2];

	return out;
}

// assume in2 is a rotation (QAngle) and rotate the input vector
function VS::VectorRotate2( in1, in2, out = _VEC )
{
	local matRotate = matrix3x4();
	AngleMatrix2( in2, matRotate );
	VectorRotate( in1, matRotate, out );

	return out;
}

// assume in2 is a rotation (Quaternion) and rotate the input vector
function VS::VectorRotate3( in1, in2, out = _VEC )
{
	local matRotate = matrix3x4();
	QuaternionMatrix2( in2, matRotate );
	VectorRotate( in1, matRotate, out );

	return out;
}

// rotate by the inverse of the matrix
function VS::VectorIRotate( in1, in2, out = _VEC )
{
	// Assert( in1 != out );
	in2 = in2.m_flMatVal;

	out.x = in1.x*in2[0][0] + in1.y*in2[1][0] + in1.z*in2[2][0];
	out.y = in1.x*in2[0][1] + in1.y*in2[1][1] + in1.z*in2[2][1];
	out.z = in1.x*in2[0][2] + in1.y*in2[1][2] + in1.z*in2[2][2];

	return out;
}

function VS::VectorMA( start, scale, direction, dest = _VEC )
{
	dest.x = start.x + scale * direction.x;
	dest.y = start.y + scale * direction.y;
	dest.z = start.z + scale * direction.z;

	return dest;
}

function VS::VectorNegate( vec )
{
	vec.x = -vec.x;
	vec.y = -vec.y;
	vec.z = -vec.z;

	return vec;
}

function VS::QuaternionsAreEqual( a, b, tolerance = 0.0 )
{
	return ( fabs( a.x - b.x ) <= tolerance &&
	         fabs( a.y - b.y ) <= tolerance &&
	         fabs( a.z - b.z ) <= tolerance &&
	         fabs( a.w - b.w ) <= tolerance );
}

//-----------------------------------------------------------------------------
// qt = p * ( s * q )
//-----------------------------------------------------------------------------
function VS::QuaternionMA( p, s, q, qt = _QUAT )
{
	// QuaternionScale( q, s, q1 );
	local q1 = q * s;
	local p1 = QuaternionMult( p, q1, Quaternion() );;
	QuaternionNormalize( p1 );

	qt.x = p1.x;
	qt.y = p1.y;
	qt.z = p1.z;
	qt.w = p1.w;

	return qt;
}

function VS::QuaternionAdd( p, q, qt = _QUAT )
{
	// decide if one of the quaternions is backwards
	local q2 = QuaternionAlign( p, q, Quaternion() );

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

//-----------------------------------------------------------------------------
// qt = p * q
//-----------------------------------------------------------------------------
function VS::QuaternionMult( p, q, qt = _QUAT )
{
	if( p == qt )
	{
		local p2 = Quaternion(p.x,p.y,p.z,p.w);
		QuaternionMult( p2, q, qt );
		return qt;
	};

	// decide if one of the quaternions is backwards
	local q2 = QuaternionAlign( p, q, Quaternion() );

	qt.x =  p.x * q2.w + p.y * q2.z - p.z * q2.y + p.w * q2.x;
	qt.y = -p.x * q2.z + p.y * q2.w + p.z * q2.x + p.w * q2.y;
	qt.z =  p.x * q2.y - p.y * q2.x + p.z * q2.w + p.w * q2.z;
	qt.w = -p.x * q2.x - p.y * q2.y - p.z * q2.z + p.w * q2.w;

	return qt;
}

//-----------------------------------------------------------------------------
// make sure quaternions are within 180 degrees of one another, if not, reverse q
//-----------------------------------------------------------------------------
function VS::QuaternionAlign( p, q, qt = _QUAT )
{
	// decide if one of the quaternions is backwards
	local a = 0,
	      b = 0;

	a += (p.x-q.x)*(p.x-q.x);
	b += (p.x+q.x)*(p.x+q.x);

	a += (p.y-q.y)*(p.y-q.y);
	b += (p.y+q.y)*(p.y+q.y);

	a += (p.z-q.z)*(p.z-q.z);
	b += (p.z+q.z)*(p.z+q.z);

	a += (p.w-q.w)*(p.w-q.w);
	b += (p.w+q.w)*(p.w+q.w);

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

//-----------------------------------------------------------------------------
// Do a piecewise addition of the quaternion elements. This actually makes little
// mathematical sense, but it's a cheap way to simulate a slerp.
// nlerp
//-----------------------------------------------------------------------------
function VS::QuaternionBlend( p, q, t, qt = _QUAT )
{
	// decide if one of the quaternions is backwards
	local q2 = QuaternionAlign( p, q, Quaternion() );
	QuaternionBlendNoAlign( p, q2, t, qt );
	return qt;
}

function VS::QuaternionBlendNoAlign( p, q, t, qt = _QUAT )
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

function VS::QuaternionIdentityBlend( p, t, qt = _QUAT )
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
function VS::QuaternionSlerp( p, q, t, qt = _QUAT )
{
	// 0.0 returns p, 1.0 return q.

	// decide if one of the quaternions is backwards
	local q2 = QuaternionAlign( p, q, Quaternion() );

	QuaternionSlerpNoAlign( p, q2, t, qt );

	return qt;
}

function VS::QuaternionSlerpNoAlign( p, q, t, qt = _QUAT )
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

//-----------------------------------------------------------------------------
// Purpose: Returns the angular delta between the two normalized quaternions in degrees.
//-----------------------------------------------------------------------------
function VS::QuaternionAngleDiff( p, q )
{
// #if(1){
	// this code path is here for 2 reasons:
	// 1 - acos maps 1-epsilon to values much larger than epsilon (vs asin, which maps epsilon to itself)
	//     this means that in floats, anything below ~0.05 degrees truncates to 0
	// 2 - normalized quaternions are frequently slightly non-normalized due to float precision issues,
	//     and the epsilon off of normalized can be several percents of a degree
	local qInv = Quaternion(),
	      diff = Quaternion();
	QuaternionConjugate( q, qInv );
	QuaternionMult( p, qInv, diff );

	// Note if the quaternion is slightly non-normalized the square root below may be more than 1,
	// the value is clamped to one otherwise it may result in asin() returning an undefined result.
	local sinang = min( 1.0, sqrt( diff.x * diff.x + diff.y * diff.y + diff.z * diff.z ) );
	local angle = RAD2DEG* 2 * asin( sinang );
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
			return RAD2DEG*omega;
		}
		return 0.0;
	}
	return 180.0;
}*/
}

function VS::QuaternionConjugate( p, q )
{
	q.x = -p.x;
	q.y = -p.y;
	q.z = -p.z;
	q.w = p.w;
}

function VS::QuaternionInvert( p, q )
{
	QuaternionConjugate( p, q );

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
// Make sure the quaternion is of unit length
//-----------------------------------------------------------------------------
function VS::QuaternionNormalize( q )
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

/*
// FIXME2: p.x is float, not Vector. Why is it vector here???
function VS::QuaternionScale( p, t, q )
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
	local sinom = sqrt( DotProduct( &p.x, &p.x ) );
	sinom = min( sinom, 1.0 );

	local sinsom = sin( asin( sinom ) * t );

	t = sinsom / (sinom + FLT_EPSILON);
	q.x = VectorMultiply( &p.x, t );

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
function VS::RotationDeltaAxisAngle( srcAngles, destAngles, deltaAxis, deltaAngle )
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
function VS::RotationDelta( srcAngles, destAngles, out )
{
	local src = matrix3x4(),
	      srcInv = matrix3x4(),
	      dest = matrix3x4();

	AngleMatrix2( srcAngles, src );
	AngleMatrix2( destAngles, dest );
	// xform = src(-1) * dest
	MatrixInvert( src, srcInv );
	// xform
	MatrixScaleBy( dest, srcInv );

	local xformAngles = Vector();
	MatrixAngles( dest, xformAngles );

	out.x = xformAngles.x;
	out.y = xformAngles.y;
	out.z = xformAngles.z;
}
*/

function VS::QuaternionMatrix( q, pos, matrix )
{
	QuaternionMatrix2( q, matrix );

	matrix = matrix.m_flMatVal;
	matrix[0][3] = pos.x;
	matrix[1][3] = pos.y;
	matrix[2][3] = pos.z;
}

function VS::QuaternionMatrix2( q, matrix )
{
	matrix = matrix.m_flMatVal;

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
}

//-----------------------------------------------------------------------------
// Purpose: Converts a quaternion into engine angles
// Input  : *quaternion - q3 + q0.i + q1.j + q2.k
//          *outAngles - PITCH, YAW, ROLL
//-----------------------------------------------------------------------------
function VS::QuaternionAngles( q, angles = _VEC )
{
/*# if(1){
	// FIXME: doing it this way calculates too much data, needs to do an optimized version...
	local matrix = matrix3x4();
	QuaternionMatrix2( q, matrix );
	MatrixAngles( matrix, angles );
#}else{ */
	local m11 = ( 2.0 * q.w * q.w ) + ( 2.0 * q.x * q.x ) - 1.0,
	      m12 = ( 2.0 * q.x * q.y ) + ( 2.0 * q.w * q.z ),
	      m13 = ( 2.0 * q.x * q.z ) - ( 2.0 * q.w * q.y ),
	      m23 = ( 2.0 * q.y * q.z ) + ( 2.0 * q.w * q.x ),
	      m33 = ( 2.0 * q.w * q.w ) + ( 2.0 * q.z * q.z ) - 1.0;
	// FIXME: this code has a singularity near PITCH +-90
	angles.y = RAD2DEG*atan2(m12, m11);
	angles.x = RAD2DEG*asin(-m13);
	angles.z = RAD2DEG*atan2(m23, m33);
//#}
	return angles;
}

//-----------------------------------------------------------------------------
// Purpose: Converts a quaternion to an axis / angle in degrees
//          (exponential map)
//-----------------------------------------------------------------------------
function VS::QuaternionAxisAngle( q, axis )
{
	local angle = RAD2DEG*2*acos(q.w);

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
function VS::AxisAngleQuaternion( axis, angle, q = _QUAT )
{
	angle = DEG2RAD* angle * 0.5;

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
function VS::AngleQuaternion( angles, outQuat = _QUAT )
{
	local ay = DEG2RAD* angles.y * 0.5,
	      ax = DEG2RAD* angles.x * 0.5,
	      az = DEG2RAD* angles.z * 0.5;

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

function VS::MatrixQuaternion( mat, q = _QUAT )
{
	local angles = MatrixAngles( mat );
	AngleQuaternion( angles, q );
	return q;
}

//-----------------------------------------------------------------------------
// Purpose: Converts a basis to a quaternion
//-----------------------------------------------------------------------------
function VS::BasisToQuaternion( vecForward, vecRight, vecUp, q = _QUAT )
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

	local mat = matrix3x4( vecForward, vecLeft, vecUp );

	// mat -> QAng -> Quat
	// local angles = Vector();
	// MatrixAngles( mat, angles );
	// AngleQuaternion( angles, q );

	VS.MatrixAnglesQ( mat, q );

	// Assert( fabs(q.x - q2.x) < 1.e-3 );
	// Assert( fabs(q.y - q2.y) < 1.e-3 );
	// Assert( fabs(q.z - q2.z) < 1.e-3 );
	// Assert( fabs(q.w - q2.w) < 1.e-3 );

	return q;
}

//-----------------------------------------------------------------------------
// Purpose: Generates Euler angles given a left-handed orientation matrix. The
//			columns of the matrix contain the forward, left, and up vectors.
// Input  : matrix - Left-handed orientation matrix.
//          angles[PITCH, YAW, ROLL]. Receives right-handed counterclockwise
//               rotations in degrees around Y, Z, and X respectively.
//-----------------------------------------------------------------------------
// QAngle
function VS::MatrixAngles( matrix, angles = _VEC, position = null )
{
	if( position )
		MatrixGetColumn( matrix, 3, position );

	matrix = matrix.m_flMatVal;

	//
	// Extract the basis vectors from the matrix. Since we only need the Z
	// component of the up vector, we don't get X and Y.
	//
	local forward = [ matrix[0][0],
	                  matrix[1][0],
	                  matrix[2][0] ],

	      left    = [ matrix[0][1],
	                  matrix[1][1],
	                  matrix[2][1] ],

	      up      = [ null,
	                  null,
	                  matrix[2][2] ];
/*
	forward[0] = matrix[0][0];
	forward[1] = matrix[1][0];
	forward[2] = matrix[2][0];
	left[0] = matrix[0][1];
	left[1] = matrix[1][1];
	left[2] = matrix[2][1];
	up[2] = matrix[2][2];
*/
	local xyDist = sqrt( forward[0] * forward[0] + forward[1] * forward[1] );

	// enough here to get angles?
	if( xyDist > 0.001 )
	{
		// (yaw)	y = ATAN( forward[1], forward[0] );		-- in our space, forward is the X axis
		angles.y = RAD2DEG*atan2( forward[1], forward[0] );

		// (pitch)	x = ATAN( -forward[2], sqrt(forward[0]*forward[0]+forward[1]*forward[1]) );
		angles.x = RAD2DEG*atan2( -forward[2], xyDist );

		// (roll)	z = ATAN( left[2], up[2] );
		angles.z = RAD2DEG*atan2( left[2], up[2] );
	}
	else	// forward is mostly Z, gimbal lock-
	{
		// (yaw)	y = ATAN( -left[0], left[1] );			-- forward is mostly z, so use right for yaw
		angles.y = RAD2DEG*atan2( -left[0], left[1] );

		// (pitch)	x = ATAN( -forward[2], sqrt(forward[0]*forward[0]+forward[1]*forward[1]) );
		angles.x = RAD2DEG*atan2( -forward[2], xyDist );

		// Assume no roll in this case as one degree of freedom has been lost (i.e. yaw == roll)
		angles.z = 0;
	};

	return angles;
}

// Quaternion
function VS::MatrixAnglesQ( matrix, q = _QUAT, pos = null )
{
	if( pos )
		MatrixGetColumn( matrix, 3, pos );

	matrix = matrix.m_flMatVal;

	local trace = matrix[0][0] + matrix[1][1] + matrix[2][2] + 1.0;

	if( trace > 1.0 + FLT_EPSILON )
	{
		q.x = ( matrix[2][1] - matrix[1][2] );
		q.y = ( matrix[0][2] - matrix[2][0] );
		q.z = ( matrix[1][0] - matrix[0][1] );
		q.w = trace;
	}
	else if( matrix[0][0] > matrix[1][1] && matrix[0][0] > matrix[2][2] )
	{
		trace = 1.0 + matrix[0][0] - matrix[1][1] - matrix[2][2];
		q.x = trace;
		q.y = ( matrix[1][0] + matrix[0][1] );
		q.z = ( matrix[0][2] + matrix[2][0] );
		q.w = ( matrix[2][1] - matrix[1][2] );
	}
	else if( matrix[1][1] > matrix[2][2] )
	{
		trace = 1.0 + matrix[1][1] - matrix[0][0] - matrix[2][2];
		q.x = ( matrix[0][1] + matrix[1][0] );
		q.y = trace;
		q.z = ( matrix[2][1] + matrix[1][2] );
		q.w = ( matrix[0][2] - matrix[2][0] );
	}
	else
	{
		trace = 1.0 + matrix[2][2] - matrix[0][0] - matrix[1][1];
		q.x = ( matrix[0][2] + matrix[2][0] );
		q.y = ( matrix[2][1] + matrix[1][2] );
		q.z = trace;
		q.w = ( matrix[1][0] - matrix[0][1] );
	};;;

	QuaternionNormalize(q);

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
function VS::AngleMatrix( angles, position, matrix )
{
	AngleMatrix2( angles, matrix );
	MatrixSetColumn( position, 3, matrix );
}

function VS::AngleMatrix2( angles, matrix )
{
	local ay = DEG2RAD*angles.y,
	      ax = DEG2RAD*angles.x,
	      az = DEG2RAD*angles.z;

	local sy = sin(ay),
	      cy = cos(ay),

	      sp = sin(ax),
	      cp = cos(ax),

	      sr = sin(az),
	      cr = cos(az);

	matrix = matrix.m_flMatVal;
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
}

function VS::AngleIMatrix( angles, position, mat )
{
	AngleIMatrix2( angles, mat );
	local vecTranslation = VectorRotate( position, mat ) * -1.0;
	MatrixSetColumn( vecTranslation, 3, mat );
}

function VS::AngleIMatrix2( angles, matrix )
{
	local ay = DEG2RAD*angles.y,
	      ax = DEG2RAD*angles.x,
	      az = DEG2RAD*angles.z;

	local sy = sin(ay),
	      cy = cos(ay),

	      sp = sin(ax),
	      cp = cos(ax),

	      sr = sin(az),
	      cr = cos(az);

	matrix = matrix.m_flMatVal;
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
}

// Matrix is right-handed x=forward, y=left, z=up.  Valve uses left-handed convention for vectors in the game code (forward, right, up)
function VS::MatrixVectors( matrix, pForward, pRight, pUp )
{
	MatrixGetColumn( matrix, 0, pForward );
	MatrixGetColumn( matrix, 1, pRight );
	MatrixGetColumn( matrix, 2, pUp );
	VectorMultiply( pRight, -1.0, pRight );
}

function VS::MatricesAreEqual( src1, src2, flTolerance )
{
	src1 = src1.m_flMatVal;
	src2 = src2.m_flMatVal;

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
	for( local i = 0; i < 3; ++i )
	{
		for( local j = 0; j < 4; ++j )
		{
			dst[i][j] = src[i][j];
		}
	}

	return dst;
}

// NOTE: This is just the transpose not a general inverse
function VS::MatrixInvert( in1, out )
{
	in1 = in1.m_flMatVal;
	out = out.m_flMatVal;

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
	local tmp = [ in1[0][3],
	              in1[1][3],
	              in1[2][3] ];

	// -DotProduct( tmp, out[0] );
	out[0][3] = -(tmp[0]*out[0][0] + tmp[1]*out[0][1] + tmp[2]*out[0][2]);
	out[1][3] = -(tmp[0]*out[1][0] + tmp[1]*out[1][1] + tmp[2]*out[1][2]);
	out[2][3] = -(tmp[0]*out[2][0] + tmp[1]*out[2][1] + tmp[2]*out[2][2]);
}

function VS::MatrixGetColumn( in1, column, out = _VEC )
{
	in1 = in1.m_flMatVal;

	out.x = in1[0][column];
	out.y = in1[1][column];
	out.z = in1[2][column];

	return out;
}

function VS::MatrixSetColumn( in1, column, out )
{
	out = out.m_flMatVal;

	out[0][column] = in1.x;
	out[1][column] = in1.y;
	out[2][column] = in1.z;
}

function VS::MatrixScaleBy( flScale, out )
{
	out = out.m_flMatVal;

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
	out = out.m_flMatVal;

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
	SetScaleMatrix( 1.0, 1.0, 1.0, matrix );
}

//-----------------------------------------------------------------------------
// Builds a scale matrix
//-----------------------------------------------------------------------------
function VS::SetScaleMatrix( x, y, z, dst )
{
	dst = dst.m_flMatVal;

	dst[0][0] = x;   dst[0][1] = 0.0; dst[0][2] = 0.0; dst[0][3] = 0.0;
	dst[1][0] = 0.0; dst[1][1] = y;   dst[1][2] = 0.0; dst[1][3] = 0.0;
	dst[2][0] = 0.0; dst[2][1] = 0.0; dst[2][2] = z;   dst[2][3] = 0.0;
}

//-----------------------------------------------------------------------------
// Compute a matrix that has the correct orientation but which has an origin at
// the center of the bounds
//-----------------------------------------------------------------------------
function VS::ComputeCenterMatrix( origin, angles, mins, maxs, matrix )
{
	local centroid = (mins + maxs)*0.5;
	AngleMatrix2( angles, matrix );

	local worldCentroid = VectorRotate( centroid, matrix ) + origin;
	MatrixSetColumn( worldCentroid, 3, matrix );
}

function VS::ComputeCenterIMatrix( origin, angles, mins, maxs, matrix )
{
	local centroid = (mins + maxs)*-0.5;
	AngleIMatrix2( angles, matrix );

	// For the translational component here, note that the origin in world space
	// is T = R * C + O, (R = rotation matrix, C = centroid in local space, O = origin in world space)
	// The IMatrix translation = - transpose(R) * T = -C - transpose(R) * 0
	local localOrigin = VectorRotate( origin, matrix );
	centroid -= localOrigin;
	MatrixSetColumn( centroid, 3, matrix );
}

//-----------------------------------------------------------------------------
// Compute a matrix which is the absolute value of another
//-----------------------------------------------------------------------------
function VS::ComputeAbsMatrix( in1, out )
{
	in1 = in1.m_flMatVal;
	out = out.m_flMatVal;

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

	in1 = in1.m_flMatVal;
	in2 = in2.m_flMatVal;
	out = out.m_flMatVal;

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

function VS::ConcatTransforms( in1, in2, out )
{
	in1 = in1.m_flMatVal;
	in2 = in2.m_flMatVal;

	local lastMask = [0,0,0,0xFFFFFFFF];

	local rowA0 = in1[0],
	      rowA1 = in1[1],
	      rowA2 = in1[2];

	local rowB0 = in2[0],
	      rowB1 = in2[1],
	      rowB2 = in2[2];

	local out0 = [(rowA0[0]*rowB0[0]+rowA0[1]*rowB1[0]+rowA0[2]*rowB2[0])+(rowA0[0]&lastMask[0]),(rowA0[0]*rowB0[1]+rowA0[1]*rowB1[1]+rowA0[2]*rowB2[1])+(rowA0[1]&lastMask[1]),(rowA0[0]*rowB0[2]+rowA0[1]*rowB1[2]+rowA0[2]*rowB2[2])+(rowA0[2]&lastMask[2]),(rowA0[0]*rowB0[3]+rowA0[1]*rowB1[3]+rowA0[2]*rowB2[3])+(rowA0[3]&lastMask[3])],

	      out1 = [(rowA1[0]*rowB0[0]+rowA1[1]*rowB1[0]+rowA1[2]*rowB2[0])+(rowA1[0]&lastMask[0]),(rowA1[0]*rowB0[1]+rowA1[1]*rowB1[1]+rowA1[2]*rowB2[1])+(rowA1[1]&lastMask[1]),(rowA1[0]*rowB0[2]+rowA1[1]*rowB1[2]+rowA1[2]*rowB2[2])+(rowA1[2]&lastMask[2]),(rowA1[0]*rowB0[3]+rowA1[1]*rowB1[3]+rowA1[2]*rowB2[3])+(rowA1[3]&lastMask[3])],

	      out2 = [(rowA2[0]*rowB0[0]+rowA2[1]*rowB1[0]+rowA2[2]*rowB2[0])+(rowA2[0]&lastMask[0]),(rowA2[0]*rowB0[1]+rowA2[1]*rowB1[1]+rowA2[2]*rowB2[1])+(rowA2[1]&lastMask[1]),(rowA2[0]*rowB0[2]+rowA2[1]*rowB1[2]+rowA2[2]*rowB2[2])+(rowA2[2]&lastMask[2]),(rowA2[0]*rowB0[3]+rowA2[1]*rowB1[3]+rowA2[2]*rowB2[3])+(rowA2[3]&lastMask[3])];

	// write to output
	out = out.m_flMatVal;

	out[0][0] = out0[0];
	out[0][1] = out0[1];
	out[0][2] = out0[2];
	out[0][3] = out0[3];

	out[1][0] = out1[0];
	out[1][1] = out1[1];
	out[1][2] = out1[2];
	out[1][3] = out1[3];

	out[2][0] = out2[0];
	out[2][1] = out2[1];
	out[2][2] = out2[2];
	out[2][3] = out2[3];
}

::VS.MatrixMultiply <- ::VS.ConcatTransforms;

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
//          matrix3x4 mat -
//-----------------------------------------------------------------------------
function VS::MatrixBuildRotationAboutAxis( vAxisOfRot, angleDegrees, dst )
{
	local radians = angleDegrees * DEG2RAD;
	local fSin = sin( radians ),
	      fCos = cos( radians );

	local axisXSquared = vAxisOfRot[0] * vAxisOfRot[0],
	      axisYSquared = vAxisOfRot[1] * vAxisOfRot[1],
	      axisZSquared = vAxisOfRot[2] * vAxisOfRot[2];

	dst = dst.m_flMatVal;

	dst[0][0] = axisXSquared + (1 - axisXSquared) * fCos;
	dst[1][0] = vAxisOfRot[0] * vAxisOfRot[1] * (1 - fCos) + vAxisOfRot[2] * fSin;
	dst[2][0] = vAxisOfRot[2] * vAxisOfRot[0] * (1 - fCos) - vAxisOfRot[1] * fSin;

	dst[0][1] = vAxisOfRot[0] * vAxisOfRot[1] * (1 - fCos) - vAxisOfRot[2] * fSin;
	dst[1][1] = axisYSquared + (1 - axisYSquared) * fCos;
	dst[2][1] = vAxisOfRot[1] * vAxisOfRot[2] * (1 - fCos) + vAxisOfRot[0] * fSin;

	dst[0][2] = vAxisOfRot[2] * vAxisOfRot[0] * (1 - fCos) + vAxisOfRot[1] * fSin;
	dst[1][2] = vAxisOfRot[1] * vAxisOfRot[2] * (1 - fCos) - vAxisOfRot[0] * fSin;
	dst[2][2] = axisZSquared + (1 - axisZSquared) * fCos;

	dst[0][3] = 0;
	dst[1][3] = 0;
	dst[2][3] = 0;
}

/*
//-----------------------------------------------------------------------------
// Builds a rotation matrix that rotates one direction vector into another
//
// Input  : matrix
//          Vector
//          Vector
//-----------------------------------------------------------------------------
function VS::MatrixBuildRotation( dst, initialDirection, finalDirection )
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
		angle = acos(angle) * RAD2DEG;
	}

	MatrixBuildRotationAboutAxis( axis, angle, dst );

// #ifdef _DEBUG
	local test = Vector();
	Vector3DMultiply( initialDirection, test, dst );
	test -= finalDirection;
	Assert( test.LengthSqr() < 1e-3 );
// #endif
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
	local v;

	// Make sure it works if src2 == dst
	if( src2 == dst )
	{
		v = VectorCopy( src2, Vector() );
	}
	else
	{
		v = src2;
	};

	dst.x = src1[0][0] * v.x + src1[0][1] * v.y + src1[0][2] * v.z;
	dst.y = src1[1][0] * v.x + src1[1][1] * v.y + src1[1][2] * v.z;
	dst.z = src1[2][0] * v.x + src1[2][1] * v.y + src1[2][2] * v.z;
}

//-----------------------------------------------------------------------------
// Vector3DMultiplyPositionProjective treats src2 as if it's a point
// and does the perspective divide at the end
//
// Input  : matrix
//          Vector
//          Vector
//-----------------------------------------------------------------------------
function VS::Vector3DMultiplyPositionProjective( src1, src2, dst )
{
	local v;

	// Make sure it works if src2 == dst
	if( src2 == dst )
	{
		v = VectorCopy( src2, Vector() );
	}
	else
	{
		v = src2;
	};

	local w = src1[3][0] * v[0] + src1[3][1] * v[1] + src1[3][2] * v[2] + src1[3][3];

	if( w != 0.0 )
	{
		w = 1.0 / w;
	};

	dst.x = src1[0][0] * v.x + src1[0][1] * v.y + src1[0][2] * v.z + src1[0][3];
	dst.y = src1[1][0] * v.x + src1[1][1] * v.y + src1[1][2] * v.z + src1[1][3];
	dst.z = src1[2][0] * v.x + src1[2][1] * v.y + src1[2][2] * v.z + src1[2][3];

	VectorMultiply( dst, w, dst );
}

//-----------------------------------------------------------------------------
// Vector3DMultiplyProjective treats src2 as if it's a direction
// and does the perspective divide at the end
//
// Input  : matrix
//          Vector
//          Vector
//-----------------------------------------------------------------------------
function VS::Vector3DMultiplyProjective( src1, src2, dst )
{
	local v;

	// Make sure it works if src2 == dst
	if( src2 == dst )
	{
		v = VectorCopy( src2, Vector() );
	}
	else
	{
		v = src2;
	};

	local w = src1[3][0] * v[0] + src1[3][1] * v[1] + src1[3][2] * v[2];

	if( w != 0.0 )
	{
		VectorDivide( dst, w, dst );
	}
	else
	{
		dst.x = 0;
		dst.y = 0;
		dst.z = 0;
	};

	dst.x = src1[0][0] * v.x + src1[0][1] * v.y + src1[0][2] * v.z;
	dst.y = src1[1][0] * v.x + src1[1][1] * v.y + src1[1][2] * v.z;
	dst.z = src1[2][0] * v.x + src1[2][1] * v.y + src1[2][2] * v.z;
}
*/

//-----------------------------------------------------------------------------
// Transforms a AABB into another space; which will inherently grow the box.
//-----------------------------------------------------------------------------
function VS::TransformAABB( transform, vecMinsIn, vecMaxsIn, vecMinsOut, vecMaxsOut )
{
	local localCenter = (vecMinsIn + vecMaxsIn) * 0.5;

	local localExtents = vecMaxsIn - localCenter;

	local worldCenter = VectorTransform( localCenter, transform );

	transform = transform.m_flMatVal;

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
function VS::ITransformAABB( transform, vecMinsIn, vecMaxsIn, vecMinsOut, vecMaxsOut )
{
	local worldCenter = (vecMinsIn + vecMaxsIn) * 0.5;

	local worldExtents = vecMaxsIn - worldCenter;

	local localCenter = VectorITransform( worldCenter, transform );

	transform = transform.m_flMatVal;

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
function VS::RotateAABB( transform, vecMinsIn, vecMaxsIn, vecMinsOut, vecMaxsOut )
{
	local localCenter = (vecMinsIn + vecMaxsIn) * 0.5;

	local localExtents = vecMaxsIn - localCenter;

	local newCenter = VectorRotate( localCenter, transform );

	transform = transform.m_flMatVal;

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
function VS::IRotateAABB( transform, vecMinsIn, vecMaxsIn, vecMinsOut, vecMaxsOut )
{
	local oldCenter = (vecMinsIn + vecMaxsIn) * 0.5;

	local oldExtents = vecMaxsIn - oldCenter;

	local newCenter = VectorIRotate( oldCenter, transform );

	transform = transform.m_flMatVal;

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
