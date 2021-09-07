//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//-----------------------------------------------------------------------
//
// Math library. Contains code from the Source Engine and DirectX.
//
//-----------------------------------------------------------------------


if ( !("VS" in getroottable()) )
	::VS <- { version = "vs_library 0.0.0" };

if ( "VectorRotate" in VS )
	return;


const FLT_EPSILON		= 1.192092896e-7;;
const FLT_MAX			= 3.402823466e+38;;
const FLT_MIN			= 1.175494351e-38;;

// Assert( _intsize_ == 4 );
const INT_MAX			= 0x7FFFFFFF;;
const INT_MIN			= 0x80000000;;

const DEG2RAD			= 0.017453293;;			// PI / 180 = 0.01745329251994329576
const RAD2DEG			= 57.295779513;; 		// 180 / PI = 57.29577951308232087679
const PI				= 3.141592654;;			// 3.14159265358979323846
const RAND_MAX			= 0x7FFF;;
const MAX_COORD_FLOAT	= 16384.0;;
const MAX_TRACE_LENGTH	= 56755.840862417;;	 	// sqrt(3) * 2 * MAX_COORD_FLOAT = 56755.84086241697115430736

::CONST <- getconsttable();
::DEG2RAD <- DEG2RAD;
::RAD2DEG <- RAD2DEG;
::MAX_COORD_FLOAT <- MAX_COORD_FLOAT;
::MAX_TRACE_LENGTH <- MAX_TRACE_LENGTH;


const DEG2RADDIV2		= 0.008726646;;
const RAD2DEG2			= 114.591559026;;
const PI2				= 6.283185307;;			// 6.28318530717958647692
const PIDIV2			= 1.570796327;;			// 1.57079632679489661923
const FLT_MAX_N			= -3.402823466e+38;;

delete CONST.DEG2RADDIV2;
delete CONST.RAD2DEG2;
delete CONST.PI2;
delete CONST.PIDIV2;
delete CONST.FLT_MAX_N;


// NOTE: Vector extensions will only be applied if these were run before creating an instance.
// This cannot be guaranteed when the library is executed post server init -
// where other scripts could have created a vector instance.

// REMOVED: While I could keep this in for map scripts where this would be guaranteed,
// I am wary of the uncertain edge cases.
// For personal uses, use this vec3_t class.
/*
// class ::vec3_t extends Vector {}
// local Vector = vec3_t;

function Vector::IsValid()
{
	return ( x > -FLT_MAX && x < FLT_MAX ) &&
		( y > -FLT_MAX && y < FLT_MAX ) &&
		( z > -FLT_MAX && z < FLT_MAX );
}

function Vector::IsZero()
{
	return !x && !y && !z;
}

function Vector::_unm()
{
	return this * -1.0;
}

function Vector::_div(f)
{
	return this * ( 1.0 / f );
}

function Vector::Negate()
{
	x = -x;
	y = -y;
	z = -z;
}

function Vector::Init(X, Y, Z)
{
	x = X;
	y = Y;
	z = Z;
}

function Vector::Copy(v)
{
	x = v.x;
	y = v.y;
	z = v.z;
}

function Vector::Replicate(f)
{
	x = y = z = f;
}

function Vector::Normalized()
{
	local v = this * 1.0;
	v.Norm();
	return v;
}
*/


local Fmt = format;

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

	function IsValid()
	{
		return ( x > FLT_MAX_N && x < FLT_MAX ) &&
			( y > FLT_MAX_N && y < FLT_MAX ) &&
			( z > FLT_MAX_N && z < FLT_MAX ) &&
			( w > FLT_MAX_N && w < FLT_MAX );
	}

	function _get(i)
	{
		switch (i)
		{
			case 0: return x;
			case 1: return y;
			case 2: return z;
			case 3: return w;
		}
		return rawget(i);
	}

	function _set(i,v)
	{
		switch (i)
		{
			case 0: return x = v;
			case 1: return y = v;
			case 2: return z = v;
			case 3: return w = v;
		}
		return rawset(i,v);
	}

	function _typeof()
	{
		return "Quaternion";
	}

	function _tostring():(Fmt)
	{
		return Fmt("Quaternion(%.6g, %.6g, %.6g, %.6g)", x, y, z, w);
	}
}

function Quaternion::_add(d):(Quaternion) { return Quaternion( x+d.x,y+d.y,z+d.z,w+d.w ) }
function Quaternion::_sub(d):(Quaternion) { return Quaternion( x-d.x,y-d.y,z-d.z,w-d.w ) }
function Quaternion::_mul(d):(Quaternion) { return Quaternion( x*d,y*d,z*d,w*d ) }
function Quaternion::_div(d):(Quaternion) { local f = 1.0/d; return Quaternion( x*f,y*f,z*f,w*f ) }
function Quaternion::_unm() :(Quaternion) { return Quaternion( -x,-y,-z,-w ) }


class ::matrix3x4_t
{
	m = null;

	constructor(
		m00 = 0.0, m01 = 0.0, m02 = 0.0, m03 = 0.0,
		m10 = 0.0, m11 = 0.0, m12 = 0.0, m13 = 0.0,
		m20 = 0.0, m21 = 0.0, m22 = 0.0, m23 = 0.0 )
	{
		m =	[
				[ m00, m01, m02, m03 ],
				[ m10, m11, m12, m13 ],
				[ m20, m21, m22, m23 ]
			];
	}

	function Init(
		m00 = 0.0, m01 = 0.0, m02 = 0.0, m03 = 0.0,
		m10 = 0.0, m11 = 0.0, m12 = 0.0, m13 = 0.0,
		m20 = 0.0, m21 = 0.0, m22 = 0.0, m23 = 0.0 )
	{
		local m0 = m[0];
		local m1 = m[1];
		local m2 = m[2];

		m0[0] = m00;
		m0[1] = m01;
		m0[2] = m02;
		m0[3] = m03;

		m1[0] = m10;
		m1[1] = m11;
		m1[2] = m12;
		m1[3] = m13;

		m2[0] = m20;
		m2[1] = m21;
		m2[2] = m22;
		m2[3] = m23;
	}

	function _cloned( src )
	{
		src = src.m;
		constructor(
			src[0][0], src[0][1], src[0][2], src[0][3],
			src[1][0], src[1][1], src[1][2], src[1][3],
			src[2][0], src[2][1], src[2][2], src[2][3]
		);
	}

	function _tostring() : (Fmt)
	{
		local m = m;
		return Fmt( "[ (%.6g, %.6g, %.6g), (%.6g, %.6g, %.6g), (%.6g, %.6g, %.6g), (%.6g, %.6g, %.6g) ]",
			m[0][0], m[0][1], m[0][2],
			m[1][0], m[1][1], m[1][2],
			m[2][0], m[2][1], m[2][2],
			m[0][3], m[1][3], m[2][3] );
	}

	function _typeof()
	{
		return "matrix3x4_t";
	}

	function _get(i)
	{
		switch (i)
		{
			case 0: return m[0];
			case 1: return m[1];
			case 2: return m[2];
		}
		return rawget(i);
	}
}


class ::VMatrix extends matrix3x4_t
{
	m = null;

	constructor(
		m00 = 0.0, m01 = 0.0, m02 = 0.0, m03 = 0.0,
		m10 = 0.0, m11 = 0.0, m12 = 0.0, m13 = 0.0,
		m20 = 0.0, m21 = 0.0, m22 = 0.0, m23 = 0.0,
		m30 = 0.0, m31 = 0.0, m32 = 0.0, m33 = 1.0 )
	{
		m =	[
				[ m00, m01, m02, m03 ],
				[ m10, m11, m12, m13 ],
				[ m20, m21, m22, m23 ],
				[ m30, m31, m32, m33 ]
			];
	}

	function Identity()
	{
		local m = m;

		m[0][0] = m[1][1] = m[2][2] = m[3][3] = 1.0;

		m[0][1] = m[0][2] = m[0][3] =
		m[1][0] = m[1][2] = m[1][3] =
		m[2][0] = m[2][1] = m[2][3] =
		m[3][0] = m[3][1] = m[3][2] = 0.0;
	}

	function _cloned( src )
	{
		src = src.m;
		constructor(
			src[0][0], src[0][1], src[0][2], src[0][3],
			src[1][0], src[1][1], src[1][2], src[1][3],
			src[2][0], src[2][1], src[2][2], src[2][3],
			src[3][0], src[3][1], src[3][2], src[3][3]
		);
	}

	function _tostring() : (Fmt)
	{
		local m = m;
		return Fmt( "[ (%.6g, %.6g, %.6g, %.6g), (%.6g, %.6g, %.6g, %.6g), (%.6g, %.6g, %.6g, %.6g), (%.6g, %.6g, %.6g, %.6g) ]",
			m[0][0], m[0][1], m[0][2], m[0][3],
			m[1][0], m[1][1], m[1][2], m[1][3],
			m[2][0], m[2][1], m[2][2], m[2][3],
			m[3][0], m[3][1], m[3][2], m[3][3] );
	}

	function _typeof()
	{
		return "VMatrix";
	}

	function _get(i)
	{
		switch (i)
		{
			case 0: return m[0];
			case 1: return m[1];
			case 2: return m[2];
			case 3: return m[3];
		}
		return rawget(i);
	}
}


// static instances for reading values from functions with optional output parameters
local _VEC = Vector();
local _QUAT = Quaternion();


function VS::fabs(f)
{
	// NOTE: hand order matters for -0.0
	// Assert( -0.0 > 0.0 )
	// Assert( 0.0 > -0.0 )

	if ( 0.0 <= f )
		return f;
	return -f;
}

local fabs = VS.fabs;

::max <- function( a, b )
{
	if ( a > b )
		return a;
	return b;
}

::min <- function( a, b )
{
	if ( a < b )
		return a;
	return b;
}

::clamp <- function( val, min, max )
{
	if ( max < min )
		return max;
	if ( val < min )
		return min;
	if ( val > max )
		return max;
	return val;
	// (v < min) ? min : (max < v) ? max : v
}

function VS::IsInteger(f)
{
	return ( f.tointeger() == f );
}

/*
function VS::IsFinite(f)
{
	return ( f > -FLT_MAX && f < FLT_MAX );
}
*/


//-----------------------------------------------------------------------
// IsLookingAt with tolerance
// cosTolerance [-1..1]
//
// VIEW_FIELD_FULL         = -1.0 // +-180 degrees
// VIEW_FIELD_WIDE         = -0.7 // +-135 degrees 0.1 // +-85 degrees
// VIEW_FIELD_NARROW       =  0.7 // +-45 degrees
// VIEW_FIELD_ULTRA_NARROW =  0.9 // +-25 degrees
//-----------------------------------------------------------------------
function VS::IsLookingAt( vSrc, vTarget, vDir, cosTolerance )
{
	local to = vTarget - vSrc;
	to.Norm();
	return to.Dot( vDir ) >= cosTolerance;
}

//-----------------------------------------------------------------------
// Angle between 2 vectors
// Identical to < VS.VectorAngles(vTo-vFrom) >
// return QAngle
//-----------------------------------------------------------------------
function VS::GetAngle( vFrom, vTo ) : ( atan2 )
{
	local dt = vTo - vFrom;
	local pitch = RAD2DEG * atan2( -dt.z, dt.Length2D() );
	local yaw = RAD2DEG * atan2( dt.y, dt.x );

	dt.x = pitch;
	dt.y = yaw;
	dt.z = 0.0;

	return dt;
}

//-----------------------------------------------------------------------
//
//-----------------------------------------------------------------------
function VS::VectorVectors( forward, right, up ) : (Vector)
{
	if ( !forward.x && !forward.y )
	{
		// pitch 90 degrees up/down from identity
		right.y = -1.0;
		up.x = -forward.z;
		right.x = right.z = up.y = up.z = 0.0;
	}
	else
	{
		local r = forward.Cross( Vector(0.0, 0.0, 1.0) );
		r.Norm();
		right.x = r.x; right.y = r.y; right.z = r.z;

		local u = right.Cross(forward);
		u.Norm();
		up.x = u.x; up.y = u.y; up.z = u.z;
	};
}

local VectorVectors = VS.VectorVectors;

//-----------------------------------------------------------------------
// Euler QAngle -> Basis Vectors.  Each vector is optional
// input vector pointers
//-----------------------------------------------------------------------
function VS::AngleVectors( angle, forward = _VEC, right = null, up = null ) : (sin, cos)
{
	local sr, cr,

		yr = DEG2RAD*angle.y,
		sy = sin(yr),
		cy = cos(yr),

		pr = DEG2RAD*angle.x,
		sp = sin(pr),
		cp = cos(pr);

	if ( angle.z )
	{
		local rr = DEG2RAD*angle.z;
		sr = -sin(rr);
		cr = cos(rr);
	}
	else
	{
		sr = 0.0;
		cr = 1.0;
	};

	if ( forward )
	{
		forward.x = cp*cy;
		forward.y = cp*sy;
		forward.z = -sp;
	};

	if ( right )
	{
		right.x = sr*sp*cy+cr*sy;
		right.y = sr*sp*sy-cr*cy;
		right.z = sr*cp;
	};

	if ( up )
	{
		up.x = cr*sp*cy-sr*sy;
		up.y = cr*sp*sy+sr*cy;
		up.z = cr*cp;
	};

	return forward;
}

//-----------------------------------------------------------------------
// Forward direction vector -> Euler QAngle
//-----------------------------------------------------------------------
function VS::VectorAngles( forward, vOut = _VEC ) : ( Vector, atan2 )
{
	local yaw, pitch;

	if ( !forward.y && !forward.x )
	{
		yaw = 0.0;
		if ( forward.z > 0.0 )
			pitch = 270.0;
		else
			pitch = 90.0;
	}
	else
	{
		yaw = RAD2DEG * atan2( forward.y, forward.x );
		if ( yaw < 0.0 )
			yaw += 360.0;

		pitch = RAD2DEG * atan2( -forward.z, forward.Length2D() );
		if ( pitch < 0.0 )
			pitch += 360.0;
	};

	vOut.x = pitch;
	vOut.y = yaw;
	vOut.z = 0.0;

	return vOut;
}

//-----------------------------------------------------------------------
// Rotate a vector around the Z axis (YAW)
//-----------------------------------------------------------------------
function VS::VectorYawRotate( vIn, fYaw, vOut = _VEC ) : (sin, cos)
{
	local rad = DEG2RAD * fYaw;
	local sy  = sin(rad);
	local cy  = cos(rad);

	vOut.x = vIn.x * cy - vIn.y * sy;
	vOut.y = vIn.x * sy + vIn.y * cy;
	vOut.z = vIn.z;

	return vOut;
}

function VS::YawToVector( yaw ) : (Vector, sin, cos)
{
	local ang = DEG2RAD * yaw;
	return Vector( cos(ang), sin(ang), 0.0 );
}

function VS::VecToYaw( vec ) : (atan2)
{
	if ( !vec.y && !vec.x )
		return 0.0;

	local yaw = RAD2DEG * atan2( vec.y, vec.x );

	return yaw;
}

function VS::VecToPitch( vec ) : (atan2)
{
	if ( !vec.y && !vec.x )
	{
		if ( vec.z < 0.0 )
			return 180.0;
		return -180.0;
	};

	return RAD2DEG * atan2( -vec.z, vec.Length2D() );
}

function VS::VectorIsZero(v)
{
	return !v.x && !v.y && !v.z;
}

//-----------------------------------------------------------------------
// Vector equality with tolerance
//-----------------------------------------------------------------------
function VS::VectorsAreEqual( a, b, tolerance = 0.0 )
{
	local x = a.x - b.x;
	if (0.0 > x) x = -x;

	local y = a.y - b.y;
	if (0.0 > y) y = -y;

	local z = a.z - b.z;
	if (0.0 > z) z = -z;

	return ( x <= tolerance &&
		y <= tolerance &&
		z <= tolerance );
}

//-----------------------------------------------------------------------
// Angle equality with tolerance
//-----------------------------------------------------------------------
function VS::AnglesAreEqual( a, b, tolerance = 0.0 )
{
	local d = AngleDiff(a, b)
	if (0.0 > d)
		d = -d;

	return d <= tolerance;
}

//-----------------------------------------------------------------------
// Equality with tolerance
//-----------------------------------------------------------------------
function VS::CloseEnough( a, b, e = 1.e-3 )
{
	local d = a - b;
	if (0.0 > d)
		d = -d;

	return d <= e;
}

function VS::Approach( target, value, speed )
{
	local delta = target - value;

	if ( delta > speed )
		return value + speed;
	if ( -speed > delta )
		return value - speed;
	return target;
}

// Vector, Vector, float
function VS::ApproachVector( target, value, speed )
{
	local dv = target - value;
	local delta = dv.Norm();

	if ( delta > speed )
		return value + dv * speed;
	if ( -speed > delta )
		return value - dv * speed;
	return target;
}

function VS::ApproachAngle( target, value, speed )
{
	target = AngleNormalize( target );
	value = AngleNormalize( value );

	local delta = AngleDiff( target, value );

	if (speed < 0.0)
		speed = -speed;

	if ( delta > speed )
		return value + speed;
	if ( -speed > delta )
		return value - speed;
	return target;
}

// float, float
function VS::AngleDiff( destAngle, srcAngle )
{
	return AngleNormalize( destAngle - srcAngle );
}

// float
function VS::AngleNormalize( angle )
{
	angle %= 360.0;

	if ( angle > 180.0 )
		return angle - 360.0;
	if ( -180.0 > angle )
		return angle + 360.0;
	return angle;
}

// input vector pointer
function VS::QAngleNormalize( vAng )
{
	vAng.x = AngleNormalize( vAng.x );
	vAng.y = AngleNormalize( vAng.y );
	vAng.z = AngleNormalize( vAng.z );
	return vAng;
}

//-----------------------------------------------------------------------------
// Snaps the input vector to the closest axis
// input vector pointer [ normalised direction vector ]
//-----------------------------------------------------------------------------
function VS::SnapDirectionToAxis( vDirection, epsilon = 0.002 )
{
	local proj = 1.0 - epsilon;
	local f = vDirection.x < 0.0;

	if( (f ? -vDirection.x : vDirection.x) > proj )
	{
		vDirection.x = f ? -1.0 : 1.0;
		vDirection.y = vDirection.z = 0.0;

		return vDirection;
	};

	f = vDirection.y < 0.0;

	if( (f ? -vDirection.y : vDirection.y) > proj )
	{
		vDirection.y = f ? -1.0 : 1.0;
		vDirection.z = vDirection.x = 0.0;

		return vDirection;
	};

	f = vDirection.z < 0.0;

	if( (f ? -vDirection.z : vDirection.z) > proj )
	{
		vDirection.z = f ? -1.0 : 1.0;
		vDirection.x = vDirection.y = 0.0;

		return vDirection;
	};
}

function VS::VectorNegate( vec )
{
	vec.x = -vec.x;
	vec.y = -vec.y;
	vec.z = -vec.z;

	return vec;
}

//-----------------------------------------------------------------------------
// Copy source's values into destination
//-----------------------------------------------------------------------------
function VS::VectorCopy( src, dst )
{
	dst.x = src.x;
	dst.y = src.y;
	dst.z = src.z;

	return dst;
}

//-----------------------------------------------------------------------------
// Store the min or max of each of x, y, and z into the result.
//-----------------------------------------------------------------------------
function VS::VectorMin( a, b, o = _VEC )
{
	if ( a.x < b.x )
		o.x = a.x;
	else
		o.x = b.x;

	if ( a.y < b.y )
		o.y = a.y;
	else
		o.y = b.y;

	if ( a.z < b.z )
		o.z = a.z;
	else
		o.z = b.z;

	return o;
}

function VS::VectorMax( a, b, o = _VEC )
{
	if ( a.x > b.x )
		o.x = a.x;
	else
		o.x = b.x;

	if ( a.y > b.y )
		o.y = a.y;
	else
		o.y = b.y;

	if ( a.z > b.z )
		o.z = a.z;
	else
		o.z = b.z;

	return o;
}

// input vector pointer
function VS::VectorAbs( v )
{
	if (0.0 > v.x) v.x = -v.x;
	if (0.0 > v.y) v.y = -v.y;
	if (0.0 > v.z) v.z = -v.z;

	return v;
}

// Vector a + Vector b
function VS::VectorAdd( a, b, o )
{
	o.x = a.x + b.x;
	o.y = a.y + b.y;
	o.z = a.z + b.z;

	return o;
}

// Vector a - Vector b
function VS::VectorSubtract( a, b, o )
{
	o.x = a.x - b.x;
	o.y = a.y - b.y;
	o.z = a.z - b.z;

	return o;
}

// scalar
// Vector a * b
function VS::VectorScale( a, b, o )
{
	o.x = a.x * b;
	o.y = a.y * b;
	o.z = a.z * b;

	return o;
}
/*
// Vector a * Vector b
function VS::VectorMultiply( a, b, o )
{
	o.x = a.x*b.x;
	o.y = a.y*b.y;
	o.z = a.z*b.z;

	return o;
}

// Vector a / Vector b
function VS::VectorDivide( a, b, o )
{
	o.x = a.x/b.x;
	o.y = a.y/b.y;
	o.z = a.z/b.z;

	return o;
}
*/

function VS::VectorMA( start, scale, direction, dest = _VEC )
{
	dest.x = start.x + scale * direction.x;
	dest.y = start.y + scale * direction.y;
	dest.z = start.z + scale * direction.z;

	return dest;
}

local VectorAdd = VS.VectorAdd;
local VectorSubtract = VS.VectorSubtract;

function VS::ComputeVolume( vecMins, vecMaxs )
{
	return (vecMaxs - vecMins).LengthSqr();
}

//-----------------------------------------------------------------------------
// Get a random vector
//-----------------------------------------------------------------------------
function VS::RandomVector( minVal = -RAND_MAX, maxVal = RAND_MAX ) : ( Vector, RandomFloat )
{
	return Vector( RandomFloat( minVal, maxVal ), RandomFloat( minVal, maxVal ), RandomFloat( minVal, maxVal ) );
}

// Guarantee uniform random distribution within a sphere
function VS::RandomVectorInUnitSphere( out ) : ( rand, sin, cos, acos, pow )
{
	// local rd = 2.0 / RAND_MAX; // 0.00006103702
	local phi = acos( 1.0 - rand() * 0.00006103702 );
	local theta = rand() * 0.00019175345; // rd * PI
	local r = pow( rand() * 0.00003051851, 0.333333 );
	local sp = r * sin( phi );
	out.x = sp * cos( theta );
	out.y = sp * sin( theta );
	out.z = r * cos( phi );
	return r;
}

// Guarantee uniform random distribution on a sphere
function VS::RandomVectorOnUnitSphere( out ) : ( rand, sin, cos, acos )
{
	// local rd = 2.0 / RAND_MAX; // 0.00006103702
	local phi = acos( 1.0 - rand() * 0.00006103702 );
	local theta = rand() * 0.00019175345; // rd * PI
	// r = 1
	local sp = sin( phi );
	out.x = sp * cos( theta );
	out.y = sp * sin( theta );
	out.z = cos( phi );
}

// decayTo is factor the value should decay to in decayTime
function VS::ExponentialDecay( decayTo, decayTime, dt ) : (log, exp)
{
	return exp( log(decayTo) / decayTime * dt );
}

// halflife is time for value to reach 50%
function VS::ExponentialDecay2( halflife, dt ) : (exp)
{
	// log(0.5) == -0.69314718055994530941723212145818
	return exp( -0.6931471806 / halflife * dt );
}

// Get the integrated distanced traveled
// decayTo is factor the value should decay to in decayTime
// dt is the time relative to the last velocity update
function VS::ExponentialDecayIntegral( decayTo, decayTime, dt ) : (log, pow)
{
	return (pow(decayTo, dt / decayTime) * decayTime - decayTime) / log(decayTo);
}

// hermite basis function for smooth interpolation
// very cheap to call
// value should be between 0 & 1 inclusive
function VS::SimpleSpline( value )
{
	local valueSquared = value * value;

	// Nice little ease-in, ease-out spline-like curve
	return ( 3.0 * valueSquared - 2.0 * valueSquared * value );
}

// remaps a value in [startInterval, startInterval+rangeInterval] from linear to
// spline using SimpleSpline
function VS::SimpleSplineRemapVal( val, A, B, C, D )
{
	if ( A == B )
	{
		if ( val >= B )
			return D;
		return C;
	};
	local cVal = (val - A) / (B - A);
	local sqr = cVal * cVal;
	return C + (D - C) * ( 3.0 * sqr - 2.0 * sqr * cVal );
}

// remaps a value in [startInterval, startInterval+rangeInterval] from linear to
// spline using SimpleSpline
function VS::SimpleSplineRemapValClamped( val, A, B, C, D )
{
	if ( A == B )
	{
		if ( val >= B )
			return D;
		return C;
	};
	local cVal = (val - A) / (B - A);
	if ( cVal < 0.0 )
		cVal = 0.0;
	else if ( cVal > 1.0 )
		cVal = 1.0;;
	local sqr = cVal * cVal;
	return C + (D - C) * ( 3.0 * sqr - 2.0 * sqr * cVal );
}

// Remap a value in the range [A,B] to [C,D].
function VS::RemapVal( val, A, B, C, D )
{
	if ( A == B )
	{
		if ( val >= B )
			return D;
		return C;
	};
	return C + (D - C) * (val - A) / (B - A);
}

function VS::RemapValClamped( val, A, B, C, D )
{
	if ( A == B )
	{
		if ( val >= B )
			return D;
		return C;
	};
	local cVal = (val - A) / (B - A);
	if ( cVal < 0.0 )
		cVal = 0.0;
	else if ( cVal > 1.0 )
		cVal = 1.0;;
	return C + (D - C) * cVal;
}

//
// Bias takes an X value between 0 and 1 and returns another value between 0 and 1
// The curve is biased towards 0 or 1 based on biasAmt, which is between 0 and 1.
// Lower values of biasAmt bias the curve towards 0 and higher values bias it towards 1.
//
// For example, with biasAmt = 0.2, the curve looks like this:
//
// 1
// |                  *
// |                  *
// |                 *
// |               **
// |             **
// |         ****
// |*********
// |___________________
// 0                   1
//
//
// With biasAmt = 0.8, the curve looks like this:
//
// 1
// |    **************
// |  **
// | *
// | *
// |*
// |*
// |*
// |___________________
// 0                   1
//
// With a biasAmt of 0.5, Bias returns X.
//
function VS::Bias( x, biasAmt ) : ( log, pow )
{
	// local lastAmt = -1.0;
	local lastExponent = 0.0;
	if ( -1.0 != biasAmt )
		lastExponent = log(biasAmt) * -1.442695041; // (-1.442695041 = 1 / log(0.5))
	return pow( x, lastExponent );
}

//
// Gain is similar to Bias, but biasAmt biases towards or away from 0.5.
// Lower bias values bias towards 0.5 and higher bias values bias away from it.
//
// For example, with biasAmt = 0.2, the curve looks like this:
//
// 1
// |                  *
// |                 *
// |                **
// |  ***************
// | **
// | *
// |*
// |___________________
// 0                   1
//
//
// With biasAmt = 0.8, the curve looks like this:
//
// 1
// |            *****
// |         ***
// |        *
// |        *
// |        *
// |     ***
// |*****
// |___________________
// 0                   1
//
local Bias = VS.Bias;

function VS::Gain( x, biasAmt ) : (Bias)
{
	if ( x < 0.5 )
		return 0.5 * Bias( 2.0*x, 1.0-biasAmt );
	return 1.0 - 0.5 * Bias( 2.0 - 2.0*x, 1.0-biasAmt );
}

//
// SmoothCurve maps a 0-1 value into another 0-1 value based on a cosine wave
// where the derivatives of the function at 0 and 1 (and 0.5) are 0. This is useful for
// any fadein/fadeout effect where it should start and end smoothly.
//
// The curve looks like this:
//
// 1
// |        **
// |       *  *
// |      *    *
// |      *    *
// |     *      *
// |   **        **
// |***            ***
// |___________________
// 0                   1
//
function VS::SmoothCurve( x ) : (cos)
{
	return (1.0 - cos(x * PI)) * 0.5;
}

function VS::MovePeak( x, flPeakPos )
{
	if ( x < flPeakPos )
		return x * 0.5 / flPeakPos;
	return 0.5 + 0.5 * (x - flPeakPos) / (1.0 - flPeakPos);
}

local MovePeak = VS.MovePeak;
local Gain = VS.Gain;

// This works like SmoothCurve, with two changes:
//
// 1. Instead of the curve peaking at 0.5, it will peak at flPeakPos.
//    (So if you specify flPeakPos=0.2, then the peak will slide to the left).
//
// 2. flPeakSharpness is a 0-1 value controlling the sharpness of the peak.
//    Low values blunt the peak and high values sharpen the peak.
function VS::SmoothCurve_Tweak( x, flPeakPos, flPeakSharpness ) : (MovePeak, Gain, cos)
{
	local flMovedPeak = MovePeak( x, flPeakPos );
	local flSharpened = Gain( flMovedPeak, flPeakSharpness );
	return (1.0 - cos(flSharpened * PI)) * 0.5;
}

function VS::Lerp( A, B, f )
{
	return A + ( B - A ) * f;
}

//
// 5-argument floating point linear interpolation.
// FLerp(f1,f2,i1,i2,x)=
//    f1 at x=i1
//    f2 at x=i2
//   smooth lerp between f1 and f2 at x>i1 and x<i2
//   extrapolation for x<i1 or x>i2
//
//   If you know a function f(x)'s value (f1) at position i1, and its value (f2) at position i2,
//   the function can be linearly interpolated with FLerp(f1,f2,i1,i2,x)
//    i2=i1 will cause a divide by zero.
//
function VS::FLerp( f1, f2, i1, i2, x )
{
	return f1 + ( f2 - f1 ) * ( x - i1 ) / ( i2 - i1 );
}

function VS::VectorLerp( v1, v2, f, o = _VEC )
{
	local v = v1 + ( v2 - v1 ) * f;
	o.x = v.x;
	o.y = v.y;
	o.z = v.z;

	return o;
}

function VS::DotProductAbs( in1, in2 )
{
	local x = in1.x * in2.x;
	local y = in1.y * in2.y;
	local z = in1.z * in2.z;

	if ( 0.0 > x ) x = -x;
	if ( 0.0 > y ) y = -y;
	if ( 0.0 > z ) z = -z;

	return x + y + z;
}

local DotProductAbs = VS.DotProductAbs;

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
function VS::VectorRotate2( in1, in2, out = _VEC ) : (matrix3x4_t, VectorRotate)
{
	local matRotate = matrix3x4_t();
	AngleMatrix( in2, null, matRotate );
	return VectorRotate( in1, matRotate, out );
}

// assume in2 is a rotation (Quaternion) and rotate the input vector
function VS::VectorRotate3( in1, in2, out = _VEC )
{
//	local matRotate = matrix3x4_t();
//	QuaternionMatrix( in2, matRotate );
//	VectorRotate( in1, matRotate, out );

	// rotation ( q * v ) * q^-1

	local in2x = in2.x;
	local in2y = in2.y;
	local in2z = in2.z;
	local in2w = in2.w;

	// q*v
	local qvx = in2y * in1.z - in2z * in1.y + in2w * in1.x;
	local qvy = in2z * in1.x + in2w * in1.y - in2x * in1.z;
	local qvz = in2x * in1.y - in2y * in1.x + in2w * in1.z;
	local qvw = in2x * in1.x + in2y * in1.y + in2z * in1.z;

	// qv*(q^-1)
	out.x = qvx * in2w - qvy * in2z + qvz * in2y + qvw * in2x;
	out.y = qvx * in2z + qvy * in2w - qvz * in2x + qvw * in2y;
	out.z = qvy * in2x + qvz * in2w + qvw * in2z - qvx * in2y;

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

local VectorITransform = VS.VectorITransform;
local VectorTransform = VS.VectorTransform;
local VectorIRotate = VS.VectorIRotate;


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

// Matrix is right-handed x=forward, y=left, z=up.  Valve uses left-handed convention for vectors in the game code (forward, right, up)
function VS::MatrixVectors( matrix, pForward, pRight, pUp )
{
	matrix = matrix.m;

	// MatrixGetColumn( matrix, 0, pForward );
	pForward.x = matrix[0][0];
	pForward.y = matrix[1][0];
	pForward.z = matrix[2][0];

	// MatrixGetColumn( matrix, 1, pRight );
	pRight.x = -matrix[0][1];
	pRight.y = -matrix[1][1];
	pRight.z = -matrix[2][1];

	// MatrixGetColumn( matrix, 2, pUp );
	pUp.x = matrix[0][2];
	pUp.y = matrix[1][2];
	pUp.z = matrix[2][2];
}

//-----------------------------------------------------------------------------
// Purpose: Generates Euler angles given a left-handed orientation matrix. The
//			columns of the matrix contain the forward, left, and up vectors.
// Input  : matrix - Left-handed orientation matrix.
//          angles[PITCH, YAW, ROLL]. Receives right-handed counterclockwise
//               rotations in degrees around Y, Z, and X respectively.
//-----------------------------------------------------------------------------
function VS::MatrixAngles( matrix, angles = _VEC, position = null ) : (sqrt,atan2)
{
	matrix = matrix.m;

	if ( position )
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

	local left0 = matrix[0][1];
	local left1 = matrix[1][1];
	local left2 = matrix[2][1];

	local up2 = matrix[2][2];

	local xyDist = sqrt( forward0 * forward0 + forward1 * forward1 );

	// enough here to get angles?
	if( xyDist > 0.001 )
	{
		// (yaw)	y = ATAN( forward[1], forward[0] );		-- in our space, forward is the X axis
		angles.y = RAD2DEG*atan2( forward1, forward0 );

		// (pitch)	x = ATAN( -forward[2], sqrt(forward[0]*forward[0]+forward[1]*forward[1]) );
		angles.x = RAD2DEG*atan2( -forward2, xyDist );

		// (roll)	z = ATAN( left[2], up[2] );
		angles.z = RAD2DEG*atan2( left2, up2 );
	}
	else	// forward is mostly Z, gimbal lock-
	{
		// (yaw)	y = ATAN( -left[0], left[1] );			-- forward is mostly z, so use right for yaw
		angles.y = RAD2DEG*atan2( -left0, left1 );

		// (pitch)	x = ATAN( -forward[2], sqrt(forward[0]*forward[0]+forward[1]*forward[1]) );
		angles.x = RAD2DEG*atan2( -forward2, xyDist );

		// Assume no roll in this case as one degree of freedom has been lost (i.e. yaw == roll)
		angles.z = 0.0;
	};

	return angles;
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
	local ay = DEG2RAD*angles.y,
		ax = DEG2RAD*angles.x,
		az = DEG2RAD*angles.z;

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

	matrix[0][2] = sp*crcy+srsy;
	matrix[1][2] = sp*crsy-srcy;
	matrix[2][2] = cr*cp;

	if ( position )
	{
		// MatrixSetColumn( position, 3, matrix );
		matrix[0][3] = position.x;
		matrix[1][3] = position.y;
		matrix[2][3] = position.z;
	}
	else
	{
		matrix[0][3] = matrix[1][3] = matrix[2][3] = 0.0;
	};
}

function VS::AngleIMatrix( angles, position, matrix ) : (sin, cos, VectorRotate)
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

	local m = matrix.m;
	// matrix = (YAW * PITCH) * ROLL
	m[0][0] = cp*cy;
	m[0][1] = cp*sy;
	m[0][2] = -sp;

	local srsp = sr*sp, crsp = cr*sp;

	m[1][0] = srsp*cy-cr*sy;
	m[1][1] = srsp*sy+cr*cy;
	m[1][2] = sr*cp;

	m[2][0] = crsp*cy+sr*sy;
	m[2][1] = crsp*sy-sr*cy;
	m[2][2] = cr*cp;

	if ( position )
	{
		local vecTranslation = VectorRotate( position, matrix );
		// MatrixSetColumn( vecTranslation * -1, 3, matrix );
		m[0][3] = -vecTranslation.x;
		m[1][3] = -vecTranslation.y;
		m[2][3] = -vecTranslation.z;
	}
	else
	{
		m[0][3] = m[1][3] = m[2][3] = 0.0;
	};
}

local MatrixAngles = VS.MatrixAngles;
local AngleMatrix = VS.AngleMatrix;
local AngleIMatrix = VS.AngleIMatrix;


function VS::QuaternionsAreEqual( a, b, tolerance = 0.0 )
{
	local x = a.x - b.x;
	if (0.0 > x) x = -x;

	local y = a.y - b.y;
	if (0.0 > y) y = -y;

	local z = a.z - b.z;
	if (0.0 > z) z = -z;

	local w = a.w - b.w;
	if (0.0 > w) w = -w;

	return ( x <= tolerance &&
		y <= tolerance &&
		z <= tolerance &&
		w <= tolerance );
}

//-----------------------------------------------------------------------------
// Make sure the quaternion is of unit length
//-----------------------------------------------------------------------------
function VS::QuaternionNormalize(q) : (sqrt)
{
	local radius = q.x*q.x + q.y*q.y + q.z*q.z + q.w*q.w;

	if ( radius ) // > FLT_EPSILON && ((radius < 1.0 - 4*FLT_EPSILON) || (radius > 1.0 + 4*FLT_EPSILON))
	{
		local ir = 1.0 / sqrt(radius);
		q.w *= ir;
		q.z *= ir;
		q.y *= ir;
		q.x *= ir;
	};
	return radius;
}

//-----------------------------------------------------------------------------
// make sure quaternions are within 180 degrees of one another, if not, reverse q
//-----------------------------------------------------------------------------
function VS::QuaternionAlign( p, q, qt = _QUAT )
{
	local px = p.x,
		py = p.y,
		pz = p.z,
		pw = p.w,
		qx = q.x,
		qy = q.y,
		qz = q.z,
		qw = q.w;

	// a = dot(p-q)
	// b = dot(p+q)
	local a =
		(px-qx)*(px-qx)+(py-qy)*(py-qy)+
		(pz-qz)*(pz-qz)+(pw-qw)*(pw-qw);
	local b =
		(px+qx)*(px+qx)+(py+qy)*(py+qy)+
		(pz+qz)*(pz+qz)+(pw+qw)*(pw+qw);

	if ( a > b )
	{
		qt.x = -qx;
		qt.y = -qy;
		qt.z = -qz;
		qt.w = -qw;
	}
	else if ( qt != q )
	{
		qt.x = qx;
		qt.y = qy;
		qt.z = qz;
		qt.w = qw;
	};;

	return qt;
}

local QuaternionNormalize = VS.QuaternionNormalize;
local QuaternionAlign = VS.QuaternionAlign;

//-----------------------------------------------------------------------------
// qt = p * q
//-----------------------------------------------------------------------------
function VS::QuaternionMult( p, q, qt = _QUAT ) : (QuaternionAlign, Quaternion)
{
	if ( p == qt )
	{
		local p2 = Quaternion( p.x, p.y, p.z, p.w );
		return QuaternionMult( p2, q, qt );
	};

	// decide if one of the quaternions is backwards
	local q2 = QuaternionAlign( p, q );

	local px = p.x,
		py = p.y,
		pz = p.z,
		pw = p.w,
		qx = q2.x,
		qy = q2.y,
		qz = q2.z,
		qw = q2.w;

	qt.x = px * qw + py * qz - pz * qy + pw * qx;
	qt.y = py * qw + pz * qx + pw * qy - px * qz;
	qt.z = px * qy - py * qx + pz * qw + pw * qz;
	qt.w = pw * qw - px * qx - py * qy - pz * qz;

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
function VS::QuaternionMA( p, s, q, qt = _QUAT ) : ( Quaternion, QuaternionNormalize, QuaternionMult )
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

function VS::QuaternionAdd( p, q, qt = _QUAT ) : ( Quaternion, QuaternionAlign )
{
	local q2 = QuaternionAlign( p, q );

	qt.x = p.x + q2.x;
	qt.y = p.y + q2.y;
	qt.z = p.z + q2.z;
	qt.w = p.w + q2.w;

	return qt;
}

// QuaternionLength
function VS::QuaternionDotProduct( p, q )
{
	return p.x * q.x + p.y * q.y + p.z * q.z + p.w * q.w;
}

//-----------------------------------------------------------------------------
// q = p^-1 / pLenSqr
//-----------------------------------------------------------------------------
function VS::QuaternionInvert( p, q )
{
	// QuaternionDotProduct
	local magnitudeSqr = p.x*p.x + p.y*p.y + p.z*p.z + p.w*p.w;

	if ( magnitudeSqr )
	{
		local inv = 1.0 / magnitudeSqr;
		q.x = -p.x * inv;
		q.y = -p.y * inv;
		q.z = -p.z * inv;
		q.w = p.w * inv;
	};

	// Assert( magnitudeSqr );
}

//-----------------------------------------------------------------------------
// Do a piecewise addition of the quaternion elements. This actually makes little
// mathematical sense, but it's a cheap way to simulate a slerp.
// nlerp
//-----------------------------------------------------------------------------
function VS::QuaternionBlendNoAlign( p, q, t, qt = _QUAT ) : (QuaternionNormalize)
{
	local sclp = 1.0 - t, sclq = t;

	qt.x = sclp * p.x + sclq * q.x;
	qt.y = sclp * p.y + sclq * q.y;
	qt.z = sclp * p.z + sclq * q.z;
	qt.w = sclp * p.w + sclq * q.w;

	QuaternionNormalize( qt );

	return qt;
}

local QuaternionBlendNoAlign = VS.QuaternionBlendNoAlign;

function VS::QuaternionBlend( p, q, t, qt = _QUAT ) : (QuaternionAlign, QuaternionBlendNoAlign)
{
	// decide if one of the quaternions is backwards
	local q2 = QuaternionAlign( p, q );
	return QuaternionBlendNoAlign( p, q2, t, qt );
}

function VS::QuaternionIdentityBlend( p, t, qt = _QUAT ) : (QuaternionNormalize)
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
function VS::QuaternionSlerpNoAlign( p, q, t, qt = _QUAT ) : ( sin, acos )
{
	local sclp, sclq;

	// QuaternionDotProduct
	local cosom = p.x*q.x + p.y*q.y + p.z*q.z + p.w*q.w;

	if ( cosom > -0.999999 ) // ( (1.0 + cosom) > 0.000001 )
	{
		if ( cosom < 0.999999 ) // ( (1.0 - cosom) > 0.000001 )
		{
			local omega = acos( cosom );
			local invSinom = 1.0 / sin( omega );
			sclp = sin( (1.0 - t)*omega ) * invSinom;
			sclq = sin( t*omega ) * invSinom;
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
		sclp = sin( (1.0 - t) * PIDIV2 );
		sclq = sin( t * PIDIV2 );

		qt.x = sclp * p.x - sclq * q.y;
		qt.y = sclp * p.y + sclq * q.x;
		qt.z = sclp * p.z - sclq * q.w;
		qt.w = sclp * p.w + sclq * q.z;
	};

	return qt;
}

local QuaternionSlerpNoAlign = VS.QuaternionSlerpNoAlign;

function VS::QuaternionSlerp( p, q, t, qt = _QUAT ) : (QuaternionAlign, QuaternionSlerpNoAlign)
{
	// decide if one of the quaternions is backwards
	local q2 = QuaternionAlign( p, q );
	return QuaternionSlerpNoAlign( p, q2, t, qt );
}

//-------------------------------------------------
//
//
// DirectX (c) Microsoft
//-------------------------------------------------
function VS::QuaternionExp( p, q ) : (sqrt, sin, cos)
{
	// const Zero = XMVectorZero();
	// const g_XMEpsilon = XMVectorReplicate(1.192092896e-7f)

	// Theta = XMVector3Length(Q);
	local Theta = sqrt( p.x*q.x + p.y*q.y + p.z*q.z );

	// Control = XMVectorNearEqual(Theta, Zero, g_XMEpsilon.v);
	if ( Theta > FLT_EPSILON )
	{
		// XMVectorSinCos(&SinTheta, &CosTheta, Theta);
		local SinTheta = sin(Theta);

		// S = XMVectorDivide(SinTheta, Theta);
		local S = SinTheta / Theta;

		// Result = XMVectorMultiply(Q, S);
		// Result = XMVectorSelect(Result, Q, Control);
		q.x = S * p.x;
		q.y = S * p.y;
		q.z = S * p.z;
	}
	else
	{
		// Result = XMVectorSelect(Result, Q, Control);
		q.x = p.x;
		q.y = p.y;
		q.z = p.z;
	};
	// Result = XMVectorSelect(CosTheta, Result, g_XMSelect1110.v);
	q.w = cos(Theta);
}

//-------------------------------------------------
//
//
// DirectX (c) Microsoft
//-------------------------------------------------
function VS::QuaternionLn( p, q ) : (acos, sin)
{
	// const OneMinusEpsilon = XMVectorReplicate(1.0f - 0.00001f);

	// ControlW = XMVectorInBounds(QW, OneMinusEpsilon.v);
	if ( p.w > 0.99999 || -0.99999 > p.w )
	{
		// Theta = XMVectorACos(QW);
		local Theta = acos(p.w);

		// S = XMVectorDivide(Theta, XMVectorSin(Theta));
		local S = Theta / sin(Theta);

		// Result = XMVectorMultiply(Q0, S);
		// Result = XMVectorSelect(Q0, Result, ControlW);
		q.x = S * p.x;
		q.y = S * p.y;
		q.z = S * p.z;
	}
	else
	{
		// Result = XMVectorSelect(Q0, Result, ControlW);
		q.x = p.x;
		q.y = p.y;
		q.z = p.z;
	};
	// Q0 = XMVectorSelect(g_XMSelect1110.v, Q, g_XMSelect1110.v);
	q.w = 0.0;
}

//-------------------------------------------------
// Interpolates between quaternions Q1 to Q2, using spherical quadrangle interpolation.
//
// DirectX (c) Microsoft
//-------------------------------------------------
function VS::QuaternionSquad( Q0, Q1, Q2, Q3, T, out ) : (Quaternion, QuaternionSlerpNoAlign)
{
	// FLOAT T;
	// XMVECTOR Q0;
	// XMVECTOR Q1;
	// XMVECTOR Q2;
	// XMVECTOR Q3;
	//
	// XMQuaternionSquadSetup( &Q1, &Q2, &Q3, Q0, Q1, Q2, Q3 );
	// XMVECTOR spline = XMQuaternionSquad( Q1, Q1, Q2, Q3, T );
	//
	//------------------------------------------------------------------
	// XMQuaternionSquadSetup(*pA, *pB, *pC, Q0, Q1, Q2, Q3)
		// QuaternionAlign( Q1, Q2 )
			// LS12 = XMQuaternionLengthSq(XMVectorAdd(Q1, Q2));
			local aQ12x = Q1.x + Q2.x;
			local aQ12y = Q1.y + Q2.y;
			local aQ12z = Q1.z + Q2.z;
			local aQ12w = Q1.w + Q2.w;
			local LS12 = aQ12x*aQ12x + aQ12y*aQ12y + aQ12z*aQ12z + aQ12w*aQ12w;

			// LD12 = XMQuaternionLengthSq(XMVectorSubtract(Q1, Q2));
			local sQ12x = Q1.x - Q2.x;
			local sQ12y = Q1.y - Q2.y;
			local sQ12z = Q1.z - Q2.z;
			local sQ12w = Q1.w - Q2.w;
			local LD12 = sQ12x*sQ12x + sQ12y*sQ12y + sQ12z*sQ12z + sQ12w*sQ12w;

			local SQ2;
			// Control1 = XMVectorLess(LS12, LD12);
			// SQ2 = XMVectorSelect(Q2, XMVectorNegate(Q2), Control1);
			if ( LS12 < LD12 )
			{
				SQ2 = Quaternion( -Q2.x, -Q2.y, -Q2.z, -Q2.w );
			}
			else
			{
				SQ2 = Q2;
			};

		// QuaternionAlign( Q0, Q1 )
			// LS01 = XMQuaternionLengthSq(XMVectorAdd(Q0, Q1));
			local aQ01x = Q0.x + Q1.x;
			local aQ01y = Q0.y + Q1.y;
			local aQ01z = Q0.z + Q1.z;
			local aQ01w = Q0.w + Q1.w;
			local LS01 = aQ01x*aQ01x + aQ01y*aQ01y + aQ01z*aQ01z + aQ01w*aQ01w;

			// LD01 = XMQuaternionLengthSq(XMVectorSubtract(Q0, Q1));
			local sQ01x = Q0.x - Q1.x;
			local sQ01y = Q0.y - Q1.y;
			local sQ01z = Q0.z - Q1.z;
			local sQ01w = Q0.w - Q1.w;
			local LD01 = sQ01x*sQ01x + sQ01y*sQ01y + sQ01z*sQ01z + sQ01w*sQ01w;

			local SQ0;
			// Control0 = XMVectorLess(LS01, LD01);
			// SQ0 = XMVectorSelect(Q0, XMVectorNegate(Q0), Control0);
			if ( LS01 < LD01 )
			{
				SQ0 = Quaternion( -Q0.x, -Q0.y, -Q0.z, -Q0.w );
			}
			else
			{
				SQ0 = Q0;
			};

		// QuaternionAlign( Q2, Q3 )
			// LS23 = XMQuaternionLengthSq(XMVectorAdd(SQ2, Q3));
			local aQ23x = Q2.x + Q3.x;
			local aQ23y = Q2.y + Q3.y;
			local aQ23z = Q2.z + Q3.z;
			local aQ23w = Q2.w + Q3.w;
			local LS23 = aQ23x*aQ23x + aQ23y*aQ23y + aQ23z*aQ23z + aQ23w*aQ23w;

			// LD23 = XMQuaternionLengthSq(XMVectorSubtract(SQ2, Q3));
			local sQ23x = Q2.x - Q3.x;
			local sQ23y = Q2.y - Q3.y;
			local sQ23z = Q2.z - Q3.z;
			local sQ23w = Q2.w - Q3.w;
			local LD23 = sQ23x*sQ23x + sQ23y*sQ23y + sQ23z*sQ23z + sQ23w*sQ23w;

			local SQ3;
			// Control2 = XMVectorLess(LS23, LD23);
			// SQ3 = XMVectorSelect(Q3, XMVectorNegate(Q3), Control2);
			if ( LS23 < LD23 )
			{
				SQ3 = Quaternion( -Q3.x, -Q3.y, -Q3.z, -Q3.w );
			}
			else
			{
				SQ3 = Q3;
			};

		// InvQ1 = XMQuaternionInverse(Q1);
		local InvQ1 = Quaternion();
		QuaternionInvert( Q1, InvQ1 );
		// InvQ2 = XMQuaternionInverse(SQ2);
		local InvQ2 = Quaternion();
		QuaternionInvert( Q2, InvQ2 );

		// LnQ0 = XMQuaternionLn(XMQuaternionMultiply(InvQ1, SQ0));
		local LnQ0 = Quaternion();
			// QuaternionMult(InvQ1, SQ0, LnQ0)
			LnQ0.x =  InvQ1.x * SQ0.w + InvQ1.y * SQ0.z - InvQ1.z * SQ0.y + InvQ1.w * SQ0.x;
			LnQ0.y = -InvQ1.x * SQ0.z + InvQ1.y * SQ0.w + InvQ1.z * SQ0.x + InvQ1.w * SQ0.y;
			LnQ0.z =  InvQ1.x * SQ0.y - InvQ1.y * SQ0.x + InvQ1.z * SQ0.w + InvQ1.w * SQ0.z;
			LnQ0.w = -InvQ1.x * SQ0.x - InvQ1.y * SQ0.y - InvQ1.z * SQ0.z + InvQ1.w * SQ0.w;
			// QuaternionLn(LnQ0, LnQ0)
			QuaternionLn(LnQ0, LnQ0);

		// LnQ2 = XMQuaternionLn(XMQuaternionMultiply(InvQ1, SQ2));
		local LnQ2 = Quaternion();
			// QuaternionMult(InvQ1, SQ2, LnQ2)
			LnQ2.x =  InvQ1.x * SQ2.w + InvQ1.y * SQ2.z - InvQ1.z * SQ2.y + InvQ1.w * SQ2.x;
			LnQ2.y = -InvQ1.x * SQ2.z + InvQ1.y * SQ2.w + InvQ1.z * SQ2.x + InvQ1.w * SQ2.y;
			LnQ2.z =  InvQ1.x * SQ2.y - InvQ1.y * SQ2.x + InvQ1.z * SQ2.w + InvQ1.w * SQ2.z;
			LnQ2.w = -InvQ1.x * SQ2.x - InvQ1.y * SQ2.y - InvQ1.z * SQ2.z + InvQ1.w * SQ2.w;
			// QuaternionLn(LnQ2, LnQ2)
			QuaternionLn(LnQ2, LnQ2);

		// LnQ1 = XMQuaternionLn(XMQuaternionMultiply(InvQ2, Q1));
		local LnQ1 = Quaternion();
			// QuaternionMult(InvQ2, Q1, LnQ1)
			LnQ1.x =  InvQ2.x * Q1.w + InvQ2.y * Q1.z - InvQ2.z * Q1.y + InvQ2.w * Q1.x;
			LnQ1.y = -InvQ2.x * Q1.z + InvQ2.y * Q1.w + InvQ2.z * Q1.x + InvQ2.w * Q1.y;
			LnQ1.z =  InvQ2.x * Q1.y - InvQ2.y * Q1.x + InvQ2.z * Q1.w + InvQ2.w * Q1.z;
			LnQ1.w = -InvQ2.x * Q1.x - InvQ2.y * Q1.y - InvQ2.z * Q1.z + InvQ2.w * Q1.w;
			// QuaternionLn(LnQ1, LnQ1)
			QuaternionLn(LnQ1, LnQ1);

		// LnQ3 = XMQuaternionLn(XMQuaternionMultiply(InvQ2, SQ3));
		local LnQ3 = Quaternion();
			// QuaternionMult(InvQ2, SQ3, LnQ3)
			LnQ3.x =  InvQ2.x * SQ3.w + InvQ2.y * SQ3.z - InvQ2.z * SQ3.y + InvQ2.w * SQ3.x;
			LnQ3.y = -InvQ2.x * SQ3.z + InvQ2.y * SQ3.w + InvQ2.z * SQ3.x + InvQ2.w * SQ3.y;
			LnQ3.z =  InvQ2.x * SQ3.y - InvQ2.y * SQ3.x + InvQ2.z * SQ3.w + InvQ2.w * SQ3.z;
			LnQ3.w = -InvQ2.x * SQ3.x - InvQ2.y * SQ3.y - InvQ2.z * SQ3.z + InvQ2.w * SQ3.w;
			// QuaternionLn(LnQ3, LnQ3)
			QuaternionLn(LnQ3, LnQ3);

		// const NegativeOneQuarter = XMVectorSplatConstant(-1, 2);
		// const NegativeOneQuarter = XMVectorReplicate(-0.25);

		// ExpQ02 = XMVectorMultiply(XMVectorAdd(LnQ0, LnQ2), NegativeOneQuarter);
		local ExpQ02 = Quaternion();
		ExpQ02.x = -0.25 * (LnQ0.x + LnQ2.x);
		ExpQ02.y = -0.25 * (LnQ0.y + LnQ2.y);
		ExpQ02.z = -0.25 * (LnQ0.z + LnQ2.z);
		ExpQ02.w = -0.25 * (LnQ0.w + LnQ2.w);
		// ExpQ02 = XMQuaternionExp(ExpQ02);
		QuaternionExp(ExpQ02, ExpQ02);

		// ExpQ13 = XMVectorMultiply(XMVectorAdd(LnQ1, LnQ3), NegativeOneQuarter);
		local ExpQ13 = Quaternion();
		ExpQ13.x = -0.25 * (LnQ1.x + LnQ3.x);
		ExpQ13.y = -0.25 * (LnQ1.y + LnQ3.y);
		ExpQ13.z = -0.25 * (LnQ1.z + LnQ3.z);
		ExpQ13.w = -0.25 * (LnQ1.w + LnQ3.w);
		// ExpQ13 = XMQuaternionExp(ExpQ13);
		QuaternionExp(ExpQ13, ExpQ13);

		// pA = XMQuaternionMultiply(Q1, ExpQ02);
		local pA = Quaternion();
			// QuaternionMult(Q1, ExpQ02, pA)
			pA.x =  Q1.x * ExpQ02.w + Q1.y * ExpQ02.z - Q1.z * ExpQ02.y + Q1.w * ExpQ02.x;
			pA.y = -Q1.x * ExpQ02.z + Q1.y * ExpQ02.w + Q1.z * ExpQ02.x + Q1.w * ExpQ02.y;
			pA.z =  Q1.x * ExpQ02.y - Q1.y * ExpQ02.x + Q1.z * ExpQ02.w + Q1.w * ExpQ02.z;
			pA.w = -Q1.x * ExpQ02.x - Q1.y * ExpQ02.y - Q1.z * ExpQ02.z + Q1.w * ExpQ02.w;

		// pB = XMQuaternionMultiply(SQ2, ExpQ13);
		local pB = Quaternion();
			// QuaternionMult(SQ2, ExpQ13, pB)
			pB.x =  SQ2.x * ExpQ13.w + SQ2.y * ExpQ13.z - SQ2.z * ExpQ13.y + SQ2.w * ExpQ13.x;
			pB.y = -SQ2.x * ExpQ13.z + SQ2.y * ExpQ13.w + SQ2.z * ExpQ13.x + SQ2.w * ExpQ13.y;
			pB.z =  SQ2.x * ExpQ13.y - SQ2.y * ExpQ13.x + SQ2.z * ExpQ13.w + SQ2.w * ExpQ13.z;
			pB.w = -SQ2.x * ExpQ13.x - SQ2.y * ExpQ13.y - SQ2.z * ExpQ13.z + SQ2.w * ExpQ13.w;

		// pC = SQ2;
		local pC = SQ2;

	// XMQuaternionSquad(Q0, Q1, Q2, Q3, T, out)
		local Q0 = Q1;
		local Q1 = pA;
		local Q2 = pB;
		local Q3 = pC;

		// XMQuaternionSlerpV
		local Q03 = Quaternion();
		QuaternionSlerpNoAlign( Q0, Q3, T, Q03 );

		// XMQuaternionSlerpV
		local Q12 = Quaternion();
		QuaternionSlerpNoAlign( Q1, Q2, T, Q12 );

		// TP = XMVectorReplicate(T);
		// const Two = XMVectorSplatConstant(2, 0);
		// TP = XMVectorNegativeMultiplySubtract(TP, TP, TP);
		// TP = XMVectorMultiply(TP, Two);
		T = (T - T * T) * 2.0;

		QuaternionSlerpNoAlign( Q03, Q12, T, out );
}


// TODO: weights
function VS::QuaternionAverageExponential( q, nCount, pStack ) : (Quaternion)
{
	local pFirst = pStack[0];

	if ( nCount == 1 )
	{
		q.x = pFirst.x;
		q.y = pFirst.y;
		q.z = pFirst.z;
		q.w = pFirst.w;
		return;
	};

	local weight = 1.0 / nCount;

	local sum = Quaternion();
	local tmp = Quaternion();

	for ( local i = 0; i < nCount; ++i )
	{
		QuaternionAlign( pFirst, pStack[i], tmp );
		QuaternionLn( tmp, tmp );
		sum.x += tmp.x * weight;
		sum.y += tmp.y * weight;
		sum.z += tmp.z * weight;
		sum.w += tmp.w * weight;
	}

	QuaternionExp( sum, q );
}

//-----------------------------------------------------------------------------
// Purpose: Returns the angular delta between the two normalized quaternions in degrees.
//-----------------------------------------------------------------------------
function VS::QuaternionAngleDiff( p, q ) : ( Quaternion, QuaternionMult, sqrt, asin )
{
// #if 1
	// this code path is here for 2 reasons:
	// 1 - acos maps 1-epsilon to values much larger than epsilon (vs asin, which maps epsilon to itself)
	//     this means that in floats, anything below ~0.05 degrees truncates to 0
	// 2 - normalized quaternions are frequently slightly non-normalized due to float precision issues,
	//     and the epsilon off of normalized can be several percents of a degree

	// QuaternionConjugate( q, qInv );
	local qInv = Quaternion( -q.x, -q.y, -q.z, q.w );
	local diff = QuaternionMult( p, qInv );

	// Note if the quaternion is slightly non-normalized the square root below may be more than 1,
	// the value is clamped to one otherwise it may result in asin() returning an undefined result.
	local sinang = sqrt( diff.x * diff.x + diff.y * diff.y + diff.z * diff.z );
	if ( sinang > 1.0 )
		sinang = 1.0;

	return asin(sinang) * RAD2DEG2;
/*
#else
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
*/
}

function VS::QuaternionScale( p, t, q ) : ( Vector, sqrt, sin, asin )
{
/*
#if 0
	local p0 = Quaternion();
	local q = Quaternion();
	p0.Init( 0.0, 0.0, 0.0, 1.0 );

	// slerp in "reverse order" so that p doesn't get realigned
	QuaternionSlerp( p, p0, 1.0 - fabs( t ), q );
	if(t < 0.0)
	{
		q.w = -q.w;
	}
#else
*/
	// FIXME: this isn't overly sensitive to accuracy, and it may be faster to
	// use the cos part (w) of the quaternion (sin(omega)*N,cos(omega)) to figure the new scale.

	local qv = Vector(p.x,p.y,p.z);
	local sinom = qv.Length();
	if ( sinom > 1.0 )
		sinom = 1.0;

	local sinsom = sin( asin( sinom ) * t );

	t = sinsom / (sinom + FLT_EPSILON);
	VectorScale( qv, t, q );

	// rescale rotation
	local r = 1.0 - sinsom * sinsom;

	// Assert( r >= 0 );
	if ( r < 0.0 )
		r = 0.0;
	r = sqrt( r );

	// keep sign of rotation
	if ( 0.0 > p.w )
		q.w = -r;
	else
		q.w = r;
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
	QuaternionScale( srcQuat, -1.0, srcQuatInv );
	QuaternionMult( destQuat, srcQuatInv, out );

	QuaternionNormalize( out );
	QuaternionAxisAngle( out, deltaAxis, deltaAngle );
}

// QAngle , QAngle , Vector, float
function VS::RotationDelta( srcAngles, destAngles, out ) : ( matrix3x4_t )
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

function VS::MatrixQuaternionFast( matrix, q ) : (sqrt)
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
		if ( -matrix[1][1] > matrix[0][0] )
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


local MatrixQuaternionFast = VS.MatrixQuaternionFast;

function VS::QuaternionMatrix( q, pos, matrix )
{
	matrix = matrix.m;
/*
#if 1
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
#else
*/
	local x = q.x, y = q.y, z = q.z, w = q.w;
	local x2 = x + x,
		y2 = y + y,
		z2 = z + z,
		xx = x * x2,
		xy = x * y2,
		xz = x * z2,
		yy = y * y2,
		yz = y * z2,
		zz = z * z2,
		wx = w * x2,
		wy = w * y2,
		wz = w * z2;

	matrix[0][0] = 1.0 - (yy + zz);
	matrix[1][0] = xy + wz;
	matrix[2][0] = xz - wy;

	matrix[0][1] = xy - wz;
	matrix[1][1] = 1.0 - (xx + zz);
	matrix[2][1] = yz + wx;

	matrix[0][2] = xz + wy;
	matrix[1][2] = yz - wx;
	matrix[2][2] = 1.0 - (xx + yy);

	if (pos)
	{
		matrix[0][3] = pos.x;
		matrix[1][3] = pos.y;
		matrix[2][3] = pos.z;
	}
	else
	{
		matrix[0][3] = matrix[1][3] = matrix[2][3] = 0.0;
	};
}

//-----------------------------------------------------------------------------
// Purpose: Converts a quaternion into engine angles
// Input  : *quaternion - q3 + q0.i + q1.j + q2.k
//          *outAngles - PITCH, YAW, ROLL
//-----------------------------------------------------------------------------
function VS::QuaternionAngles2( q, angles = _VEC ):(asin,atan2)
{
/*
#if 1
	// FIXME: doing it this way calculates too much data, needs to do an optimized version...
	local matrix = matrix3x4_t();
	QuaternionMatrix( q, matrix );
	MatrixAngles( matrix, angles );
#else
*/
	local m11 = ( 2.0 * q.w * q.w ) + ( 2.0 * q.x * q.x ) - 1.0,
	      m12 = ( 2.0 * q.x * q.y ) + ( 2.0 * q.w * q.z ),
	      m13 = ( 2.0 * q.x * q.z ) - ( 2.0 * q.w * q.y ),
	      m23 = ( 2.0 * q.y * q.z ) + ( 2.0 * q.w * q.x ),
	      m33 = ( 2.0 * q.w * q.w ) + ( 2.0 * q.z * q.z ) - 1.0;
	// FIXME: this code has a singularity near PITCH +-90
	angles.y = RAD2DEG*atan2(m12, m11);
	angles.x = RAD2DEG*asin(-m13);
	angles.z = RAD2DEG*atan2(m23, m33);

	return angles;
}

local QuaternionMatrix = VS.QuaternionMatrix;

function VS::QuaternionAngles( q, angles = _VEC ) : ( matrix3x4_t, QuaternionMatrix, MatrixAngles )
{
	// FIXME: doing it this way calculates too much data, needs to do an optimized version...
	local matrix = matrix3x4_t();
	QuaternionMatrix( q, null, matrix );
	return MatrixAngles( matrix, angles );
}

//-----------------------------------------------------------------------------
// Purpose: Converts a quaternion to an axis / angle in degrees
//          (exponential map)
//-----------------------------------------------------------------------------
function VS::QuaternionAxisAngle( q, axis ):(acos)
{
	local angle = acos(q.w)*RAD2DEG2;

	// AngleNormalize
	if( angle > 180.0 )
		angle -= 360.0;

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
	angle *= DEG2RADDIV2;

	local sa = sin(angle);

	q.x = axis.x * sa;
	q.y = axis.y * sa;
	q.z = axis.z * sa;
	q.w = cos(angle);

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
	local ay = angles.y * DEG2RADDIV2,
		ax = angles.x * DEG2RADDIV2,
		az = angles.z * DEG2RADDIV2;

	local sy = sin(ay),
		cy = cos(ay),

		sp = sin(ax),
		cp = cos(ax),

		sr = sin(az),
		cr = cos(az);

	local srXcp = sr * cp, crXsp = cr * sp;
	outQuat.x = srXcp*cy-crXsp*sy;
	outQuat.y = crXsp*cy+srXcp*sy;

	local crXcp = cr * cp, srXsp = sr * sp;
	outQuat.z = crXcp*sy-srXsp*cy;
	outQuat.w = crXcp*cy+srXsp*sy;

	return outQuat;
}

local AngleQuaternion = VS.AngleQuaternion;

function VS::MatrixQuaternion( mat, q = _QUAT ) : (AngleQuaternion, MatrixAngles)
{
	local angles = MatrixAngles( mat );
	return AngleQuaternion( angles, q );
}

//-----------------------------------------------------------------------------
// Purpose: Converts a basis to a quaternion
//-----------------------------------------------------------------------------
function VS::BasisToQuaternion( vecForward, vecRight, vecUp, q = _QUAT ) : ( matrix3x4_t, MatrixQuaternionFast )
{
	// Assert( fabs( vecForward.LengthSqr() - 1.0 ) < 1.e-3 );
	// Assert( fabs( vecRight.LengthSqr() - 1.0 ) < 1.e-3 );
	// Assert( fabs( vecUp.LengthSqr() - 1.0 ) < 1.e-3 );

	// local vecLeft = vecRight * -1.0;

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

	// Version 2:

	local mat = matrix3x4_t(
		vecForward.x, -vecRight.x, vecUp.x, 0.0,
		vecForward.y, -vecRight.y, vecUp.y, 0.0,
		vecForward.z, -vecRight.z, vecUp.z, 0.0 );

	MatrixQuaternionFast( mat, q );

	// Assert( fabs(q.x - q2.x) < 1.e-3 );
	// Assert( fabs(q.y - q2.y) < 1.e-3 );
	// Assert( fabs(q.z - q2.z) < 1.e-3 );
	// Assert( fabs(q.w - q2.w) < 1.e-3 );

	return q;
}


function VS::MatricesAreEqual( src1, src2, flTolerance )
{
	src1 = src1.m;
	src2 = src2.m;

	for ( local i = 3; i--; )
		for ( local j = 4; j--; )
		{
			local f = src1[i][j] - src2[i][j];
			if ( 0.0 > f ) f = -f;
			if ( f > flTolerance )
				return false;
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
function VS::MatrixInvert( in1, out )
{
	in1 = in1.m;
	out = out.m;

	if ( in1 == out )
	{
		local t = out[0][1];
		out[0][1] = out[1][0];
		out[1][0] = t;

		t = out[0][2];
		out[0][2] = out[2][0];
		out[2][0] = t;

		t = out[1][2];
		out[1][2] = out[2][1];
		out[2][1] = t;
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

//-----------------------------------------------------------------------------
// Inverts any matrix at all
//-----------------------------------------------------------------------------
function VS::MatrixInverseGeneral( src, dst ) : ( array, fabs )
{
	local mat = array( 4 );
	for ( local i = 4; i--; )
		mat[i] = array( 8, 0.0 );

	local rowMap = array( 4, 0 );

	// How it's done.
	// AX = I
	// A = this
	// X = the matrix we're looking for
	// I = identity

	src = src.m;

	// Setup AI
	for ( local i = 0; i < 4; ++i )
	{
		local pIn = src[i];
		local pOut = mat[i];

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

	for ( local iRow = 0; iRow < 4; ++iRow )
	{
		// Find the row with the largest element in this column.
		local fLargest = 0.00001;
		local iLargest = 0xFFFFFFFF;
		for ( local iTest = iRow; iTest < 4; ++iTest )
		{
			local fTest = fabs( mat[rowMap[iTest]][iRow] );
			if (fTest > fLargest)
			{
				iLargest = iTest;
				fLargest = fTest;
			}
		}

		// They're all too small.. sorry.
		if (iLargest == 0xFFFFFFFF)
			return false;

		// Swap the rows.
		local iTemp = rowMap[iLargest];
		rowMap[iLargest] = rowMap[iRow];
		rowMap[iRow] = iTemp;

		local pRow = mat[rowMap[iRow]];

		// Divide this row by the element.
		local mul = 1.0 / pRow[iRow];
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
		for ( local i = 0; i < 4; ++i )
		{
			if (i == iRow)
				continue;

			local pScaleRow = mat[rowMap[i]];

			// Multiply this row by -(iRow*the element).
			local mul = pScaleRow[iRow];
				pScaleRow[0] -= pRow[0] * mul;
				pScaleRow[1] -= pRow[1] * mul;
				pScaleRow[2] -= pRow[2] * mul;
				pScaleRow[3] -= pRow[3] * mul;
				pScaleRow[4] -= pRow[4] * mul;
				pScaleRow[5] -= pRow[5] * mul;
				pScaleRow[6] -= pRow[6] * mul;
				pScaleRow[7] -= pRow[7] * mul;
			pScaleRow[iRow] = 0.0; // Preserve accuracy...
		}
	}

	dst = dst.m;

	// The inverse is on the right side of AX now (the identity is on the left).
	for ( local i = 0; i < 4; ++i )
	{
		local pIn = mat[rowMap[i]];
		local pOut = dst[i];
			pOut[0] = pIn[0 + 4];
			pOut[1] = pIn[1 + 4];
			pOut[2] = pIn[2 + 4];
			pOut[3] = pIn[3 + 4];
	}

	return true;
}

//-----------------------------------------------------------------------------
// Does a fast inverse, assuming the matrix only contains translation and rotation.
//-----------------------------------------------------------------------------
function VS::MatrixInverseTR( src, dst )
{
	src = src.m;
	dst = dst.m;

	// Transpose the upper 3x3.
	dst[0][0] = src[0][0];  dst[0][1] = src[1][0]; dst[0][2] = src[2][0];
	dst[1][0] = src[0][1];  dst[1][1] = src[1][1]; dst[1][2] = src[2][1];
	dst[2][0] = src[0][2];  dst[2][1] = src[1][2]; dst[2][2] = src[2][2];

	// Transform the translation.
	// Vector vTrans( -src.m[0][3], -src.m[1][3], -src.m[2][3] );
	// Vector3DMultiply( dst, vTrans, vNewTrans );
	// MatrixSetColumn( dst, 3, vNewTrans );
	dst[0][3] = dst[0][0] * -src[0][3] - dst[0][1] * src[1][3] - dst[0][2] * src[2][3];
	dst[1][3] = dst[1][0] * -src[0][3] - dst[1][1] * src[1][3] - dst[1][2] * src[2][3];
	dst[2][3] = dst[2][0] * -src[0][3] - dst[2][1] * src[1][3] - dst[2][2] * src[2][3];

	dst[3][0] = dst[3][1] = dst[3][2] = 0.0;
	dst[3][3] = 1.0;
}

/*
// matrix, int, vector
function VS::MatrixRowDotProduct( in1, row, in2 )
{
	in1row = in1.m[row];
	return in1row[0] * in2.x + in1row[1] * in2.y + in1row[2] * in2.z;
}

function VS::MatrixColumnDotProduct( in1, col, in2 )
{
	in1 = in1.m;
	return in1[0][col] * in2.x + in1[1][col] * in2.y + in1[2][col] * in2.z;
}
*/

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

	out[0][0] =
	out[1][0] =
	out[2][0] =
	out[0][1] =
	out[1][1] =
	out[2][1] =
	out[0][2] =
	out[1][2] =
	out[2][2] = 0.0;
}

function VS::SetIdentityMatrix( matrix )
{
	// SetScaleMatrix( 1.0, 1.0, 1.0, matrix );

	matrix = matrix.m;

	matrix[0][0] = matrix[1][1] = matrix[2][2] = 1.0;

	matrix[0][1] = matrix[0][2] = matrix[0][3] =
	matrix[1][0] = matrix[1][2] = matrix[1][3] =
	matrix[2][0] = matrix[2][1] = matrix[2][3] = 0.0;
}

//-----------------------------------------------------------------------------
// Builds a scale matrix
//-----------------------------------------------------------------------------
function VS::SetScaleMatrix( x, y, z, dst )
{
	dst = dst.m;

	dst[0][0] = x;
	dst[1][1] = y;
	dst[2][2] = z;

	dst[0][1] = dst[0][2] = dst[0][3] =
	dst[1][0] = dst[1][2] = dst[1][3] =
	dst[2][0] = dst[2][1] = dst[2][3] = 0.0;
}

//-----------------------------------------------------------------------------
// Compute a matrix that has the correct orientation but which has an origin at
// the center of the bounds
//-----------------------------------------------------------------------------
function VS::ComputeCenterMatrix( origin, angles, mins, maxs, matrix ) : (VectorRotate, AngleMatrix)
{
	AngleMatrix( angles, null, matrix );

	local centroid = (mins + maxs)*0.5;
	local worldCentroid = VectorRotate( centroid, matrix ) + origin;

	// MatrixSetColumn( worldCentroid, 3, matrix );
	matrix = matrix.m;
	matrix[0][3] = worldCentroid.x;
	matrix[1][3] = worldCentroid.y;
	matrix[2][3] = worldCentroid.z;
}

function VS::ComputeCenterIMatrix( origin, angles, mins, maxs, matrix ) : (VectorRotate, AngleIMatrix)
{
	AngleIMatrix( angles, null, matrix );

	// For the translational component here, note that the origin in world space
	// is T = R * C + O, (R = rotation matrix, C = centroid in local space, O = origin in world space)
	// The IMatrix translation = - transpose(R) * T = -C - transpose(R) * 0
	local localOrigin = VectorRotate( origin, matrix );
	local centroid = (mins + maxs)*-0.5 - localOrigin;

	// MatrixSetColumn( centroid, 3, matrix );
	matrix = matrix.m;
	matrix[0][3] = centroid.x;
	matrix[1][3] = centroid.y;
	matrix[2][3] = centroid.z;
}

//-----------------------------------------------------------------------------
// Compute a matrix which is the absolute value of another
//-----------------------------------------------------------------------------
function VS::ComputeAbsMatrix( in1, out ) : (fabs)
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
	local radians = angleDegrees * DEG2RAD;
	local fSin = sin( radians );
	local fCos = cos( radians );

	local xx = vAxisOfRot.x * vAxisOfRot.x;
	local yy = vAxisOfRot.y * vAxisOfRot.y;
	local zz = vAxisOfRot.z * vAxisOfRot.z;

	dst = dst.m;

	dst[0][0] = xx + (1.0 - xx) * fCos;
	dst[1][1] = yy + (1.0 - yy) * fCos;
	dst[2][2] = zz + (1.0 - zz) * fCos;

	fCos = 1.0 - fCos;

	local xyc = vAxisOfRot.x * vAxisOfRot.y * fCos;
	local yzc = vAxisOfRot.y * vAxisOfRot.z * fCos;
	local xzc = vAxisOfRot.z * vAxisOfRot.x * fCos;

	local xs = vAxisOfRot.x * fSin;
	local ys = vAxisOfRot.y * fSin;
	local zs = vAxisOfRot.z * fSin;

	dst[1][0] = xyc + zs;
	dst[2][0] = xzc - ys;

	dst[0][1] = xyc - zs;
	dst[2][1] = yzc + xs;

	dst[0][2] = xzc + ys;
	dst[1][2] = yzc - xs;

	dst[0][3] = dst[1][3] = dst[2][3] = 0.0;
}

local MatrixBuildRotationAboutAxis = VS.MatrixBuildRotationAboutAxis;

//-----------------------------------------------------------------------------
// Builds a rotation matrix that rotates one direction vector into another
//
// Input  : matrix
//          Vector
//          Vector
//-----------------------------------------------------------------------------
function VS::MatrixBuildRotation( dst, initialDirection, finalDirection ) : ( Vector, fabs, acos, MatrixBuildRotationAboutAxis )
{
	local angle = initialDirection.Dot( finalDirection );
	// Assert( IsFinite(angle) );

	local axis;

	// No rotation required
	if ( angle > 0.999 )
	{
		// parallel case
		return SetIdentityMatrix(dst);
	}
	else if ( -0.999 > angle )
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

		axis = Vector();
		axis[idx] = 1.0;

		// VectorMA( axis, -axis.Dot( finalDirection ), finalDirection, axis );
		local t = -axis.Dot( finalDirection );
		axis.x += finalDirection.x * t;
		axis.y += finalDirection.y * t;
		axis.z += finalDirection.z * t;
		axis.Norm();
		angle = 180.0;
	}
	else
	{
		axis = initialDirection.Cross( finalDirection );
		axis.Norm();
		angle = acos(angle) * RAD2DEG;
	};;

	return MatrixBuildRotationAboutAxis( axis, angle, dst );

/*
#ifdef _DEBUG
	local test = Vector();
	VectorRotate( initialDirection, dst, test );
	test -= finalDirection;
	Assert( test.LengthSqr() < 1e-3 );
#endif
*/
}

/*
//-----------------------------------------------------------------------------
// Matrix/vector multiply
// NOTE: identical to VectorRotate
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
// Vector3DMultiplyPosition treats src2 as if it's a point (adds the translation)
// NOTE: identical to VectorTransform
//
// Input  : VMatrix
//          Vector
//          Vector
//-----------------------------------------------------------------------------
function VS::Vector3DMultiplyPosition( src1, src2, dst )
{
	src1 = src1.m;
	local x = src1[0][0] * src2.x + src1[0][1] * src2.y + src1[0][2] * src2.z + src1[0][3];
	local y = src1[1][0] * src2.x + src1[1][1] * src2.y + src1[1][2] * src2.z + src1[1][3];
	local z = src1[2][0] * src2.x + src1[2][1] * src2.y + src1[2][2] * src2.z + src1[2][3];

	dst.x = x;
	dst.y = y;
	dst.z = z;
}
*/
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
	local invw = 1.0  / ( src1[3][0] * src2.x + src1[3][1] * src2.y + src1[3][2] * src2.z );
	local x    = invw * ( src1[0][0] * src2.x + src1[0][1] * src2.y + src1[0][2] * src2.z );
	local y    = invw * ( src1[1][0] * src2.x + src1[1][1] * src2.y + src1[1][2] * src2.z );
	local z    = invw * ( src1[2][0] * src2.x + src1[2][1] * src2.y + src1[2][2] * src2.z );

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
function VS::TransformAABB( transform, vecMinsIn, vecMaxsIn, vecMinsOut, vecMaxsOut )
	: ( Vector, fabs, VectorAdd, VectorSubtract, VectorTransform )
{
	local localCenter = (vecMinsIn + vecMaxsIn) * 0.5;

	local localExtents = vecMaxsIn - localCenter;

	local worldCenter = VectorTransform( localCenter, transform );

	transform = transform.m;

	local worldExtents = Vector(
		fabs( localExtents.x * transform[0][0] ) +
		fabs( localExtents.y * transform[0][1] ) +
		fabs( localExtents.z * transform[0][2] ),

		fabs( localExtents.x * transform[1][0] ) +
		fabs( localExtents.y * transform[1][1] ) +
		fabs( localExtents.z * transform[1][2] ),

		fabs( localExtents.x * transform[2][0] ) +
		fabs( localExtents.y * transform[2][1] ) +
		fabs( localExtents.z * transform[2][2] ) );

	VectorSubtract( worldCenter, worldExtents, vecMinsOut );
	VectorAdd( worldCenter, worldExtents, vecMaxsOut );
}

//-----------------------------------------------------------------------------
// Uses the inverse transform of in1
//-----------------------------------------------------------------------------
function VS::ITransformAABB( transform, vecMinsIn, vecMaxsIn, vecMinsOut, vecMaxsOut )
	: ( Vector, fabs, VectorAdd, VectorSubtract, VectorITransform )
{
	local worldCenter = (vecMinsIn + vecMaxsIn) * 0.5;

	local worldExtents = vecMaxsIn - worldCenter;

	local localCenter = VectorITransform( worldCenter, transform );

	transform = transform.m;

	local localExtents = Vector(
		fabs( worldExtents.x * transform[0][0] ) +
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
	: ( Vector, fabs, VectorAdd, VectorSubtract, VectorRotate )
{
	local localCenter = (vecMinsIn + vecMaxsIn) * 0.5;

	local localExtents = vecMaxsIn - localCenter;

	local newCenter = VectorRotate( localCenter, transform );

	transform = transform.m;

	local newExtents = Vector(
		fabs( localExtents.x * transform[0][0] ) +
		fabs( localExtents.y * transform[0][1] ) +
		fabs( localExtents.z * transform[0][2] ),

		fabs( localExtents.x * transform[1][0] ) +
		fabs( localExtents.y * transform[1][1] ) +
		fabs( localExtents.z * transform[1][2] ),

		fabs( localExtents.x * transform[2][0] ) +
		fabs( localExtents.y * transform[2][1] ) +
		fabs( localExtents.z * transform[2][2] ) );

	VectorSubtract( newCenter, newExtents, vecMinsOut );
	VectorAdd( newCenter, newExtents, vecMaxsOut );
}

//-----------------------------------------------------------------------------
// Uses the inverse transform of in1
//-----------------------------------------------------------------------------
function VS::IRotateAABB( transform, vecMinsIn, vecMaxsIn, vecMinsOut, vecMaxsOut )
	: ( Vector, fabs, VectorAdd, VectorSubtract, VectorIRotate )
{
	local oldCenter = (vecMinsIn + vecMaxsIn) * 0.5;

	local oldExtents = vecMaxsIn - oldCenter;

	local newCenter = VectorIRotate( oldCenter, transform );

	transform = transform.m;

	local newExtents = Vector(
		fabs( oldExtents.x * transform[0][0] ) +
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
function VS::GetBoxVertices( origin, angles, mins, maxs, pVerts )
	: ( matrix3x4_t, Vector, VectorAdd, VectorRotate, AngleMatrix )
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
function VS::MatrixBuildPerspective( dst, fovX, flAspect, zNear, zFar ) : ( tan )
{
	dst = dst.m;
	// memset( dst.Base(), 0, sizeof( dst ) );
	            dst[0][1] =             dst[0][3] =
	dst[1][0] =                         dst[1][3] =
	dst[2][0] = dst[2][1] =
	dst[3][0] = dst[3][1] =             dst[3][3] = 0.0;

	local invW = -0.5 / tan( fovX * DEG2RADDIV2 );
	local range = zFar / ( zNear - zFar );

	// create the final matrix directly
	dst[0][0] = invW;
	dst[1][1] = invW * flAspect;
	dst[0][2] = dst[1][2] = 0.5;
	dst[2][2] = -range;
	dst[3][2] = 1.0;
	dst[2][3] = zNear * range;

/*
	local width  = tan( fovX * DEG2RAD * 0.5 );
	local height = width / flAspect;
	local range = zFar / ( zNear - zFar );

	dst[0][0]  = 1.0 / width;
	dst[1][1]  = 1.0 / height;
	dst[2][2] = -range;
	dst[3][2] = 1.0;
	dst[2][3] = zNear * range;

	// negate X and Y so that X points right, and Y points up.
	// negateXY
	//[	(-1, 0, 0, 0),
	//	(0, -1, 0, 0),
	//	(0, 0, 1, 0),
	//	(0, 0, 0, 1)	]
	dst[0][0] *= -1.0;
	// dst[0][1] *= -1.0;
	// dst[0][2] *= -1.0;
	// dst[0][3] *= -1.0;

	// dst[1][0] *= -1.0;
	dst[1][1] *= -1.0;
	// dst[1][2] *= -1.0;
	// dst[1][3] *= -1.0;

	// addW
	//[	(1, 0, 0, 1),
	//	(0, 1, 0, 1),
	//	(0, 0, 1, 0),
	//	(0, 0, 0, 1)	]
	// dst[0][0] += dst[3][0];
	// dst[0][1] += dst[3][1];
	dst[0][2] += dst[3][2];
	// dst[0][3] += dst[3][3];

	// dst[1][0] += dst[3][0];
	// dst[1][1] += dst[3][1];
	dst[1][2] += dst[3][2];
	// dst[1][3] += dst[3][3];

	// scaleHalf
	//[	(0.5, 0, 0, 0),
	//	(0, 0.5, 0, 0),
	//	(0, 0, 1, 0),
	//	(0, 0, 0, 1)	]
	dst[0][0] *= 0.5;
	// dst[0][1] *= 0.5;
	dst[0][2] *= 0.5;
	// dst[0][3] *= 0.5;

	// dst[1][0] *= 0.5;
	dst[1][1] *= 0.5;
	dst[1][2] *= 0.5;
	// dst[1][3] *= 0.5;
*/
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

	local flRange = flZFar / ( flZNear - flZFar );
	dst[2][0] = 0.0;
	dst[2][1] = 0.0;
	dst[2][2] = flRange;
	dst[2][3] = flZNear * flRange;

	dst[3][0] = 0.0;
	dst[3][1] = 0.0;
	dst[3][2] = -1.0;
	dst[3][3] = 0.0;
}

function VS::ComputeProjectionMatrix( pCameraToProjection, flZNear, flZFar, flFOVX, flAspect )
{
	// memset( pCameraToProjection, 0, sizeof( VMatrix ) );
	local m = pCameraToProjection.m;
	MatrixScaleByZero( pCameraToProjection );
	m[3][0] = m[3][1] = m[3][2] = m[3][3] = 0.0;

	local halfWidth = tan( flFOVX * DEG2RAD * 0.5 );
	local halfHeight = halfWidth / flAspect;

	m[0][0]  = 1.0 / halfWidth;
	m[1][1]  = 1.0 / halfHeight;
	m[2][2] = flZFar / ( flZNear - flZFar );
	m[3][2] = -1.0;
	m[2][3] = flZNear * flZFar / ( flZNear - flZFar );
}
*/

function VS::ComputeViewMatrix( pWorldToView, origin, forward, left, up ) : ( Vector, matrix3x4_t, VMatrix )
{
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

/*
function VS::ComputeViewMatrix( pWorldToView, vecOrigin, vecForward, vecLeft, vecUp ) : ( matrix3x4_t )
{
	local pCameraToWorld = matrix3x4_t();
	MatrixSetColumn( vecForward, 0, pCameraToWorld );
	MatrixSetColumn( vecLeft, 1, pCameraToWorld );
	MatrixSetColumn( vecUp, 2, pCameraToWorld );
	MatrixSetColumn( vecOrigin, 3, pCameraToWorld );

	local g_ViewAlignMatrix = matrix3x4_t();
	local m = g_ViewAlignMatrix.m;
	m[0][0] = 0.0;  m[0][1] = 0.0; m[0][2] = -1.0; m[0][3] = 0.0;
	m[1][0] = -1.0; m[1][1] = 0.0; m[1][2] = 0.0;  m[1][3] = 0.0;
	m[2][0] = 0.0;  m[2][1] = 1.0; m[2][2] = 0.0;  m[2][3] = 0.0;

	local tmp = matrix3x4_t();
	ConcatTransforms( pCameraToWorld, g_ViewAlignMatrix, tmp );
	MatrixInvert( tmp, pWorldToView );
}

function VS::ComputeViewMatrix( pViewMatrix, matGameCustom )
{
	pViewMatrix = pViewMatrix.m;
	matGameCustom = matGameCustom.m;

	pViewMatrix[0][0] = -matGameCustom[1][0];
	pViewMatrix[0][1] = -matGameCustom[1][1];
	pViewMatrix[0][2] = -matGameCustom[1][2];
	pViewMatrix[0][3] = -matGameCustom[1][3];

	pViewMatrix[1][0] = matGameCustom[2][0];
	pViewMatrix[1][1] = matGameCustom[2][1];
	pViewMatrix[1][2] = matGameCustom[2][2];
	pViewMatrix[1][3] = matGameCustom[2][3];

	pViewMatrix[2][0] = -matGameCustom[0][0];
	pViewMatrix[2][1] = -matGameCustom[0][1];
	pViewMatrix[2][2] = -matGameCustom[0][2];
	pViewMatrix[2][3] = -matGameCustom[0][3];

	pViewMatrix[3][0] = pViewMatrix[3][1] = pViewMatrix[3][2] = 0.0;
	pViewMatrix[3][3] = 1.0;
}

function VS::ViewMatrixRH( vEye, vForward, vUp, mOut )
{
	local zAxis = vEye - vForward;
	local xAxis = vUp.Cross( zAxis );
	local yAxis = zAxis.Cross( xAxis );
	xAxis.Norm();
	yAxis.Norm();
	zAxis.Norm();
	local flDotX = -xAxis.Dot( vEye );
	local flDotY = -yAxis.Dot( vEye );
	local flDotZ = -zAxis.Dot( vEye );

	local m = mOut.m;

	// xAxis.x, yAxis.x, zAxis.x, 0
	// xAxis.y, yAxis.y, zAxis.y, 0
	// xAxis.z, yAxis.z, zAxis.z, 0
	// flDotX,  flDotY,  flDotZ,  1

	// Transpose
	m[0][0] = xAxis.x; m[1][0] = xAxis.y; m[2][0] = xAxis.z; m[3][0] = flDotX;
	m[0][1] = yAxis.x; m[1][1] = yAxis.y; m[2][1] = yAxis.z; m[3][1] = flDotY;
	m[0][2] = zAxis.x; m[1][2] = zAxis.y; m[2][2] = zAxis.z; m[3][2] = flDotZ;
	m[0][3] = 0.0;     m[1][3] = 0.0;     m[2][3] = 0.0;     m[3][3] = 1.0;
}
*/

// NOTE: inverted!
function VS::ComputeCameraVariables( vecOrigin, pVecForward, pVecRight, pVecUp, pMatCamInverse )
{
	pMatCamInverse = pMatCamInverse.m;

	pMatCamInverse[0][0] = -pVecRight.x;
	pMatCamInverse[0][1] = -pVecRight.y;
	pMatCamInverse[0][2] = -pVecRight.z;
	pMatCamInverse[0][3] = pVecRight.Dot( vecOrigin );

	pMatCamInverse[1][0] = -pVecUp.x;
	pMatCamInverse[1][1] = -pVecUp.y;
	pMatCamInverse[1][2] = -pVecUp.z;
	pMatCamInverse[1][3] = pVecUp.Dot( vecOrigin );

	pMatCamInverse[2][0] = pVecForward.x;
	pMatCamInverse[2][1] = pVecForward.y;
	pMatCamInverse[2][2] = pVecForward.z;
	pMatCamInverse[2][3] = -pVecForward.Dot( vecOrigin );

	pMatCamInverse[3][0] = pMatCamInverse[3][1] = pMatCamInverse[3][2] = 0.0;
	pMatCamInverse[3][3] = 1.0;
}


function VS::ScreenToWorldMatrix( pOut, origin, forward, right, up, fov, flAspect, zNear, zFar )
	: (VMatrix)
{
	local viewToProj = VMatrix();
	MatrixBuildPerspective( viewToProj, fov, flAspect, zNear, zFar );

	local worldToView = VMatrix();
	ComputeCameraVariables(
		origin,
		forward,
		right,
		up,
		worldToView );

	local worldToProj = viewToProj; // VMatrix();
	MatrixMultiply( viewToProj, worldToView, worldToProj );

	local screenToWorld = worldToView; // VMatrix();
	MatrixInverseGeneral( worldToProj, screenToWorld );

	pOut = pOut.m;
	screenToWorld = screenToWorld.m;

	pOut[0][0] = screenToWorld[0][0];
	pOut[0][1] = screenToWorld[0][1];
	pOut[0][2] = screenToWorld[0][2];
	pOut[0][3] = screenToWorld[0][3];

	pOut[1][0] = screenToWorld[1][0];
	pOut[1][1] = screenToWorld[1][1];
	pOut[1][2] = screenToWorld[1][2];
	pOut[1][3] = screenToWorld[1][3];

	pOut[2][0] = screenToWorld[2][0];
	pOut[2][1] = screenToWorld[2][1];
	pOut[2][2] = screenToWorld[2][2];
	pOut[2][3] = screenToWorld[2][3];

	pOut[3][0] = screenToWorld[3][0];
	pOut[3][1] = screenToWorld[3][1];
	pOut[3][2] = screenToWorld[3][2];
	pOut[3][3] = screenToWorld[3][3];
}

local Vector3DMultiplyPositionProjective = VS.Vector3DMultiplyPositionProjective;

function VS::ScreenToWorld( x, y, screenToWorld, pOut = _VEC ) : (Vector, Vector3DMultiplyPositionProjective)
{
	local vecScreen = Vector( x, 1.0 - y, 1.0 );
	Vector3DMultiplyPositionProjective( screenToWorld, vecScreen, pOut );
	return pOut;
}


//-----------------------------------------------------------------------------
// Computes Y fov from an X fov and a screen aspect ratio
//-----------------------------------------------------------------------------
function VS::CalcFovY( flFovX, flAspect ) : ( tan, atan )
{
	if ( flFovX < 1.0 || flFovX > 179.0)
		flFovX = 90.0;

	return RAD2DEG2 * atan( tan( DEG2RADDIV2 * flFovX ) / flAspect );
}

function VS::CalcFovX( flFovY, flAspect ) : ( tan, atan )
{
	return RAD2DEG2 * atan( tan( DEG2RADDIV2 * flFovY ) * flAspect );
}

local initFrustumDraw = function()
{
	local Line = DebugDrawLine;
	local Vector3DMultiplyPositionProjective = VS.Vector3DMultiplyPositionProjective;

	local startWorldSpace = Vector(), endWorldSpace = Vector();

	local draw = function( startLocalSpace, endLocalSpace, mat, r, g, b, z, t ) :
		( Vector, Vector3DMultiplyPositionProjective, Line, startWorldSpace, endWorldSpace )
	{
		Vector3DMultiplyPositionProjective( mat, startLocalSpace, startWorldSpace );
		Vector3DMultiplyPositionProjective( mat, endLocalSpace, endWorldSpace );

		return Line( startWorldSpace, endWorldSpace, r, g, b, z, t );
	}

	local v000 = Vector();
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

	function VS::DrawFrustum( matViewToWorld, r, g, b, z, t ) : ( draw, frustum )
	{
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
	local ScreenToWorldMatrix = VS.ScreenToWorldMatrix;

	function VS::DrawViewFrustum( vecOrigin, vecForward, vecRight, vecUp,
		flFovX, flAspect, zNear, zFar, r, g, b, z, time ) :
			( VMatrix, ScreenToWorldMatrix, DrawFrustum )
	{
		local mat = VMatrix();
		ScreenToWorldMatrix( mat, vecOrigin, vecForward, vecRight, vecUp, flFovX, flAspect, zNear, zFar );
		return DrawFrustum( mat, r, g, b, z, time );
	}
}

function VS::DrawFrustum( matrix, r, g, b, z, t ) : (initFrustumDraw)
{
	initFrustumDraw();
	return DrawFrustum( matrix, r, g, b, z, t );
}

function VS::DrawViewFrustum( vecOrigin, vecForward, vecRight, vecUp,
		flFovX, flAspect, zNear, zFar, r, g, b, z, time ) : (initFrustumDraw)
{
	initFrustumDraw();
	return DrawViewFrustum( vecOrigin, vecForward, vecRight, vecUp,
		flFovX, flAspect, zNear, zFar, r, g, b, z, time );
}

local initBoxDraw = function()
{
	local Line = DebugDrawLine;
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
}

function VS::DrawBoxAngles( origin, mins, maxs, angles, r, g, b, z, time ) : ( initBoxDraw )
{
	initBoxDraw();
	return DrawBoxAngles( origin, mins, maxs, angles, r, g, b, z, time );
}

local Line = DebugDrawLine;

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
			local theta = PI2 * u;
			local phi = PI * v;
			local sp = flRadius * sin(phi);

			pVerts[c++] = Vector(
				vCenter.x + ( sp * cos(theta) ),
				vCenter.y + ( sp * sin(theta) ),
				vCenter.z + ( flRadius * cos(phi) ) );
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
	// local matCapsuleRotationSpace = matrix3x4_t();
	// VS.VectorMatrix( Vector(0,0,1), matCapsuleRotationSpace );

	//-----------------------------------------------------------------------
	// Draws a capsule at world origin.
	//-----------------------------------------------------------------------
	function VS::DrawCapsule( start, end, radius, r, g, b, z, time )
		: ( g_capsuleVertPositions, g_capsuleLineIndices, g_capsuleVerts, Line, Vector, matrix3x4_t )
	{
		// local vecCapsuleCoreNormal = start - end;
		local vecLen = end - start;
		// vecCapsuleCoreNormal.Norm();

		// local matCapsuleSpace = matrix3x4_t();
		// VectorMatrix( vecCapsuleCoreNormal, matCapsuleSpace );

		for ( local i = 0; i < 74; ++i )
		{
			local vert = Vector(
				g_capsuleVertPositions[i][0],
				g_capsuleVertPositions[i][1],
				g_capsuleVertPositions[i][2] );

			// VectorRotate( vert, matCapsuleRotationSpace, vert );
			// VectorRotate( vert, matCapsuleSpace, vert );

			vert *= radius;

			if ( g_capsuleVertPositions[i][2] > 0.0 )
			{
				vert += vecLen;
			};
			g_capsuleVerts[i] = vert + start;
		}

		local i = 0;
		while ( i < 117 )
		{
			local i0 = g_capsuleLineIndices[i];
			if ( i0 == 0xFFFFFFFF )
			{
				i += 2;
				continue;
			};

			local i1 = g_capsuleLineIndices[++i];
			if ( i1 == 0xFFFFFFFF )
			{
				i += 2;
				if ( i > 116 )
					break;
				continue;
			};

			Line( g_capsuleVerts[i0], g_capsuleVerts[i1], r, g, b, z, time )
		}
	}
}

function VS::DrawCapsule( start, end, radius, r, g, b, z, time ) : ( initCapsule )
{
	initCapsule();
	return DrawCapsule( start, end, radius, r, g, b, z, time );
}


/*
class ::cplane_t
{
	normal = null;
	dist = 0.0;
	type = 0;			// for fast side tests
	signbits = 0;		// signx + (signy<<1) + (signz<<1)
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
		m_Plane = [null,null,null,null,null,null];
		m_AbsNormal = [null,null,null,null,null,null];

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

	m_Plane = null;
	m_AbsNormal = null;
}

//-----------------------------------------------------------------------------
// Generate a frustum based on perspective view parameters
//-----------------------------------------------------------------------------
function VS::GeneratePerspectiveFrustum( origin, vecForward, vecRight, vecUp, flZNear, flZFar, flFovX, flAspectRatio, frustum )
{
	local flIntercept = origin.Dot( forward );

	// Setup the near and far planes.
	frustum.SetPlane( FRUSTUM_FARZ, PLANE_ANYZ, -forward, -flZFar - flIntercept );
	frustum.SetPlane( FRUSTUM_NEARZ, PLANE_ANYZ, forward, flZNear + flIntercept );

	local flTanX = tan( DEG2RAD * flFovX * 0.5 );
	local flTanY = flTanX / flAspectRatio;

	local normalPos = Vector(), normalNeg = Vector();

	VectorMA( right, flTanX, forward, normalPos );
	VectorMA( normalPos, -2.0, right * -1.0, normalNeg );

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
*/


//==============================================================
//==============================================================
{


local QuaternionAngles = VS.QuaternionAngles;
local QuaternionSlerp = VS.QuaternionSlerp;
local VectorMA = VS.VectorMA;
local VectorLerp = VS.VectorLerp;


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
	// local tension, bias, continuity;
	switch ( interpolationType )
	{
		case INTERPOLATE.KOCHANEK_BARTELS:
			tbc[0] = 0.77;
			tbc[1] = 0.0;
			tbc[2] = 0.77;
			break;
		case INTERPOLATE.KOCHANEK_BARTELS_EARLY:
			tbc[0] = 0.77;
			tbc[1] = -1.0;
			tbc[2] = 0.77;
			break;
		case INTERPOLATE.KOCHANEK_BARTELS_LATE:
			tbc[0] = 0.77;
			tbc[1] = 1.0;
			tbc[2] = 0.77;
			break;
		default:
			tbc[0] =
			tbc[1] =
			tbc[2] = 0.0;
			// Assert( 0 );
			break;
	};
}

function VS::Interpolator_CurveInterpolate( interpolationType, vPre, vStart, vEnd, vNext, f, vOut )
	: ( sin )
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
				f = sin( f * PIDIV2 );
				// ignores vPre and vNext
				VectorLerp( vStart, vEnd, f, vOut );
			}
			break;
		case INTERPOLATE.EASE_OUT:
			{
				f = 1.0 - sin( f * PIDIV2 + PIDIV2 );
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
				if ( dt > 0.0 )
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
	: ( sin )
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
				f = sin( f * PIDIV2 );
				// ignores vPre and vNext
				VectorLerp( vStart, vEnd, f, vOut );
			}
			break;
		case INTERPOLATE.EASE_OUT:
			{
				f = 1.0 - sin( f * PIDIV2 + PIDIV2 );
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

	if ( dt )
	{
		if ( p1.x != p2.x )
		{
			VectorLerp( p2, p1, dt / (p2.x - p1.x), p1n );
		};
		if ( p4.x != p3.x )
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
			- 0.25*(p1 - p3)*tt
			+ 0.166667*(2.0*p1 - 5.0*p2 + 4.0*p3 - p4)*ttt
			- 0.125*(p1 - 3.0*p2 + 3.0*p3 - p4)*ttt*t;
	output.x = o.x;
	output.y = o.y;
	output.z = o.z;
}

// area under the curve [0..1]
function VS::Catmull_Rom_Spline_Integral2( p1, p2, p3, p4, t, output )
{
	local o = ( (p2 + p3)*3.25 - (p1 + p4)*0.25 ) * 0.166667;
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

function VS::Parabolic_Spline_NormalizeX( p1, p2, p3, p4, t, output ) :
	( Vector, Spline_Normalize, Parabolic_Spline )
{
	local p1n = Vector(), p4n = Vector();
	Spline_Normalize( p1, p2, p3, p4, p1n, p4n );
	return Parabolic_Spline( p1n, p2, p3, p4n, t, output );
}

//-----------------------------------------------------------------------------
// Purpose: Compress the input values for a ranged result such that from 75% to 200% smoothly of the range maps
//-----------------------------------------------------------------------------
function VS::RangeCompressor( flValue, flMin, flMax, flBase ) : ( Hermite_SplineF )
{
	// clamp base
	if ( flBase < flMin )
		flBase = flMin;
	else if ( flBase > flMax )
		flBase = flMax;;

	// convert to 0 to 1 value
	local flMid = (flBase + flValue - flMin) / (flMax - flMin);
	// convert to -1 to 1 value
	local flTarget = flMid * 2.0 - 1.0;

	local fAbs;
	if ( flTarget < 0.0 )
		fAbs = -flTarget;
	else
		fAbs = flTarget;

	if ( fAbs > 0.75 )
	{
		local t = (fAbs - 0.75) / 1.25;
		if ( t < 1.0 )
		{
			if ( flTarget > 0.0 )
			{
				flTarget = Hermite_SplineF( 0.75, 1.0, 0.75, 0.0, t );
			}
			else
			{
				flTarget = -Hermite_SplineF( 0.75, 1.0, 0.75, 0.0, t );
			};
		}
		else
		{
			if ( 0.0 < flTarget )
				flTarget = 1.0;
			else
				flTarget = -1.0;
		};
	};

	flMid = ( flTarget + 1.0 ) * 0.5;

	return ( flMin * (1.0 - flMid) + flMax * flMid ) - flBase;
}

// QAngle slerp
function VS::InterpolateAngles( v1, v2, flPercent, out ) :
	( Quaternion, AngleQuaternion, QuaternionAngles, QuaternionSlerp )
{
	if ( v1 == v2 )
		return v1;

	local src = Quaternion();
	AngleQuaternion( v1, src );
	local dest = Quaternion();
	AngleQuaternion( v2, dest );

	local result = QuaternionSlerp( src, dest, flPercent );

	return QuaternionAngles( result, out );
}


}
//==============================================================
//==============================================================


function VS::PointOnLineNearestPoint( vStartPos, vEndPos, vPoint )
{
	local v1 = vEndPos - vStartPos;
	local dist = v1.Dot(vPoint - vStartPos) / v1.LengthSqr();

	if ( dist < 0.0 )
		return vStartPos;
	if ( dist > 1.0 )
		return vEndPos;
	return vStartPos + v1 * dist;
}

function VS::CalcSqrDistanceToAABB( mins, maxs, point )
{
	local flDelta;

	if ( point.x < mins.x )
	{
		flDelta = mins.x - point.x;
	}
	else if ( point.x > maxs.x )
	{
		flDelta = point.x - maxs.x;
	};;

	if ( point.y < mins.y )
	{
		flDelta = mins.y - point.y;
	}
	else if ( point.y > maxs.y )
	{
		flDelta = point.y - maxs.y;
	};;

	if ( point.z < mins.z )
	{
		flDelta = mins.z - point.z;
	}
	else if ( point.z > maxs.z )
	{
		flDelta = point.z - maxs.z;
	};;

	return flDelta * flDelta;
}

function VS::CalcClosestPointOnAABB( mins, maxs, point, closestOut = _VEC )
{
	closestOut.x = (point.x < mins.x) ? mins.x : (maxs.x < point.x) ? maxs.x : point.x;
	closestOut.y = (point.y < mins.y) ? mins.y : (maxs.y < point.y) ? maxs.y : point.y;
	closestOut.z = (point.z < mins.z) ? mins.z : (maxs.z < point.z) ? maxs.z : point.z;
}


class ::Ray_t
{
	m_Start = null;
	m_Delta = null;
	m_StartOffset = null;
	m_Extents = null;
	m_IsRay = null;
	m_IsSwept = null;

	function Init( start, end, mins = null, maxs = null ) : (Vector)
	{
		m_Delta = end - start;
		m_IsSwept = ( m_Delta.LengthSqr() != 0.0 );

		if ( !mins )
		{
			m_Extents = Vector();
			m_IsRay = true;
			m_StartOffset = Vector();
			m_Start = start * 1.0;
		}
		else
		{
			m_Extents = (maxs - mins) * 0.5;
			m_IsRay = ( m_Extents.LengthSqr() < 1.e-6 );
			m_StartOffset = (mins + maxs) * 0.5;
			m_Start = start + m_StartOffset;
			m_StartOffset *= -1.0;
		};
	}
}

/*
//-----------------------------------------------------------------------------
// Clears the trace
//-----------------------------------------------------------------------------
function VS::Collision_ClearTrace( vecRayStart, vecRayDelta, pTrace )
{
	pTrace.startpos = vecRayStart;
	pTrace.endpos = vecRayStart + vecRayDelta;
	pTrace.fraction = 1.0;
}
*/

//-----------------------------------------------------------------------------
// Compute the offset in t along the ray that we'll use for the collision
//-----------------------------------------------------------------------------
function VS::ComputeBoxOffset( ray ) : (fabs)
{
	if ( ray.m_IsRay )
		return 1.e-3;

	// Find the projection of the box diagonal along the ray...
	local offset = fabs(ray.m_Extents.x * ray.m_Delta.x) +
				fabs(ray.m_Extents.y * ray.m_Delta.y) +
				fabs(ray.m_Extents.z * ray.m_Delta.z);

	// We need to divide twice: Once to normalize the computation above
	// so we get something in units of extents, and the second to normalize
	// that with respect to the entire raycast.
	local lsqr = ray.m_Delta.LengthSqr();
	if ( lsqr >= 1.0 )
		return (offset / lsqr) + 1.e-3;

	// 1e-3 is an epsilon
	return offset + 1.e-3;
}

// VectorWithinAABox
function VS::IsPointInBox( vec, boxmin, boxmax )
{
	return ( vec.x >= boxmin.x && vec.x <= boxmax.x &&
		vec.y >= boxmin.y && vec.y <= boxmax.y &&
		vec.z >= boxmin.z && vec.z <= boxmax.z );
}

// Return true of the boxes intersect (but not if they just touch)
function VS::IsBoxIntersectingBox( boxMin1, boxMax1, boxMin2, boxMax2 )
{
	if ( ( boxMin1.x > boxMax2.x ) || ( boxMax1.x < boxMin2.x ) )
		return false;
	if ( ( boxMin1.y > boxMax2.y ) || ( boxMax1.y < boxMin2.y ) )
		return false;
	if ( ( boxMin1.z > boxMax2.z ) || ( boxMax1.z < boxMin2.z ) )
		return false;
	return true;
}

//-----------------------------------------------------------------------------
// Purpose: returns true if pt intersects the truncated cone
// origin - cone tip, axis - unit cone axis, cosAngle - cosine of cone axis to surface angle
//
// Input  : Vector
//          Vector
//          Vector
//          float
//          float
//-----------------------------------------------------------------------------
function VS::IsPointInCone( pt, origin, axis, cosAngle, length )
{
	local delta = pt - origin;
	local dist = delta.Norm();
	local dot = delta.Dot(axis);

	if ( dot < cosAngle )
		return false;
	if ( dist * dot > length )
		return false;
	return true;
}

//-----------------------------------------------------------------------------
// Returns true if a box intersects with a sphere
//-----------------------------------------------------------------------------
function VS::IsSphereIntersectingSphere( center1, radius1, center2, radius2 )
{
	local radiusSum = radius1 + radius2;
	return ((center2 - center1).LengthSqr() <= (radiusSum * radiusSum));
}

//-----------------------------------------------------------------------------
// Returns true if a box intersects with a sphere
//-----------------------------------------------------------------------------
function VS::IsBoxIntersectingSphere( boxMin, boxMax, center, radius )
{
	// See Graphics Gems, box-sphere intersection
	local flDelta;

	if (center.x < boxMin.x)
	{
		flDelta = center.x - boxMin.x;
	}
	else if (center.x > boxMax.x)
	{
		flDelta = boxMax.x - center.x;
	};;

	if (center.y < boxMin.y)
	{
		flDelta = center.y - boxMin.y;
	}
	else if (center.y > boxMax.y)
	{
		flDelta = boxMax.y - center.y;
	};;

	if (center.z < boxMin.z)
	{
		flDelta = center.z - boxMin.z;
	}
	else if (center.z > boxMax.z)
	{
		flDelta = boxMax.z - center.z;
	};;

	return flDelta * flDelta < radius * radius;
}

//-----------------------------------------------------------------------------
// Returns true if a rectangle intersects with a circle
//-----------------------------------------------------------------------------
function VS::IsCircleIntersectingRectangle( boxMin, boxMax, center, radius )
{
	// See Graphics Gems, box-sphere intersection
	local flDelta;

	if ( center.x < boxMin.x )
	{
		flDelta = center.x - boxMin.x;
	}
	else if ( center.x > boxMax.x )
	{
		flDelta = boxMax.x - center.x;
	};;

	if ( center.y < boxMin.y )
	{
		flDelta = center.y - boxMin.y;
	}
	else if ( center.y > boxMax.y )
	{
		flDelta = boxMax.y - center.y;
	};;

	return flDelta * flDelta < radius * radius;
}

//-----------------------------------------------------------------------------
// returns true if there's an intersection between ray and sphere
// flTolerance [0..1]
//-----------------------------------------------------------------------------
function VS::IsRayIntersectingSphere( vecRayOrigin, vecRayDelta, vecCenter, flRadius, flTolerance = 0.0 )
{
	// For this algorithm, find a point on the ray  which is closest to the sphere origin
	// Do this by making a plane passing through the sphere origin
	// whose normal is parallel to the ray. Intersect that plane with the ray.
	// Plane: N dot P = I, N = D (ray direction), I = C dot N = C dot D
	// Ray: P = O + D * t
	// D dot ( O + D * t ) = C dot D
	// D dot O + D dot D * t = C dot D
	// t = (C - O) dot D / D dot D
	// Clamp t to (0,1)
	// Find distance of the point on the ray to the sphere center.
	// Assert( flTolerance >= 0.0 );

	flRadius += flTolerance;

	local vecRayToSphere = vecCenter - vecRayOrigin;
	local flNumerator = vecRayToSphere.Dot( vecRayDelta );

	local t;
	if ( flNumerator <= 0.0 )
	{
		t = 0.0;
	}
	else
	{
		local flDenominator = vecRayDelta.LengthSqr();
		if ( flNumerator > flDenominator )
			t = 1.0;
		else
			t = flNumerator / flDenominator;
	};

	local vecClosestPoint = vecRayOrigin + vecRayDelta * t;
	return ( (vecClosestPoint-vecCenter).LengthSqr() <= flRadius * flRadius );
}

//-----------------------------------------------------------------------------
// IntersectInfiniteRayWithSphere
//
// Returns whether or not there was an intersection.
// Returns the two intersection points
//-----------------------------------------------------------------------------
function VS::IntersectInfiniteRayWithSphere( vecRayOrigin, vecRayDelta, vecSphereCenter, flRadius, pT ) : (sqrt)
{
	// Solve using the ray equation + the sphere equation
	// P = o + dt
	// (x - xc)^2 + (y - yc)^2 + (z - zc)^2 = r^2
	// (ox + dx * t - xc)^2 + (oy + dy * t - yc)^2 + (oz + dz * t - zc)^2 = r^2
	// (ox - xc)^2 + 2 * (ox-xc) * dx * t + dx^2 * t^2 +
	//		(oy - yc)^2 + 2 * (oy-yc) * dy * t + dy^2 * t^2 +
	//		(oz - zc)^2 + 2 * (oz-zc) * dz * t + dz^2 * t^2 = r^2
	// (dx^2 + dy^2 + dz^2) * t^2 + 2 * ((ox-xc)dx + (oy-yc)dy + (oz-zc)dz) t +
	//		(ox-xc)^2 + (oy-yc)^2 + (oz-zc)^2 - r^2 = 0
	// or, t = (-b +/- sqrt( b^2 - 4ac)) / 2a
	// a = DotProduct( vecRayDelta, vecRayDelta );
	// b = 2 * DotProduct( vecRayOrigin - vecCenter, vecRayDelta )
	// c = DotProduct(vecRayOrigin - vecCenter, vecRayOrigin - vecCenter) - flRadius * flRadius;

	local vecSphereToRay = vecRayOrigin - vecSphereCenter;

	local a = vecRayDelta.LengthSqr();

	// This would occur in the case of a zero-length ray
	if ( !a )
	{
		pT[0] = pT[1] = 0.0;
		return vecSphereToRay.LengthSqr() <= flRadius * flRadius;
	};

	local b = 2.0 * vecSphereToRay.Dot( vecRayDelta );
	local c = vecSphereToRay.LengthSqr() - flRadius * flRadius;
	local flDiscrim = b * b - 4.0 * a * c;
	if ( flDiscrim < 0.0 )
		return false;

	flDiscrim = sqrt( flDiscrim );
	local oo2a = 0.5 / a;
	pT[0] = ( -flDiscrim - b ) * oo2a;
	pT[1] = ( flDiscrim - b ) * oo2a;
	return true;
}
/*
//-----------------------------------------------------------------------------
// IntersectInfiniteRayWithSphere clamped to (0,1)
//-----------------------------------------------------------------------------
function VS::IntersectRayWithSphere( vecRayOrigin, vecRayDelta, vecSphereCenter, flRadius, pT )
{
	if ( !IntersectInfiniteRayWithSphere( vecRayOrigin, vecRayDelta, vecSphereCenter, flRadius, pT ) )
		return false;

	if (( pT[0] > 1.0 ) || ( pT[1] < 0.0 ))
		return false;

	if ( pT[0] < 0.0 )
		pT[0] = 0.0;
	if ( pT[1] > 1.0 )
		pT[1] = 1.0;

	return true;
}
*/
//-----------------------------------------------------------------------------
// Intersects a ray with a AABB, return true if they intersect
// Input  : worldMins, worldMaxs
//-----------------------------------------------------------------------------
function VS::IsBoxIntersectingRay( boxMin, boxMax, origin, vecDelta, flTolerance = 0.0 ):(fabs)
{
	// Assert( boxMin.x <= boxMax.x );
	// Assert( boxMin.y <= boxMax.y );
	// Assert( boxMin.z <= boxMax.z );

	// FIXME: Surely there's a faster way
	local tmin = FLT_MIN, tmax = FLT_MAX;

	// Parallel case...
	if ( fabs(vecDelta.x) < 1.e-8 )
	{
		// Check that origin is in the box
		// if not, then it doesn't intersect..
		if ( (origin.x < boxMin.x - flTolerance) || (origin.x > boxMax.x + flTolerance) )
			return false;
	}
	else
	{
		// non-parallel case
		// Find the t's corresponding to the entry and exit of
		// the ray along x, y, and z. The find the furthest entry
		// point, and the closest exit point. Once that is done,
		// we know we don't collide if the closest exit point
		// is behind the starting location. We also don't collide if
		// the closest exit point is in front of the furthest entry point
		local invDelta = 1.0 / vecDelta.x;
		local t1 = (boxMin.x - flTolerance - origin.x) * invDelta;
		local t2 = (boxMax.x + flTolerance - origin.x) * invDelta;
		if ( t1 > t2 )
		{
			local temp = t1;
			t1 = t2;
			t2 = temp;
		};
		if (t1 > tmin)
			tmin = t1;
		if (t2 < tmax)
			tmax = t2;
		if (tmin > tmax)
			return false;
		if (tmax < 0.0)
			return false;
		if (tmin > 1.0)
			return false;
	};

	// other points:
	if ( fabs(vecDelta.y) < 1.e-8 )
	{
		if ( (origin.y < boxMin.y - flTolerance) || (origin.y > boxMax.y + flTolerance) )
			return false;
	}
	else
	{
		local invDelta = 1.0 / vecDelta.y;
		local t1 = (boxMin.y - flTolerance - origin.y) * invDelta;
		local t2 = (boxMax.y + flTolerance - origin.y) * invDelta;
		if ( t1 > t2 )
		{
			local temp = t1;
			t1 = t2;
			t2 = temp;
		};
		if (t1 > tmin)
			tmin = t1;
		if (t2 < tmax)
			tmax = t2;
		if (tmin > tmax)
			return false;
		if (tmax < 0.0)
			return false;
		if (tmin > 1.0)
			return false;
	};

	if ( fabs(vecDelta.z) < 1.e-8 )
	{
		if ( (origin.z < boxMin.z - flTolerance) || (origin.z > boxMax.z + flTolerance) )
			return false;
	}
	else
	{
		local invDelta = 1.0 / vecDelta.z;
		local t1 = (boxMin.z - flTolerance - origin.z) * invDelta;
		local t2 = (boxMax.z + flTolerance - origin.z) * invDelta;
		if ( t1 > t2 )
		{
			local temp = t1;
			t1 = t2;
			t2 = temp;
		};
		if (t1 > tmin)
			tmin = t1;
		if (t2 < tmax)
			tmax = t2;
		if (tmin > tmax)
			return false;
		if (tmax < 0.0)
			return false;
		if (tmin > 1.0)
			return false;
	};

	return true;
}

local IsBoxIntersectingRay = VS.IsBoxIntersectingRay;

//-----------------------------------------------------------------------------
// Intersects a ray with a AABB, return true if they intersect
// Input  : localMins, localMaxs
//-----------------------------------------------------------------------------
function VS::IsBoxIntersectingRay2( origin, vecBoxMin, vecBoxMax, ray, flTolerance = 0.0 )
	: ( IsBoxIntersectingRay )
{
	if ( !ray.m_IsSwept )
	{
		local rayMins = ray.m_Start - ray.m_Extents;
		local rayMaxs = ray.m_Start + ray.m_Extents;
		if ( flTolerance )
		{
			rayMins.x -= flTolerance; rayMins.y -= flTolerance; rayMins.z -= flTolerance;
			rayMaxs.x += flTolerance; rayMaxs.y += flTolerance; rayMaxs.z += flTolerance;
		};
		return IsBoxIntersectingBox( vecBoxMin, vecBoxMax, rayMins, rayMaxs );
	};

	// world
	local vecExpandedBoxMin = vecBoxMin - ray.m_Extents + origin;
	local vecExpandedBoxMax = vecBoxMax + ray.m_Extents + origin;

	return IsBoxIntersectingRay( vecExpandedBoxMin, vecExpandedBoxMax, ray.m_Start, ray.m_Delta, flTolerance );
}

//-----------------------------------------------------------------------------
// Intersects a ray with a ray, return true if they intersect
// t, s = parameters of closest approach (if not intersecting!)
//-----------------------------------------------------------------------------
function VS::IntersectRayWithRay( vecStart0, vecDelta0, vecStart1, vecDelta1/* , pT = [0.0,0.0] */ )
{
	//
	// r0 = p0 + v0t
	// r1 = p1 + v1s
	//
	// intersection : r0 = r1 :: p0 + v0t = p1 + v1s
	// NOTE: v(0,1) are unit direction vectors
	//
	// subtract p0 from both sides and cross with v1 (NOTE: v1 x v1 = 0)
	//  (v0 x v1)t = ((p1 - p0 ) x v1)
	//
	// dotting  with (v0 x v1) and dividing by |v0 x v1|^2
	//	t = Det | (p1 - p0) , v1 , (v0 x v1) | / |v0 x v1|^2
	//  s = Det | (p1 - p0) , v0 , (v0 x v1) | / |v0 x v1|^2
	//
	//  Det | A B C | = -( A x C ) dot B or -( C x B ) dot A
	//
	//  NOTE: if |v0 x v1|^2 = 0, then the lines are parallel
	//

	local v0xv1 = vecDelta0.Cross( vecDelta1 );
	local lengthSq = v0xv1.LengthSqr();
	if ( !lengthSq )
	{
		// pT[0] = pT[1] = 0.0;
		return false;		// parallel
	};

	local p1p0 = vecStart1 - vecStart0;

	local AxC = p1p0.Cross( v0xv1 );
	VectorNegate(AxC);
	local detT = AxC.Dot( vecDelta1 );

	AxC = p1p0.Cross( v0xv1 );
	VectorNegate(AxC);
	local detS = AxC.Dot( vecDelta0 );

	local invL = 1.0 / lengthSq;
	local t = detT * invL;
	local s = detS * invL;
	// pT[0] = t;
	// pT[1] = s;

	// intersection????
	local i0 = vecStart0 + vecDelta0 * t;
	local i1 = vecStart1 + vecDelta1 * s;

	return ( i0.x == i1.x && i0.y == i1.y && i0.z == i1.z );
}

function VS::IntersectRayWithPlane( org, dir, normal, dist )
{
	local d	= dir.Dot( normal );
	if ( d )
		return ( dist - org.Dot( normal ) ) / d;
	return 0.0;
}

//-----------------------------------------------------------------------------
// Intersects a ray against a box
//-----------------------------------------------------------------------------
function VS::IntersectRayWithBox( vecRayStart, vecRayDelta, boxMins, boxMaxs, flTolerance, pTrace )
{
	local f, d1, d2;

	local t1 = -1.0;
	local t2 = 1.0;
	// local hitside = -1;

	local startsolid = true;

	for ( local i = 0; i < 6; ++i )
	{
		// HACKHACK:
		switch (i)
		{
		case 0:
			d1 = boxMins.x - vecRayStart.x;
			d2 = d1 - vecRayDelta.x;
			break;
		case 1:
			d1 = boxMins.y - vecRayStart.y;
			d2 = d1 - vecRayDelta.y;
			break;
		case 2:
			d1 = boxMins.z - vecRayStart.z;
			d2 = d1 - vecRayDelta.z;
			break;
		case 3:
			d1 = vecRayStart.x - boxMaxs.x;
			d2 = d1 + vecRayDelta.x;
			break;
		case 4:
			d1 = vecRayStart.y - boxMaxs.y;
			d2 = d1 + vecRayDelta.y;
			break;
		case 5:
			d1 = vecRayStart.z - boxMaxs.z;
			d2 = d1 + vecRayDelta.z;
			break;
		}

		// if completely in front of face, no intersection
		if (d1 > 0.0 && d2 > 0.0)
		{
			// UNDONE: Have to revert this in case it's still set
			// UNDONE: Refactor to have only 2 return points (true/false) from this function
			// startsolid = false;
			return false;
		};

		// completely inside, check next face
		if (d1 <= 0.0 && d2 <= 0.0)
			continue;

		if (d1 > 0.0)
			startsolid = false;

		// crosses face
		if (d1 > d2)
		{
			f = d1 - flTolerance;
			if ( f < 0.0 )
				f = 0.0;
			f /= (d1-d2);
			if (f > t1)
			{
				t1 = f;
				// hitside = i;
			};
		}
		else
		{
			// leave
			f = (d1 + flTolerance) / (d1-d2);
			if (f < t2)
			{
				t2 = f;
			};
		};
	}

	pTrace[0] = t1;
	pTrace[1] = t2;

	return startsolid || (t1 < t2 && t1 >= 0.0);
}

//-----------------------------------------------------------------------------
// Intersects a ray against an OBB, returns t1 and t2
//-----------------------------------------------------------------------------
function VS::IntersectRayWithOBB( vecRayStart, vecRayDelta, matOBBToWorld,
	vecOBBMins, vecOBBMaxs, flTolerance, pTrace ) : (Vector, VectorITransform, VectorIRotate)
{
	local start = Vector(), delta = Vector();
	VectorITransform( vecRayStart, matOBBToWorld, start );
	VectorIRotate( vecRayDelta, matOBBToWorld, delta );

	return IntersectRayWithBox( start, delta, vecOBBMins, vecOBBMaxs, flTolerance, pTrace );
}
/*
{
	// Collision_ClearTrace( vecRayStart, vecRayDelta, pTrace );

	// FIXME: Make it work with tolerance
	// Assert( flTolerance == 0.0 );

	// OPTIMIZE: Store this in the box instead of computing it here
	// compute center in local space
	local vecBoxExtents = (vecOBBMins + vecOBBMaxs) * 0.5;
	local vecBoxCenter = Vector();

	// transform to world space
	VectorTransform( vecBoxExtents, matOBBToWorld, vecBoxCenter );

	// calc extents from local center
	vecBoxExtents = vecOBBMaxs - vecBoxExtents;

	// OPTIMIZE: This is optimized for world space.  If the transform is fast enough, it may make more
	// sense to just xform and call UTIL_ClipToBox() instead.  MEASURE THIS.

	// save the extents of the ray along
	local extent = Vector(), uextent = Vector();
	local segmentCenter = vecRayStart + vecRayDelta - vecBoxCenter;

	// check box axes for separation
	extent.x = vecRayDelta.x * matOBBToWorld[0][0] + vecRayDelta.y * matOBBToWorld[1][0] +	vecRayDelta.z * matOBBToWorld[2][0];
	uextent.x = fabs(extent.x);
	local coord = segmentCenter.x * matOBBToWorld[0][0] + segmentCenter.y * matOBBToWorld[1][0] +	segmentCenter.z * matOBBToWorld[2][0];

	if ( fabs(coord) > (vecBoxExtents.x + uextent.x) )
		return false;

	extent.y = vecRayDelta.x * matOBBToWorld[0][1] + vecRayDelta.y * matOBBToWorld[1][1] +	vecRayDelta.z * matOBBToWorld[2][1];
	uextent.y = fabs(extent.y);
	local coord = segmentCenter.x * matOBBToWorld[0][1] + segmentCenter.y * matOBBToWorld[1][1] +	segmentCenter.z * matOBBToWorld[2][1];

	if ( fabs(coord) > (vecBoxExtents.y + uextent.y) )
		return false;

	extent.z = vecRayDelta.x * matOBBToWorld[0][2] + vecRayDelta.y * matOBBToWorld[1][2] +	vecRayDelta.z * matOBBToWorld[2][2];
	uextent.z = fabs(extent.z);
	local coord = segmentCenter.x * matOBBToWorld[0][2] + segmentCenter.y * matOBBToWorld[1][2] +	segmentCenter.z * matOBBToWorld[2][2];

	if ( fabs(coord) > (vecBoxExtents.z + uextent.z) )
		return false;

	// now check cross axes for separation
	local tmp, cextent;
	Vector cross = vecRayDelta.Cross( segmentCenter );
	cextent = cross.x * matOBBToWorld[0][0] + cross.y * matOBBToWorld[1][0] + cross.z * matOBBToWorld[2][0];
	tmp = vecBoxExtents.y*uextent.z + vecBoxExtents.z*uextent.y;
	if ( fabs(cextent) > tmp )
		return false;

	cextent = cross.x * matOBBToWorld[0][1] + cross.y * matOBBToWorld[1][1] + cross.z * matOBBToWorld[2][1];
	tmp = vecBoxExtents.x*uextent.z + vecBoxExtents.z*uextent.x;
	if ( fabs(cextent) > tmp )
		return false;

	cextent = cross.x * matOBBToWorld[0][2] + cross.y * matOBBToWorld[1][2] + cross.z * matOBBToWorld[2][2];
	tmp = vecBoxExtents.x*uextent.y + vecBoxExtents.y*uextent.x;
	if ( fabs(cextent) > tmp )
		return false;

	// !!! We hit this box !!! compute intersection point and return
	// Compute ray start in bone space
	local start = Vector();
	VectorITransform( vecRayStart, matOBBToWorld, start );

	// extent is ray.m_Delta in bone space, recompute delta in bone space
	extent *= 2.0;

	// delta was prescaled by the current t, so no need to see if this intersection
	// is closer
	if ( !IntersectRayWithBox( start, extent, vecOBBMins, vecOBBMaxs, flTolerance, pTrace ) )
		return false;

	// Fix up the start/end pos and fraction
	local vecTemp = start;
	VectorTransform( pTrace.endpos, matOBBToWorld, vecTemp );
	pTrace.endpos = vecTemp;

	pTrace.startpos = vecRayStart;
	pTrace.fraction *= 2.0;

	// Fix up the plane information
	local flSign = pTrace.plane.normal[ pTrace.plane.type ];
	pTrace.plane.normal.x = flSign * matOBBToWorld[0][pTrace.plane.type];
	pTrace.plane.normal.y = flSign * matOBBToWorld[1][pTrace.plane.type];
	pTrace.plane.normal.z = flSign * matOBBToWorld[2][pTrace.plane.type];
	pTrace.plane.dist = pTrace.endpos.Dot( pTrace.plane.normal );
	pTrace.plane.type = 3;

	return true;
}
*/


//-----------------------------------------------------------------------------
// Swept OBB test
// Input  : localMins, localMaxs
//-----------------------------------------------------------------------------
function VS::IsRayIntersectingOBB( ray, org, angles, mins, maxs )
	: ( matrix3x4_t, Vector, Ray_t, DotProductAbs )
{
	if ( VectorIsZero(angles) )
	{
		local vecWorldMins = org + mins;
		local vecWorldMaxs = org + maxs;
		return IsBoxIntersectingRay( vecWorldMins, vecWorldMaxs, ray.m_Start, ray.m_Delta );
	};

	if ( ray.m_IsRay )
	{
		local worldToBox = matrix3x4_t();
		AngleIMatrix( angles, org, worldToBox );

		local rotatedRay = Ray_t.instance();
		rotatedRay.m_Start = Vector();
		rotatedRay.m_Delta = Vector();

		VectorTransform( ray.m_Start, worldToBox, rotatedRay.m_Start );
		VectorRotate( ray.m_Delta, worldToBox, rotatedRay.m_Delta );

		rotatedRay.m_StartOffset = Vector();
		rotatedRay.m_Extents = Vector();
		rotatedRay.m_IsRay = true;
		rotatedRay.m_IsSwept = ray.m_IsSwept;

		return IsBoxIntersectingRay2( rotatedRay.m_StartOffset, mins, maxs, rotatedRay );
	};

//	if ( !ray.m_IsSwept )
//	{
//		return ComputeSeparatingPlane2( ray.m_Start, Vector(), ray.m_Extents * -1, ray.m_Extents,
//			org, angles, mins, maxs, 0.0 ) == false;
//	};

	// NOTE: See the comments in ComputeSeparatingPlane to understand this math

	// First, compute the basis of box in the space of the ray
	// NOTE: These basis place the origin at the centroid of each box!
//	local worldToBox1 = matrix3x4_t();
	local box2ToWorld = matrix3x4_t();
	ComputeCenterMatrix( org, angles, mins, maxs, box2ToWorld );

	// Find the center + extents of an AABB surrounding the ray
//	local vecRayCenter = VectorMA( ray.m_Start, 0.5, ray.m_Delta ) * -1.0;
//
//	SetIdentityMatrix( worldToBox1 );
//	MatrixSetColumn( vecRayCenter, 3, worldToBox1 );

//	local box1Size = Vector( ray.m_Extents.x + fabs( ray.m_Delta.x ) * 0.5,
//							ray.m_Extents.y + fabs( ray.m_Delta.y ) * 0.5,
//							ray.m_Extents.z + fabs( ray.m_Delta.z ) * 0.5 );

	// Then compute the size of the box
	local box2Size = (maxs - mins)*0.5;

//	// Do an OBB test of the box with the AABB surrounding the ray
//	if ( ComputeSeparatingPlane( worldToBox1, box2ToWorld, box1Size, box2Size, 0.0 ) )
//		return false;

	// Now deal with the planes which are the cross products of the ray sweep direction vs box edges
	local vecRayDirection = ray.m_Delta * 1;
	vecRayDirection.Norm();

	// Rotate the ray direction into the space of the OBB
	local vecAbsRayDirBox2 = VectorIRotate( vecRayDirection, box2ToWorld );

	// Make abs versions of the ray in world space + ray in box2 space
	VectorAbs( vecAbsRayDirBox2 );

	box2ToWorld = box2ToWorld.m;
	// Need a vector between ray center vs box center measured in the space of the ray (world)
	local vecCenterDelta = Vector( box2ToWorld[0][3] - ray.m_Start.x,
									box2ToWorld[1][3] - ray.m_Start.y,
									box2ToWorld[2][3] - ray.m_Start.z );

	// Now do the work for the planes which are perpendicular to the edges of the AABB
	// and the sweep direction edges...

	// In this example, the line to check is perpendicular to box edge x + ray delta
	// we can compute this line by taking the cross-product:
	//
	// [  i  j  k ]
	// [  1  0  0 ] = - dz j + dy k = l1
	// [ dx dy dz ]

	// Where dx, dy, dz is the ray delta (normalized)

	// The projection of the box onto this line = the absolute dot product of the box size
	// against the line, which =
	// AbsDot( vecBoxHalfDiagonal, l1 ) = abs( -dz * vecBoxHalfDiagonal.y ) + abs( dy * vecBoxHalfDiagonal.z )

	// Because the plane contains the sweep direction, the sweep will produce
	// no extra projection onto the line normal to the plane.
	// Therefore all we need to do is project the ray extents onto this line also:
	// AbsDot( ray.m_Extents, l1 ) = abs( -dz * ray.m_Extents.y ) + abs( dy * ray.m_Extents.z )

	local vecPlaneNormal, flBoxProjectionSum, flCenterDeltaProjection;

	// box x x ray delta
	vecPlaneNormal = vecRayDirection.Cross( Vector( box2ToWorld[0][0], box2ToWorld[1][0], box2ToWorld[2][0] ) );
	flCenterDeltaProjection = vecPlaneNormal.Dot(vecCenterDelta);
	if ( 0.0 > flCenterDeltaProjection )
		flCenterDeltaProjection = -flCenterDeltaProjection;
	flBoxProjectionSum =
		vecAbsRayDirBox2.z * box2Size.y + vecAbsRayDirBox2.y * box2Size.z +
		DotProductAbs( vecPlaneNormal, ray.m_Extents );
	if ( flCenterDeltaProjection > flBoxProjectionSum )
		return false;

	// box y x ray delta
	vecPlaneNormal = vecRayDirection.Cross( Vector( box2ToWorld[0][1], box2ToWorld[1][1], box2ToWorld[2][1] ) );
	flCenterDeltaProjection = vecPlaneNormal.Dot(vecCenterDelta);
	if ( 0.0 > flCenterDeltaProjection )
		flCenterDeltaProjection = -flCenterDeltaProjection;
	flBoxProjectionSum =
		vecAbsRayDirBox2.z * box2Size.x + vecAbsRayDirBox2.x * box2Size.z +
		DotProductAbs( vecPlaneNormal, ray.m_Extents );
	if ( flCenterDeltaProjection > flBoxProjectionSum )
		return false;

	// box z x ray delta
	vecPlaneNormal = vecRayDirection.Cross( Vector( box2ToWorld[0][2], box2ToWorld[1][2], box2ToWorld[2][2] ) );
	flCenterDeltaProjection = vecPlaneNormal.Dot(vecCenterDelta);
	if ( 0.0 > flCenterDeltaProjection )
		flCenterDeltaProjection = -flCenterDeltaProjection;
	flBoxProjectionSum =
		vecAbsRayDirBox2.y * box2Size.x + vecAbsRayDirBox2.x * box2Size.y +
		DotProductAbs( vecPlaneNormal, ray.m_Extents );
	if ( flCenterDeltaProjection > flBoxProjectionSum )
		return false;

	return true;
}
/*
//-----------------------------------------------------------------------------
// Compute a separating plane between two boxes (expensive!)
// Returns false if no separating plane exists
//-----------------------------------------------------------------------------
function VS::ComputeSeparatingPlane( worldToBox1, box2ToWorld, box1Size, box2Size, tolerance, pNormalOut = _VEC )
	: (matrix3x4_t, Vector, fabs)
{
	// The various separating planes can be either
	// 1) A plane parallel to one of the box face planes
	// 2) A plane parallel to the cross-product of an edge from each box

	// First, compute the basis of second box in the space of the first box
	// NOTE: These basis place the origin at the centroid of each box!
	local box2ToBox1 = matrix3x4_t();
	ConcatTransforms( worldToBox1, box2ToWorld, box2ToBox1 );
	worldToBox1 = worldToBox1.m;

	// We're going to be using the origin of box2 in the space of box1 alot,
	// lets extract it from the matrix....
	local box2Origin = Vector();
	MatrixGetColumn( box2ToBox1, 3, box2Origin );

	// Next get the absolute values of these entries and store in absbox2ToBox1.
	local absBox2ToBox1 = matrix3x4_t();
	ComputeAbsMatrix( box2ToBox1, absBox2ToBox1 );

	// There are 15 tests to make.  The first 3 involve trying planes parallel
	// to the faces of the first box.

	// NOTE: The algorithm here involves finding the projections of the two boxes
	// onto a particular line. If the projections on the line do not overlap,
	// that means that there's a plane perpendicular to the line which separates
	// the two boxes; and we've therefore found a separating plane.

	// The way we check for overlay is we find the projections of the two boxes
	// onto the line, and add them up. We compare the sum with the projection
	// of the relative center of box2 onto the same line.

	local boxProjectionSum, originProjection;

	// NOTE: For these guys, we're taking advantage of the fact that the ith
	// row of the box2ToBox1 is the direction of the box1 (x,y,z)-axis
	// transformed into the space of box2.

	// First side of box 1
	boxProjectionSum = box1Size.x + MatrixRowDotProduct( absBox2ToBox1, 0, box2Size );
	originProjection = fabs( box2Origin.x ) + tolerance;
	if ( originProjection > boxProjectionSum )
	{
		pNormalOut.x = worldToBox1[0][0];
		pNormalOut.y = worldToBox1[0][1];
		pNormalOut.z = worldToBox1[0][2];
		return true;
	};

	// Second side of box 1
	boxProjectionSum = box1Size.y + MatrixRowDotProduct( absBox2ToBox1, 1, box2Size );
	originProjection = fabs( box2Origin.y ) + tolerance;
	if ( originProjection > boxProjectionSum )
	{
		pNormalOut.x = worldToBox1[1][0];
		pNormalOut.y = worldToBox1[1][1];
		pNormalOut.z = worldToBox1[1][2];
		return true;
	};

	// Third side of box 1
	boxProjectionSum = box1Size.z + MatrixRowDotProduct( absBox2ToBox1, 2, box2Size );
	originProjection = fabs( box2Origin.z ) + tolerance;
	if ( originProjection > boxProjectionSum )
	{
		pNormalOut.x = worldToBox1[2][0];
		pNormalOut.y = worldToBox1[2][1];
		pNormalOut.z = worldToBox1[2][2];
		return true;
	};

	// The next three involve checking splitting planes parallel to the
	// faces of the second box.

	// NOTE: For these guys, we're taking advantage of the fact that the 0th
	// column of the box2ToBox1 is the direction of the box2 x-axis
	// transformed into the space of box1.
	// Here, we're determining the distance of box2's center from box1's center
	// by projecting it onto a line parallel to box2's axis

	// First side of box 2
	boxProjectionSum = box2Size.x +	MatrixColumnDotProduct( absBox2ToBox1, 0, box1Size );
	originProjection = fabs( MatrixColumnDotProduct( box2ToBox1, 0, box2Origin ) ) + tolerance;
	if ( originProjection > boxProjectionSum )
	{
		MatrixGetColumn( box2ToWorld, 0, pNormalOut );
		return true;
	};

	// Second side of box 2
	boxProjectionSum = box2Size.y +	MatrixColumnDotProduct( absBox2ToBox1, 1, box1Size );
	originProjection = fabs( MatrixColumnDotProduct( box2ToBox1, 1, box2Origin ) ) + tolerance;
	if ( originProjection > boxProjectionSum )
	{
		MatrixGetColumn( box2ToWorld, 1, pNormalOut );
		return true;
	};

	// Third side of box 2
	boxProjectionSum = box2Size.z +	MatrixColumnDotProduct( absBox2ToBox1, 2, box1Size );
	originProjection = fabs( MatrixColumnDotProduct( box2ToBox1, 2, box2Origin ) ) + tolerance;
	if ( originProjection > boxProjectionSum )
	{
		MatrixGetColumn( box2ToWorld, 2, pNormalOut );
		return true;
	};

	// Next check the splitting planes which are orthogonal to the pairs
	// of edges, one from box1 and one from box2.  As only direction matters,
	// there are 9 pairs since each box has 3 distinct edge directions.

	// Here, we take advantage of the fact that the edges from box 1 are all
	// axis aligned; therefore the crossproducts are simplified. Let's walk through
	// the example of b1e1 x b2e1:

	// In this example, the line to check is perpendicular to b1e1 + b2e2
	// we can compute this line by taking the cross-product:
	//
	// [  i  j  k ]
	// [  1  0  0 ] = - ez j + ey k = l1
	// [ ex ey ez ]

	// Where ex, ey, ez is the components of box2's x axis in the space of box 1,
	// which is == to the 0th column of of box2toBox1

	// The projection of box1 onto this line = the absolute dot product of the box size
	// against the line, which =
	// AbsDot( box1Size, l1 ) = abs( -ez * box1.y ) + abs( ey * box1.z )

	// To compute the projection of box2 onto this line, we'll do it in the space of box 2
	//
	// [  i  j  k ]
	// [ fx fy fz ] = fz j - fy k = l2
	// [  1  0  0 ]

	// Where fx, fy, fz is the components of box1's x axis in the space of box 2,
	// which is == to the 0th row of of box2toBox1

	// The projection of box2 onto this line = the absolute dot product of the box size
	// against the line, which =
	// AbsDot( box2Size, l2 ) = abs( fz * box2.y ) + abs ( fy * box2.z )

	// The projection of the relative origin position on this line is done in the
	// space of box 1:
	//
	// originProjection = DotProduct( <-ez j + ey k>, box2Origin ) =
	//		-ez * box2Origin.y + ey * box2Origin.z

	// NOTE: These checks can be bogus if both edges are parallel. The if
	// checks at the beginning of each block are designed to catch that case

	absBox2ToBox1 = absBox2ToBox1.m;
	box2ToBox1 = box2ToBox1.m;

	// b1e1 x b2e1
	if ( absBox2ToBox1[0][0] < 0.999 )
	{
		boxProjectionSum =
			box1Size.y * absBox2ToBox1[2][0] + box1Size.z * absBox2ToBox1[1][0] +
			box2Size.y * absBox2ToBox1[0][2] + box2Size.z * absBox2ToBox1[0][1];
		originProjection = fabs( -box2Origin.y * box2ToBox1[2][0] + box2Origin.z * box2ToBox1[1][0] ) + tolerance;
		if ( originProjection > boxProjectionSum )
		{
			MatrixGetColumn( box2ToWorld, 0, pNormalOut );
			local v = worldToBox1[0].Cross(pNormalOut);
			pNormalOut.x = v.x;
			pNormalOut.y = v.y;
			pNormalOut.z = v.z;
			return true;
		};
	};

	// b1e1 x b2e2
	if ( absBox2ToBox1[0][1] < 0.999 )
	{
		boxProjectionSum =
			box1Size.y * absBox2ToBox1[2][1] + box1Size.z * absBox2ToBox1[1][1] +
			box2Size.x * absBox2ToBox1[0][2] + box2Size.z * absBox2ToBox1[0][0];
		originProjection = fabs( -box2Origin.y * box2ToBox1[2][1] + box2Origin.z * box2ToBox1[1][1] ) + tolerance;
		if ( originProjection > boxProjectionSum )
		{
			MatrixGetColumn( box2ToWorld, 1, pNormalOut );
			local v = worldToBox1[0].Cross(pNormalOut);
			pNormalOut.x = v.x;
			pNormalOut.y = v.y;
			pNormalOut.z = v.z;
			return true;
		};
	};

	// b1e1 x b2e3
	if ( absBox2ToBox1[0][2] < 0.999 )
	{
		boxProjectionSum =
			box1Size.y * absBox2ToBox1[2][2] + box1Size.z * absBox2ToBox1[1][2] +
			box2Size.x * absBox2ToBox1[0][1] + box2Size.y * absBox2ToBox1[0][0];
		originProjection = fabs( -box2Origin.y * box2ToBox1[2][2] + box2Origin.z * box2ToBox1[1][2] ) + tolerance;
		if ( originProjection > boxProjectionSum )
		{
			MatrixGetColumn( box2ToWorld, 2, pNormalOut );
			local v = worldToBox1[0].Cross(pNormalOut);
			pNormalOut.x = v.x;
			pNormalOut.y = v.y;
			pNormalOut.z = v.z;
			return true;
		};
	};

	// b1e2 x b2e1
	if ( absBox2ToBox1[1][0] < 0.999 )
	{
		boxProjectionSum =
			box1Size.x * absBox2ToBox1[2][0] + box1Size.z * absBox2ToBox1[0][0] +
			box2Size.y * absBox2ToBox1[1][2] + box2Size.z * absBox2ToBox1[1][1];
		originProjection = fabs( box2Origin.x * box2ToBox1[2][0] - box2Origin.z * box2ToBox1[0][0] ) + tolerance;
		if ( originProjection > boxProjectionSum )
		{
			MatrixGetColumn( box2ToWorld, 0, pNormalOut );
			local v = worldToBox1[1].Cross(pNormalOut);
			pNormalOut.x = v.x;
			pNormalOut.y = v.y;
			pNormalOut.z = v.z;
			return true;
		};
	};

	// b1e2 x b2e2
	if ( absBox2ToBox1[1][1] < 0.999 )
	{
		boxProjectionSum =
			box1Size.x * absBox2ToBox1[2][1] + box1Size.z * absBox2ToBox1[0][1] +
			box2Size.x * absBox2ToBox1[1][2] + box2Size.z * absBox2ToBox1[1][0];
		originProjection = fabs( box2Origin.x * box2ToBox1[2][1] - box2Origin.z * box2ToBox1[0][1] ) + tolerance;
		if ( originProjection > boxProjectionSum )
		{
			MatrixGetColumn( box2ToWorld, 1, pNormalOut );
			local v = worldToBox1[1].Cross(pNormalOut);
			pNormalOut.x = v.x;
			pNormalOut.y = v.y;
			pNormalOut.z = v.z;
			return true;
		};
	};

	// b1e2 x b2e3
	if ( absBox2ToBox1[1][2] < 0.999 )
	{
		boxProjectionSum =
			box1Size.x * absBox2ToBox1[2][2] + box1Size.z * absBox2ToBox1[0][2] +
			box2Size.x * absBox2ToBox1[1][1] + box2Size.y * absBox2ToBox1[1][0];
		originProjection = fabs( box2Origin.x * box2ToBox1[2][2] - box2Origin.z * box2ToBox1[0][2] ) + tolerance;
		if ( originProjection > boxProjectionSum )
		{
			MatrixGetColumn( box2ToWorld, 2, pNormalOut );
			local v = worldToBox1[1].Cross(pNormalOut);
			pNormalOut.x = v.x;
			pNormalOut.y = v.y;
			pNormalOut.z = v.z;
			return true;
		};
	};

	// b1e3 x b2e1
	if ( absBox2ToBox1[2][0] < 0.999 )
	{
		boxProjectionSum =
			box1Size.x * absBox2ToBox1[1][0] + box1Size.y * absBox2ToBox1[0][0] +
			box2Size.y * absBox2ToBox1[2][2] + box2Size.z * absBox2ToBox1[2][1];
		originProjection = fabs( -box2Origin.x * box2ToBox1[1][0] + box2Origin.y * box2ToBox1[0][0] ) + tolerance;
		if ( originProjection > boxProjectionSum )
		{
			MatrixGetColumn( box2ToWorld, 0, pNormalOut );
			local v = worldToBox1[2].Cross(pNormalOut);
			pNormalOut.x = v.x;
			pNormalOut.y = v.y;
			pNormalOut.z = v.z;
			return true;
		};
	};

	// b1e3 x b2e2
	if ( absBox2ToBox1[2][1] < 0.999 )
	{
		boxProjectionSum =
			box1Size.x * absBox2ToBox1[1][1] + box1Size.y * absBox2ToBox1[0][1] +
			box2Size.x * absBox2ToBox1[2][2] + box2Size.z * absBox2ToBox1[2][0];
		originProjection = fabs( -box2Origin.x * box2ToBox1[1][1] + box2Origin.y * box2ToBox1[0][1] ) + tolerance;
		if ( originProjection > boxProjectionSum )
		{
			MatrixGetColumn( box2ToWorld, 1, pNormalOut );
			local v = worldToBox1[2].Cross(pNormalOut);
			pNormalOut.x = v.x;
			pNormalOut.y = v.y;
			pNormalOut.z = v.z;
			return true;
		};
	};

	// b1e3 x b2e3
	if ( absBox2ToBox1[2][2] < 0.999 )
	{
		boxProjectionSum =
			box1Size.x * absBox2ToBox1[1][2] + box1Size.y * absBox2ToBox1[0][2] +
			box2Size.x * absBox2ToBox1[2][1] + box2Size.y * absBox2ToBox1[2][0];
		originProjection = fabs( -box2Origin.x * box2ToBox1[1][2] + box2Origin.y * box2ToBox1[0][2] ) + tolerance;
		if ( originProjection > boxProjectionSum )
		{
			MatrixGetColumn( box2ToWorld, 2, pNormalOut );
			local v = worldToBox1[2].Cross(pNormalOut);
			pNormalOut.x = v.x;
			pNormalOut.y = v.y;
			pNormalOut.z = v.z;
			return true;
		};
	};
	return false;
}

//-----------------------------------------------------------------------------
// Compute a separating plane between two boxes (expensive!)
// Returns false if no separating plane exists
//-----------------------------------------------------------------------------
function VS::ComputeSeparatingPlane2( org1, angles1, min1, max1, org2, angles2, min2, max2, tolerance, pNormal = _VEC )
	: (matrix3x4_t)
{
	local worldToBox1 = matrix3x4_t(),
		box2ToWorld = matrix3x4_t();

	ComputeCenterIMatrix( org1, angles1, min1, max1, worldToBox1 );
	ComputeCenterMatrix( org2, angles2, min2, max2, box2ToWorld );

	// Then compute the size of the two boxes
	local box1Size = (max1 - min1) * 0.5;
	local box2Size = (max2 - min2) * 0.5;

	return ComputeSeparatingPlane( worldToBox1, box2ToWorld, box1Size, box2Size, tolerance, pNormal );
}
*/
