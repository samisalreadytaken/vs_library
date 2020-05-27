//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//
//                       github.com/samisalreadytaken
//
// This project is licensed under the terms of the MIT License.
// See <README.md> or <LICENSE> for details.
//-----------------------------------------------------------------------
//
// Collision detection. Mostly sourced from the Source Engine
//
// Ray traces need to be initialised with trace.Ray()
//
// Not included in 'vs_library.nut'
//
//-----------------------------------------------------------------------

IncludeScript("vs_library/vs_math2");

//-----------------------------------------------------------------------------
// Clears the trace
//-----------------------------------------------------------------------------
function VS::Collision_ClearTrace( vecRayStart, vecRayDelta, pTrace )
{
	pTrace.startpos = vecRayStart;
	pTrace.endpos = vecRayStart;
	pTrace.endpos += vecRayDelta;
	pTrace.fraction = 1.0;
}

//-----------------------------------------------------------------------------
// Compute the offset in t along the ray that we'll use for the collision
//-----------------------------------------------------------------------------
function VS::ComputeBoxOffset( ray )
{
	if( ray.m_IsRay )
		return 1.e-3;

	// Find the projection of the box diagonal along the ray...
	local offset = ::fabs(ray.m_Extents.x * ray.m_Delta.x) +
	               ::fabs(ray.m_Extents.y * ray.m_Delta.y) +
	               ::fabs(ray.m_Extents.z * ray.m_Delta.z);

	// We need to divide twice: Once to normalize the computation above
	// so we get something in units of extents, and the second to normalize
	// that with respect to the entire raycast.
	offset *= InvRSquared( ray.m_Delta );

	// 1e-3 is an epsilon
	return offset + 1.e-3;
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

	if( dot < cosAngle )
		return false;
	if( dist * dot > length )
		return false;

	return true;
}

//-----------------------------------------------------------------------------
// Returns true if a box intersects with a sphere
//-----------------------------------------------------------------------------
function VS::IsSphereIntersectingSphere( center1, radius1, center2, radius2 )
{
	local delta = center2 - center1;
	local distSq = delta.LengthSqr();
	local radiusSum = radius1 + radius2;
	return (distSq <= (radiusSum * radiusSum));
}

//-----------------------------------------------------------------------------
// Returns true if a box intersects with a sphere
//-----------------------------------------------------------------------------
function VS::IsBoxIntersectingSphere( boxMin, boxMax, center, radius )
{
	// See Graphics Gems, box-sphere intersection
	local flDelta,
	      dmin = 0.0;

	if(center.x < boxMin.x)
	{
		flDelta = center.x - boxMin.x;
		dmin += flDelta * flDelta;
	}
	else if(center.x > boxMax.x)
	{
		flDelta = boxMax.x - center.x;
		dmin += flDelta * flDelta;
	};;

	if(center.y < boxMin.y)
	{
		flDelta = center.y - boxMin.y;
		dmin += flDelta * flDelta;
	}
	else if(center.y > boxMax.y)
	{
		flDelta = boxMax.y - center.y;
		dmin += flDelta * flDelta;
	};;

	if(center.z < boxMin.z)
	{
		flDelta = center.z - boxMin.z;
		dmin += flDelta * flDelta;
	}
	else if(center.z > boxMax.z)
	{
		flDelta = boxMax.z - center.z;
		dmin += flDelta * flDelta;
	};;

	return dmin < radius * radius;
}

//-----------------------------------------------------------------------------
// Returns true if a rectangle intersects with a circle
//-----------------------------------------------------------------------------
function VS::IsCircleIntersectingRectangle( boxMin, boxMax, center, radius )
{
	// See Graphics Gems, box-sphere intersection
	local flDelta,
	      dmin = 0.0;

	if( center.x < boxMin.x )
	{
		flDelta = center.x - boxMin.x;
		dmin += flDelta * flDelta;
	}
	else if( center.x > boxMax.x )
	{
		flDelta = boxMax.x - center.x;
		dmin += flDelta * flDelta;
	};;

	if( center.y < boxMin.y )
	{
		flDelta = center.y - boxMin.y;
		dmin += flDelta * flDelta;
	}
	else if( center.y > boxMax.y )
	{
		flDelta = boxMax.y - center.y;
		dmin += flDelta * flDelta;
	};;

	return dmin < radius * radius;
}

//-----------------------------------------------------------------------------
// returns true if there's an intersection between ray and sphere
// flTolerance [0..1]
//-----------------------------------------------------------------------------
function VS::IsRayIntersectingSphere( vecRayOrigin, vecRayDelta, vecCenter, flRadius, flTolerance )
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
	if( flNumerator <= 0.0 )
	{
		t = 0.0;
	}
	else
	{
		local flDenominator = vecRayDelta.Dot( vecRayDelta );
		if( flNumerator > flDenominator )
			t = 1.0;
		else
			t = flNumerator / flDenominator;
	};

	local vecClosestPoint = VectorMA( vecRayOrigin, t, vecRayDelta );
	return ( DistSqr( vecClosestPoint, vecCenter ) <= flRadius * flRadius );
}

//-----------------------------------------------------------------------------
// Intersects a ray with a AABB, return true if they intersect
// Input  : localMins, localMaxs
//-----------------------------------------------------------------------------
function VS::IsBoxIntersectingRay( origin, vecBoxMin, vecBoxMax, ray, flTolerance = 0.0 )
{
	if( !ray.m_IsSwept )
	{
		local rayMins = ray.m_Start - ray.m_Extents;
		local rayMaxs = ray.m_Start + ray.m_Extents;
		if( flTolerance )
		{
			rayMins.x -= flTolerance; rayMins.y -= flTolerance; rayMins.z -= flTolerance;
			rayMaxs.x += flTolerance; rayMaxs.y += flTolerance; rayMaxs.z += flTolerance;
		};
		return IsBoxIntersectingBox( vecBoxMin, vecBoxMax, rayMins, rayMaxs );
	};

	// world
	local vecExpandedBoxMin = vecBoxMin - ray.m_Extents + origin;
	local vecExpandedBoxMax = vecBoxMax + ray.m_Extents + origin;

	return IsBoxIntersectingRay2( vecExpandedBoxMin, vecExpandedBoxMax, ray.m_Start, ray.m_Delta, flTolerance );
}

//-----------------------------------------------------------------------------
// Intersects a ray with a AABB, return true if they intersect
// Input  : worldMins, worldMaxs
//-----------------------------------------------------------------------------
function VS::IsBoxIntersectingRay2( boxMin, boxMax, origin, vecDelta, flTolerance )
{
	// Assert( boxMin.x <= boxMax.x );
	// Assert( boxMin.y <= boxMax.y );
	// Assert( boxMin.z <= boxMax.z );

	// FIXME: Surely there's a faster way
	local tmin = FLT_MIN,
	      tmax = FLT_MAX;

	// Parallel case...
	if( ::fabs(vecDelta.x) < 1.e-8 )
	{
		// Check that origin is in the box
		// if not, then it doesn't intersect..
		if( (origin.x < boxMin.x - flTolerance) || (origin.x > boxMax.x + flTolerance) )
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
		if( t1 > t2 )
		{
			local temp = t1;
			t1 = t2;
			t2 = temp;
		};
		if(t1 > tmin)
			tmin = t1;
		if(t2 < tmax)
			tmax = t2;
		if(tmin > tmax)
			return false;
		if(tmax < 0)
			return false;
		if(tmin > 1)
			return false;
	};

	// other points:
	if( ::fabs(vecDelta.y) < 1.e-8 )
	{
		if( (origin.y < boxMin.y - flTolerance) || (origin.y > boxMax.y + flTolerance) )
			return false;
	}
	else
	{
		local invDelta = 1.0 / vecDelta.y;
		local t1 = (boxMin.y - flTolerance - origin.y) * invDelta;
		local t2 = (boxMax.y + flTolerance - origin.y) * invDelta;
		if( t1 > t2 )
		{
			local temp = t1;
			t1 = t2;
			t2 = temp;
		};
		if(t1 > tmin)
			tmin = t1;
		if(t2 < tmax)
			tmax = t2;
		if(tmin > tmax)
			return false;
		if(tmax < 0)
			return false;
		if(tmin > 1)
			return false;
	};

	if( ::fabs(vecDelta.z) < 1.e-8 )
	{
		if( (origin.z < boxMin.z - flTolerance) || (origin.z > boxMax.z + flTolerance) )
			return false;
	}
	else
	{
		local invDelta = 1.0 / vecDelta.z;
		local t1 = (boxMin.z - flTolerance - origin.z) * invDelta;
		local t2 = (boxMax.z + flTolerance - origin.z) * invDelta;
		if( t1 > t2 )
		{
			local temp = t1;
			t1 = t2;
			t2 = temp;
		};
		if(t1 > tmin)
			tmin = t1;
		if(t2 < tmax)
			tmax = t2;
		if(tmin > tmax)
			return false;
		if(tmax < 0)
			return false;
		if(tmin > 1)
			return false;
	};

	return true;
}

//-----------------------------------------------------------------------------
// Intersects a ray with a ray, return true if they intersect
// t, s = parameters of closest approach (if not intersecting!)
//-----------------------------------------------------------------------------
function VS::IntersectRayWithRay( ray0, ray1 )
{
	Assert( ray0.m_IsRay && ray1.m_IsRay );
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
	local v0 = ray0.m_Delta;
	local v1 = ray1.m_Delta;
	v0.Norm();
	v1.Norm();

	local v0xv1 = v0.Cross( v1 );
	local lengthSq = v0xv1.LengthSqr();
	if( lengthSq == 0.0 )
	{
		// t = 0; s = 0;
		return false;		// parallel
	};

	local p1p0 = ray1.m_Start - ray0.m_Start;

	local AxC = p1p0.Cross( v0xv1 );
	VectorNegate(AxC);
	local detT = AxC.Dot( v1 );

	AxC = p1p0.Cross( v0xv1 );
	VectorNegate(AxC);
	local detS = AxC.Dot( v0 );

	local t = detT / lengthSq;
	local s = detS / lengthSq;

	// intersection????
	local i0 = v0 * t;
	local i1 = v1 * s;
	i0 += ray0.m_Start;
	i1 += ray1.m_Start;
	if( i0.x == i1.x && i0.y == i1.y && i0.z == i1.z )
		return true;

	return false;
}

// FIXME
//-----------------------------------------------------------------------------
// Swept OBB test
// Input  : localMins, localMaxs
//-----------------------------------------------------------------------------
function VS::IsRayIntersectingOBB( ray, org, angles, mins, maxs, flTolerance )
{
	if( VectorIsZero(angles) )
	{
		local vecWorldMins = org + mins;
		local vecWorldMaxs = org + maxs;
		return IsBoxIntersectingRay2( vecWorldMins, vecWorldMaxs, ray.m_Start, ray.m_Delta, flTolerance );
	};

	if( ray.m_IsRay )
	{
		local worldToBox = ::matrix3x4();
		AngleIMatrix( angles, org, worldToBox );

		local rotatedRay = TraceLine().Ray();
		rotatedRay.m_Start = VectorTransform( ray.m_Start, worldToBox, ::Vector() );
		rotatedRay.m_Delta = VectorRotate( ray.m_Delta, worldToBox, ::Vector() );
		rotatedRay.m_StartOffset = ::Vector();
		rotatedRay.m_Extents = ::Vector();
		rotatedRay.m_IsRay = ray.m_IsRay;
		rotatedRay.m_IsSwept = ray.m_IsSwept;

		return IsBoxIntersectingRay( rotatedRay.m_Start, mins, maxs, rotatedRay, flTolerance );
	};

	if( !ray.m_IsSwept )
	{
		return ComputeSeparatingPlane2( ray.m_Start, ::Vector(), -ray.m_Extents, ray.m_Extents,
			org, angles, mins, maxs, 0.0 ) == false;
	};

	// NOTE: See the comments in ComputeSeparatingPlane to understand this math

	// First, compute the basis of box in the space of the ray
	// NOTE: These basis place the origin at the centroid of each box!
	local worldToBox1 = ::matrix3x4(),
	      box2ToWorld = ::matrix3x4();
	ComputeCenterMatrix( org, angles, mins, maxs, box2ToWorld );

	// Find the center + extents of an AABB surrounding the ray
	local vecRayCenter = VectorMA( ray.m_Start, 0.5, ray.m_Delta ) * -1.0;

	SetIdentityMatrix( worldToBox1 );
	MatrixSetColumn( vecRayCenter, 3, worldToBox1 );

	local box1Size = ::Vector( ray.m_Extents.x + ::fabs( ray.m_Delta.x ) * 0.5,
	                           ray.m_Extents.y + ::fabs( ray.m_Delta.y ) * 0.5,
	                           ray.m_Extents.z + ::fabs( ray.m_Delta.z ) * 0.5 );

	// Then compute the size of the box
	local box2Size = (maxs - mins)*0.5;

	// Do an OBB test of the box with the AABB surrounding the ray
	if( ComputeSeparatingPlane( worldToBox1, box2ToWorld, box1Size, box2Size, 0.0, ::Vector() ) )
		return false;

	// Now deal with the planes which are the cross products of the ray sweep direction vs box edges
	local vecRayDirection = VectorCopy(ray.m_Delta,::Vector());
	VectorNormalize( vecRayDirection );

	// Need a vector between ray center vs box center measured in the space of the ray (world)
	local vecCenterDelta = ::Vector( box2ToWorld[0][3] - ray.m_Start.x,
	                                 box2ToWorld[1][3] - ray.m_Start.y,
	                                 box2ToWorld[2][3] - ray.m_Start.z );

	// Rotate the ray direction into the space of the OBB
	local vecAbsRayDirBox2 = VectorIRotate( vecRayDirection, box2ToWorld, ::Vector() );

	// Make abs versions of the ray in world space + ray in box2 space
	VectorAbs( vecAbsRayDirBox2 );

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
	vecPlaneNormal = vecRayDirection.Cross( ::Vector( box2ToWorld[0][0], box2ToWorld[1][0], box2ToWorld[2][0] ) );
	flCenterDeltaProjection = ::fabs( vecPlaneNormal.Dot(vecCenterDelta) );
	flBoxProjectionSum =
		vecAbsRayDirBox2.z * box2Size.y + vecAbsRayDirBox2.y * box2Size.z +
		DotProductAbs( vecPlaneNormal, ray.m_Extents );
	if( (flCenterDeltaProjection) > (flBoxProjectionSum) )
		return false;

	// box y x ray delta
	vecPlaneNormal = vecRayDirection.Cross( ::Vector( box2ToWorld[0][1], box2ToWorld[1][1], box2ToWorld[2][1] ) );
	flCenterDeltaProjection = ::fabs( vecPlaneNormal.Dot(vecCenterDelta) );
	flBoxProjectionSum =
		vecAbsRayDirBox2.z * box2Size.x + vecAbsRayDirBox2.x * box2Size.z +
		DotProductAbs( vecPlaneNormal, ray.m_Extents );
	if( (flCenterDeltaProjection) > (flBoxProjectionSum) )
		return false;

	// box z x ray delta
	vecPlaneNormal = vecRayDirection.Cross( ::Vector( box2ToWorld[0][2], box2ToWorld[1][2], box2ToWorld[2][2] ) );
	flCenterDeltaProjection = ::fabs( vecPlaneNormal.Dot(vecCenterDelta) );
	flBoxProjectionSum =
		vecAbsRayDirBox2.y * box2Size.x + vecAbsRayDirBox2.x * box2Size.y +
		DotProductAbs( vecPlaneNormal, ray.m_Extents );
	if( (flCenterDeltaProjection) > (flBoxProjectionSum) )
		return false;

	return true;
}

//-----------------------------------------------------------------------------
// Compute a separating plane between two boxes (expensive!)
// Returns false if no separating plane exists
//-----------------------------------------------------------------------------
function VS::ComputeSeparatingPlane( worldToBox1, box2ToWorld, box1Size, box2Size, tolerance/* , pNormalOut */ )
{
	// The various separating planes can be either
	// 1) A plane parallel to one of the box face planes
	// 2) A plane parallel to the cross-product of an edge from each box

	// First, compute the basis of second box in the space of the first box
	// NOTE: These basis place the origin at the centroid of each box!
	local box2ToBox1 = ::matrix3x4();
	ConcatTransforms( worldToBox1, box2ToWorld, box2ToBox1 );

	// We're going to be using the origin of box2 in the space of box1 alot,
	// lets extract it from the matrix....
	local box2Origin = ::Vector();
	MatrixGetColumn( box2ToBox1, 3, box2Origin );

	// Next get the absolute values of these entries and store in absbox2ToBox1.
	local absBox2ToBox1 = ::matrix3x4();
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

	// local tmp = ::Vector();
	local boxProjectionSum, originProjection;

	// NOTE: For these guys, we're taking advantage of the fact that the ith
	// row of the box2ToBox1 is the direction of the box1 (x,y,z)-axis
	// transformed into the space of box2.

	// First side of box 1
	boxProjectionSum = box1Size.x + MatrixRowDotProduct( absBox2ToBox1, 0, box2Size );
	originProjection = ::fabs( box2Origin.x ) + tolerance;
	if( (originProjection) > (boxProjectionSum) )
	{
		// VectorCopy( worldToBox1[0], pNormalOut );
		return true;
	};

	// Second side of box 1
	boxProjectionSum = box1Size.y + MatrixRowDotProduct( absBox2ToBox1, 1, box2Size );
	originProjection = ::fabs( box2Origin.y ) + tolerance;
	if( (originProjection) > (boxProjectionSum) )
	{
		// VectorCopy( worldToBox1[1], pNormalOut );
		return true;
	};

	// Third side of box 1
	boxProjectionSum = box1Size.z + MatrixRowDotProduct( absBox2ToBox1, 2, box2Size );
	originProjection = ::fabs( box2Origin.z ) + tolerance;
	if( (originProjection) > (boxProjectionSum) )
	{
		// VectorCopy( worldToBox1[2], pNormalOut );
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
	originProjection = ::fabs( MatrixColumnDotProduct( box2ToBox1, 0, box2Origin ) ) + tolerance;
	if( (originProjection) > (boxProjectionSum) )
	{
		// MatrixGetColumn( box2ToWorld, 0, pNormalOut );
		return true;
	};

	// Second side of box 2
	boxProjectionSum = box2Size.y +	MatrixColumnDotProduct( absBox2ToBox1, 1, box1Size );
	originProjection = ::fabs( MatrixColumnDotProduct( box2ToBox1, 1, box2Origin ) ) + tolerance;
	if( (originProjection) > (boxProjectionSum) )
	{
		// MatrixGetColumn( box2ToWorld, 1, pNormalOut );
		return true;
	};

	// Third side of box 2
	boxProjectionSum = box2Size.z +	MatrixColumnDotProduct( absBox2ToBox1, 2, box1Size );
	originProjection = ::fabs( MatrixColumnDotProduct( box2ToBox1, 2, box2Origin ) ) + tolerance;
	if( (originProjection) > (boxProjectionSum) )
	{
		// MatrixGetColumn( box2ToWorld, 2, pNormalOut );
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

	// b1e1 x b2e1
	if( absBox2ToBox1[0][0] < 1.0 - 1.e-3 )
	{
		boxProjectionSum =
			box1Size.y * absBox2ToBox1[2][0] + box1Size.z * absBox2ToBox1[1][0] +
			box2Size.y * absBox2ToBox1[0][2] + box2Size.z * absBox2ToBox1[0][1];
		originProjection = ::fabs( -box2Origin.y * box2ToBox1[2][0] + box2Origin.z * box2ToBox1[1][0] ) + tolerance;
		if( (originProjection) > (boxProjectionSum) )
		{
			// MatrixGetColumn( box2ToWorld, 0, tmp );
			// pNormalOut = worldToBox1[0].Cross(tmp);
			return true;
		};
	};

	// b1e1 x b2e2
	if( absBox2ToBox1[0][1] < 1.0 - 1.e-3 )
	{
		boxProjectionSum =
			box1Size.y * absBox2ToBox1[2][1] + box1Size.z * absBox2ToBox1[1][1] +
			box2Size.x * absBox2ToBox1[0][2] + box2Size.z * absBox2ToBox1[0][0];
		originProjection = ::fabs( -box2Origin.y * box2ToBox1[2][1] + box2Origin.z * box2ToBox1[1][1] ) + tolerance;
		if( (originProjection) > (boxProjectionSum) )
		{
			// MatrixGetColumn( box2ToWorld, 1, tmp );
			// pNormalOut = worldToBox1[0].Cross(tmp);
			return true;
		};
	};

	// b1e1 x b2e3
	if( absBox2ToBox1[0][2] < 1.0 - 1.e-3 )
	{
		boxProjectionSum =
			box1Size.y * absBox2ToBox1[2][2] + box1Size.z * absBox2ToBox1[1][2] +
			box2Size.x * absBox2ToBox1[0][1] + box2Size.y * absBox2ToBox1[0][0];
		originProjection = ::fabs( -box2Origin.y * box2ToBox1[2][2] + box2Origin.z * box2ToBox1[1][2] ) + tolerance;
		if( (originProjection) > (boxProjectionSum) )
		{
			// MatrixGetColumn( box2ToWorld, 2, tmp );
			// pNormalOut = worldToBox1[0].Cross(tmp);
			return true;
		};
	};

	// b1e2 x b2e1
	if( absBox2ToBox1[1][0] < 1.0 - 1.e-3 )
	{
		boxProjectionSum =
			box1Size.x * absBox2ToBox1[2][0] + box1Size.z * absBox2ToBox1[0][0] +
			box2Size.y * absBox2ToBox1[1][2] + box2Size.z * absBox2ToBox1[1][1];
		originProjection = ::fabs( box2Origin.x * box2ToBox1[2][0] - box2Origin.z * box2ToBox1[0][0] ) + tolerance;
		if( (originProjection) > (boxProjectionSum) )
		{
			// MatrixGetColumn( box2ToWorld, 0, tmp );
			// pNormalOut = worldToBox1[1].Cross(tmp);
			return true;
		};
	};

	// b1e2 x b2e2
	if( absBox2ToBox1[1][1] < 1.0 - 1.e-3 )
	{
		boxProjectionSum =
			box1Size.x * absBox2ToBox1[2][1] + box1Size.z * absBox2ToBox1[0][1] +
			box2Size.x * absBox2ToBox1[1][2] + box2Size.z * absBox2ToBox1[1][0];
		originProjection = ::fabs( box2Origin.x * box2ToBox1[2][1] - box2Origin.z * box2ToBox1[0][1] ) + tolerance;
		if( (originProjection) > (boxProjectionSum) )
		{
			// MatrixGetColumn( box2ToWorld, 1, tmp );
			// pNormalOut = worldToBox1[1].Cross(tmp);
			return true;
		};
	};

	// b1e2 x b2e3
	if( absBox2ToBox1[1][2] < 1.0 - 1.e-3 )
	{
		boxProjectionSum =
			box1Size.x * absBox2ToBox1[2][2] + box1Size.z * absBox2ToBox1[0][2] +
			box2Size.x * absBox2ToBox1[1][1] + box2Size.y * absBox2ToBox1[1][0];
		originProjection = ::fabs( box2Origin.x * box2ToBox1[2][2] - box2Origin.z * box2ToBox1[0][2] ) + tolerance;
		if( (originProjection) > (boxProjectionSum) )
		{
			// MatrixGetColumn( box2ToWorld, 2, tmp );
			// pNormalOut = worldToBox1[1].Cross(tmp);
			return true;
		};
	};

	// b1e3 x b2e1
	if( absBox2ToBox1[2][0] < 1.0 - 1.e-3 )
	{
		boxProjectionSum =
			box1Size.x * absBox2ToBox1[1][0] + box1Size.y * absBox2ToBox1[0][0] +
			box2Size.y * absBox2ToBox1[2][2] + box2Size.z * absBox2ToBox1[2][1];
		originProjection = ::fabs( -box2Origin.x * box2ToBox1[1][0] + box2Origin.y * box2ToBox1[0][0] ) + tolerance;
		if( (originProjection) > (boxProjectionSum) )
		{
			// MatrixGetColumn( box2ToWorld, 0, tmp );
			// pNormalOut = worldToBox1[2].Cross(tmp);
			return true;
		};
	};

	// b1e3 x b2e2
	if( absBox2ToBox1[2][1] < 1.0 - 1.e-3 )
	{
		boxProjectionSum =
			box1Size.x * absBox2ToBox1[1][1] + box1Size.y * absBox2ToBox1[0][1] +
			box2Size.x * absBox2ToBox1[2][2] + box2Size.z * absBox2ToBox1[2][0];
		originProjection = ::fabs( -box2Origin.x * box2ToBox1[1][1] + box2Origin.y * box2ToBox1[0][1] ) + tolerance;
		if( (originProjection) > (boxProjectionSum) )
		{
			// MatrixGetColumn( box2ToWorld, 1, tmp );
			// pNormalOut = worldToBox1[2].Cross(tmp);
			return true;
		};
	};

	// b1e3 x b2e3
	if( absBox2ToBox1[2][2] < 1.0 - 1.e-3 )
	{
		boxProjectionSum =
			box1Size.x * absBox2ToBox1[1][2] + box1Size.y * absBox2ToBox1[0][2] +
			box2Size.x * absBox2ToBox1[2][1] + box2Size.y * absBox2ToBox1[2][0];
		originProjection = ::fabs( -box2Origin.x * box2ToBox1[1][2] + box2Origin.y * box2ToBox1[0][2] ) + tolerance;
		if( originProjection > boxProjectionSum )
		{
			// MatrixGetColumn( box2ToWorld, 2, tmp );
			// pNormalOut = worldToBox1[2].Cross(tmp);
			return true;
		};
	};
	return false;
}

//-----------------------------------------------------------------------------
// Compute a separating plane between two boxes (expensive!)
// Returns false if no separating plane exists
//-----------------------------------------------------------------------------
function VS::ComputeSeparatingPlane2( org1, angles1, min1, max1, org2, angles2, min2, max2, tolerance/* , pNormalOut */ )
{
	local worldToBox1 = ::matrix3x4(),
	      box2ToWorld = ::matrix3x4();

	ComputeCenterIMatrix( org1, angles1, min1, max1, worldToBox1 );
	ComputeCenterMatrix( org2, angles2, min2, max2, box2ToWorld );

	// Then compute the size of the two boxes
	local box1Size = (max1 - min1) * 0.5;
	local box2Size = (max2 - min2) * 0.5;

	return ComputeSeparatingPlane( worldToBox1, box2ToWorld, box1Size, box2Size, tolerance/* , pNormalOut */ );
}
