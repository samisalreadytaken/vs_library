//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//
//                       github.com/samisalreadytaken
//
// This project is licensed under the terms of the MIT License.
// See <README.md> or <LICENSE> for details.
//-----------------------------------------------------------------------
//
// For advanced math, see 'vs_library/vs_math2'
//
//-----------------------------------------------------------------------

// deprecated, use <RAD2DEG*> in expensive calculations instead
::toRad <- function( deg ){ return deg * DEG2RAD; } // ( deg * PI / 180.0 )
::toDeg <- function( rad ){ return rad * RAD2DEG; } // ( rad * 180 / PI )

::max <- function( a, b ){ return a > b ? a : b; }
::min <- function( a, b ){ return a < b ? a : b; }

::clamp <- function( v, lo, hi )
{
	if( hi < lo )
	{
		local t = hi;
		hi = lo;
		lo = t;
	};
	return (v < lo) ? lo : (hi < v) ? hi : v;
}

// VS.IsInteger(1.0) is true
// VS.IsInteger(1.1) is false
function VS::IsInteger( f ){ return::floor(f) == f; }

//-----------------------------------------------------------------------
// IsLookingAt with tolerance
// cosTolerance [-1..1]
//-----------------------------------------------------------------------
function VS::IsLookingAt( vSrc, vTarget, vDir, cosTolerance )
{
	local to = vTarget - vSrc;
	to.Norm();
	return to.Dot( vDir ) >= cosTolerance;
}

function VS::PointOnLineNearestPoint( vStartPos, vEndPos, vPoint )
{
	local v1 = vEndPos - vStartPos,
	      dist = v1.Dot(vPoint - vStartPos) / v1.LengthSqr();

	if     ( dist < 0 ) return vStartPos;
	else if( dist > 1 ) return vEndPos;
	else                return vStartPos + v1 * dist;;
}

//-----------------------------------------------------------------------
// Angle between 2 vectors
// return QAngle
//-----------------------------------------------------------------------
function VS::GetAngle( vFrom, vTo )
{
	local d     = vFrom - vTo,
	      pitch = ::RAD2DEG*::atan2( d.z, d.Length2D() ),
	      yaw   = ::RAD2DEG*(::atan2( d.y, d.x ) + ::PI);

	return::Vector(pitch,yaw,0);
}

//-----------------------------------------------------------------------
// Angle (yaw) between 2 vectors
// return yaw
// cheaper than the other method
//-----------------------------------------------------------------------
function VS::GetAngle2D( vFrom, vTo )
{
	local d   = vTo - vFrom,
	      yaw = ::RAD2DEG*::atan2( d.y, d.x );

	return yaw;
}

//-----------------------------------------------------------------------
//
//-----------------------------------------------------------------------
function VS::VectorVectors( forward, right, up )
{
	if( forward.x == 0 && forward.y == 0 )
	{
		// pitch 90 degrees up/down from identity
		right.x = 0;
		right.y = -1;
		right.z = 0;
		up.x = -forward.z;
		up.y = 0;
		up.z = 0;
	}
	else
	{
		local R = forward.Cross(::Vector(0,0,1));
		right.x = R.x; right.y = R.y; right.z = R.z;
		right.Norm();

		local U = right.Cross(forward);
		up.x = U.x; up.y = U.y; up.z = U.z;
		up.Norm();
	};
}

//-----------------------------------------------------------------------
// Euler QAngle -> Basis Vectors.  Each vector is optional
// input vector pointers
//-----------------------------------------------------------------------
function VS::AngleVectors( vAng, vFwd = _VEC, vRg = null, vUp = null )
{
	local sr, cr, rr,

	      yr = ::DEG2RAD*vAng.y,
	      sy = ::sin(yr),
	      cy = ::cos(yr),

	      pr = ::DEG2RAD*vAng.x,
	      sp = ::sin(pr),
	      cp = ::cos(pr);

	if( vAng.z )
	{
		rr = ::DEG2RAD*vAng.z;
		sr = ::sin(rr);
		cr = ::cos(rr);
	}
	else
	{
		sr = 0.0;
		cr = 1.0;
	};

	if( vFwd )
	{
		vFwd.x = cp*cy;
		vFwd.y = cp*sy;
		vFwd.z = -sp;
	};

	if( vRg )
	{
		vRg.x = (-1*sr*sp*cy+-1*cr*-sy);
		vRg.y = (-1*sr*sp*sy+-1*cr*cy);
		vRg.z = -1*sr*cp;
	};

	if( vUp )
	{
		vUp.x = (cr*sp*cy+-sr*-sy);
		vUp.y = (cr*sp*sy+-sr*cy);
		vUp.z = cr*cp;
	};

	return vFwd;
}

//-----------------------------------------------------------------------
// Forward direction vector -> Euler QAngle
//-----------------------------------------------------------------------
function VS::VectorAngles( vFwd )
{
	local tmp, yaw, pitch;

	if( vFwd.y == 0 && vFwd.x == 0 )
	{
		yaw = 0;
		if( vFwd.z > 0 )
			pitch = 270;
		else
			pitch = 90;
	}
	else
	{
		yaw = ::RAD2DEG*::atan2(vFwd.y, vFwd.x);
		if( yaw < 0 )
			yaw += 360;

		tmp = ::sqrt(vFwd.x*vFwd.x + vFwd.y*vFwd.y);
		pitch = ::RAD2DEG*::atan2(-vFwd.z, tmp);
		if( pitch < 0 )
			pitch += 360;
	};

	return::Vector(pitch,yaw,0);
}

//-----------------------------------------------------------------------
// Rotate a vector around the Z axis (YAW)
//-----------------------------------------------------------------------
function VS::VectorYawRotate( vIn, fYaw, vOut = _VEC )
{
	local rad = ::DEG2RAD*fYaw,
	      sy  = ::sin(rad),
	      cy  = ::cos(rad);

	vOut.x = vIn.x * cy - vIn.y * sy;
	vOut.y = vIn.x * sy + vIn.y * cy;
	vOut.z = vIn.z;

	return vOut;
}

function VS::YawToVector( yaw )
{
	local ang = ::DEG2RAD*yaw;
	return::Vector( ::cos(ang), ::sin(ang), 0 );
}

function VS::VecToYaw( vec )
{
	if( vec.y == 0 && vec.x == 0 )
		return 0;

	local yaw = ::RAD2DEG*::atan2(vec.y, vec.x);

	if( yaw < 0 )
		yaw += 360;

	return yaw;
}

function VS::VecToPitch( vec )
{
	if( vec.y == 0 && vec.x == 0 )
	{
		if( vec.z < 0 )
			return 180.0;
		else
			return -180.0;
	};

	return::RAD2DEG*::atan2(-vec.z, vec.Length2D());
}

function VS::VectorIsZero(v)
{
	return v.x == v.y && v.y == v.z && v.z == 0;
}

//-----------------------------------------------------------------------
// Vector equality with tolerance
//-----------------------------------------------------------------------
function VS::VectorsAreEqual( a, b, tolerance = 0.0 )
{
	return ( ::fabs(a.x - b.x) <= tolerance &&
	         ::fabs(a.y - b.y) <= tolerance &&
	         ::fabs(a.z - b.z) <= tolerance );
}

//-----------------------------------------------------------------------
// Angle equality with tolerance
//-----------------------------------------------------------------------
function VS::AnglesAreEqual( a, b, tolerance = 0.0 )
{
	return ::fabs(AngleDiff(a, b)) <= tolerance;
}

//-----------------------------------------------------------------------
// Equality with tolerance
//-----------------------------------------------------------------------
function VS::CloseEnough( a, b, e )
{
	return ::fabs(a - b) <= e;
}

function VS::Approach( target, value, speed )
{
	local delta = target - value;

	if( delta > speed )
		value += speed;
	else if( delta < (-speed) )
		value -= speed;
	else
		value = target;;

	return value;
}

function VS::ApproachAngle( target, value, speed )
{
	target = AngleNormalize( target );
	value = AngleNormalize( value );

	local delta = AngleDiff( target, value );

	speed = ::fabs(speed);

	if( delta > speed )
		value += speed;
	else if( delta < (-speed) )
		value -= speed;
	else
		value = target;;

	return value;
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

	if( angle > 180 )
		angle -= 360;
	else if( angle < (-180) )
		angle += 360;;

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
function VS::SnapDirectionToAxis( vDirection, epsilon = 0.1 )
{
	local proj = 1 - epsilon;

	if( ::fabs(v.x) > proj )
	{
		if( vDirection.x < 0 )
			vDirection.x = -1.0;
		else
			vDirection.x = 1.0;
		vDirection.y = 0;
		vDirection.z = 0;

		return vDirection;
	};

	if( ::fabs(v.y) > proj )
	{
		if( vDirection.y < 0 )
			vDirection.y = -1.0;
		else
			vDirection.y = 1.0;
		vDirection.z = 0;
		vDirection.x = 0;

		return vDirection;
	};

	if( ::fabs(v.z) > proj )
	{
		if( vDirection.z < 0 )
			vDirection.z = -1.0;
		else
			vDirection.z = 1.0;
		vDirection.x = 0;
		vDirection.y = 0;

		return vDirection;
	};
}

//-----------------------------------------------------------------------------
// Distance between 2 vectors
//-----------------------------------------------------------------------------
function VS::Dist( v1, v2 )
{
	return ( v1 - v2 ).Length();
}

//-----------------------------------------------------------------------------
// Use for comparisons, cheaper than getting actual length
//-----------------------------------------------------------------------------
function VS::DistSqr( v1, v2 )
{
	return ( v1 - v2 ).LengthSqr();
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
	o.x = ::min(a.x,b.x);
	o.y = ::min(a.y,b.y);
	o.z = ::min(a.z,b.z);

	return o;
}

function VS::VectorMax( a, b, o = _VEC )
{
	o.x = ::max(a.x,b.x);
	o.y = ::max(a.y,b.y);
	o.z = ::max(a.z,b.z);

	return o;
}

// input vector pointer
function VS::VectorAbs( v )
{
	v.x = ::fabs(v.x);
	v.y = ::fabs(v.y);
	v.z = ::fabs(v.z);
	return v;
}

// Vector a + Vector b
function VS::VectorAdd( a, b, o = _VEC )
{
	o.x = a.x + b.x;
	o.y = a.y + b.y;
	o.z = a.z + b.z;

	return o;
}

// Vector a - Vector b
function VS::VectorSubtract( a, b, o = _VEC )
{
	o.x = a.x - b.x;
	o.y = a.y - b.y;
	o.z = a.z - b.z;

	return o;
}

// scalar
// Vector a * b
function VS::VectorMultiply( a, b, o = _VEC )
{
	o.x = a.x * b;
	o.y = a.y * b;
	o.z = a.z * b;

	return o;
}

// Vector a * Vector b
function VS::VectorMultiply2( a, b, o = _VEC )
{
	o.x = a.x*b.x;
	o.y = a.y*b.y;
	o.z = a.z*b.z;

	return o;
}

// Vector a / b
function VS::VectorDivide( a, b, o = _VEC )
{
	local d = 1.0/b;

	o.x = a.x*d;
	o.y = a.y*d;
	o.z = a.z*d;

	return o;
}

// Vector a / Vector b
function VS::VectorDivide2( a, b, o = _VEC )
{
	o.x = a.x/b.x;
	o.y = a.y/b.y;
	o.z = a.z/b.z;

	return o;
}

function VS::ComputeVolume( vecMins, vecMaxs )
{
	local vecDelta = vecMaxs - vecMins;
	return vecDelta.Dot( vecDelta );
}

//-----------------------------------------------------------------------------
// Get a random vector
//-----------------------------------------------------------------------------
function VS::RandomVector( minVal = -RAND_MAX, maxVal = RAND_MAX )
{
	return::Vector( ::RandomFloat( minVal, maxVal ), ::RandomFloat( minVal, maxVal ), ::RandomFloat( minVal, maxVal ) );
}

// For predetermined values, multiply the value yourself, instead of making the calculation in runtime
function VS::IsLengthGreaterThan( vec, val )
{
	return vec.LengthSqr() > val * val;
}

function VS::IsLengthLessThan( vec, val )
{
	return vec.LengthSqr() < val * val;
}

function VS::CalcSqrDistanceToAABB( mins, maxs, point )
{
	local flDelta, flDistSqr = 0.0;

	if( point.x < mins.x )
	{
		flDelta = (mins.x - point.x);
		flDistSqr += flDelta * flDelta;
	}
	else if( point.x > maxs.x )
	{
		flDelta = (point.x - maxs.x);
		flDistSqr += flDelta * flDelta;
	};;

	if( point.y < mins.y )
	{
		flDelta = (mins.y - point.y);
		flDistSqr += flDelta * flDelta;
	}
	else if( point.y > maxs.y )
	{
		flDelta = (point.y - maxs.y);
		flDistSqr += flDelta * flDelta;
	};;

	if( point.z < mins.z )
	{
		flDelta = (mins.z - point.z);
		flDistSqr += flDelta * flDelta;
	}
	else if( point.z > maxs.z )
	{
		flDelta = (point.z - maxs.z);
		flDistSqr += flDelta * flDelta;
	};;

	return flDistSqr;
}

function VS::CalcClosestPointOnAABB( mins, maxs, point, closestOut = _VEC )
{
	closestOut.x = ::clamp( point.x, mins.x, maxs.x );
	closestOut.y = ::clamp( point.y, mins.y, maxs.y );
	closestOut.z = ::clamp( point.z, mins.z, maxs.z );

	return closestOut;
}

//-----------------------------------------------------------------------
//
// For advanced interpolation methods, see 'vs_library/vs_interp'
//
//-----------------------------------------------------------------------

// decayTo is factor the value should decay to in decayTime
function VS::ExponentialDecay( decayTo, decayTime, dt )
{
	return::exp( ::log(decayTo) / decayTime * dt );
}

// halflife is time for value to reach 50%
function VS::ExponentialDecay2( halflife, dt )
{
	// log(0.5) == -0.69314718055994530941723212145818
	return::exp( -0.69314718 / halflife * dt );
}

// Get the integrated distanced traveled
// decayTo is factor the value should decay to in decayTime
// dt is the time relative to the last velocity update
function VS::ExponentialDecayIntegral( decayTo, decayTime, dt )
{
	return (::pow(decayTo, dt / decayTime) * decayTime - decayTime) / ::log(decayTo);
}

// hermite basis function for smooth interpolation
// very cheap to call
// value should be between 0 & 1 inclusive
function VS::SimpleSpline( value )
{
	local valueSquared = value * value;

	// Nice little ease-in, ease-out spline-like curve
	return ( 3 * valueSquared - 2 * valueSquared * value );
}

// remaps a value in [startInterval, startInterval+rangeInterval] from linear to
// spline using SimpleSpline
function VS::SimpleSplineRemapVal( val, A, B, C, D )
{
	if( A == B ) return val >= B ? D : C;
	local cVal = (val - A) / (B - A);
	return C + (D - C) * SimpleSpline( cVal );
}

// remaps a value in [startInterval, startInterval+rangeInterval] from linear to
// spline using SimpleSpline
function VS::SimpleSplineRemapValClamped( val, A, B, C, D )
{
	if( A == B ) return val >= B ? D : C;
	local cVal = (val - A) / (B - A);
	cVal = ::clamp( cVal, 0.0, 1.0 );
	return C + (D - C) * SimpleSpline( cVal );
}

// Remap a value in the range [A,B] to [C,D].
function VS::RemapVal( val, A, B, C, D )
{
	if( A == B ) return val >= B ? D : C;
	return C + (D - C) * (val - A) / (B - A);
}

function VS::RemapValClamped( val, A, B, C, D )
{
	if( A == B ) return val >= B ? D : C;
	local cVal = (val - A) / (B - A);
	cVal = ::clamp( cVal, 0.0, 1.0 );
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
function VS::Bias( x, biasAmt )
{
	local lastAmt = -1,
	      lastExponent = 0;
	if( lastAmt != biasAmt )
		lastExponent = ::log(biasAmt) * -1.4427; // (-1.4427 = 1 / log(0.5))
	return::pow(x, lastExponent);
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
function VS::Gain( x, biasAmt )
{
	if( x < 0.5 )
		return 0.5 * Bias( 2*x, 1-biasAmt );
	else
		return 1 - 0.5 * Bias( 2 - 2*x, 1-biasAmt );
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
function VS::SmoothCurve( x )
{
	return (1 - ::cos(x * ::PI)) * 0.5;
}

function VS::MovePeak( x, flPeakPos )
{
	if( x < flPeakPos )
		return x * 0.5 / flPeakPos;
	else
		return 0.5 + 0.5 * (x - flPeakPos) / (1 - flPeakPos);
}

// This works like SmoothCurve, with two changes:
//
// 1. Instead of the curve peaking at 0.5, it will peak at flPeakPos.
//    (So if you specify flPeakPos=0.2, then the peak will slide to the left).
//
// 2. flPeakSharpness is a 0-1 value controlling the sharpness of the peak.
//    Low values blunt the peak and high values sharpen the peak.
function VS::SmoothCurve_Tweak( x, flPeakPos, flPeakSharpness )
{
	local flMovedPeak = MovePeak( x, flPeakPos );
	local flSharpened = Gain( flMovedPeak, flPeakSharpness );
	return SmoothCurve( flSharpened );
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
	o.x = Lerp( v1.x, v2.x, f );
	o.y = Lerp( v1.y, v2.y, f );
	o.z = Lerp( v1.z, v2.z, f );

	return o;
}

//-----------------------------------------------------------------------
//
// For advanced collision methods, see 'vs_library/vs_collision'
//
//-----------------------------------------------------------------------

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
	if( ( boxMin1.x > boxMax2.x ) || ( boxMax1.x < boxMin2.x ) ) return false;
	if( ( boxMin1.y > boxMax2.y ) || ( boxMax1.y < boxMin2.y ) ) return false;
	if( ( boxMin1.z > boxMax2.z ) || ( boxMax1.z < boxMin2.z ) ) return false;
	return true;
}
