//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//-----------------------------------------------------------------------
//
// Math library. Contains code from the Source Engine and DirectX.
//
//
// Run the following regex replacement for SQ3:
//	(?!function[\s\w\:]*[\(]?.*[\)]?[^\{]+?)\:\s*\(\s*[\s\w,]*\)
//
//-----------------------------------------------------------------------


if ( !("VS" in getroottable()) )
	::VS <- { version = "0.0.0" };

if ( "VectorRotate" in VS )
	return;

//
// External dependencies
//
if ( !("DebugDrawLine" in getroottable()) )
{
	if ( "debugoverlay" in getroottable() && "Line" in debugoverlay )
		::DebugDrawLine <- function( v0, v1, r, g, b, z, t ) { return debugoverlay.Line( v0, v1, r, g, b, z, t ); }
	else
		::DebugDrawLine <- dummy;
};

if ( !("RandomFloat" in getroottable()) )
{
	::RandomFloat <- function( a, b ) : (rand)
	{
		return (rand().tofloat() / RAND_MAX) * (b - a) + a;
	}
};

if ( !("Vector" in getroottable()) )
{
	::Vector <- class
	{
		x = 0.0; y = 0.0; z = 0.0;
		constructor( _x = 0.0, _y = 0.0, _z = 0.0 )
		{
			x = _x; y = _y; z = _z;
		}
		function Cross(v)
		{
			return Vector( y*v.z - z*v.y, z*v.x - x*v.z, x*v.y - y*v.x );
		}
		function Dot(v)
		{
			return x*v.x + y*v.y + z*v.z;
		}
		function Norm() : (sqrt)
		{
			local l = sqrt( x*x + y*y + z*z );
			local f = 1.0 / l;
			x *= f;
			y *= f;
			z *= f;
			return l;
		}
		function LengthSqr()
		{
			return x*x + y*y + z*z;
		}
		function Length() : (sqrt)
		{
			return sqrt( x*x + y*y + z*z );
		}
		function Length2DSqr()
		{
			return x*x + y*y;
		}
		function Length2D() : (sqrt)
		{
			return sqrt( x*x + y*y );
		}
		function _tostring() : (format)
		{
			return format( "%f %f %f", x, y, z );
		}
	}
};


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

// This is not included with the library to prevent possible issues with
// multiple origin scripts referencing the wrong Vector class passed in from others, expecting extended functionality and breaking.
// For personal uses where your scripts use the expected class, use vec3_t below
// which can be a complete substitute for Vector.
/*
::vec3_t <- class extends ::Vector {}
local Vector = ::vec3_t;

Vector.IsValid <- function()
{
	return ( x > -FLT_MAX && x < FLT_MAX ) &&
		( y > -FLT_MAX && y < FLT_MAX ) &&
		( z > -FLT_MAX && z < FLT_MAX );
}

Vector.IsZero <- function()
{
	return !x && !y && !z;
}

Vector._unm <- function()
{
	return this * 0xFFFFFFFF;
}

Vector._div <- function(f)
{
	return this * ( 1.0 / f );
}

Vector.Negate <- function()
{
	x = -x; y = -y; z = -z;
}

Vector.Init <- function( X = 0.0, Y = 0.0, Z = 0.0 )
{
	x = X; y = Y; z = Z;
}

Vector.Copy <- function(v)
{
	x = v.x; y = v.y; z = v.z;
}

Vector.Replicate <- function(f)
{
	x = y = z = f;
}

Vector.Normalized <- function()
{
	local v = this * 1.0;
	v.Norm();
	return v;
}
*/


local Fmt = format;
local sin = sin, cos = cos, tan = tan, asin = asin, acos = acos, atan = atan, atan2 = atan2,
	sqrt = sqrt, rand = rand, pow = pow, log = log, exp = exp, array = array,
	RandomFloat = RandomFloat, Vector = Vector;


local Quaternion = class
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

Quaternion._add <- function(v) : (Quaternion) { return Quaternion( x+v.x,y+v.y,z+v.z,w+v.w ) }
Quaternion._sub <- function(v) : (Quaternion) { return Quaternion( x-v.x,y-v.y,z-v.z,w-v.w ) }
Quaternion._mul <- function(v) : (Quaternion) { return Quaternion( x*v,y*v,z*v,w*v ) }
Quaternion._div <- function(v) : (Quaternion) { local f = 1.0/v; return Quaternion( x*f,y*f,z*f,w*f ) }
Quaternion._unm <- function() : (Quaternion) { return Quaternion( -x,-y,-z,-w ) }


//
// Array access operator helper for changing a
// 2D array implementation into a 1D array ( simulating C arrays
// where { *(*p + 6) == p[0][6] == p[1][2] } equality is true for { byte p[4][4] } ),
// while keeping backwards compatibility.
//
// Downsides:
//   Reduced readability
//   Increased mem usage and instr count for unchanged old code (.m[row][column])
//   No forward compatibility of a syntax change [0][M_23]
//
// Upsides:
//   Faster initialisation (creating and using 1 SQArray instead of 4)
//   Halved _OP_GET instr count for each element access ([0] instead of .m; [M_21] instead of [2][1])
//
//
// Batch conversion:
//		\[([0-3])\]\[([0-3])\]
//		\[M_\1\2\]
//
local CArrayOpMan;
{
	local CArrayOpManSub = class
	{
		[0x7E] = 0;
		[0x7F] = null;
		constructor(p) { this[0x7F] = p; }
		function _get(i) { return this[0x7F][this[0x7E]+i]; }
		function _set(i,v) { this[0x7F][this[0x7E]+i] = v; }
	};
CArrayOpMan = class
{
	[0x7F] = null;
	constructor(p) : (CArrayOpManSub) { this[0x7F] = CArrayOpManSub(p); }
	function _get(i) { local _ = this[0x7F]; _[0x7E] = 4*i; return _; } // column count : 4
}
}

const M_00 = 0;;  const M_01 = 1;;  const M_02 = 2;;  const M_03 = 3;;
const M_10 = 4;;  const M_11 = 5;;  const M_12 = 6;;  const M_13 = 7;;
const M_20 = 8;;  const M_21 = 9;;  const M_22 = 10;; const M_23 = 11;;
const M_30 = 12;; const M_31 = 13;; const M_32 = 14;; const M_33 = 15;;

local matrix3x4_t = class
{
	[0] = null;

	constructor(
		m00 = 0.0, m01 = 0.0, m02 = 0.0, m03 = 0.0,
		m10 = 0.0, m11 = 0.0, m12 = 0.0, m13 = 0.0,
		m20 = 0.0, m21 = 0.0, m22 = 0.0, m23 = 0.0 )
	{
		this[0] =
		[
			m00, m01, m02, m03,
			m10, m11, m12, m13,
			m20, m21, m22, m23
		];
	}

	function Init(
		m00 = 0.0, m01 = 0.0, m02 = 0.0, m03 = 0.0,
		m10 = 0.0, m11 = 0.0, m12 = 0.0, m13 = 0.0,
		m20 = 0.0, m21 = 0.0, m22 = 0.0, m23 = 0.0 )
	{
		local m = this[0];

		m[M_00] = m00;
		m[M_01] = m01;
		m[M_02] = m02;
		m[M_03] = m03;

		m[M_10] = m10;
		m[M_11] = m11;
		m[M_12] = m12;
		m[M_13] = m13;

		m[M_20] = m20;
		m[M_21] = m21;
		m[M_22] = m22;
		m[M_23] = m23;
	}

	// FLU
	function InitXYZ( vX, vY, vZ, vT )
	{
		local m = this[0];

		m[M_00] = vX.x;
		m[M_10] = vX.y;
		m[M_20] = vX.z;

		m[M_01] = vY.x;
		m[M_11] = vY.y;
		m[M_21] = vY.z;

		m[M_02] = vZ.x;
		m[M_12] = vZ.y;
		m[M_22] = vZ.z;

		m[M_03] = vT.x;
		m[M_13] = vT.y;
		m[M_23] = vT.z;
	}

	function _cloned( src )
	{
		this[0] = clone src[0];
	}

	function _tostring() : (Fmt)
	{
		local m = this[0];
		return Fmt( "[ (%.6g, %.6g, %.6g), (%.6g, %.6g, %.6g), (%.6g, %.6g, %.6g), (%.6g, %.6g, %.6g) ]",
			m[M_00], m[M_01], m[M_02],
			m[M_10], m[M_11], m[M_12],
			m[M_20], m[M_21], m[M_22],
			m[M_03], m[M_13], m[M_23] );
	}

	function _typeof()
	{
		return "matrix3x4_t";
	}

	_man = null;

	function _get(i) : (CArrayOpMan)
	{
		if ( !_man )
			_man = CArrayOpMan( this[0] );

		if ( i == "m" )
			return _man;

		return _man[i];
	}
}

local VMatrix = class extends matrix3x4_t
{
	[0] = null;

	constructor(
		m00 = 0.0, m01 = 0.0, m02 = 0.0, m03 = 0.0,
		m10 = 0.0, m11 = 0.0, m12 = 0.0, m13 = 0.0,
		m20 = 0.0, m21 = 0.0, m22 = 0.0, m23 = 0.0,
		m30 = 0.0, m31 = 0.0, m32 = 0.0, m33 = 1.0 )
	{
		this[0] =
		[
			m00, m01, m02, m03,
			m10, m11, m12, m13,
			m20, m21, m22, m23,
			m30, m31, m32, m33
		];
	}

	function Init(
		m00 = 0.0, m01 = 0.0, m02 = 0.0, m03 = 0.0,
		m10 = 0.0, m11 = 0.0, m12 = 0.0, m13 = 0.0,
		m20 = 0.0, m21 = 0.0, m22 = 0.0, m23 = 0.0,
		m30 = 0.0, m31 = 0.0, m32 = 0.0, m33 = 1.0 )
	{
		local m = this[0];

		m[M_00] = m00;
		m[M_01] = m01;
		m[M_02] = m02;
		m[M_03] = m03;

		m[M_10] = m10;
		m[M_11] = m11;
		m[M_12] = m12;
		m[M_13] = m13;

		m[M_20] = m20;
		m[M_21] = m21;
		m[M_22] = m22;
		m[M_23] = m23;

		m[M_30] = m30;
		m[M_31] = m31;
		m[M_32] = m32;
		m[M_33] = m33;
	}

	function Identity()
	{
		local m = this[0];

		m[M_00] = m[M_11] = m[M_22] = m[M_33] = 1.0;

		m[M_01] = m[M_02] = m[M_03] =
		m[M_10] = m[M_12] = m[M_13] =
		m[M_20] = m[M_21] = m[M_23] =
		m[M_30] = m[M_31] = m[M_32] = 0.0;
	}

	function _tostring() : (Fmt)
	{
		local m = this[0];
		return Fmt( "[ (%.6g, %.6g, %.6g, %.6g), (%.6g, %.6g, %.6g, %.6g), (%.6g, %.6g, %.6g, %.6g), (%.6g, %.6g, %.6g, %.6g) ]",
			m[M_00], m[M_01], m[M_02], m[M_03],
			m[M_10], m[M_11], m[M_12], m[M_13],
			m[M_20], m[M_21], m[M_22], m[M_23],
			m[M_30], m[M_31], m[M_32], m[M_33] );
	}

	function _typeof()
	{
		return "VMatrix";
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

// IsIntegralValue
function VS::IsInteger(f)
{
	return f.tointeger() == f;
}

/*
function VS::IsFinite(f)
{
	return ( f > FLT_MAX_N && f < FLT_MAX );
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
	vTarget = vTarget - vSrc;
	vTarget.Norm();
	return vTarget.Dot( vDir ) >= cosTolerance;
}

//-----------------------------------------------------------------------
// Angle between 2 vectors
// Identical to < VS.VectorAngles(vTo-vFrom) >
// return QAngle
//-----------------------------------------------------------------------
function VS::GetAngle( vFrom, vTo ) : ( atan2 )
{
	vTo = vTo - vFrom;
	local pitch = atan2( -vTo.z, vTo.Length2D() ) * RAD2DEG;
	local yaw = atan2( vTo.y, vTo.x ) * RAD2DEG;

	vTo.x = pitch;
	vTo.y = yaw;
	vTo.z = 0.0;

	return vTo;
}

//-----------------------------------------------------------------------
//
//-----------------------------------------------------------------------
function VS::VectorVectors( forward, right, up ) : (Vector)
{
	if ( !forward.x && !forward.y )
	{
		// pitch 90 degrees up/down from identity
		right.y = 0xFFFFFFFF;
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
		sy = sin(yr), cy = cos(yr),

		pr = DEG2RAD*angle.x,
		sp = sin(pr), cp = cos(pr);

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
function VS::VectorAngles( forward, vOut = _VEC ) : ( atan2 )
{
	local yaw = 0.0, pitch = yaw;

	if ( !forward.y && !forward.x )
	{
		if ( forward.z > 0.0 )
			pitch = 270.0;
		else
			pitch = 90.0;
	}
	else
	{
		yaw = atan2( forward.y, forward.x ) * RAD2DEG;
		if ( yaw < 0.0 )
			yaw += 360.0;

		pitch = atan2( -forward.z, forward.Length2D() ) * RAD2DEG;
		if ( pitch < 0.0 )
			pitch += 360.0;
	};

	vOut.x = pitch;
	vOut.y = yaw;
	vOut.z = 0.0;

	return vOut;
}
/*
//-----------------------------------------------------------------------
//
//-----------------------------------------------------------------------
function VS::BasisToAngles( forward, right, up, out = _VEC ) : (atan2)
{
	local xyDist = forward.Length2D();
	if ( xyDist > 0.001 )
	{
		out.y = atan2( forward.y, forward.x ) * RAD2DEG;
		out.x = atan2( -forward.z, xyDist ) * RAD2DEG;
		out.z = atan2( -right.z, up.z ) * RAD2DEG;
	}
	else
	{
		out.y = atan2( right.x, -right.y ) * RAD2DEG;
		out.x = atan2( -forward.z, xyDist ) * RAD2DEG;
		out.z = 0.0;
	};
	return out;
}
*/
//-----------------------------------------------------------------------
// Rotate a vector around the Z axis (YAW)
//-----------------------------------------------------------------------
function VS::VectorYawRotate( vIn, fYaw, vOut = _VEC ) : (sin, cos)
{
	fYaw = DEG2RAD * fYaw;
	local sy  = sin(fYaw);
	local cy  = cos(fYaw);

	local x = vIn.x * cy - vIn.y * sy;
	local y = vIn.x * sy + vIn.y * cy;

	vOut.x = x;
	vOut.y = y;
	vOut.z = vIn.z;

	return vOut;
}

function VS::YawToVector( yaw ) : (Vector, sin, cos)
{
	yaw = DEG2RAD * yaw;
	return Vector( cos(yaw), sin(yaw), 0.0 );
}

function VS::VecToYaw( vec ) : (atan2)
{
	if ( !vec.y && !vec.x )
		return 0.0;

	return atan2( vec.y, vec.x ) * RAD2DEG;
}

function VS::VecToPitch( vec ) : (atan2)
{
	if ( !vec.y && !vec.x )
	{
		if ( vec.z < 0.0 )
			return 180.0;
		return -180.0;
	};

	return atan2( -vec.z, vec.Length2D() ) * RAD2DEG;
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
	local y = a.y - b.y;
	local z = a.z - b.z;

	if (0.0 > x) x = -x;
	if (0.0 > y) y = -y;
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
	a = AngleDiff(a, b)
	if (0.0 > a)
		a = -a;

	return a <= tolerance;
}

//-----------------------------------------------------------------------
// Equality with tolerance
//-----------------------------------------------------------------------
function VS::CloseEnough( a, b, e = 1.e-3 )
{
	a = a - b;
	if (0.0 > a)
		a = -a;

	return a <= e;
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
	local _360 = 360.0, _180 = 180.0;

	// target = AngleNormalize( target );
	target %= _360;
	if ( target > _180 )
		target -= _360;
	else if ( -_180 > target )
		target += _360;;

	// value = AngleNormalize( value );
	value %= _360;
	if ( value > _180 )
		value -= _360;
	else if ( -_180 > value )
		value += _360;;

	// local delta = AngleDiff( target, value );
	local delta = ( target - value ) % _360;
	if ( delta > _180 )
		delta -= _360;
	else if ( -_180 > delta )
		delta += _360;;

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
	local _360 = 360.0, _180 = 180.0;

	angle %= _360;

	if ( angle > _180 )
		return angle - _360;
	if ( -_180 > angle )
		return angle + _360;
	return angle;
}

// QAngle
function VS::QAngleNormalize( vAng )
{
	// vAng.x = AngleNormalize( vAng.x );
	// vAng.y = AngleNormalize( vAng.y );
	// vAng.z = AngleNormalize( vAng.z );

	local _360 = 360.0, _180 = 180.0;

	vAng.x %= _360;
	if ( vAng.x > _180 )
		vAng.x -= _360;
	else if ( -_180 > vAng.x )
		vAng.x += _360;;

	vAng.y %= _360;
	if ( vAng.y > _180 )
		vAng.y -= _360;
	else if ( -_180 > vAng.y )
		vAng.y += _360;;

	vAng.z %= _360;
	if ( vAng.z > _180 )
		vAng.z -= _360;
	else if ( -_180 > vAng.z )
		vAng.z += _360;;

	return vAng;
}

//-----------------------------------------------------------------------------
// Snaps the input vector to the closest axis
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

// Vector a * Vector b
function VS::VectorMultiply( a, b, o )
{
	o.x = a.x*b.x;
	o.y = a.y*b.y;
	o.z = a.z*b.z;
}

// Vector a / Vector b
function VS::VectorDivide( a, b, o )
{
	o.x = a.x/b.x;
	o.y = a.y/b.y;
	o.z = a.z/b.z;
}

function VS::VectorMA( start, scale, direction, dest = _VEC )
{
	dest.x = start.x + scale * direction.x;
	dest.y = start.y + scale * direction.y;
	dest.z = start.z + scale * direction.z;

	return dest;
}

local VectorAdd = VS.VectorAdd;
local VectorSubtract = VS.VectorSubtract;

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
	local sp = sin( phi ) * r;

	//if ( !out )
	//	return Vector( cos( theta ) * sp, sin( theta ) * sp, cos( phi ) );

	out.x = cos( theta ) * sp;
	out.y = sin( theta ) * sp;
	out.z = cos( phi ) * r;
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

	//if ( !out )
	//	return Vector( cos( theta ) * sp, sin( theta ) * sp, cos( phi ) );

	out.x = cos( theta ) * sp;
	out.y = sin( theta ) * sp;
	out.z = cos( phi );
}

// decayTo is factor the value should decay to in decayTime
function VS::ExponentialDecay( decayTo, decayTime, dt ) : (log, exp)
{
	return exp( log(decayTo) / decayTime * dt );
}

// halflife is time for value to reach 50%
function VS::ExponentialDecayHalf( halflife, dt ) : (exp)
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

	if ( cVal <= 0.0 )
		return C;

	if ( cVal >= 1.0 )
		return D;

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

	if ( cVal <= 0.0 )
		return C;

	if ( cVal >= 1.0 )
		return D;

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
		return Bias( 2.0*x, 1.0-biasAmt ) * 0.5;
	return 1.0 - Bias( 2.0 - 2.0*x, 1.0-biasAmt ) * 0.5;
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

// NOTE: The signature of this function differs from its Source Engine mathlib definition where it is (t, A, B)
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
	in2 = in2[0];

	// out[0] = DotProduct( in1, in2[0] ) + in2[0][3];
	local x = in1.x;
	local y = in1.y;
	local z = in1.z;

	out.x = x*in2[M_00] + y*in2[M_01] + z*in2[M_02] + in2[M_03];
	out.y = x*in2[M_10] + y*in2[M_11] + z*in2[M_12] + in2[M_13];
	out.z = x*in2[M_20] + y*in2[M_21] + z*in2[M_22] + in2[M_23];

	return out;
}

// assuming the matrix is orthonormal, transform in1 by the transpose (also the inverse in this case) of in2.
function VS::VectorITransform( in1, in2, out = _VEC )
{
	in2 = in2[0];

	local in1t0 = in1.x - in2[M_03];
	local in1t1 = in1.y - in2[M_13];
	local in1t2 = in1.z - in2[M_23];

	local x = in1t0 * in2[M_00] + in1t1 * in2[M_10] + in1t2 * in2[M_20];
	local y = in1t0 * in2[M_01] + in1t1 * in2[M_11] + in1t2 * in2[M_21];
	local z = in1t0 * in2[M_02] + in1t1 * in2[M_12] + in1t2 * in2[M_22];

	out.x = x;
	out.y = y;
	out.z = z;

	return out;
}

// assume in2 is a rotation (matrix3x4_t) and rotate the input vector
function VS::VectorRotate( in1, in2, out = _VEC )
{
	in2 = in2[0];

	// out.x = DotProduct( in1, in2[0] );
	local x = in1.x;
	local y = in1.y;
	local z = in1.z;

	out.x = x*in2[M_00] + y*in2[M_01] + z*in2[M_02];
	out.y = x*in2[M_10] + y*in2[M_11] + z*in2[M_12];
	out.z = x*in2[M_20] + y*in2[M_21] + z*in2[M_22];

	return out;
}

local VectorRotate = VS.VectorRotate;

// assume in2 is a rotation (QAngle) and rotate the input vector
function VS::VectorRotateByAngle( in1, in2, out = _VEC ) : (matrix3x4_t, VectorRotate)
{
	local matRotate = matrix3x4_t();
	AngleMatrix( in2, null, matRotate );
	return VectorRotate( in1, matRotate, out );
}

// assume in2 is a rotation (Quaternion) and rotate the input vector
function VS::VectorRotateByQuaternion( in1, in2, out = _VEC )
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
	in2 = in2[0];

	local x = in1.x;
	local y = in1.y;
	local z = in1.z;

	out.x = x*in2[M_00] + y*in2[M_10] + z*in2[M_20];
	out.y = x*in2[M_01] + y*in2[M_11] + z*in2[M_21];
	out.z = x*in2[M_02] + y*in2[M_12] + z*in2[M_22];

	return out;
}

local VectorITransform = VS.VectorITransform;
local VectorTransform = VS.VectorTransform;
local VectorIRotate = VS.VectorIRotate;


function VS::VectorMatrix( forward, matrix ) : ( Vector, VectorVectors )
{
	local right = Vector(), up = Vector();
	VectorVectors( forward, right, up );

	matrix = matrix[0];

	// MatrixSetColumn( forward, 0, matrix );
	matrix[M_00] = forward.x;
	matrix[M_10] = forward.y;
	matrix[M_20] = forward.z;

	// MatrixSetColumn( -right, 1, matrix );
	matrix[M_01] = -right.x;
	matrix[M_11] = -right.y;
	matrix[M_21] = -right.z;

	// MatrixSetColumn( up, 2, matrix );
	matrix[M_02] = up.x;
	matrix[M_12] = up.y;
	matrix[M_22] = up.z;
}

// Matrix is right-handed x=forward, y=left, z=up.  Valve uses left-handed convention for vectors in the game code (forward, right, up)
function VS::MatrixVectors( matrix, pForward, pRight, pUp )
{
	matrix = matrix[0];

	// MatrixGetColumn( matrix, 0, pForward );
	pForward.x = matrix[M_00];
	pForward.y = matrix[M_10];
	pForward.z = matrix[M_20];

	// MatrixGetColumn( matrix, 1, pRight );
	pRight.x = -matrix[M_01];
	pRight.y = -matrix[M_11];
	pRight.z = -matrix[M_21];

	// MatrixGetColumn( matrix, 2, pUp );
	pUp.x = matrix[M_02];
	pUp.y = matrix[M_12];
	pUp.z = matrix[M_22];
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
	matrix = matrix[0];

	if ( position )
	{
		// MatrixGetColumn( matrix, 3, position );
		position.x = matrix[M_03];
		position.y = matrix[M_13];
		position.z = matrix[M_23];
	};

	local forward0 = matrix[M_00];
	local forward1 = matrix[M_10];
	local xyDist = sqrt( forward0 * forward0 + forward1 * forward1 );

	// enough here to get angles?
	if( xyDist > 0.001 )
	{
		// (yaw)	y = ATAN( forward[1], forward[0] );		-- in our space, forward is the X axis
		angles.y = atan2( forward1, forward0 ) * RAD2DEG;

		// (pitch)	x = ATAN( -forward[2], sqrt(forward[0]*forward[0]+forward[1]*forward[1]) );
		angles.x = atan2( -matrix[M_20], xyDist ) * RAD2DEG;

		// (roll)	z = ATAN( left[2], up[2] );
		angles.z = atan2( matrix[M_21], matrix[M_22] ) * RAD2DEG;
	}
	else	// forward is mostly Z, gimbal lock-
	{
		// (yaw)	y = ATAN( -left[0], left[1] );			-- forward is mostly z, so use right for yaw
		angles.y = atan2( -matrix[M_01], matrix[M_11] ) * RAD2DEG;

		// (pitch)	x = ATAN( -forward[2], sqrt(forward[0]*forward[0]+forward[1]*forward[1]) );
		angles.x = atan2( -matrix[M_20], xyDist ) * RAD2DEG;

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
function VS::AngleMatrix( angles, position, matrix ) : (sin, cos)
{
	local ay = DEG2RAD*angles.y,
		ax = DEG2RAD*angles.x,
		az = DEG2RAD*angles.z;

	local sy = sin(ay), cy = cos(ay),
		sp = sin(ax), cp = cos(ax),
		sr = sin(az), cr = cos(az);

	matrix = matrix[0];
	// matrix = (YAW * PITCH) * ROLL
	matrix[M_00] = cp*cy;
	matrix[M_10] = cp*sy;
	matrix[M_20] = -sp;

	local crcy = cr*cy,
		crsy = cr*sy,
		srcy = sr*cy,
		srsy = sr*sy;

	matrix[M_01] = sp*srcy-crsy;
	matrix[M_11] = sp*srsy+crcy;
	matrix[M_21] = sr*cp;

	matrix[M_02] = sp*crcy+srsy;
	matrix[M_12] = sp*crsy-srcy;
	matrix[M_22] = cr*cp;

	if ( position )
	{
		// MatrixSetColumn( position, 3, matrix );
		matrix[M_03] = position.x;
		matrix[M_13] = position.y;
		matrix[M_23] = position.z;
	}
	else
	{
		matrix[M_03] = matrix[M_13] = matrix[M_23] = 0.0;
	};
}

function VS::AngleIMatrix( angles, position, matrix ) : (sin, cos, VectorRotate)
{
	local ay = DEG2RAD*angles.y,
		ax = DEG2RAD*angles.x,
		az = DEG2RAD*angles.z;

	local sy = sin(ay), cy = cos(ay),
		sp = sin(ax), cp = cos(ax),
		sr = sin(az), cr = cos(az);

	local m = matrix[0];

	// matrix = (YAW * PITCH) * ROLL
	m[M_00] = cp*cy;
	m[M_01] = cp*sy;
	m[M_02] = -sp;

	local srsp = sr*sp, crsp = cr*sp;

	m[M_10] = srsp*cy-cr*sy;
	m[M_11] = srsp*sy+cr*cy;
	m[M_12] = sr*cp;

	m[M_20] = crsp*cy+sr*sy;
	m[M_21] = crsp*sy-sr*cy;
	m[M_22] = cr*cp;

	if ( position )
	{
		local vecTranslation = VectorRotate( position, matrix );
		// MatrixSetColumn( vecTranslation * -1, 3, matrix );
		m[M_03] = -vecTranslation.x;
		m[M_13] = -vecTranslation.y;
		m[M_23] = -vecTranslation.z;
	}
	else
	{
		m[M_03] = m[M_13] = m[M_23] = 0.0;
	};
}

local MatrixAngles = VS.MatrixAngles;
local AngleMatrix = VS.AngleMatrix;
local AngleIMatrix = VS.AngleIMatrix;


function VS::QuaternionsAreEqual( a, b, tolerance = 0.0 )
{
	local x = a.x - b.x;
	local y = a.y - b.y;
	local z = a.z - b.z;
	local w = a.w - b.w;

	if (0.0 > x) x = -x;
	if (0.0 > y) y = -y;
	if (0.0 > z) z = -z;
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
	local r = q.x*q.x + q.y*q.y + q.z*q.z + q.w*q.w;

	if ( r ) // > FLT_EPSILON && ((radius < 1.0 - 4*FLT_EPSILON) || (radius > 1.0 + 4*FLT_EPSILON))
	{
		local ir = 1.0 / sqrt(r);
		q.w *= ir;
		q.z *= ir;
		q.y *= ir;
		q.x *= ir;
	};

	return r;
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
function VS::QuaternionMult( p, q, qt = _QUAT ) : (QuaternionAlign)
{
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
function VS::QuaternionMA( p, s, q, qt = _QUAT ) : ( QuaternionNormalize, QuaternionMult )
{
	QuaternionScale( q, s, qt );
	QuaternionMult( p, qt, qt );
	QuaternionNormalize( qt );

	return qt;
}

function VS::QuaternionAdd( p, q, qt = _QUAT ) : ( QuaternionAlign )
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
	local r = p.x*p.x + p.y*p.y + p.z*p.z + p.w*p.w;
	if ( r )
	{
		local inv = 1.0 / r;
		q.x = -p.x * inv;
		q.y = -p.y * inv;
		q.z = -p.z * inv;
		q.w = p.w * inv;
	};
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
	return QuaternionBlendNoAlign( p, QuaternionAlign( p, q ), t, qt );
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
	return QuaternionSlerpNoAlign( p, QuaternionAlign( p, q ), t, qt );
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
	local Theta = sqrt( p.x*p.x + p.y*p.y + p.z*p.z );

	// Control = XMVectorNearEqual(Theta, Zero, g_XMEpsilon.v);
	if ( Theta > FLT_EPSILON )
	{
		// XMVectorSinCos(&SinTheta, &CosTheta, Theta);
		// S = XMVectorDivide(SinTheta, Theta);
		local S = sin(Theta) / Theta;

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
	if ( p.w < 0.99999 || -0.99999 < p.w )
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
function VS::QuaternionSquad( Q0, Q1, Q2, Q3, T, qt ) : (Quaternion, QuaternionSlerpNoAlign)
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
		local SQ2 = Q2;
		{
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

			// Control1 = XMVectorLess(LS12, LD12);
			// SQ2 = XMVectorSelect(Q2, XMVectorNegate(Q2), Control1);
			if ( LS12 < LD12 )
			{
				SQ2 = Quaternion( -Q2.x, -Q2.y, -Q2.z, -Q2.w );
			};
		}
		// QuaternionAlign( Q0, Q1 )
		local SQ0 = Q0;
		{
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

			// Control0 = XMVectorLess(LS01, LD01);
			// SQ0 = XMVectorSelect(Q0, XMVectorNegate(Q0), Control0);
			if ( LS01 < LD01 )
			{
				SQ0 = Quaternion( -Q0.x, -Q0.y, -Q0.z, -Q0.w );
			};
		}
		// QuaternionAlign( SQ2, Q3 )
		local SQ3 = Q3;
		{
			// LS23 = XMQuaternionLengthSq(XMVectorAdd(SQ2, Q3));
			local aQ23x = SQ2.x + Q3.x;
			local aQ23y = SQ2.y + Q3.y;
			local aQ23z = SQ2.z + Q3.z;
			local aQ23w = SQ2.w + Q3.w;
			local LS23 = aQ23x*aQ23x + aQ23y*aQ23y + aQ23z*aQ23z + aQ23w*aQ23w;

			// LD23 = XMQuaternionLengthSq(XMVectorSubtract(SQ2, Q3));
			local sQ23x = SQ2.x - Q3.x;
			local sQ23y = SQ2.y - Q3.y;
			local sQ23z = SQ2.z - Q3.z;
			local sQ23w = SQ2.w - Q3.w;
			local LD23 = sQ23x*sQ23x + sQ23y*sQ23y + sQ23z*sQ23z + sQ23w*sQ23w;

			// Control2 = XMVectorLess(LS23, LD23);
			// SQ3 = XMVectorSelect(Q3, XMVectorNegate(Q3), Control2);
			if ( LS23 < LD23 )
			{
				SQ3 = Quaternion( -Q3.x, -Q3.y, -Q3.z, -Q3.w );
			};
		}

		local pA = Quaternion();
		local pB = Quaternion();
		{
			local LnQ0 = Quaternion();
			local LnQ2 = Quaternion();
			local LnQ1 = Quaternion();
			local LnQ3 = Quaternion();
			{
				// InvQ1 = XMQuaternionInverse(Q1);
				// InvQ2 = XMQuaternionInverse(SQ2);
				local InvQ1 = Quaternion();
				local InvQ2 = Quaternion();
				QuaternionInvert( Q1, InvQ1 );
				QuaternionInvert( SQ2, InvQ2 );

				// LnQ0 = XMQuaternionLn(XMQuaternionMultiply(InvQ1, SQ0));
					// QuaternionMultNoAlign(SQ0, InvQ1, LnQ0)
					LnQ0.x = SQ0.w * InvQ1.x + SQ0.x * InvQ1.w + SQ0.y * InvQ1.z - SQ0.z * InvQ1.y;
					LnQ0.y = SQ0.w * InvQ1.y - SQ0.x * InvQ1.z + SQ0.y * InvQ1.w + SQ0.z * InvQ1.x;
					LnQ0.z = SQ0.w * InvQ1.z + SQ0.x * InvQ1.y - SQ0.y * InvQ1.x + SQ0.z * InvQ1.w;
					LnQ0.w = SQ0.w * InvQ1.w - SQ0.x * InvQ1.x - SQ0.y * InvQ1.y - SQ0.z * InvQ1.z;
					QuaternionLn(LnQ0, LnQ0);

				// LnQ2 = XMQuaternionLn(XMQuaternionMultiply(InvQ1, SQ2));
					// QuaternionMultNoAlign(SQ2, InvQ1, LnQ2)
					LnQ2.x = SQ2.w * InvQ1.x + SQ2.x * InvQ1.w + SQ2.y * InvQ1.z - SQ2.z * InvQ1.y;
					LnQ2.y = SQ2.w * InvQ1.y - SQ2.x * InvQ1.z + SQ2.y * InvQ1.w + SQ2.z * InvQ1.x;
					LnQ2.z = SQ2.w * InvQ1.z + SQ2.x * InvQ1.y - SQ2.y * InvQ1.x + SQ2.z * InvQ1.w;
					LnQ2.w = SQ2.w * InvQ1.w - SQ2.x * InvQ1.x - SQ2.y * InvQ1.y - SQ2.z * InvQ1.z;
					QuaternionLn(LnQ2, LnQ2);

				// LnQ1 = XMQuaternionLn(XMQuaternionMultiply(InvQ2, Q1));
					// QuaternionMultNoAlign(Q1, InvQ2, LnQ1)
					LnQ1.x = Q1.w * InvQ2.x + Q1.x * InvQ2.w + Q1.y * InvQ2.z - Q1.z * InvQ2.y;
					LnQ1.y = Q1.w * InvQ2.y - Q1.x * InvQ2.z + Q1.y * InvQ2.w + Q1.z * InvQ2.x;
					LnQ1.z = Q1.w * InvQ2.z + Q1.x * InvQ2.y - Q1.y * InvQ2.x + Q1.z * InvQ2.w;
					LnQ1.w = Q1.w * InvQ2.w - Q1.x * InvQ2.x - Q1.y * InvQ2.y - Q1.z * InvQ2.z;
					QuaternionLn(LnQ1, LnQ1);

				// LnQ3 = XMQuaternionLn(XMQuaternionMultiply(InvQ2, SQ3));
					// QuaternionMultNoAlign(SQ3, InvQ2, LnQ3)
					LnQ3.x = SQ3.w * InvQ2.x + SQ3.x * InvQ2.w + SQ3.y * InvQ2.z - SQ3.z * InvQ2.y;
					LnQ3.y = SQ3.w * InvQ2.y - SQ3.x * InvQ2.z + SQ3.y * InvQ2.w + SQ3.z * InvQ2.x;
					LnQ3.z = SQ3.w * InvQ2.z + SQ3.x * InvQ2.y - SQ3.y * InvQ2.x + SQ3.z * InvQ2.w;
					LnQ3.w = SQ3.w * InvQ2.w - SQ3.x * InvQ2.x - SQ3.y * InvQ2.y - SQ3.z * InvQ2.z;
					QuaternionLn(LnQ3, LnQ3);
			}

			// const NegativeOneQuarter = XMVectorSplatConstant(-1, 2);
			// const NegativeOneQuarter = XMVectorReplicate(-0.25);

			// ExpQ02 = XMVectorMultiply(XMVectorAdd(LnQ0, LnQ2), NegativeOneQuarter);
			local ExpQ02 = Quaternion();
			local ExpQ13 = Quaternion();
			ExpQ02.x = -0.25 * (LnQ0.x + LnQ2.x);
			ExpQ02.y = -0.25 * (LnQ0.y + LnQ2.y);
			ExpQ02.z = -0.25 * (LnQ0.z + LnQ2.z);
			ExpQ02.w = -0.25 * (LnQ0.w + LnQ2.w);
			// ExpQ02 = XMQuaternionExp(ExpQ02);
			QuaternionExp(ExpQ02, ExpQ02);

			// ExpQ13 = XMVectorMultiply(XMVectorAdd(LnQ1, LnQ3), NegativeOneQuarter);
			ExpQ13.x = -0.25 * (LnQ1.x + LnQ3.x);
			ExpQ13.y = -0.25 * (LnQ1.y + LnQ3.y);
			ExpQ13.z = -0.25 * (LnQ1.z + LnQ3.z);
			ExpQ13.w = -0.25 * (LnQ1.w + LnQ3.w);
			// ExpQ13 = XMQuaternionExp(ExpQ13);
			QuaternionExp(ExpQ13, ExpQ13);

			// pA = XMQuaternionMultiply(Q1, ExpQ02);
				// QuaternionMultNoAlign(ExpQ02, Q1, pA)
				pA.x = ExpQ02.x * Q1.w + ExpQ02.y * Q1.z - ExpQ02.z * Q1.y + ExpQ02.w * Q1.x;
				pA.y = ExpQ02.y * Q1.w + ExpQ02.z * Q1.x + ExpQ02.w * Q1.y - ExpQ02.x * Q1.z;
				pA.z = ExpQ02.x * Q1.y - ExpQ02.y * Q1.x + ExpQ02.z * Q1.w + ExpQ02.w * Q1.z;
				pA.w = ExpQ02.w * Q1.w - ExpQ02.x * Q1.x - ExpQ02.y * Q1.y - ExpQ02.z * Q1.z;

			// pB = XMQuaternionMultiply(SQ2, ExpQ13);
				// QuaternionMultNoAlign(ExpQ13, SQ2, pB)
				pB.x = ExpQ13.x * SQ2.w + ExpQ13.y * SQ2.z - ExpQ13.z * SQ2.y + ExpQ13.w * SQ2.x;
				pB.y = ExpQ13.y * SQ2.w + ExpQ13.z * SQ2.x + ExpQ13.w * SQ2.y - ExpQ13.x * SQ2.z;
				pB.z = ExpQ13.x * SQ2.y - ExpQ13.y * SQ2.x + ExpQ13.z * SQ2.w + ExpQ13.w * SQ2.z;
				pB.w = ExpQ13.w * SQ2.w - ExpQ13.x * SQ2.x - ExpQ13.y * SQ2.y - ExpQ13.z * SQ2.z;
		}
		// pC = SQ2;
		local pC = SQ2;

	// XMQuaternionSquad(Q0, Q1, Q2, Q3, T, qt)
		local _Q0 = Q1;
		local _Q1 = pA;
		local _Q2 = pB;
		local _Q3 = pC;

		// XMQuaternionSlerpV(Q0, Q3, T)
		// XMQuaternionSlerpV(Q1, Q2, T)
		local Q03 = Quaternion();
		local Q12 = Quaternion();
		QuaternionSlerpNoAlign( _Q0, _Q3, T, Q03 );
		QuaternionSlerpNoAlign( _Q1, _Q2, T, Q12 );

		// TP = XMVectorReplicate(T);
		// const Two = XMVectorSplatConstant(2, 0);
		// TP = XMVectorNegativeMultiplySubtract(TP, TP, TP);
		// TP = XMVectorMultiply(TP, Two);
		T = (T - T * T) * 2.0;

		return QuaternionSlerpNoAlign( Q03, Q12, T, qt );
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

	return QuaternionExp( sum, q );
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

function VS::QuaternionScale( p, t, q ) : ( sqrt, sin, asin )
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

	local sinom = sqrt( p.x * p.x + p.y * p.y + p.z * p.z );
	if ( sinom > 1.0 )
		sinom = 1.0;

	local r = sin( asin( sinom ) * t );

	t = r / (sinom + FLT_EPSILON);
	q.x = p.x * t;
	q.y = p.y * t;
	q.z = p.z * t;

	// rescale rotation
	r = 1.0 - r * r;

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

// QAngle , QAngle , Vector, return float
function VS::RotationDeltaAxisAngle( srcAngles, destAngles, deltaAxis ) : (Quaternion)
{
	local srcQuat = Quaternion(),
		destQuat = Quaternion();

	AngleQuaternion( srcAngles, srcQuat );
	AngleQuaternion( destAngles, destQuat );
	QuaternionScale( srcQuat, -1.0, srcQuat );

	local out = QuaternionMult( destQuat, srcQuat );
	QuaternionNormalize( out );

	return QuaternionAxisAngle( out, deltaAxis );
}

// QAngle , QAngle, QAngle
function VS::RotationDelta( srcAngles, destAngles, out ) : ( matrix3x4_t )
{
	local src = matrix3x4_t(),
		dest = matrix3x4_t();

	// xform = src(-1) * dest
	AngleIMatrix( srcAngles, null, src );
	AngleMatrix( destAngles, null, dest );
	ConcatRotations( dest, src, dest );

	// xformAngles
	return MatrixAngles( dest, out );
}

function VS::MatrixQuaternionFast( matrix, q ) : (sqrt)
{
	matrix = matrix[0];
	local trace;
	if ( matrix[M_22] < 0.0 )
	{
		if ( matrix[M_00] > matrix[M_11] )
		{
			trace = 1.0 + matrix[M_00] - matrix[M_11] - matrix[M_22];
			q.x = trace;
			q.y = matrix[M_01] + matrix[M_10];
			q.z = matrix[M_02] + matrix[M_20];
			q.w = matrix[M_21] - matrix[M_12];
		}
		else
		{
			trace = 1.0 - matrix[M_00] + matrix[M_11] - matrix[M_22];
			q.x = matrix[M_01] + matrix[M_10];
			q.y = trace;
			q.z = matrix[M_21] + matrix[M_12];
			q.w = matrix[M_02] - matrix[M_20];
		}
	}
	else
	{
		if ( -matrix[M_11] > matrix[M_00] )
		{
			trace = 1.0 - matrix[M_00] - matrix[M_11] + matrix[M_22];
			q.x = matrix[M_02] + matrix[M_20];
			q.y = matrix[M_21] + matrix[M_12];
			q.z = trace;
			q.w = matrix[M_10] - matrix[M_01]
		}
		else
		{
			trace = 1.0 + matrix[M_00] + matrix[M_11] + matrix[M_22];
			q.x = matrix[M_21] - matrix[M_12];
			q.y = matrix[M_02] - matrix[M_20];
			q.z = matrix[M_10] - matrix[M_01];
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
	matrix = matrix[0];
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

	matrix[M_00] = 1.0 - (yy + zz);
	matrix[M_10] = xy + wz;
	matrix[M_20] = xz - wy;

	matrix[M_01] = xy - wz;
	matrix[M_11] = 1.0 - (xx + zz);
	matrix[M_21] = yz + wx;

	matrix[M_02] = xz + wy;
	matrix[M_12] = yz - wx;
	matrix[M_22] = 1.0 - (xx + yy);

	if (pos)
	{
		matrix[M_03] = pos.x;
		matrix[M_13] = pos.y;
		matrix[M_23] = pos.z;
	}
	else
	{
		matrix[M_03] = matrix[M_13] = matrix[M_23] = 0.0;
	};
}

//-----------------------------------------------------------------------------
// Purpose: Converts a quaternion into engine angles
// Input  : *quaternion - q3 + q0.i + q1.j + q2.k
//          *outAngles - PITCH, YAW, ROLL
//-----------------------------------------------------------------------------
function VS::QuaternionAngles2( q, angles = _VEC ) : (asin, atan2)
{
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
function VS::QuaternionAxisAngle( q, axis ) : (acos)
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
function VS::AxisAngleQuaternion( axis, angle, q = _QUAT ) : (sin, cos)
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
function VS::AngleQuaternion( angles, outQuat = _QUAT ) : (sin, cos)
{
	local ay = angles.y * DEG2RADDIV2,
		ax = angles.x * DEG2RADDIV2,
		az = angles.z * DEG2RADDIV2,

		sy = sin(ay), cy = cos(ay),
		sp = sin(ax), cp = cos(ax),
		sr = sin(az), cr = cos(az),

		srcp = sr * cp,
		crsp = cr * sp,
		crcp = cr * cp,
		srsp = sr * sp;

	outQuat.x = srcp * cy - crsp * sy;
	outQuat.y = crsp * cy + srcp * sy;
	outQuat.z = crcp * sy - srsp * cy;
	outQuat.w = crcp * cy + srsp * sy;

	return outQuat;
}

local AngleQuaternion = VS.AngleQuaternion;

function VS::MatrixQuaternion( mat, q = _QUAT ) : (AngleQuaternion, MatrixAngles)
{
	return AngleQuaternion( MatrixAngles( mat ), q );
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


function VS::MatricesAreEqual( src1, src2, flTolerance = 0.0 )
{
	src2 = src2[0];

	foreach( i, v in src1[0] )
	{
		local f = v - src2[i];
		if ( 0.0 > f ) f = -f;
		if ( f > flTolerance )
			return false;
	}
	return true;
}

function VS::MatrixCopy( src, dst )
{
	// Cloning is, compared to individually copying,
	// 50% faster when dst has no manager
	// 25% slower when dst has a manager
	// 7% slower when code falls back to manual copy.
	// Putting the consts in the stack makes it 14% faster, but increases stack size by 11
	// Incrementing local index is 2% faster than const loading (14 less instructions)

	// Use fallback code because it is more likely that the copied matrices will be pure (no manager)

	local i = 0, b1 = M_30 in src[i], b2 = M_30 in dst[i];

	if ( (b1 != b2) || dst._man )
	{
		src = src[i];
		dst = dst[i];

		dst[i] = src[i]; ++i;
		dst[i] = src[i]; ++i;
		dst[i] = src[i]; ++i;
		dst[i] = src[i]; ++i;

		dst[i] = src[i]; ++i;
		dst[i] = src[i]; ++i;
		dst[i] = src[i]; ++i;
		dst[i] = src[i]; ++i;

		dst[i] = src[i]; ++i;
		dst[i] = src[i]; ++i;
		dst[i] = src[i]; ++i;
		dst[i] = src[i]; ++i;

		if ( b1 && b2 )
		{
			dst[i] = src[i]; ++i;
			dst[i] = src[i]; ++i;
			dst[i] = src[i]; ++i;
			dst[i] = src[i];
		};

		return;
	};

	dst[i] = clone src[i];
}

// NOTE: This is just the transpose not a general inverse
function VS::MatrixInvert( in1, out )
{
	in1 = in1[0];
	out = out[0];

	if ( in1 == out )
	{
		local t = out[M_01];
		out[M_01] = out[M_10];
		out[M_10] = t;

		t = out[M_02];
		out[M_02] = out[M_20];
		out[M_20] = t;

		t = out[M_12];
		out[M_12] = out[M_21];
		out[M_21] = t;
	}
	else
	{
		// transpose the matrix
		out[M_00] = in1[M_00];
		out[M_01] = in1[M_10];
		out[M_02] = in1[M_20];

		out[M_10] = in1[M_01];
		out[M_11] = in1[M_11];
		out[M_12] = in1[M_21];

		out[M_20] = in1[M_02];
		out[M_21] = in1[M_12];
		out[M_22] = in1[M_22];
	};

	// now fix up the translation to be in the other space
	local tmp0 = in1[M_03];
	local tmp1 = in1[M_13];
	local tmp2 = in1[M_23];

	// -DotProduct( tmp, out[0] );
	out[M_03] = -(tmp0 * out[M_00] + tmp1 * out[M_01] + tmp2 * out[M_02]);
	out[M_13] = -(tmp0 * out[M_10] + tmp1 * out[M_11] + tmp2 * out[M_12]);
	out[M_23] = -(tmp0 * out[M_20] + tmp1 * out[M_21] + tmp2 * out[M_22]);
}

//-----------------------------------------------------------------------------
// Inverts any matrix at all
//-----------------------------------------------------------------------------
function VS::MatrixInverseGeneral( src, dst ) : ( array )
{
	// [4][8]
	local mat = [ array(8, 0.0), array(8, 0.0), array(8, 0.0), array(8, 0.0) ];
	local rowMap = [0, 1, 2, 3];

	// How it's done.
	// AX = I
	// A = this
	// X = the matrix we're looking for
	// I = identity

	src = src[0];

	// Setup AI
	for ( local i = 0; i < 4; ++i )
	{
		local ii = 4*i;
		// local pIn = src[i];
		local pOut = mat[i];

		pOut[0] = src[ii    ];
		pOut[1] = src[ii + 1];
		pOut[2] = src[ii + 2];
		pOut[3] = src[ii + 3];
		pOut[4] =
		pOut[5] =
		pOut[6] =
		pOut[7] = 0.0;
		pOut[i+4] = 1.0;

		// rowMap[i] = i;
	}

	// Use row operations to get to reduced row-echelon form using these rules:
	// 1. Multiply or divide a row by a nonzero number.
	// 2. Add a multiple of one row to another.
	// 3. Interchange two rows.

	for ( local mul,iRow = 0; iRow < 4; ++iRow )
	{
		// Find the row with the largest element in this column.
		local fLargest = 1.e-6;
		local iLargest = 0xFFFFFFFF;
		for ( local iTest = iRow; iTest < 4; ++iTest )
		{
			local fTest = mat[rowMap[iTest]][iRow];
			if ( 0.0 > fTest )
				fTest = -fTest;

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
		for ( local i = 0; i < 4; ++i )
		{
			if ( i != iRow )
			{
				local pScaleRow = mat[rowMap[i]];

				// Multiply this row by -(iRow*the element).
				mul = pScaleRow[iRow];
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
	}

	dst = dst[0];

	// The inverse is on the right side of AX now (the identity is on the left).
	for ( local i = 0; i < 4; ++i )
	{
		local pIn = mat[rowMap[i]];
		local ii = 4*i;
		// local pOut = dst[i];
			dst[ii    ] = pIn[4];
			dst[ii + 1] = pIn[5];
			dst[ii + 2] = pIn[6];
			dst[ii + 3] = pIn[7];
	}

	return true;
}

//-----------------------------------------------------------------------------
// Does a fast inverse, assuming the matrix only contains translation and rotation.
//-----------------------------------------------------------------------------
function VS::MatrixInverseTR( src, dst )
{
	local m = dst[0];
	m[M_30] = m[M_31] = m[M_32] = 0.0;
	m[M_33] = 1.0;
	return MatrixInvert( src, dst );
}

function VS::MatrixRowDotProduct( in1, row, in2 )
{
	row = row * 4;
	in1 = in1[0];
	return in1[row] * in2.x + in1[row+1] * in2.y + in1[row+2] * in2.z;
}

function VS::MatrixColumnDotProduct( in1, col, in2 )
{
	in1 = in1[0];
	return in1[col] * in2.x + in1[4+col] * in2.y + in1[8+col] * in2.z;
}

function VS::MatrixGetColumn( in1, column, out = _VEC )
{
	in1 = in1[0];

	out.x = in1[    column];
	out.y = in1[4 + column];
	out.z = in1[8 + column];

	return out;
}

function VS::MatrixSetColumn( in1, column, out )
{
	out = out[0];

	out[    column] = in1.x;
	out[4 + column] = in1.y;
	out[8 + column] = in1.z;
}

function VS::MatrixScaleBy( flScale, out )
{
	out = out[0];

	out[M_00] *= flScale;
	out[M_10] *= flScale;
	out[M_20] *= flScale;

	out[M_01] *= flScale;
	out[M_11] *= flScale;
	out[M_21] *= flScale;

	out[M_02] *= flScale;
	out[M_12] *= flScale;
	out[M_22] *= flScale;
}

function VS::MatrixScaleByZero( out )
{
	out = out[0];

	out[M_00] =
	out[M_10] =
	out[M_20] =

	out[M_01] =
	out[M_11] =
	out[M_21] =

	out[M_02] =
	out[M_12] =
	out[M_22] = 0.0;
}

function VS::SetIdentityMatrix( matrix )
{
	// SetScaleMatrix( 1.0, 1.0, 1.0, matrix );

	matrix = matrix[0];

	matrix[M_00] = matrix[M_11] = matrix[M_22] = 1.0;

	matrix[M_01] = matrix[M_02] = matrix[M_03] =
	matrix[M_10] = matrix[M_12] = matrix[M_13] =
	matrix[M_20] = matrix[M_21] = matrix[M_23] = 0.0;
}

//-----------------------------------------------------------------------------
// Builds a scale matrix
//-----------------------------------------------------------------------------
function VS::SetScaleMatrix( x, y, z, dst )
{
	dst = dst[0];

	dst[M_00] = x;
	dst[M_11] = y;
	dst[M_22] = z;

	dst[M_01] = dst[M_02] = dst[M_03] =
	dst[M_10] = dst[M_12] = dst[M_13] =
	dst[M_20] = dst[M_21] = dst[M_23] = 0.0;
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
	matrix = matrix[0];
	matrix[M_03] = worldCentroid.x;
	matrix[M_13] = worldCentroid.y;
	matrix[M_23] = worldCentroid.z;
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
	matrix = matrix[0];
	matrix[M_03] = centroid.x;
	matrix[M_13] = centroid.y;
	matrix[M_23] = centroid.z;
}

//-----------------------------------------------------------------------------
// Compute a matrix which is the absolute value of another
//-----------------------------------------------------------------------------
function VS::ComputeAbsMatrix( in1, out ) : (fabs)
{
	in1 = in1[0];
	out = out[0];

	out[M_00] = fabs( in1[M_00] );
	out[M_01] = fabs( in1[M_01] );
	out[M_02] = fabs( in1[M_02] );

	out[M_10] = fabs( in1[M_10] );
	out[M_11] = fabs( in1[M_11] );
	out[M_12] = fabs( in1[M_12] );

	out[M_20] = fabs( in1[M_20] );
	out[M_21] = fabs( in1[M_21] );
	out[M_22] = fabs( in1[M_22] );
}

function VS::ConcatRotations( in1, in2, out )
{
	local
		M_00=M_00, M_01=M_01, M_02=M_02,
		M_10=M_10, M_11=M_11, M_12=M_12,
		M_20=M_20, M_21=M_21, M_22=M_22;

	in1 = in1[0];
	in2 = in2[0];
	out = out[0];

	local
		i2m00 = in2[M_00],
		i2m01 = in2[M_01],
		i2m02 = in2[M_02],

		i2m10 = in2[M_10],
		i2m11 = in2[M_11],
		i2m12 = in2[M_12],

		i2m20 = in2[M_20],
		i2m21 = in2[M_21],
		i2m22 = in2[M_22];

	local
		m0 = in1[M_00] * i2m00 + in1[M_01] * i2m10 + in1[M_02] * i2m20,
		m1 = in1[M_00] * i2m01 + in1[M_01] * i2m11 + in1[M_02] * i2m21,
		m2 = in1[M_00] * i2m02 + in1[M_01] * i2m12 + in1[M_02] * i2m22;

	out[M_00] = m0;
	out[M_01] = m1;
	out[M_02] = m2;

		m0 = in1[M_10] * i2m00 + in1[M_11] * i2m10 + in1[M_12] * i2m20;
		m1 = in1[M_10] * i2m01 + in1[M_11] * i2m11 + in1[M_12] * i2m21;
		m2 = in1[M_10] * i2m02 + in1[M_11] * i2m12 + in1[M_12] * i2m22;

	out[M_10] = m0;
	out[M_11] = m1;
	out[M_12] = m2;

		m0 = in1[M_20] * i2m00 + in1[M_21] * i2m10 + in1[M_22] * i2m20;
		m1 = in1[M_20] * i2m01 + in1[M_21] * i2m11 + in1[M_22] * i2m21;
		m2 = in1[M_20] * i2m02 + in1[M_21] * i2m12 + in1[M_22] * i2m22;

	out[M_20] = m0;
	out[M_21] = m1;
	out[M_22] = m2;
}

// matrix3x4_t multiply
function VS::ConcatTransforms( in1, in2, out )
{
	local
		M_00=M_00, M_01=M_01, M_02=M_02, M_03=M_03,
		M_10=M_10, M_11=M_11, M_12=M_12, M_13=M_13,
		M_20=M_20, M_21=M_21, M_22=M_22, M_23=M_23;

	in1 = in1[0];
	in2 = in2[0];
	out = out[0];

	local
		i2m00 = in2[M_00],
		i2m01 = in2[M_01],
		i2m02 = in2[M_02],
		i2m03 = in2[M_03],

		i2m10 = in2[M_10],
		i2m11 = in2[M_11],
		i2m12 = in2[M_12],
		i2m13 = in2[M_13],

		i2m20 = in2[M_20],
		i2m21 = in2[M_21],
		i2m22 = in2[M_22],
		i2m23 = in2[M_23];

	local
		m0 = in1[M_00] * i2m00 + in1[M_01] * i2m10 + in1[M_02] * i2m20,
		m1 = in1[M_00] * i2m01 + in1[M_01] * i2m11 + in1[M_02] * i2m21,
		m2 = in1[M_00] * i2m02 + in1[M_01] * i2m12 + in1[M_02] * i2m22,
		m3 = in1[M_00] * i2m03 + in1[M_01] * i2m13 + in1[M_02] * i2m23 + in1[M_03];

	out[M_00] = m0;
	out[M_01] = m1;
	out[M_02] = m2;
	out[M_03] = m3;

		m0 = in1[M_10] * i2m00 + in1[M_11] * i2m10 + in1[M_12] * i2m20;
		m1 = in1[M_10] * i2m01 + in1[M_11] * i2m11 + in1[M_12] * i2m21;
		m2 = in1[M_10] * i2m02 + in1[M_11] * i2m12 + in1[M_12] * i2m22;
		m3 = in1[M_10] * i2m03 + in1[M_11] * i2m13 + in1[M_12] * i2m23 + in1[M_13];

	out[M_10] = m0;
	out[M_11] = m1;
	out[M_12] = m2;
	out[M_13] = m3;

		m0 = in1[M_20] * i2m00 + in1[M_21] * i2m10 + in1[M_22] * i2m20;
		m1 = in1[M_20] * i2m01 + in1[M_21] * i2m11 + in1[M_22] * i2m21;
		m2 = in1[M_20] * i2m02 + in1[M_21] * i2m12 + in1[M_22] * i2m22;
		m3 = in1[M_20] * i2m03 + in1[M_21] * i2m13 + in1[M_22] * i2m23 + in1[M_23];

	out[M_20] = m0;
	out[M_21] = m1;
	out[M_22] = m2;
	out[M_23] = m3;
}

// VMatrix multiply
function VS::MatrixMultiply( in1, in2, out )
{
	local
		M_00=M_00, M_01=M_01, M_02=M_02, M_03=M_03,
		M_10=M_10, M_11=M_11, M_12=M_12, M_13=M_13,
		M_20=M_20, M_21=M_21, M_22=M_22, M_23=M_23,
		M_30=M_30, M_31=M_31, M_32=M_32, M_33=M_33;

	in1 = in1[0];
	in2 = in2[0];
	out = out[0];

	local
		i2m00 = in2[M_00],
		i2m01 = in2[M_01],
		i2m02 = in2[M_02],
		i2m03 = in2[M_03],

		i2m10 = in2[M_10],
		i2m11 = in2[M_11],
		i2m12 = in2[M_12],
		i2m13 = in2[M_13],

		i2m20 = in2[M_20],
		i2m21 = in2[M_21],
		i2m22 = in2[M_22],
		i2m23 = in2[M_23],

		i2m30 = in2[M_30],
		i2m31 = in2[M_31],
		i2m32 = in2[M_32],
		i2m33 = in2[M_33];

	local
		m0 = in1[M_00] * i2m00 + in1[M_01] * i2m10 + in1[M_02] * i2m20 + in1[M_03] * i2m30,
		m1 = in1[M_00] * i2m01 + in1[M_01] * i2m11 + in1[M_02] * i2m21 + in1[M_03] * i2m31,
		m2 = in1[M_00] * i2m02 + in1[M_01] * i2m12 + in1[M_02] * i2m22 + in1[M_03] * i2m32,
		m3 = in1[M_00] * i2m03 + in1[M_01] * i2m13 + in1[M_02] * i2m23 + in1[M_03] * i2m33;

	out[M_00] = m0;
	out[M_01] = m1;
	out[M_02] = m2;
	out[M_03] = m3;

		m0 = in1[M_10] * i2m00 + in1[M_11] * i2m10 + in1[M_12] * i2m20 + in1[M_13] * i2m30;
		m1 = in1[M_10] * i2m01 + in1[M_11] * i2m11 + in1[M_12] * i2m21 + in1[M_13] * i2m31;
		m2 = in1[M_10] * i2m02 + in1[M_11] * i2m12 + in1[M_12] * i2m22 + in1[M_13] * i2m32;
		m3 = in1[M_10] * i2m03 + in1[M_11] * i2m13 + in1[M_12] * i2m23 + in1[M_13] * i2m33;

	out[M_10] = m0;
	out[M_11] = m1;
	out[M_12] = m2;
	out[M_13] = m3;

		m0 = in1[M_20] * i2m00 + in1[M_21] * i2m10 + in1[M_22] * i2m20 + in1[M_23] * i2m30;
		m1 = in1[M_20] * i2m01 + in1[M_21] * i2m11 + in1[M_22] * i2m21 + in1[M_23] * i2m31;
		m2 = in1[M_20] * i2m02 + in1[M_21] * i2m12 + in1[M_22] * i2m22 + in1[M_23] * i2m32;
		m3 = in1[M_20] * i2m03 + in1[M_21] * i2m13 + in1[M_22] * i2m23 + in1[M_23] * i2m33;

	out[M_20] = m0;
	out[M_21] = m1;
	out[M_22] = m2;
	out[M_23] = m3;

		m0 = in1[M_30] * i2m00 + in1[M_31] * i2m10 + in1[M_32] * i2m20 + in1[M_33] * i2m30;
		m1 = in1[M_30] * i2m01 + in1[M_31] * i2m11 + in1[M_32] * i2m21 + in1[M_33] * i2m31;
		m2 = in1[M_30] * i2m02 + in1[M_31] * i2m12 + in1[M_32] * i2m22 + in1[M_33] * i2m32;
		m3 = in1[M_30] * i2m03 + in1[M_31] * i2m13 + in1[M_32] * i2m23 + in1[M_33] * i2m33;

	out[M_30] = m0;
	out[M_31] = m1;
	out[M_32] = m2;
	out[M_33] = m3;
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
	angleDegrees = angleDegrees * DEG2RAD;
	local fCos = cos( angleDegrees );
{
	local xx = vAxisOfRot.x * vAxisOfRot.x;
	local yy = vAxisOfRot.y * vAxisOfRot.y;
	local zz = vAxisOfRot.z * vAxisOfRot.z;

	dst = dst[0];
	dst[M_00] = xx + fCos - xx * fCos;
	dst[M_11] = yy + fCos - yy * fCos;
	dst[M_22] = zz + fCos - zz * fCos;
}
{
	fCos = 1.0 - fCos;

	local xyc = vAxisOfRot.x * vAxisOfRot.y * fCos;
	local yzc = vAxisOfRot.y * vAxisOfRot.z * fCos;
	local xzc = vAxisOfRot.z * vAxisOfRot.x * fCos;

	local fSin = sin( angleDegrees );
	local xs = vAxisOfRot.x * fSin;
	local ys = vAxisOfRot.y * fSin;
	local zs = vAxisOfRot.z * fSin;

	dst[M_10] = xyc + zs;
	dst[M_20] = xzc - ys;

	dst[M_01] = xyc - zs;
	dst[M_21] = yzc + xs;

	dst[M_02] = xzc + ys;
	dst[M_12] = yzc - xs;
}
	dst[M_03] = dst[M_13] = dst[M_23] = 0.0;
}

local MatrixBuildRotationAboutAxis = VS.MatrixBuildRotationAboutAxis;

//-----------------------------------------------------------------------------
// Builds a rotation matrix that rotates one direction vector into another
//
// Input  : matrix
//          Vector
//          Vector
//-----------------------------------------------------------------------------
function VS::MatrixBuildRotation( dst, initialDirection, finalDirection )
	: ( Vector, fabs, acos, MatrixBuildRotationAboutAxis )
{
	local angle = initialDirection.Dot( finalDirection );
	// Assert( IsFinite(angle) );

	// No rotation required
	if ( angle > 0.99999 )
		return SetIdentityMatrix(dst); // parallel case

	if ( -0.99999 > angle )
	{
		// antiparallel case, pick any axis in the plane
		// perpendicular to the final direction. Choose the direction (x,y,z)
		// which has the minimum component of the final direction, use that
		// as an initial guess, then subtract out the component which is
		// parallel to the final direction
		local idx = "x";
		if ( fabs(finalDirection.y) < fabs(finalDirection[idx]) )
			idx = "y";
		if ( fabs(finalDirection.z) < fabs(finalDirection[idx]) )
			idx = "z";

		local axis = Vector();
		axis[idx] = 1.0;

		// VectorMA( axis, -axis.Dot( finalDirection ), finalDirection, axis );
		local t = axis.Dot( finalDirection );
		axis.x -= finalDirection.x * t;
		axis.y -= finalDirection.y * t;
		axis.z -= finalDirection.z * t;
		axis.Norm();
		return MatrixBuildRotationAboutAxis( axis, 180.0, dst );
	};

	local axis = initialDirection.Cross( finalDirection );
	axis.Norm();
	return MatrixBuildRotationAboutAxis( axis, acos(angle) * RAD2DEG, dst );
/*
	local test = Vector();
	VectorRotate( initialDirection, dst, test );
	local d = (test - finalDirection).LengthSqr();
	Assert( d < 1.e-3, "MatrixBuildRotation" );
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
	local x = src2.x;
	local y = src2.y;
	local z = src2.z;

	dst.x = src1[0][0] * x + src1[0][1] * y + src1[0][2] * z;
	dst.y = src1[1][0] * x + src1[1][1] * y + src1[1][2] * z;
	dst.z = src1[2][0] * x + src1[2][1] * y + src1[2][2] * z;
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
	local x = src2.x;
	local y = src2.y;
	local z = src2.z;

	dst.x = src1[0][0] * x + src1[0][1] * y + src1[0][2] * z + src1[0][3];
	dst.y = src1[1][0] * x + src1[1][1] * y + src1[1][2] * z + src1[1][3];
	dst.z = src1[2][0] * x + src1[2][1] * y + src1[2][2] * z + src1[2][3];
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
	src1 = src1[0];
	local x = src2.x;
	local y = src2.y;
	local z = src2.z;

	local invw = 1.0 / ( src1[M_30] * x + src1[M_31] * y + src1[M_32] * z );
	dst.x = invw * ( src1[M_00] * x + src1[M_01] * y + src1[M_02] * z );
	dst.y = invw * ( src1[M_10] * x + src1[M_11] * y + src1[M_12] * z );
	dst.z = invw * ( src1[M_20] * x + src1[M_21] * y + src1[M_22] * z );
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
	src1 = src1[0];
	local x = src2.x;
	local y = src2.y;
	local z = src2.z;

	local invw = 1.0 / ( src1[M_30] * x + src1[M_31] * y + src1[M_32] * z + src1[M_33] );
	dst.x = invw * ( src1[M_00] * x + src1[M_01] * y + src1[M_02] * z + src1[M_03] );
	dst.y = invw * ( src1[M_10] * x + src1[M_11] * y + src1[M_12] * z + src1[M_13] );
	dst.z = invw * ( src1[M_20] * x + src1[M_21] * y + src1[M_22] * z + src1[M_23] );
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

	transform = transform[0];

	local worldExtents = Vector(
		fabs( localExtents.x * transform[M_00] ) +
		fabs( localExtents.y * transform[M_01] ) +
		fabs( localExtents.z * transform[M_02] ),

		fabs( localExtents.x * transform[M_10] ) +
		fabs( localExtents.y * transform[M_11] ) +
		fabs( localExtents.z * transform[M_12] ),

		fabs( localExtents.x * transform[M_20] ) +
		fabs( localExtents.y * transform[M_21] ) +
		fabs( localExtents.z * transform[M_22] ) );

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

	transform = transform[0];

	local localExtents = Vector(
		fabs( worldExtents.x * transform[M_00] ) +
		fabs( worldExtents.y * transform[M_10] ) +
		fabs( worldExtents.z * transform[M_20] ),

		fabs( worldExtents.x * transform[M_01] ) +
		fabs( worldExtents.y * transform[M_11] ) +
		fabs( worldExtents.z * transform[M_21] ),

		fabs( worldExtents.x * transform[M_02] ) +
		fabs( worldExtents.y * transform[M_12] ) +
		fabs( worldExtents.z * transform[M_22] ) );

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

	transform = transform[0];

	local newExtents = Vector(
		fabs( localExtents.x * transform[M_00] ) +
		fabs( localExtents.y * transform[M_01] ) +
		fabs( localExtents.z * transform[M_02] ),

		fabs( localExtents.x * transform[M_10] ) +
		fabs( localExtents.y * transform[M_11] ) +
		fabs( localExtents.z * transform[M_12] ),

		fabs( localExtents.x * transform[M_20] ) +
		fabs( localExtents.y * transform[M_21] ) +
		fabs( localExtents.z * transform[M_22] ) );

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

	transform = transform[0];

	local newExtents = Vector(
		fabs( oldExtents.x * transform[M_00] ) +
		fabs( oldExtents.y * transform[M_10] ) +
		fabs( oldExtents.z * transform[M_20] ),

		fabs( oldExtents.x * transform[M_01] ) +
		fabs( oldExtents.y * transform[M_11] ) +
		fabs( oldExtents.z * transform[M_21] ),

		fabs( oldExtents.x * transform[M_02] ) +
		fabs( oldExtents.y * transform[M_12] ) +
		fabs( oldExtents.z * transform[M_22] ) );

	VectorSubtract( newCenter, newExtents, vecMinsOut );
	VectorAdd( newCenter, newExtents, vecMaxsOut );
}
/*
function VS::MatrixTransformPlane( src, inNormal, inDist, outNormal ) : ( VectorRotate )
{
	// What we want to do is the following:
	// 1) transform the normal into the new space.
	// 2) Determine a point on the old plane given by plane dist * plane normal
	// 3) Transform that point into the new space
	// 4) Plane dist = DotProduct( new normal, new point )

	// An optimized version, which works if the plane is orthogonal.
	// 1) Transform the normal into the new space
	// 2) Realize that transforming the old plane point into the new space
	// is given by [ d * n'x + Tx, d * n'y + Ty, d * n'z + Tz ]
	// where d = old plane dist, n' = transformed normal, Tn = translational component of transform
	// 3) Compute the new plane dist using the dot product of the normal result of #2

	// For a correct result, this should be an inverse-transpose matrix
	// but that only matters if there are nonuniform scale or skew factors in this matrix.
	VectorRotate( inNormal, src, outNormal );
	src = src[0];
	return inDist * outNormal.LengthSqr() + outNormal.x * src[M_03] + outNormal.y * src[M_13] + outNormal.z * src[M_23];
}

function VS::MatrixITransformPlane( src, inNormal, inDist, outNormal ) : ( VectorIRotate )
{
	// The trick here is that Tn = translational component of transform,
	// but for an inverse transform, Tn = - R^-1 * T
	local vecTranslation = Vector( src[0][M_03], src[0][M_13], src[0][M_23] );
	local vecInvTranslation = VectorIRotate( vecTranslation, src );

	VectorIRotate( inNormal, src, outNormal );

	return inDist * outNormal.LengthSqr() - outNormal.Dot( vecInvTranslation );
}
*/
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
	local width = -0.5 / tan( fovX * DEG2RADDIV2 );
	local range = zFar / ( zNear - zFar );

	dst = dst[0];

	            dst[M_01] =             dst[M_03] =
	dst[M_10] =                         dst[M_13] =
	dst[M_20] = dst[M_21] =
	dst[M_30] = dst[M_31] =             dst[M_33] = 0.0;

	dst[M_00] = width;
	dst[M_11] = width * flAspect;
	dst[M_02] = dst[M_12] = 0.5;
	dst[M_22] = -range;
	dst[M_32] = 1.0;
	dst[M_23] = zNear * range;

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

function VS::MatrixBuildPerspectiveX( dst, flFovX, flAspect, flZNear, flZFar ) : ( tan )
{
	local width = 1.0 / tan( flFovX * DEG2RAD );
	local range = flZFar / ( flZNear - flZFar );

	dst = dst[0];

				dst[M_01] = dst[M_02] = dst[M_03] =
	dst[M_10] =             dst[M_12] = dst[M_13] =
	dst[M_20] = dst[M_21] =
	dst[M_30] = dst[M_31] =             dst[M_33] = 0.0;

	dst[M_00] = width;
	dst[M_11] = width * flAspect;
	dst[M_22] = range;
	dst[M_32] = -1.0;
	dst[M_23] = flZNear * range;
}
/*
function VS::ComputeProjectionMatrix( dst, flZNear, flZFar, flFovX, flAspect )
{
	return MatrixBuildPerspectiveX( dst, flFovX * 0.5, flAspect, flZNear, flZFar );
}
*/

function VS::ComputeCameraVariables( vecOrigin, pVecForward, pVecRight, pVecUp, pMatCamInverse )
{
	pMatCamInverse = pMatCamInverse[0];

	pMatCamInverse[M_00] = pVecRight.x;
	pMatCamInverse[M_01] = pVecRight.y;
	pMatCamInverse[M_02] = pVecRight.z;
	pMatCamInverse[M_03] = -pVecRight.Dot( vecOrigin );

	pMatCamInverse[M_10] = pVecUp.x;
	pMatCamInverse[M_11] = pVecUp.y;
	pMatCamInverse[M_12] = pVecUp.z;
	pMatCamInverse[M_13] = -pVecUp.Dot( vecOrigin );

	pMatCamInverse[M_20] = -pVecForward.x;
	pMatCamInverse[M_21] = -pVecForward.y;
	pMatCamInverse[M_22] = -pVecForward.z;
	pMatCamInverse[M_23] = pVecForward.Dot( vecOrigin );

	pMatCamInverse[M_30] = pMatCamInverse[M_31] = pMatCamInverse[M_32] = 0.0;
	pMatCamInverse[M_33] = 1.0;
}

//
// range [-1,1]
//
function VS::WorldToScreenMatrix( pOut, origin, forward, right, up, fov, flAspect, zNear, zFar )
	: (VMatrix)
{
	local viewToProj = VMatrix();
	local worldToView = VMatrix();

	MatrixBuildPerspectiveX( viewToProj, fov * 0.5, flAspect, zNear, zFar );
	ComputeCameraVariables( origin, forward, right, up, worldToView );

	local worldToProj = viewToProj; // VMatrix();
	MatrixMultiply( viewToProj, worldToView, worldToProj );

	pOut = pOut[0];
	worldToProj = worldToProj[0];

	pOut[M_00] = worldToProj[M_00];
	pOut[M_01] = worldToProj[M_01];
	pOut[M_02] = worldToProj[M_02];
	pOut[M_03] = worldToProj[M_03];

	pOut[M_10] = worldToProj[M_10];
	pOut[M_11] = worldToProj[M_11];
	pOut[M_12] = worldToProj[M_12];
	pOut[M_13] = worldToProj[M_13];

	pOut[M_20] = worldToProj[M_20];
	pOut[M_21] = worldToProj[M_21];
	pOut[M_22] = worldToProj[M_22];
	pOut[M_23] = worldToProj[M_23];

	pOut[M_30] = worldToProj[M_30];
	pOut[M_31] = worldToProj[M_31];
	pOut[M_32] = worldToProj[M_32];
	pOut[M_33] = worldToProj[M_33];
}
/*
//
// range [0,1]
//
function VS::WorldToScreenMatrix2( pOut, origin, forward, right, up, fov, flAspect, zNear, zFar )
	: (VMatrix)
{
	local view = VMatrix(), proj = VMatrix();
	MatrixBuildPerspective( proj, fov, flAspect, zNear, zFar );
	{
		local viewm = view[0];
		viewm[M_00] = -right.x;
		viewm[M_01] = -right.y;
		viewm[M_02] = -right.z;
		viewm[M_03] = right.Dot( origin );

		viewm[M_10] = up.x;
		viewm[M_11] = up.y;
		viewm[M_12] = up.z;
		viewm[M_13] = -up.Dot( origin );

		viewm[M_20] = forward.x;
		viewm[M_21] = forward.y;
		viewm[M_22] = forward.z;
		viewm[M_23] = -forward.Dot( origin );

		viewm[M_33] = 1.0;
	}
	MatrixMultiply( proj, view, proj );

	pOut = pOut[0];
	proj = proj[0];

	pOut[M_00] = proj[M_00];
	pOut[M_01] = proj[M_01];
	pOut[M_02] = proj[M_02];
	pOut[M_03] = proj[M_03];

	pOut[M_10] = proj[M_10];
	pOut[M_11] = proj[M_11];
	pOut[M_12] = proj[M_12];
	pOut[M_13] = proj[M_13];

	pOut[M_20] = proj[M_20];
	pOut[M_21] = proj[M_21];
	pOut[M_22] = proj[M_22];
	pOut[M_23] = proj[M_23];

	pOut[M_30] = proj[M_30];
	pOut[M_31] = proj[M_31];
	pOut[M_32] = proj[M_32];
	pOut[M_33] = proj[M_33];
}
*/

local Vector3DMultiplyPositionProjective = VS.Vector3DMultiplyPositionProjective;

function VS::ScreenToWorld( x, y, screenToWorld, pOut = _VEC ) : (Vector, Vector3DMultiplyPositionProjective)
{
	local vecScreen = Vector( 2.0 * x - 1.0, 1.0 - 2.0 * y, 1.0 );
	Vector3DMultiplyPositionProjective( screenToWorld, vecScreen, pOut );
	return pOut;
}

function VS::WorldToScreen( vecPos, worldToScreen, pOut = _VEC ) : (Vector, Vector3DMultiplyPositionProjective)
{
	Vector3DMultiplyPositionProjective( worldToScreen, vecPos, pOut );
	local s = 0.5;
	pOut.x = s + pOut.x * s;
	pOut.y = s - pOut.y * s;
	return pOut;
}

//-----------------------------------------------------------------------------
// Computes Y fov from an X fov and a screen aspect ratio
//-----------------------------------------------------------------------------
function VS::CalcFovY( flFovX, flAspect ) : ( tan, atan )
{
	if ( flFovX < 1.0 || flFovX > 179.0)
		flFovX = 90.0;

	return atan( tan( DEG2RADDIV2 * flFovX ) / flAspect ) * RAD2DEG2;
}

function VS::CalcFovX( flFovY, flAspect ) : ( tan, atan )
{
	return atan( tan( DEG2RADDIV2 * flFovY ) * flAspect ) * RAD2DEG2;
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

	// [0,1]
	//local v000 = Vector();
	//local v001 = Vector( 0.0, 0.0, 1.0 );
	//local v011 = Vector( 0.0, 1.0, 1.0 );
	//local v010 = Vector( 0.0, 1.0, 0.0 );
	//local v100 = Vector( 1.0, 0.0, 0.0 );
	//local v101 = Vector( 1.0, 0.0, 1.0 );
	//local v111 = Vector( 1.0, 1.0, 1.0 );
	//local v110 = Vector( 1.0, 1.0, 0.0 );

	// [-1,1]
	local v000 = Vector( -1.0, -1.0, 0.0 );
	local v001 = Vector( -1.0, -1.0, 1.0 );
	local v011 = Vector( -1.0, 1.0, 1.0 );
	local v010 = Vector( -1.0, 1.0, 0.0 );
	local v100 = Vector( 1.0, -1.0, 0.0 );
	local v101 = Vector( 1.0, -1.0, 1.0 );
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
		return draw( frustum[22], frustum[23], matViewToWorld, r, g, b, z, t );
	}

	local DrawFrustum = VS.DrawFrustum;
	local WorldToScreenMatrix = VS.WorldToScreenMatrix;
	local MatrixInverseGeneral = VS.MatrixInverseGeneral;

	function VS::DrawViewFrustum( vecOrigin, vecForward, vecRight, vecUp,
		flFovX, flAspect, zNear, zFar, r, g, b, z, time ) :
			( VMatrix, WorldToScreenMatrix, MatrixInverseGeneral, DrawFrustum )
	{
		local mat = VMatrix();
		WorldToScreenMatrix( mat, vecOrigin, vecForward, vecRight, vecUp, flFovX, flAspect, zNear, zFar );
		MatrixInverseGeneral( mat, mat );
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
		return Line( v7, v6, r, g, b, z, time );
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
		-0.01, -0.01, 1.0,		0.51, 0.0, 0.86,		0.44, 0.25, 0.86,		0.25, 0.44, 0.86,
		-0.01, 0.51, 0.86,		-0.26, 0.44, 0.86,		-0.45, 0.25, 0.86,		-0.51, 0.0, 0.86,
		-0.45, -0.26, 0.86,		-0.26, -0.45, 0.86,		-0.01, -0.51, 0.86,		0.25, -0.45, 0.86,
		0.44, -0.26, 0.86,		0.86, 0.0, 0.51,		0.75, 0.43, 0.51,		0.43, 0.75, 0.51,
		-0.01, 0.86, 0.51,		-0.44, 0.75, 0.51,		-0.76, 0.43, 0.51,		-0.87, 0.0, 0.51,
		-0.76, -0.44, 0.51,		-0.44, -0.76, 0.51,		-0.01, -0.87, 0.51,		0.43, -0.76, 0.51,
		0.75, -0.44, 0.51,		1.0, 0.0, 0.01,			0.86, 0.5, 0.01,		0.49, 0.86, 0.01,
		-0.01, 1.0, 0.01,		-0.51, 0.86, 0.01,		-0.87, 0.5, 0.01,		-1.0, 0.0, 0.01,
		-0.87, -0.5, 0.01,		-0.51, -0.87, 0.01,		-0.01, -1.0, 0.01,		0.49, -0.87, 0.01,
		0.86, -0.51, 0.01,		1.0, 0.0, -0.02,		0.86, 0.5, -0.02,		0.49, 0.86, -0.02,
		-0.01, 1.0, -0.02,		-0.51, 0.86, -0.02,		-0.87, 0.5, -0.02,		-1.0, 0.0, -0.02,
		-0.87, -0.5, -0.02,		-0.51, -0.87, -0.02,	-0.01, -1.0, -0.02,		0.49, -0.87, -0.02,
		0.86, -0.51, -0.02,		0.86, 0.0, -0.51,		0.75, 0.43, -0.51,		0.43, 0.75, -0.51,
		-0.01, 0.86, -0.51,		-0.44, 0.75, -0.51,		-0.76, 0.43, -0.51,		-0.87, 0.0, -0.51,
		-0.76, -0.44, -0.51,	-0.44, -0.76, -0.51,	-0.01, -0.87, -0.51,	0.43, -0.76, -0.51,
		0.75, -0.44, -0.51,		0.51, 0.0, -0.87,		0.44, 0.25, -0.87,		0.25, 0.44, -0.87,
		-0.01, 0.51, -0.87,		-0.26, 0.44, -0.87,		-0.45, 0.25, -0.87,		-0.51, 0.0, -0.87,
		-0.45, -0.26, -0.87,	-0.26, -0.45, -0.87,	-0.01, -0.51, -0.87,	0.25, -0.45, -0.87,
		0.44, -0.26, -0.87,		0.0, 0.0, -1.0
	];

	local g_capsuleLineIndices = [
		0,	4,	16,	28,	40,	52,	64,	73,	70,	58,	46,	34,	22,	10,		0,	-1,
		0,	1,	13,	25,	37,	49,	61,	73,	67,	55,	43,	31,	19,	7,		0,	-1,
		61,	62,	63,	64,	65,	66,	67,	68,	69,	70,	71,	72,				61,	-1,
		49,	50,	51,	52,	53,	54,	55,	56,	57,	58,	59,	60,				49,	-1,
		37,	38,	39,	40,	41,	42,	43,	44,	45,	46,	47,	48,				37,	-1,
		25,	26,	27,	28,	29,	30,	31,	32,	33,	34,	35,	36,				25,	-1,
		13,	14,	15,	16,	17,	18,	19,	20,	21,	22,	23,	24,				13,	-1,
		1,	2,	3,	4,	5,	6,	7,	8,	9,	10,	11,	12,				1
	];

	local g_capsuleVerts = array(74);
	local matCapsuleRotationSpace = matrix3x4_t();
	VS.VectorMatrix( Vector(0,0,1), matCapsuleRotationSpace );

	//-----------------------------------------------------------------------
	// Draws a capsule at world origin.
	//-----------------------------------------------------------------------
	function VS::DrawCapsule( start, end, radius, r, g, b, z, time )
		: ( g_capsuleVertPositions, g_capsuleLineIndices, g_capsuleVerts, Line, matCapsuleRotationSpace, Vector, matrix3x4_t )
	{
		local vecCapsuleCoreNormal = start - end;
		local vecLen = end - start;
		vecCapsuleCoreNormal.Norm();

		local matCapsuleSpace = matrix3x4_t();
		VectorMatrix( vecCapsuleCoreNormal, matCapsuleSpace );

		ConcatTransforms( matCapsuleSpace, matCapsuleRotationSpace, matCapsuleSpace );

		for ( local i = 0; i < 74; ++i )
		{
			local j = i*3;
			local vert = Vector(
				g_capsuleVertPositions[j],
				g_capsuleVertPositions[j+1],
				g_capsuleVertPositions[j+2] );

			VectorRotate( vert, matCapsuleSpace, vert );

			vert *= radius;

			if ( g_capsuleVertPositions[j+2] > 0.0 )
				vert += vecLen;

			g_capsuleVerts[i] = vert + start;
		}

		local i = 0;
		do
		{
			local i0 = g_capsuleLineIndices[i];
			local i1 = g_capsuleLineIndices[++i];
			if ( i1 == 0xFFFFFFFF )
			{
				++i;
				continue;
			};

			Line( g_capsuleVerts[i0], g_capsuleVerts[i1], r, g, b, z, time )
		} while ( i != 114 );
	}
}

function VS::DrawCapsule( start, end, radius, r, g, b, z, time ) : ( initCapsule )
{
	initCapsule();
	return DrawCapsule( start, end, radius, r, g, b, z, time );
}

function VS::DrawHorzArrow( startPos, endPos, width, r, g, b, noDepthTest, flDuration ) : (Line, Vector)
{
	local lineDir = endPos - startPos;
	lineDir.Norm();
	local upVec = Vector( 0, 0, 1 );
	local sideDir = lineDir.Cross( upVec );
	local radius = width * 0.5;

	local sr = sideDir * radius;
	local sw = sideDir * width;
	local ep = endPos - lineDir * width;

	local p1 = startPos - sr;
	local p2 = ep - sr;
	local p3 = ep - sw;
	local p4 = endPos;
	local p5 = ep + sw;
	local p6 = ep + sr;
	local p7 = startPos + sr;

	Line( p1, p2, r,g,b,noDepthTest,flDuration );
	Line( p2, p3, r,g,b,noDepthTest,flDuration );
	Line( p3, p4, r,g,b,noDepthTest,flDuration );
	Line( p4, p5, r,g,b,noDepthTest,flDuration );
	Line( p5, p6, r,g,b,noDepthTest,flDuration );
	return Line( p6, p7, r,g,b,noDepthTest,flDuration );
}

function VS::DrawVertArrow( startPos, endPos, width, r, g, b, noDepthTest, flDuration ) : (Line, Vector)
{
	local lineDir = endPos - startPos;
	lineDir.Norm();
	local upVec = Vector();
	local sideDir = Vector();
	local radius = width * 0.5;

	VectorVectors( lineDir, sideDir, upVec );

	local ur = upVec * radius;
	local uw = upVec * width;
	local ep = endPos - lineDir * width;

	local p1 = startPos - ur;
	local p2 = ep - ur;
	local p3 = ep - uw;
	local p4 = endPos;
	local p5 = ep + uw;
	local p6 = ep + ur;
	local p7 = startPos + ur;

	Line( p1, p2, r,g,b,noDepthTest,flDuration );
	Line( p2, p3, r,g,b,noDepthTest,flDuration );
	Line( p3, p4, r,g,b,noDepthTest,flDuration );
	Line( p4, p5, r,g,b,noDepthTest,flDuration );
	Line( p5, p6, r,g,b,noDepthTest,flDuration );
	return Line( p6, p7, r,g,b,noDepthTest,flDuration );
}


//==============================================================
//==============================================================

/*
//
// Vector mins, Vector maxs, cplane_t plane{ Vector normal, float dist, int type, string sindex }
//
local BoxOnPlaneSide = function( emins, emaxs, p )
{
	// fast axial cases
	if ( p.type < 3 )
	{
		if ( p.dist <= emins[ p.sindex ] )
			return 1;
		if ( p.dist >= emaxs[ p.sindex ] )
			return 2;
		return 3;
	}

	local dist1, dist2;
	local normal = p.normal;

	// general case
	switch ( p.signbits )
	{
	case 0:
		dist1 = normal.Dot( emaxs );
		dist2 = normal.Dot( emins );
		break;
	case 1:
		dist1 = normal.x*emins.x + normal.y*emaxs.y + normal.z*emaxs.z;
		dist2 = normal.x*emaxs.x + normal.y*emins.y + normal.z*emins.z;
		break;
	case 2:
		dist1 = normal.x*emaxs.x + normal.y*emins.y + normal.z*emaxs.z;
		dist2 = normal.x*emins.x + normal.y*emaxs.y + normal.z*emins.z;
		break;
	case 3:
		dist1 = normal.x*emins.x + normal.y*emins.y + normal.z*emaxs.z;
		dist2 = normal.x*emaxs.x + normal.y*emaxs.y + normal.z*emins.z;
		break;
	case 4:
		dist1 = normal.x*emaxs.x + normal.y*emaxs.y + normal.z*emins.z;
		dist2 = normal.x*emins.x + normal.y*emins.y + normal.z*emaxs.z;
		break;
	case 5:
		dist1 = normal.x*emins.x + normal.y*emaxs.y + normal.z*emins.z;
		dist2 = normal.x*emaxs.x + normal.y*emins.y + normal.z*emaxs.z;
		break;
	case 6:
		dist1 = normal.x*emaxs.x + normal.y*emins.y + normal.z*emins.z;
		dist2 = normal.x*emins.x + normal.y*emaxs.y + normal.z*emaxs.z;
		break;
	case 7:
		dist1 = normal.Dot( emins );
		dist2 = normal.Dot( emaxs );
		break;
	default:
		Msg( "VS::BoxOnPlaneSide: invalid plane signbits "+p.signbits+"\n" );
		break;
	}

	local sides = 0;

	if ( dist1 >= p.dist )
		sides = 1;

	if ( dist2 < p.dist )
		sides = sides | 2;

	// Assert( sides != 0 );
	return sides;
}
*/

local cplane_t = class
{
	normal = null;
	dist = 0.0;
	type = 0;			// for fast side tests
	sindex = "";		// for indexing vectors
	signbits = 0;		// signx + (signy<<1) + (signz<<1)
}

/*
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
//const FRUSTUM_NUMPLANES	= 6;;

local Frustum_t = class
{
	m_Plane = null;			// cplane_t[6]
	m_AbsNormal = null;		// Vector[6]

	constructor() : ( Vector, cplane_t )
	{
		m_Plane = [ null, null, null, null, null, null ];
		m_AbsNormal = [ null, null, null, null, null, null ];

		for ( local i = 6; i--; )
		{
			m_Plane[i] = cplane_t();
			m_AbsNormal[i] = Vector();
		}
	}

	function SetPlane( i, nType, vecNormal, dist ) : ( fabs )
	{
		local plane = m_Plane[i];
		plane.normal = vecNormal;
		plane.dist = dist;
		plane.type = nType;

		if ( nType < 3 )
			plane.sindex = ('x'+nType).tochar();
		else
			plane.sindex = ('x'+(nType-3)).tochar();

		// for fast box on planeside test
		local bits = 0;
		if ( 0.0 > vecNormal.x )
			bits = 1;
		if ( 0.0 > vecNormal.y )
			bits = bits | 2;
		if ( 0.0 > vecNormal.z )
			bits = bits | 4;
		plane.signbits = bits;

		local normal = m_AbsNormal[i];
		normal.x = fabs( vecNormal.x );
		normal.y = fabs( vecNormal.y );
		normal.z = fabs( vecNormal.z );
	}

	function CullBox( mins, maxs ) : ( BoxOnPlaneSide )
	{
		local plane = m_Plane;
		return (( BoxOnPlaneSide( mins, maxs, plane[FRUSTUM_RIGHT] ) == 2 ) ||
				( BoxOnPlaneSide( mins, maxs, plane[FRUSTUM_LEFT] ) == 2 ) ||
				( BoxOnPlaneSide( mins, maxs, plane[FRUSTUM_TOP] ) == 2 ) ||
				( BoxOnPlaneSide( mins, maxs, plane[FRUSTUM_BOTTOM] ) == 2 ) ||
				( BoxOnPlaneSide( mins, maxs, plane[FRUSTUM_NEARZ] ) == 2 ) ||
				( BoxOnPlaneSide( mins, maxs, plane[FRUSTUM_FARZ] ) == 2 ) );
	}
}
*/
/*
//-----------------------------------------------------------------------------
// Generate a frustum based on perspective view parameters
//-----------------------------------------------------------------------------
function VS::GeneratePerspectiveFrustum( origin, forward, right, up, flZNear, flZFar, flFovX, flAspectRatio, frustum ) : ( Vector, tan )
{
	local flIntercept = origin.Dot( forward );

	frustum.SetPlane( FRUSTUM_FARZ, PLANE_ANYZ, forward * 0xFFFFFFFF, -flZFar - flIntercept );
	frustum.SetPlane( FRUSTUM_NEARZ, PLANE_ANYZ, forward, flZNear + flIntercept );

	local flTanX = tan( DEG2RADDIV2 * flFovX );
	local flTanY = flTanX / flAspectRatio;

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
					f = 1.0 - ExponentialDecay( 0.001, dt, f * dt );
					vOut.y = vStart.y + f * ( vEnd.y - vStart.y );
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
					f = 1.0 - ExponentialDecay( 0.001, dt, f * dt );
					vOut.y = vStart.y + f * ( vEnd.y - vStart.y );
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
			- (p1 - p3)*(tt*0.25)
			+ (p1*2.0 - p2*5.0 + p3*4.0 - p4)*(ttt*0.166667)
			- (p1 - p2*3.0 + p3*3.0 - p4)*(ttt*t*0.125);
	output.x = o.x;
	output.y = o.y;
	output.z = o.z;
}

// area under the curve [0..1]
function VS::Catmull_Rom_Spline_Integral2( p1, p2, p3, p4, output )
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
	local ONE = 1.0;

	local ffa = ( ONE - tension ) * ( ONE + continuity ) * ( ONE + bias );
	local ffb = ( ONE - tension ) * ( ONE - continuity ) * ( ONE - bias );
	local ffc = ( ONE - tension ) * ( ONE - continuity ) * ( ONE + bias );
	local ffd = ( ONE - tension ) * ( ONE + continuity ) * ( ONE - bias );

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
	local b = t3 * (4.0 + ffa - ffb - ffc) + t2 * (-6.0 - 2.0 * ffa + 2.0 * ffb + ffc) + th * (ffa - ffb) + ONE;
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
function VS::InterpolateAngles( v1, v2, t, out = _VEC ) :
	( Quaternion, AngleQuaternion, QuaternionAngles, QuaternionSlerp )
{
	if ( v1 == v2 )
		return v1;

	local p = Quaternion(), q = Quaternion();
	AngleQuaternion( v1, p );
	AngleQuaternion( v2, q );

	local qt = QuaternionSlerp( p, q, t );

	return QuaternionAngles( qt, out );
}


}
//==============================================================
//==============================================================


function VS::PointOnLineNearestPoint( vStartPos, vEndPos, vPoint )
{
	local v1 = vEndPos - vStartPos;
	local dist = v1.Dot(vPoint - vStartPos) / v1.LengthSqr();

	if ( dist <= 0.0 )
		return vStartPos;
	if ( dist >= 1.0 )
		return vEndPos;
	return vStartPos + v1 * dist;
}

function VS::CalcSqrDistanceToAABB( mins, maxs, point )
{
	local flDelta, flDistSqr = 0.0;

	if ( point.x < mins.x )
	{
		flDelta = mins.x - point.x;
		flDistSqr += flDelta * flDelta;
	}
	else if ( point.x > maxs.x )
	{
		flDelta = point.x - maxs.x;
		flDistSqr += flDelta * flDelta;
	};;

	if ( point.y < mins.y )
	{
		flDelta = mins.y - point.y;
		flDistSqr += flDelta * flDelta;
	}
	else if ( point.y > maxs.y )
	{
		flDelta = point.y - maxs.y;
		flDistSqr += flDelta * flDelta;
	};;

	if ( point.z < mins.z )
	{
		flDelta = mins.z - point.z;
		flDistSqr += flDelta * flDelta;
	}
	else if ( point.z > maxs.z )
	{
		flDelta = point.z - maxs.z;
		flDistSqr += flDelta * flDelta;
	};;

	return flDistSqr;
}

function VS::CalcClosestPointOnAABB( mins, maxs, point, closestOut = _VEC )
{
	if ( point.x < mins.x )
	{
		closestOut.x = mins.x;
	}
	else if ( maxs.x < point.x )
	{
		closestOut.x = maxs.x;
	}
	else
	{
		closestOut.x = point.x;
	};;

	if ( point.y < mins.y )
	{
		closestOut.y = mins.y;
	}
	else if ( maxs.y < point.y )
	{
		closestOut.y = maxs.y;
	}
	else
	{
		closestOut.y = point.y;
	};;

	if ( point.z < mins.z )
	{
		closestOut.z = mins.z;
	}
	else if ( maxs.z < point.z )
	{
		closestOut.z = maxs.z;
	}
	else
	{
		closestOut.z = point.z;
	};;

	return closestOut;
}


local Ray_t = class
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

		if ( mins )
		{
			m_Extents = (maxs - mins) * 0.5;
			m_IsRay = ( m_Extents.LengthSqr() < 1.e-6 );
			m_StartOffset = (mins + maxs) * -0.5;
			m_Start = start - m_StartOffset;
		}
		else
		{
			m_Extents = Vector();
			m_IsRay = true;
			m_StartOffset = Vector();
			m_Start = start * 1.0;
		};
	}
}

local trace_t = class
{
	startpos = null;
	endpos = null;
	fraction = 1.0;
	allsolid = false;
	startsolid = false;
	fractionleftsolid = 0.0;
	plane = null;

	constructor() : (cplane_t)
	{
		plane = cplane_t();
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
	pTrace.startsolid = pTrace.allsolid = false;
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

local ComputeBoxOffset = VS.ComputeBoxOffset;

//-----------------------------------------------------------------------------
// Intersects a swept box against a triangle.
//
// t will be less than zero if no intersection occurred
// oneSided will cull collisions which approach the triangle from the back
// side, assuming the vertices are specified in counter-clockwise order
// The vertices need not be specified in that order if oneSided is not used
//-----------------------------------------------------------------------------
function VS::IntersectRayWithTriangle( ray, v1, v2, v3, oneSided ) : (ComputeBoxOffset)
{
	// This is cute: Use barycentric coordinates to represent the triangle
	// Vo(1-u-v) + V1u + V2v and intersect that with a line Po + Dt
	// This gives us 3 equations + 3 unknowns, which we can solve with
	// Cramer's rule...
	//		E1x u + E2x v - Dx t = Pox - Vox
	// There's a couple of other optimizations, Cramer's rule involves
	// computing the determinant of a matrix which has been constructed
	// by three vectors. It turns out that
	// det | A B C | = -( A x C ) dot B or -(C x B) dot A
	// which we'll use below..

	local edge1 = v2 - v1;
	local edge2 = v3 - v1;

	// Cull out one-sided stuff
	if (oneSided)
	{
		local normal = edge1.Cross( edge2 );
		if ( normal.Dot( ray.m_Delta ) >= 0.0 )
			return 0xFFFFFFFF;
	};

	// FIXME: This is inaccurate, but fast for boxes
	// We want to do a fast separating axis implementation here
	// with a swept triangle along the reverse direction of the ray.

	// Compute some intermediary terms
	local dirCrossEdge2 = ray.m_Delta.Cross( edge2 );

	// Compute the denominator of Cramer's rule:
	//		| -Dx E1x E2x |
	// det	| -Dy E1y E2y | = (D x E2) dot E1
	//		| -Dz E1z E2z |
	local denom = dirCrossEdge2.Dot( edge1 );
	if ( denom < 1.e-6 && denom > -1.e-6 )
		return 0xFFFFFFFF;
	denom = 1.0 / denom;

	// Compute u. It's gotta lie in the range of 0 to 1.
	//				   | -Dx orgx E2x |
	// u = denom * det | -Dy orgy E2y | = (D x E2) dot org
	//				   | -Dz orgz E2z |
	local org = ray.m_Start - v1;
	local u = dirCrossEdge2.Dot( org ) * denom;
	if ( (u < 0.0) || (u > 1.0) )
		return 0xFFFFFFFF;

	// Compute t and v the same way...
	// In barycentric coords, u + v < 1
	local orgCrossEdge1 = org.Cross( edge1 );
	local v = orgCrossEdge1.Dot( ray.m_Delta ) * denom;
	if ( (v < 0.0) || (v + u > 1.0) )
		return 0xFFFFFFFF;

	// Compute the distance along the ray direction that we need to fudge
	// when using swept boxes
	local boxt = 1.e-3;
	if ( !ray.m_IsRay )
		boxt = ComputeBoxOffset( ray );
	local t = orgCrossEdge1.Dot( edge2 ) * denom;
	if ( ( -boxt > t ) || ( t > 1.0 + boxt ) )
		return 0xFFFFFFFF;

	if ( t < 0.0 )
		return 0.0;
	if ( t > 1.0 )
		return 1.0;
	return t;
}

//-----------------------------------------------------------------------------
// Computes the barycentric coordinates of an intersection
//
// Figures out the barycentric coordinates (u,v) where a ray hits a
// triangle. Note that this will ignore the ray extents, and it also ignores
// the ray length. Note that the edge from v1->v2 represents u (v2: u = 1),
// and the edge from v1->v3 represents v (v3: v = 1). It returns false
// if the ray is parallel to the triangle (or when t is specified if t is less
// than zero).
//-----------------------------------------------------------------------------
function VS::ComputeIntersectionBarycentricCoordinates( ray, v1, v2, v3, uvt ) : (ComputeBoxOffset)
{
	local edge1 = v2 - v1;
	local edge2 = v3 - v1;

	// Compute some intermediary terms
	local dirCrossEdge2 = ray.m_Delta.Cross( edge2 );

	// Compute the denominator of Cramer's rule:
	//		| -Dx E1x E2x |
	// det	| -Dy E1y E2y | = (D x E2) dot E1
	//		| -Dz E1z E2z |
	local denom = dirCrossEdge2.Dot( edge1 );
	if ( denom < 1.e-6 && denom > -1.e-6 )
		return false;
	denom = 1.0 / denom;

	// Compute u. It's gotta lie in the range of 0 to 1.
	//				   | -Dx orgx E2x |
	// u = denom * det | -Dy orgy E2y | = (D x E2) dot org
	//				   | -Dz orgz E2z |
	local org = ray.m_Start - v1;
	uvt[0] = dirCrossEdge2.Dot( org ) * denom;

	// Compute t and v the same way...
	// In barycentric coords, u + v < 1
	local orgCrossEdge1 = org.Cross( edge1 );
	uvt[1] = orgCrossEdge1.Dot( ray.m_Delta ) * denom;

	// if ( 2 in uvt )
	{
		// Compute the distance along the ray direction that we need to fudge
		// when using swept boxes
		local boxt = 1.e-3;
		if ( !ray.m_IsRay )
			boxt = ComputeBoxOffset( ray );
		local t = uvt[2] = orgCrossEdge1.Dot( edge2 ) * denom;
		if ( ( -boxt > t ) || ( t > 1.0 + boxt ) )
			return false;
	};

	return true;
}
/*
//-----------------------------------------------------------------------------
// Compute point from barycentric specification
// Edge u goes from v0 to v1, edge v goes from v0 to v2
//-----------------------------------------------------------------------------
function VS::ComputePointFromBarycentric( v0, v1, v2, u, v, pt )
{
	local edgeU = v1 - v0;
	local edgeV = v2 - v0;
	local p = v0 + edgeU * u + edgeV * v;
	pt.x = p.x;
	pt.y = p.y;
	pt.z = p.z;
}
*/
/*
function VS::IsBoxIntersectingTriangle()
{
}
*/
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
	radius2 = radius1 + radius2;
	return ((center2 - center1).LengthSqr() <= (radius2 * radius2));
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

	local t = 0.0; // ( flNumerator <= 0.0 )

	if ( t < flNumerator )
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
	if ( a )
	{
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
	};

	// This would occur in the case of a zero-length ray
	pT[0] = pT[1] = 0.0;
	return vecSphereToRay.LengthSqr() <= flRadius * flRadius;
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
// Intersects a ray with an AABB, return true if they intersect
//-----------------------------------------------------------------------------
function VS::IsBoxIntersectingRay( boxMin, boxMax, origin, vecDelta, flTolerance = 0.0 )
{
	// Assert( boxMin.x <= boxMax.x );
	// Assert( boxMin.y <= boxMax.y );
	// Assert( boxMin.z <= boxMax.z );

	// FIXME: Surely there's a faster way
	local tmin = FLT_MAX_N, tmax = FLT_MAX, EPS = 1.e-8;

	// Parallel case...
	if ( vecDelta.x < EPS && vecDelta.x > -EPS )
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
	if ( vecDelta.y < EPS && vecDelta.y > -EPS )
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

	if ( vecDelta.z < EPS && vecDelta.z > -EPS )
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
// Intersects a ray with an AABB, return true if they intersect
//-----------------------------------------------------------------------------
function VS::IsBoxIntersectingRay2( origin, vecBoxMin, vecBoxMax, ray, flTolerance = 0.0 )
	: ( IsBoxIntersectingRay )
{
	if ( ray.m_IsSwept )
		return IsBoxIntersectingRay(
			origin + vecBoxMin - ray.m_Extents,
			origin + vecBoxMax + ray.m_Extents,
			ray.m_Start,
			ray.m_Delta,
			flTolerance );

	local rayMins = ray.m_Start - ray.m_Extents;
	local rayMaxs = ray.m_Start + ray.m_Extents;
	if ( flTolerance )
	{
		rayMins.x -= flTolerance; rayMins.y -= flTolerance; rayMins.z -= flTolerance;
		rayMaxs.x += flTolerance; rayMaxs.y += flTolerance; rayMaxs.z += flTolerance;
	};
	return IsBoxIntersectingBox( vecBoxMin, vecBoxMax, rayMins, rayMaxs );
}

//-----------------------------------------------------------------------------
// Intersects a ray with a ray, return true if they intersect
// t, s = parameters of closest approach (if not intersecting!)
//-----------------------------------------------------------------------------
function VS::IntersectRayWithRay( vecStart0, vecDelta0, vecStart1, vecDelta1, pT )
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
	if ( lengthSq )
	{
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
		pT[0] = t;
		pT[1] = s;

		// intersection????
		local i0 = vecStart0 + vecDelta0 * t;
		local i1 = vecStart1 + vecDelta1 * s;

		return ( i0.x == i1.x && i0.y == i1.y && i0.z == i1.z );
	};

	pT[0] = pT[1] = 0.0;
	return false;		// parallel
}

function VS::IntersectRayWithPlane( org, dir, normal, dist )
{
	local d	= dir.Dot( normal );
	if ( d )
		return ( dist - org.Dot( normal ) ) / d;
	return 0.0;
}

//-----------------------------------------------------------------------------
// Intersects a ray against a box, returns t1 and t2
//-----------------------------------------------------------------------------
function VS::IntersectRayWithBox( vecRayStart, vecRayDelta, boxMins, boxMaxs, flTolerance, pTrace )
{
	local ZERO = 0.0;

	local f, d1, d2;

	local t2 = 1.0;
	local t1 = -t2;
	local hitside = -1;

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
		if (d1 > ZERO && d2 > ZERO)
		{
			// UNDONE: Have to revert this in case it's still set
			// UNDONE: Refactor to have only 2 return points (true/false) from this function
			if ( 2 in pTrace )
				pTrace[2] = false;
			// startsolid = false;
			return false;
		};

		// completely inside, check next face
		if (d1 <= ZERO && d2 <= ZERO)
			continue;

		if (d1 > ZERO)
			startsolid = false;

		// crosses face
		if (d1 > d2)
		{
			f = d1 - flTolerance;
			if ( f < ZERO )
				f = ZERO;
			f /= (d1-d2);
			if (f > t1)
			{
				t1 = f;
				hitside = i;
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
	if ( 2 in pTrace )
	{
		pTrace[2] = startsolid;
		pTrace[3] = hitside;
	};

	return startsolid || (t1 < t2 && t1 >= ZERO);
}

local IntersectRayWithBox = VS.IntersectRayWithBox;

//-----------------------------------------------------------------------------
// Intersects a ray against a box, returns trace_t info
// IntersectRayWithBox
//-----------------------------------------------------------------------------
function VS::ClipRayToBox( vecRayStart, vecRayDelta, boxMins, boxMaxs, flTolerance, pTrace ) : (IntersectRayWithBox)
{
	// Collision_ClearTrace( vecRayStart, vecRayDelta, pTrace );
	pTrace.startpos = vecRayStart;
	pTrace.endpos = vecRayStart + vecRayDelta;
	pTrace.fraction = 1.0;
	pTrace.startsolid = pTrace.allsolid = false;

	local trace = [ 0.0, 0.0, 0, false ];

	if ( IntersectRayWithBox( vecRayStart, vecRayDelta, boxMins, boxMaxs, flTolerance, trace ) )
	{
		local plane = pTrace.plane;
		pTrace.startsolid = trace[2];
		if (trace[0] < trace[1] && trace[0] >= 0.0)
		{
			pTrace.fraction = trace[0];
			VectorMA( pTrace.startpos, trace[0], vecRayDelta, pTrace.endpos );
			plane.normal = Vector();
			if ( trace[3] >= 3 )
			{
				local hitside = trace[3]-3;
				local idx = ('x'+hitside).tochar();
				plane.type = hitside;
				plane.sindex = idx;
				plane.dist = boxMaxs[idx];
				plane.normal[idx] = 1.0;
			}
			else
			{
				local hitside = trace[3];
				local idx = ('x'+hitside).tochar();
				plane.type = hitside;
				plane.sindex = idx;
				plane.dist = -boxMins[idx];
				plane.normal[idx] = -1.0;
			};
			return true;
		};

		if ( pTrace.startsolid )
		{
			pTrace.allsolid = (trace[1] <= 0.0) || (trace[1] >= 1.0);
			pTrace.fraction = 0.0;
			pTrace.fractionleftsolid = trace[1];
			pTrace.endpos = pTrace.startpos * 1;
			plane.dist = pTrace.startpos.x;
			plane.normal = Vector( 1.0, 0.0, 0.0 );
			plane.type = 0;
			plane.sindex = "x";
			pTrace.startpos = vecRayStart + vecRayDelta * trace[1];
			return true;
		};
	};

	return false;
}

local ClipRayToBox = VS.ClipRayToBox;

//-----------------------------------------------------------------------------
// Intersects a ray against a box, returns trace_t info
// IntersectRayWithBox
//-----------------------------------------------------------------------------
function VS::ClipRayToBox2( ray, boxMins, boxMaxs, flTolerance, pTrace ) : (ClipRayToBox)
{
	if ( ray.m_IsRay )
		return ClipRayToBox( ray.m_Start, ray.m_Delta, boxMins, boxMaxs, flTolerance, pTrace );

	local ret = ClipRayToBox(
		ray.m_Start,
		ray.m_Delta,
		boxMins - ray.m_Extents,
		boxMaxs + ray.m_Extents,
		flTolerance,
		pTrace );
	pTrace.startpos += ray.m_StartOffset;
	pTrace.endpos += ray.m_StartOffset;
	return ret;
}

//-----------------------------------------------------------------------------
// Intersects a ray against an OBB, returns t1 and t2
//-----------------------------------------------------------------------------
function VS::IntersectRayWithOBB( vecRayStart, vecRayDelta, matOBBToWorld,
	vecOBBMins, vecOBBMaxs, flTolerance, pTrace ) : (Vector, VectorITransform, VectorIRotate, IntersectRayWithBox)
{
	local start = Vector(), delta = Vector();
	VectorITransform( vecRayStart, matOBBToWorld, start );
	VectorIRotate( vecRayDelta, matOBBToWorld, delta );

	return IntersectRayWithBox( start, delta, vecOBBMins, vecOBBMaxs, flTolerance, pTrace );
}

//-----------------------------------------------------------------------------
// Intersects a ray against an OBB, returns trace_t info
// IntersectRayWithOBB
//-----------------------------------------------------------------------------
function VS::ClipRayToOBB( vecRayStart, vecRayDelta, matOBBToWorld,
	vecOBBMins, vecOBBMaxs, flTolerance, pTrace ) : ( fabs, Vector, ClipRayToBox )
{
	// Collision_ClearTrace( vecRayStart, vecRayDelta, pTrace );
	pTrace.startpos = vecRayStart;
	pTrace.endpos = vecRayStart + vecRayDelta;
	pTrace.fraction = 1.0;
	pTrace.startsolid = pTrace.allsolid = false;

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

	local mat = matOBBToWorld[0];

	// check box axes for separation
	extent.x = vecRayDelta.x * mat[M_00] + vecRayDelta.y * mat[M_10] + vecRayDelta.z * mat[M_20];
	uextent.x = fabs(extent.x);
	local coord = segmentCenter.x * mat[M_00] + segmentCenter.y * mat[M_10] + segmentCenter.z * mat[M_20];

	if ( fabs(coord) > (vecBoxExtents.x + uextent.x) )
		return false;

	extent.y = vecRayDelta.x * mat[M_01] + vecRayDelta.y * mat[M_11] + vecRayDelta.z * mat[M_21];
	uextent.y = fabs(extent.y);
	coord = segmentCenter.x * mat[M_01] + segmentCenter.y * mat[M_11] + segmentCenter.z * mat[M_21];

	if ( fabs(coord) > (vecBoxExtents.y + uextent.y) )
		return false;

	extent.z = vecRayDelta.x * mat[M_02] + vecRayDelta.y * mat[M_12] + vecRayDelta.z * mat[M_22];
	uextent.z = fabs(extent.z);
	coord = segmentCenter.x * mat[M_02] + segmentCenter.y * mat[M_12] + segmentCenter.z * mat[M_22];

	if ( fabs(coord) > (vecBoxExtents.z + uextent.z) )
		return false;

	// now check cross axes for separation
	local cross = vecRayDelta.Cross( segmentCenter );
	local cextent = cross.x * mat[M_00] + cross.y * mat[M_10] + cross.z * mat[M_20];
	if ( fabs(cextent) > (vecBoxExtents.y*uextent.z + vecBoxExtents.z*uextent.y) )
		return false;

	cextent = cross.x * mat[M_01] + cross.y * mat[M_11] + cross.z * mat[M_21];
	if ( fabs(cextent) > (vecBoxExtents.x*uextent.z + vecBoxExtents.z*uextent.x) )
		return false;

	cextent = cross.x * mat[M_02] + cross.y * mat[M_12] + cross.z * mat[M_22];
	if ( fabs(cextent) > (vecBoxExtents.x*uextent.y + vecBoxExtents.y*uextent.x) )
		return false;

	// !!! We hit this box !!! compute intersection point and return
	// Compute ray start in bone space
	local start = Vector();
	VectorITransform( vecRayStart, matOBBToWorld, start );

	// extent is ray.m_Delta in bone space, recompute delta in bone space
	extent *= 2.0;

	// delta was prescaled by the current t, so no need to see if this intersection is closer
	if ( !ClipRayToBox( start, extent, vecOBBMins, vecOBBMaxs, flTolerance, pTrace ) )
		return false;

	// Fix up the start/end pos and fraction
	VectorTransform( pTrace.endpos, matOBBToWorld, pTrace.endpos );

	pTrace.startpos = vecRayStart;
	pTrace.fraction *= 2.0;

	// Fix up the plane information
	local plane = pTrace.plane;
	local normal = plane.normal;
	local flSign = normal[ plane.sindex ];
	normal.x = flSign * mat[    plane.type];
	normal.y = flSign * mat[4 + plane.type];
	normal.z = flSign * mat[8 + plane.type];
	plane.dist = pTrace.endpos.Dot( normal );
	plane.type = 3;
	plane.sindex = "x";

	return true;
}

// float[3], float[3], float[3], float[2]
local ComputeSupportMap = function( vecDirection, vecBoxMins, vecBoxMaxs, pDist )
{
	local fl = vecDirection[0];
	local nIndex = (fl > 0.0).tointeger();
	pDist[nIndex] = vecBoxMaxs[0] * fl;
	pDist[1 - nIndex] = vecBoxMins[0] * fl;

	fl = vecDirection[1];
	nIndex = (fl > 0.0).tointeger();
	pDist[nIndex] += vecBoxMaxs[1] * fl;
	pDist[1 - nIndex] += vecBoxMins[1] * fl;

	fl = vecDirection[2];
	nIndex = (fl > 0.0).tointeger();
	pDist[nIndex] += vecBoxMaxs[2] * fl;
	pDist[1 - nIndex] += vecBoxMins[2] * fl;
}

local ComputeSupportMap2 = function( vecDirection, i1, i2, vecBoxMins, vecBoxMaxs, pDist )
{
	// local ii = i1[0]-'x';
	local nIndex = (vecDirection[i1] > 0.0).tointeger();
	pDist[nIndex] = vecBoxMaxs[i1] * vecDirection[i1];
	pDist[1 - nIndex] = vecBoxMins[i1] * vecDirection[i1];

	// ii = i2[0]-'x';
	nIndex = (vecDirection[i2] > 0.0).tointeger();
	pDist[nIndex] += vecBoxMaxs[i2] * vecDirection[i2];
	pDist[1 - nIndex] += vecBoxMins[i2] * vecDirection[i2];
}

// [3][2]
local s_ExtIndices =
[
	2, 1,
	0, 2,
	0, 1,
];

// [3][2]
local s_MatIndices =
[
	1*4, 2*4,
	2*4, 0*4,
	1*4, 0*4,
];

local ClipRayToOBB = VS.ClipRayToOBB;

//-----------------------------------------------------------------------------
// Intersects a ray against an OBB, returns trace_t info
// IntersectRayWithOBB
//-----------------------------------------------------------------------------
function VS::ClipRayToOBB2( ray, matOBBToWorld, vecOBBMins, vecOBBMaxs, flTolerance, pTrace ) :
	( ClipRayToOBB, ComputeSupportMap, ComputeSupportMap2, Vector, array, fabs, s_ExtIndices, s_MatIndices )
{
	if ( ray.m_IsRay )
		return ClipRayToOBB( ray.m_Start, ray.m_Delta, matOBBToWorld,
			vecOBBMins, vecOBBMaxs, flTolerance, pTrace );

	// Collision_ClearTrace( ray.m_Start + ray.m_StartOffset, ray.m_Delta, pTrace );
	pTrace.startpos = ray.m_Start + ray.m_StartOffset;
	pTrace.endpos = pTrace.startpos + ray.m_Delta;
	pTrace.fraction = 1.0;
	pTrace.startsolid = pTrace.allsolid = false;
{
	// Compute a bounding sphere around the bloated OBB
	local vecOBBCenter = (vecOBBMins + vecOBBMaxs) * 0.5;
	vecOBBCenter.x += matOBBToWorld[0][M_03];
	vecOBBCenter.y += matOBBToWorld[0][M_13];
	vecOBBCenter.z += matOBBToWorld[0][M_23];

	local vecOBBHalfDiagonal = (vecOBBMaxs - vecOBBMins) * 0.5;

	local flRadius = vecOBBHalfDiagonal.Length() + ray.m_Extents.Length();
	if ( !IsRayIntersectingSphere( ray.m_Start, ray.m_Delta, vecOBBCenter, flRadius, flTolerance ) )
		return false;
}
	// Ok, we passed the trivial reject, so lets do the dirty deed.
	// Basically we're going to do the GJK thing explicitly. We'll shrink the ray down
	// to a point, and bloat the OBB by the ray's extents. This will generate facet
	// planes which are perpendicular to all of the separating axes typically seen in
	// a standard seperating axis implementation.

	// We're going to create a number of planes through various vertices in the OBB
	// which represent all of the separating planes. Then we're going to bloat the planes
	// by the ray extents.

	// We're going to do all work in OBB-space because it's easier to do the
	// support-map in this case

	// First, transform the ray into the space of the OBB
	local vecLocalRayOrigin = Vector(), vecLocalRayDirection = Vector();
	VectorITransform( ray.m_Start, matOBBToWorld, vecLocalRayOrigin );
	VectorIRotate( ray.m_Delta, matOBBToWorld, vecLocalRayDirection );

	// Next compute all separating planes
	local pPlaneNormal = array(15);	// float[15][3]
	local ppPlaneDist = array(15);	// float[15][2]

	for ( local i = 15; i--; )
	{
		ppPlaneDist[i] = [ 0.0, 0.0 ];
	}

	for ( local i = 0,
		rgflOBBMins = [ vecOBBMins.x, vecOBBMins.y, vecOBBMins.z ],
		rgflOBBMaxs = [ vecOBBMaxs.x, vecOBBMaxs.y, vecOBBMaxs.z ],
		rgflExtents = [ ray.m_Extents.x, ray.m_Extents.y, ray.m_Extents.z ],
		mat = matOBBToWorld[0];
		i < 3;
		++i )
	{
		// Each plane needs to be bloated an amount = to the abs dot product of
		// the ray extents with the plane normal
		// For the OBB planes, do it in world space;
		// and use the direction of the OBB (the ith column of matOBBToWorld) in world space vs extents
		pPlaneNormal[i] = [ 0.0, 0.0, 0.0 ];
		pPlaneNormal[i][i] = 1.0;

		local flExtentDotNormal =
			fabs( mat[  i] * rgflExtents[0] ) +
			fabs( mat[4+i] * rgflExtents[1] ) +
			fabs( mat[8+i] * rgflExtents[2] );

		ppPlaneDist[i][0] = rgflOBBMins[i] - flExtentDotNormal;
		ppPlaneDist[i][1] = rgflOBBMaxs[i] + flExtentDotNormal;

		// For the ray-extents planes, they are bloated by the extents
		// Use the support map to determine which
		pPlaneNormal[i+3] = [ mat[i*4  ], mat[i*4+1], mat[i*4+2] ];

		ComputeSupportMap( pPlaneNormal[i+3], rgflOBBMins, rgflOBBMaxs, ppPlaneDist[i+3] );
		ppPlaneDist[i+3][0] -= rgflExtents[i];
		ppPlaneDist[i+3][1] += rgflExtents[i];

		// Now the edge cases... (take the cross product of x,y,z axis w/ ray extent axes
		// given by the rows of the obb to world matrix.
		// Compute the ray extent bloat in world space because it's easier...

		// These are necessary to compute the world-space versions of
		// the edges so we can compute the extent dot products
		local flRayExtent0 = rgflExtents[s_ExtIndices[i*2  ]];
		local flRayExtent1 = rgflExtents[s_ExtIndices[i*2+1]];
		local iMatRow0 = s_MatIndices[i*2  ];
		local iMatRow1 = s_MatIndices[i*2+1];

		// x axis of the OBB + world ith axis
		pPlaneNormal[i+6] = [ 0.0, -mat[i*4+2], mat[i*4+1] ];
		ComputeSupportMap2( pPlaneNormal[i+6], 1, 2, rgflOBBMins, rgflOBBMaxs, ppPlaneDist[i+6] );
		flExtentDotNormal =
			fabs( mat[iMatRow0] ) * flRayExtent0 +
			fabs( mat[iMatRow1] ) * flRayExtent1;
		ppPlaneDist[i+6][0] -= flExtentDotNormal;
		ppPlaneDist[i+6][1] += flExtentDotNormal;

		// y axis of the OBB + world ith axis
		pPlaneNormal[i+9] = [ mat[i*4+2], 0.0, -mat[i*4] ];
		ComputeSupportMap2( pPlaneNormal[i+9], 0, 2, rgflOBBMins, rgflOBBMaxs, ppPlaneDist[i+9] );
		flExtentDotNormal =
			fabs( mat[iMatRow0+1] ) * flRayExtent0 +
			fabs( mat[iMatRow1+1] ) * flRayExtent1;
		ppPlaneDist[i+9][0] -= flExtentDotNormal;
		ppPlaneDist[i+9][1] += flExtentDotNormal;

		// z axis of the OBB + world ith axis
		pPlaneNormal[i+12] = [ -mat[i*4+1], mat[i*4], 0.0 ];
		ComputeSupportMap2( pPlaneNormal[i+12], 0, 1, rgflOBBMins, rgflOBBMaxs, ppPlaneDist[i+12] );
		flExtentDotNormal =
			fabs( mat[iMatRow0+2] ) * flRayExtent0 +
			fabs( mat[iMatRow1+2] ) * flRayExtent1;
		ppPlaneDist[i+12][0] -= flExtentDotNormal;
		ppPlaneDist[i+12][1] += flExtentDotNormal;
	}

	pTrace.startsolid = true;

	local hitplane = -1;
	local hitside = -1;
	local enterfrac = -1.0;
	local leavefrac = 1.0;
{
	local d1 = [0.0, 0.0], d2 = [0.0, 0.0];
	local f;

	local vecLocalRayEnd = vecLocalRayOrigin + vecLocalRayDirection;

	for ( local i = 0; i < 15; ++i )
	{
		local pNormal = pPlaneNormal[i];
		local pDist = ppPlaneDist[i];

		// FIXME: Not particularly optimal since there's a lot of 0's in the plane normals
		local flStartDot = pNormal[0]*vecLocalRayOrigin.x + pNormal[1]*vecLocalRayOrigin.y + pNormal[2]*vecLocalRayOrigin.z;
		local flEndDot = pNormal[0]*vecLocalRayEnd.x + pNormal[1]*vecLocalRayEnd.y + pNormal[2]*vecLocalRayEnd.z;

		// NOTE: Negative here is because the plane normal + dist
		// are defined in negative terms for the far plane (plane dist index 0)
		d1[0] = -(flStartDot - pDist[0]);
		d2[0] = -(flEndDot - pDist[0]);

		d1[1] = flStartDot - pDist[1];
		d2[1] = flEndDot - pDist[1];

		for ( local j = 0; j < 2; ++j )
		{
			// if completely in front near plane or behind far plane no intersection
			if (d1[j] > 0.0 && d2[j] > 0.0)
				return false;

			// completely inside, check next plane set
			if (d1[j] <= 0.0 && d2[j] <= 0.0)
				continue;

			if (d1[j] > 0.0)
				pTrace.startsolid = false;

			// crosses face
			local flDenom = 1.0 / (d1[j] - d2[j]);
			if (d1[j] > d2[j])
			{
				f = d1[j] - flTolerance;

				if ( f < 0.0 )
					f = 0.0;

				f *= flDenom;
				if (f > enterfrac)
				{
					enterfrac = f;
					hitplane = i;
					hitside = j;
				};
			}
			else
			{
				// leave
				f = (d1[j] + flTolerance) * flDenom;

				if (f < leavefrac)
					leavefrac = f;
			};
		}
	}
}
	if ( enterfrac < leavefrac && enterfrac >= 0.0 )
	{
		pTrace.fraction = enterfrac;
		VectorMA( pTrace.startpos, enterfrac, ray.m_Delta, pTrace.endpos );

		// Need to transform the plane into world space...
		local pNormal = pPlaneNormal[hitplane];
		local normal, dist;

		if ( hitside == 0 )
		{
			normal = Vector( -pNormal[0], -pNormal[1], -pNormal[2] );
			dist = -ppPlaneDist[hitplane][hitside];
		}
		else
		{
			normal = Vector( pNormal[0], pNormal[1], pNormal[2] );
			dist = ppPlaneDist[hitplane][hitside];
		};

		local worldNormal = Vector();
		pTrace.plane.normal = worldNormal;
		pTrace.plane.type = 3;
		pTrace.plane.sindex = "x";

		// pTrace.plane.dist = MatrixTransformPlane( matOBBToWorld, normal, dist, pTrace.plane.normal );
		VectorRotate( normal, matOBBToWorld, worldNormal );
		pTrace.plane.dist = pTrace.endpos.Dot( worldNormal );
		return true;
	};

	if ( pTrace.startsolid )
	{
		pTrace.allsolid = (leavefrac <= 0.0) || (leavefrac >= 1.0);
		pTrace.fraction = 0.0;
		pTrace.endpos = pTrace.startpos;
		pTrace.plane.dist = pTrace.startpos.x;
		pTrace.plane.normal = Vector( 1.0, 0.0, 0.0 );
		pTrace.plane.type = 0;
		pTrace.plane.sindex = "x";
		return true;
	};

	return false;
}

//-----------------------------------------------------------------------------
// Swept OBB test
//-----------------------------------------------------------------------------
function VS::IsRayIntersectingOBB( ray, org, ang, mins, maxs )
	: ( matrix3x4_t, Vector, AngleIMatrix, VectorTransform, VectorRotate, IsBoxIntersectingRay, DotProductAbs )
{
	if ( !ang.x && !ang.y && !ang.z )
		return IsBoxIntersectingRay( org + mins, org + maxs, ray.m_Start, ray.m_Delta );

	if ( ray.m_IsRay )
	{
		local worldToBox = matrix3x4_t();
		local rayStart = Vector();
		local rayDelta = Vector();

		AngleIMatrix( ang, org, worldToBox );
		VectorTransform( ray.m_Start, worldToBox, rayStart );
		VectorRotate( ray.m_Delta, worldToBox, rayDelta );

		return IsBoxIntersectingRay( mins, maxs, rayStart, rayDelta );
	};

	if ( !ray.m_IsSwept )
		return IsOBBIntersectingOBB( ray.m_Start, Vector(), ray.m_Extents * -1, ray.m_Extents,
			org, ang, mins, maxs, 0.0 );

	// NOTE: See the comments in ComputeSeparatingPlane to understand this math

	// First, compute the basis of box in the space of the ray
	// NOTE: These basis place the origin at the centroid of each box!
	local box2ToWorld = matrix3x4_t();
	ComputeCenterMatrix( org, ang, mins, maxs, box2ToWorld );

	// Find the center + extents of an AABB surrounding the ray
	local vecRayCenter = VectorMA( ray.m_Start, 0.5, ray.m_Delta ) * -1.0;

	local worldToBox1 = matrix3x4_t(
		1.0, 0.0, 0.0, vecRayCenter.x,
		0.0, 1.0, 0.0, vecRayCenter.y,
		0.0, 0.0, 1.0, vecRayCenter.z );

	local box1Size = Vector( ray.m_Extents.x + fabs( ray.m_Delta.x ) * 0.5,
							ray.m_Extents.y + fabs( ray.m_Delta.y ) * 0.5,
							ray.m_Extents.z + fabs( ray.m_Delta.z ) * 0.5 );

	// Then compute the size of the box
	local box2Size = (maxs - mins)*0.5;

	// Do an OBB test of the box with the AABB surrounding the ray
	if ( ComputeSeparatingPlane( worldToBox1, box2ToWorld, box1Size, box2Size, 0.0 ) )
		return false;

	// Now deal with the planes which are the cross products of the ray sweep direction vs box edges
	local vecRayDirection = ray.m_Delta * 1;
	vecRayDirection.Norm();

	// Rotate the ray direction into the space of the OBB
	local vecAbsRayDirBox2 = VectorIRotate( vecRayDirection, box2ToWorld );

	// Make abs versions of the ray in world space + ray in box2 space
	VectorAbs( vecAbsRayDirBox2 );

	box2ToWorld = box2ToWorld[0];
	// Need a vector between ray center vs box center measured in the space of the ray (world)
	local vecCenterDelta = Vector( box2ToWorld[M_03] - ray.m_Start.x,
									box2ToWorld[M_13] - ray.m_Start.y,
									box2ToWorld[M_23] - ray.m_Start.z );

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
	vecPlaneNormal = vecRayDirection.Cross( Vector( box2ToWorld[M_00], box2ToWorld[M_10], box2ToWorld[M_20] ) );
	flCenterDeltaProjection = vecPlaneNormal.Dot(vecCenterDelta);
	if ( 0.0 > flCenterDeltaProjection )
		flCenterDeltaProjection = -flCenterDeltaProjection;
	flBoxProjectionSum =
		vecAbsRayDirBox2.z * box2Size.y + vecAbsRayDirBox2.y * box2Size.z +
		DotProductAbs( vecPlaneNormal, ray.m_Extents );
	if ( flCenterDeltaProjection > flBoxProjectionSum )
		return false;

	// box y x ray delta
	vecPlaneNormal = vecRayDirection.Cross( Vector( box2ToWorld[M_01], box2ToWorld[M_11], box2ToWorld[M_21] ) );
	flCenterDeltaProjection = vecPlaneNormal.Dot(vecCenterDelta);
	if ( 0.0 > flCenterDeltaProjection )
		flCenterDeltaProjection = -flCenterDeltaProjection;
	flBoxProjectionSum =
		vecAbsRayDirBox2.z * box2Size.x + vecAbsRayDirBox2.x * box2Size.z +
		DotProductAbs( vecPlaneNormal, ray.m_Extents );
	if ( flCenterDeltaProjection > flBoxProjectionSum )
		return false;

	// box z x ray delta
	vecPlaneNormal = vecRayDirection.Cross( Vector( box2ToWorld[M_02], box2ToWorld[M_12], box2ToWorld[M_22] ) );
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
	worldToBox1 = worldToBox1[0];

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
	boxProjectionSum = MatrixRowDotProduct( absBox2ToBox1, 0, box2Size ) + box1Size.x;
	originProjection = fabs( box2Origin.x ) + tolerance;
	if ( originProjection > boxProjectionSum )
	{
		pNormalOut.x = worldToBox1[M_00];
		pNormalOut.y = worldToBox1[M_01];
		pNormalOut.z = worldToBox1[M_02];
		return true;
	};

	// Second side of box 1
	boxProjectionSum = MatrixRowDotProduct( absBox2ToBox1, 1, box2Size ) + box1Size.y;
	originProjection = fabs( box2Origin.y ) + tolerance;
	if ( originProjection > boxProjectionSum )
	{
		pNormalOut.x = worldToBox1[M_10];
		pNormalOut.y = worldToBox1[M_11];
		pNormalOut.z = worldToBox1[M_12];
		return true;
	};

	// Third side of box 1
	boxProjectionSum = MatrixRowDotProduct( absBox2ToBox1, 2, box2Size ) + box1Size.z;
	originProjection = fabs( box2Origin.z ) + tolerance;
	if ( originProjection > boxProjectionSum )
	{
		pNormalOut.x = worldToBox1[M_20];
		pNormalOut.y = worldToBox1[M_21];
		pNormalOut.z = worldToBox1[M_22];
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
	boxProjectionSum = MatrixColumnDotProduct( absBox2ToBox1, 0, box1Size ) + box2Size.x;
	originProjection = fabs( MatrixColumnDotProduct( box2ToBox1, 0, box2Origin ) ) + tolerance;
	if ( originProjection > boxProjectionSum )
	{
		MatrixGetColumn( box2ToWorld, 0, pNormalOut );
		return true;
	};

	// Second side of box 2
	boxProjectionSum = MatrixColumnDotProduct( absBox2ToBox1, 1, box1Size ) + box2Size.y;
	originProjection = fabs( MatrixColumnDotProduct( box2ToBox1, 1, box2Origin ) ) + tolerance;
	if ( originProjection > boxProjectionSum )
	{
		MatrixGetColumn( box2ToWorld, 1, pNormalOut );
		return true;
	};

	// Third side of box 2
	boxProjectionSum = MatrixColumnDotProduct( absBox2ToBox1, 2, box1Size ) + box2Size.z;
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

	absBox2ToBox1 = absBox2ToBox1[0];
	box2ToBox1 = box2ToBox1[0];

	// b1e1 x b2e1
	if ( absBox2ToBox1[M_00] < 0.999 )
	{
		boxProjectionSum =
			box1Size.y * absBox2ToBox1[M_20] + box1Size.z * absBox2ToBox1[M_10] +
			box2Size.y * absBox2ToBox1[M_02] + box2Size.z * absBox2ToBox1[M_01];
		originProjection = fabs( -box2Origin.y * box2ToBox1[M_20] + box2Origin.z * box2ToBox1[M_10] ) + tolerance;
		if ( originProjection > boxProjectionSum )
		{
			MatrixGetColumn( box2ToWorld, 0, pNormalOut );
			local v = Vector( worldToBox1[M_00], worldToBox1[M_01], worldToBox1[M_02] ).Cross(pNormalOut);
			pNormalOut.x = v.x;
			pNormalOut.y = v.y;
			pNormalOut.z = v.z;
			return true;
		};
	};

	// b1e1 x b2e2
	if ( absBox2ToBox1[M_01] < 0.999 )
	{
		boxProjectionSum =
			box1Size.y * absBox2ToBox1[M_21] + box1Size.z * absBox2ToBox1[M_11] +
			box2Size.x * absBox2ToBox1[M_02] + box2Size.z * absBox2ToBox1[M_00];
		originProjection = fabs( -box2Origin.y * box2ToBox1[M_21] + box2Origin.z * box2ToBox1[M_11] ) + tolerance;
		if ( originProjection > boxProjectionSum )
		{
			MatrixGetColumn( box2ToWorld, 1, pNormalOut );
			local v = Vector( worldToBox1[M_00], worldToBox1[M_01], worldToBox1[M_02] ).Cross(pNormalOut);
			pNormalOut.x = v.x;
			pNormalOut.y = v.y;
			pNormalOut.z = v.z;
			return true;
		};
	};

	// b1e1 x b2e3
	if ( absBox2ToBox1[M_02] < 0.999 )
	{
		boxProjectionSum =
			box1Size.y * absBox2ToBox1[M_22] + box1Size.z * absBox2ToBox1[M_12] +
			box2Size.x * absBox2ToBox1[M_01] + box2Size.y * absBox2ToBox1[M_00];
		originProjection = fabs( -box2Origin.y * box2ToBox1[M_22] + box2Origin.z * box2ToBox1[M_12] ) + tolerance;
		if ( originProjection > boxProjectionSum )
		{
			MatrixGetColumn( box2ToWorld, 2, pNormalOut );
			local v = Vector( worldToBox1[M_00], worldToBox1[M_01], worldToBox1[M_02] ).Cross(pNormalOut);
			pNormalOut.x = v.x;
			pNormalOut.y = v.y;
			pNormalOut.z = v.z;
			return true;
		};
	};

	// b1e2 x b2e1
	if ( absBox2ToBox1[M_10] < 0.999 )
	{
		boxProjectionSum =
			box1Size.x * absBox2ToBox1[M_20] + box1Size.z * absBox2ToBox1[M_00] +
			box2Size.y * absBox2ToBox1[M_12] + box2Size.z * absBox2ToBox1[M_11];
		originProjection = fabs( box2Origin.x * box2ToBox1[M_20] - box2Origin.z * box2ToBox1[M_00] ) + tolerance;
		if ( originProjection > boxProjectionSum )
		{
			MatrixGetColumn( box2ToWorld, 0, pNormalOut );
			local v = Vector( worldToBox1[M_10], worldToBox1[M_11], worldToBox1[M_12] ).Cross(pNormalOut);
			pNormalOut.x = v.x;
			pNormalOut.y = v.y;
			pNormalOut.z = v.z;
			return true;
		};
	};

	// b1e2 x b2e2
	if ( absBox2ToBox1[M_11] < 0.999 )
	{
		boxProjectionSum =
			box1Size.x * absBox2ToBox1[M_21] + box1Size.z * absBox2ToBox1[M_01] +
			box2Size.x * absBox2ToBox1[M_12] + box2Size.z * absBox2ToBox1[M_10];
		originProjection = fabs( box2Origin.x * box2ToBox1[M_21] - box2Origin.z * box2ToBox1[M_01] ) + tolerance;
		if ( originProjection > boxProjectionSum )
		{
			MatrixGetColumn( box2ToWorld, 1, pNormalOut );
			local v = Vector( worldToBox1[M_10], worldToBox1[M_11], worldToBox1[M_12] ).Cross(pNormalOut);
			pNormalOut.x = v.x;
			pNormalOut.y = v.y;
			pNormalOut.z = v.z;
			return true;
		};
	};

	// b1e2 x b2e3
	if ( absBox2ToBox1[M_12] < 0.999 )
	{
		boxProjectionSum =
			box1Size.x * absBox2ToBox1[M_22] + box1Size.z * absBox2ToBox1[M_02] +
			box2Size.x * absBox2ToBox1[M_11] + box2Size.y * absBox2ToBox1[M_10];
		originProjection = fabs( box2Origin.x * box2ToBox1[M_22] - box2Origin.z * box2ToBox1[M_02] ) + tolerance;
		if ( originProjection > boxProjectionSum )
		{
			MatrixGetColumn( box2ToWorld, 2, pNormalOut );
			local v = Vector( worldToBox1[M_10], worldToBox1[M_11], worldToBox1[M_12] ).Cross(pNormalOut);
			pNormalOut.x = v.x;
			pNormalOut.y = v.y;
			pNormalOut.z = v.z;
			return true;
		};
	};

	// b1e3 x b2e1
	if ( absBox2ToBox1[M_20] < 0.999 )
	{
		boxProjectionSum =
			box1Size.x * absBox2ToBox1[M_10] + box1Size.y * absBox2ToBox1[M_00] +
			box2Size.y * absBox2ToBox1[M_22] + box2Size.z * absBox2ToBox1[M_21];
		originProjection = fabs( -box2Origin.x * box2ToBox1[M_10] + box2Origin.y * box2ToBox1[M_00] ) + tolerance;
		if ( originProjection > boxProjectionSum )
		{
			MatrixGetColumn( box2ToWorld, 0, pNormalOut );
			local v = Vector( worldToBox1[M_20], worldToBox1[M_21], worldToBox1[M_22] ).Cross(pNormalOut);
			pNormalOut.x = v.x;
			pNormalOut.y = v.y;
			pNormalOut.z = v.z;
			return true;
		};
	};

	// b1e3 x b2e2
	if ( absBox2ToBox1[M_21] < 0.999 )
	{
		boxProjectionSum =
			box1Size.x * absBox2ToBox1[M_11] + box1Size.y * absBox2ToBox1[M_01] +
			box2Size.x * absBox2ToBox1[M_22] + box2Size.z * absBox2ToBox1[M_20];
		originProjection = fabs( -box2Origin.x * box2ToBox1[M_11] + box2Origin.y * box2ToBox1[M_01] ) + tolerance;
		if ( originProjection > boxProjectionSum )
		{
			MatrixGetColumn( box2ToWorld, 1, pNormalOut );
			local v = Vector( worldToBox1[M_20], worldToBox1[M_21], worldToBox1[M_22] ).Cross(pNormalOut);
			pNormalOut.x = v.x;
			pNormalOut.y = v.y;
			pNormalOut.z = v.z;
			return true;
		};
	};

	// b1e3 x b2e3
	if ( absBox2ToBox1[M_22] < 0.999 )
	{
		boxProjectionSum =
			box1Size.x * absBox2ToBox1[M_12] + box1Size.y * absBox2ToBox1[M_02] +
			box2Size.x * absBox2ToBox1[M_21] + box2Size.y * absBox2ToBox1[M_20];
		originProjection = fabs( -box2Origin.x * box2ToBox1[M_12] + box2Origin.y * box2ToBox1[M_02] ) + tolerance;
		if ( originProjection > boxProjectionSum )
		{
			MatrixGetColumn( box2ToWorld, 2, pNormalOut );
			local v = Vector( worldToBox1[M_20], worldToBox1[M_21], worldToBox1[M_22] ).Cross(pNormalOut);
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
// Returns true if there's an intersection between two OBBs
//-----------------------------------------------------------------------------
function VS::IsOBBIntersectingOBB( org1, ang1, min1, max1, org2, ang2, min2, max2, tolerance )
	: (matrix3x4_t)
{
	local worldToBox1 = matrix3x4_t(), box2ToWorld = matrix3x4_t();

	ComputeCenterIMatrix( org1, ang1, min1, max1, worldToBox1 );
	ComputeCenterMatrix( org2, ang2, min2, max2, box2ToWorld );

	local box1Size = (max1 - min1) * 0.5;
	local box2Size = (max2 - min2) * 0.5;

	return !ComputeSeparatingPlane( worldToBox1, box2ToWorld, box1Size, box2Size, tolerance );
}

//=============================================================================
//=============================================================================
{
// Place in VS if this is mapbase, in root if not.
local v = getroottable();
if ( "_versionnumber_" in v && v._versionnumber_ >= 300 )
	v = VS;

v.Quaternion <- Quaternion;
v.matrix3x4_t <- matrix3x4_t;
v.VMatrix <- VMatrix;
v.Ray_t <- Ray_t;
v.trace_t <- trace_t;
}
//=============================================================================
//=============================================================================
