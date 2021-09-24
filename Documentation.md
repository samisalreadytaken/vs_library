# VScript Library Documentation
Documentation for [vs_library](https://github.com/samisalreadytaken/vs_library).

________________________________
<!-- U+2800 U+2514 U+2500 -->
### Table of Contents
└─ [**README**](#README)  
└─ **Reference**  
⠀ ⠀└─ [Keywords, symbols and variables](#keywords-and-symbols-used-in-this-documentation)  
⠀ ⠀└─ [Constants](#Constants)  
⠀ ⠀└─ [vs_math](#vs_math)  
⠀ ⠀└─ [vs_utility](#vs_utility)  
⠀ ⠀└─ [vs_entity](#vs_entity)  
⠀ ⠀└─ [vs_events](#vs_events)  
⠀ ⠀└─ [vs_log](#vs_log)  
________________________________

## README

See [README.md](https://github.com/samisalreadytaken/vs_library/blob/master/README.md) for installation, downloading and usage.
________________________________


## Keywords and symbols used in this documentation
| Type                  | Example                                                                             |
| --------------------- | ----------------------------------------------------------------------------------- |
| `null`, `void`        | `null`                                                                              |
| `int`                 | `1`                                                                                 |
| `float`               | `1.0`                                                                               |
| `bool`                | `true`, `false`                                                                     |
| `string`              | `""`                                                                                |
| `table`               | `{}`                                                                                |
| `array`               | `[]`, `array()`                                                                     |
| `closure`, `function` | function                                                                            |
| `handle`,`CBaseEntity`| Entity script handle                                                                |
| `Vector`, `vec3_t`    | `Vector(0,1,2)`                                                                     |
| `QAngle`              | `Vector(0,1,2)`, `(pitch, yaw, roll)` Euler angle. Vector, **not a different type** |
| `Quaternion`          | `Quaternion(0,1,2,3)`                                                               |
| `matrix3x4_t`         | `matrix3x4_t()`                                                                     |
| `VMatrix`             | `VMatrix()`                                                                         |
| `trace_t`             | `VS.TraceLine()`                                                                    |
| `Ray_t`               | `Ray_t()`                                                                           |
| `TYPE`                | Multiple types. Any unless specified in description                                 |

| Symbols | Description                                                                                                                                                                                                       |
| ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `&`     | instance reference. This means the input will be modified. Optional references can be omitted, but their result will be modified the next time another function with omitted reference parameter is called. |
| `[]`    | array. `float[3]` represents an array made of floats, with only 3 indices.                                                                                                                                        |

### Variables used in examples
| Variable       | Creation                          | Description                                           |
| -------------- | --------------------------------- | ----------------------------------------------------- |
| `player`       | `ToExtendedPlayer(VS.GetPlayerByIndex(1))`             | Local player in the server                            |
| `m_hHudHint`   | `VS.CreateEntity("env_hudhint")`  | Hud hint, show messages to the player                 |
| `Think()`      | `VS.Timer(0, 0.0, Think)`         | A function that is executed every frame               |


### Constants
| Variable           | Value                            |
| ------------------ | -------------------------------- |
| `CONST`            | `table` Squirrel constant table  |
| `FLT_EPSILON`      | `1.192092896e-7`                 |
| `FLT_MAX`          | `3.402823466e+38`                |
| `FLT_MIN`          | `1.175494351e-38`                |
| `INT_MAX`          | `2147483647`                     |
| `INT_MIN`          | `-2147483648`                    |
| `DEG2RAD`          | `0.017453293`                    |
| `RAD2DEG`          | `57.295779513`                   |
| `PI`               | `3.141592654`                    |
| `RAND_MAX`         | `0x7FFF`                         |
| `MAX_COORD_FLOAT`  | `16384.0` (`1<<14`)              |
| `MAX_TRACE_LENGTH` | `56755.840862417`                |
| `TextColor`        |                                  |

NOTE: To use these constants in your scripts, the library needs to have been compiled before your script. To ensure this happens, you may load your scripts using a buffer script which loads the library first, then loads your custom script.

```cs
IncludeScript("vs_library")
IncludeScript("myscript")
```


### [vs_math](#vs_math-1)
[`Quaternion`](#f_Quaternion)  
[`matrix3x4_t`](#f_matrix3x4_t)  
[`VMatrix`](#f_VMatrix)  
[`VS.fabs()`](#f_fabs)  
[`max()`](#f_max)  
[`min()`](#f_min)  
[`clamp()`](#f_clamp)  
[`VS.IsInteger()`](#f_IsInteger)  
[`VS.IsLookingAt()`](#f_IsLookingAt)  
[`VS.GetAngle()`](#f_GetAngle)  
[`VS.VectorVectors()`](#f_VectorVectors)  
[`VS.AngleVectors()`](#f_AngleVectors)  
[`VS.VectorAngles()`](#f_VectorAngles)  
[`VS.VectorYawRotate()`](#f_VectorYawRotate)  
[`VS.YawToVector()`](#f_YawToVector)  
[`VS.VecToYaw()`](#f_VecToYaw)  
[`VS.VecToPitch()`](#f_VecToPitch)  
[`VS.VectorIsZero()`](#f_VectorIsZero)  
[`VS.VectorsAreEqual()`](#f_VectorsAreEqual)  
[`VS.AnglesAreEqual()`](#f_AnglesAreEqual)  
[`VS.CloseEnough()`](#f_CloseEnough)  
[`VS.Approach()`](#f_Approach)  
[`VS.ApproachVector()`](#f_ApproachVector)  
[`VS.ApproachAngle()`](#f_ApproachAngle)  
[`VS.AngleDiff()`](#f_AngleDiff)  
[`VS.AngleNormalize()`](#f_AngleNormalize)  
[`VS.QAngleNormalize()`](#f_QAngleNormalize)  
[`VS.SnapDirectionToAxis()`](#f_SnapDirectionToAxis)  
[`VS.VectorNegate()`](#f_VectorNegate)  
[`VS.VectorCopy()`](#f_VectorCopy)  
[`VS.VectorMin()`](#f_VectorMin)  
[`VS.VectorMax()`](#f_VectorMax)  
[`VS.VectorAbs()`](#f_VectorAbs)  
[`VS.VectorAdd()`](#f_VectorAdd)  
[`VS.VectorSubtract()`](#f_VectorSubtract)  
[`VS.VectorScale()`](#f_VectorScale)  
[`VS.VectorMultiply()`](#f_VectorMultiply)  
[`VS.VectorDivide()`](#f_VectorDivide)  
[`VS.VectorMA()`](#f_VectorMA)  
[`VS.ComputeVolume()`](#f_ComputeVolume)  
[`VS.RandomVector()`](#f_RandomVector)  
[`VS.RandomVectorInUnitSphere()`](#f_RandomVectorInUnitSphere)  
[`VS.RandomVectorOnUnitSphere()`](#f_RandomVectorOnUnitSphere)  
[`VS.ExponentialDecay()`](#f_ExponentialDecay)  
[`VS.ExponentialDecay2()`](#f_ExponentialDecay2)  
[`VS.ExponentialDecayIntegral()`](#f_ExponentialDecayIntegral)  
[`VS.SimpleSpline()`](#f_SimpleSpline)  
[`VS.SimpleSplineRemapVal()`](#f_SimpleSplineRemapVal)  
[`VS.SimpleSplineRemapValClamped()`](#f_SimpleSplineRemapValClamped)  
[`VS.RemapVal()`](#f_RemapVal)  
[`VS.RemapValClamped()`](#f_RemapValClamped)  
[`VS.Bias()`](#f_Bias)  
[`VS.Gain()`](#f_Gain)  
[`VS.SmoothCurve()`](#f_SmoothCurve)  
[`VS.MovePeak()`](#f_MovePeak)  
[`VS.SmoothCurve_Tweak()`](#f_SmoothCurve_Tweak)  
[`VS.Lerp()`](#f_Lerp)  
[`VS.FLerp()`](#f_FLerp)  
[`VS.VectorLerp()`](#f_VectorLerp)  
[`VS.DotProductAbs()`](#f_DotProductAbs)  
[`VS.QuaternionsAreEqual()`](#f_QuaternionsAreEqual)  
[`VS.QuaternionNormalize()`](#f_QuaternionNormalize)  
[`VS.QuaternionAlign()`](#f_QuaternionAlign)  
[`VS.QuaternionMult()`](#f_QuaternionMult)  
[`VS.QuaternionConjugate()`](#f_QuaternionConjugate)  
[`VS.QuaternionMA()`](#f_QuaternionMA)  
[`VS.QuaternionAdd()`](#f_QuaternionAdd)  
[`VS.QuaternionDotProduct()`](#f_QuaternionDotProduct)  
[`VS.QuaternionInvert()`](#f_QuaternionInvert)  
[`VS.QuaternionBlend()`](#f_QuaternionBlend)  
[`VS.QuaternionBlendNoAlign()`](#f_QuaternionBlendNoAlign)  
[`VS.QuaternionIdentityBlend()`](#f_QuaternionIdentityBlend)  
[`VS.QuaternionSlerp()`](#f_QuaternionSlerp)  
[`VS.QuaternionSlerpNoAlign()`](#f_QuaternionSlerpNoAlign)  
[`VS.QuaternionLn()`](#f_QuaternionLn)  
[`VS.QuaternionExp()`](#f_QuaternionExp)  
[`VS.QuaternionSquad()`](#f_QuaternionSquad)  
[`VS.QuaternionAverageExponential()`](#f_QuaternionAverageExponential)  
[`VS.QuaternionAngleDiff()`](#f_QuaternionAngleDiff)  
[`VS.QuaternionScale()`](#f_QuaternionScale)  
[`VS.RotationDeltaAxisAngle()`](#f_RotationDeltaAxisAngle)  
[`VS.RotationDelta()`](#f_RotationDelta)  
[`VS.QuaternionMatrix()`](#f_QuaternionMatrix)  
[`VS.QuaternionAngles()`](#f_QuaternionAngles)  
[`VS.QuaternionAxisAngle()`](#f_QuaternionAxisAngle)  
[`VS.AxisAngleQuaternion()`](#f_AxisAngleQuaternion)  
[`VS.AngleQuaternion()`](#f_AngleQuaternion)  
[`VS.MatrixQuaternion()`](#f_MatrixQuaternion)  
[`VS.BasisToQuaternion()`](#f_BasisToQuaternion)  
[`VS.MatrixAngles()`](#f_MatrixAngles)  
[`VS.MatrixQuaternionFast()`](#f_MatrixQuaternionFast)  
[`VS.AngleMatrix()`](#f_AngleMatrix)  
[`VS.AngleIMatrix()`](#f_AngleIMatrix)  
[`VS.VectorMatrix()`](#f_VectorMatrix)  
[`VS.MatrixVectors()`](#f_MatrixVectors)  
[`VS.MatricesAreEqual()`](#f_MatricesAreEqual)  
[`VS.MatrixCopy()`](#f_MatrixCopy)  
[`VS.MatrixInvert()`](#f_MatrixInvert)  
[`VS.MatrixInverseGeneral()`](#f_MatrixInverseGeneral)  
[`VS.MatrixInverseTR()`](#f_MatrixInverseTR)  
[`VS.MatrixGetColumn()`](#f_MatrixGetColumn)  
[`VS.MatrixSetColumn()`](#f_MatrixSetColumn)  
[`VS.MatrixScaleBy()`](#f_MatrixScaleBy)  
[`VS.MatrixScaleByZero()`](#f_MatrixScaleByZero)  
[`VS.SetIdentityMatrix()`](#f_SetIdentityMatrix)  
[`VS.SetScaleMatrix()`](#f_SetScaleMatrix)  
[`VS.ComputeCenterMatrix()`](#f_ComputeCenterMatrix)  
[`VS.ComputeCenterIMatrix()`](#f_ComputeCenterIMatrix)  
[`VS.ComputeAbsMatrix()`](#f_ComputeAbsMatrix)  
[`VS.ConcatRotations()`](#f_ConcatRotations)  
[`VS.ConcatTransforms()`](#f_ConcatTransforms)  
[`VS.MatrixMultiply()`](#f_MatrixMultiply)  
[`VS.MatrixBuildRotationAboutAxis()`](#f_MatrixBuildRotationAboutAxis)  
[`VS.MatrixBuildRotation()`](#f_MatrixBuildRotation)  
[`VS.VectorTransform()`](#f_VectorTransform)  
[`VS.VectorITransform()`](#f_VectorITransform)  
[`VS.VectorRotate()`](#f_VectorRotate)  
[`VS.VectorRotateByAngle()`](#f_VectorRotateByAngle)  
[`VS.VectorRotateByQuaternion()`](#f_VectorRotateByQuaternion)  
[`VS.VectorIRotate()`](#f_VectorIRotate)  
[`VS.Vector3DMultiplyProjective()`](#f_Vector3DMultiplyProjective)  
[`VS.Vector3DMultiplyPositionProjective()`](#f_Vector3DMultiplyPositionProjective)  
[`VS.TransformAABB()`](#f_TransformAABB)  
[`VS.ITransformAABB()`](#f_ITransformAABB)  
[`VS.RotateAABB()`](#f_RotateAABB)  
[`VS.IRotateAABB()`](#f_IRotateAABB)  
[`VS.GetBoxVertices()`](#f_GetBoxVertices)  
[`VS.MatrixBuildPerspective()`](#f_MatrixBuildPerspective)  
[`VS.ComputeViewMatrix()`](#f_ComputeViewMatrix)  
[`VS.ScreenToWorldMatrix()`](#f_ScreenToWorldMatrix)  
[`VS.ScreenToWorld()`](#f_ScreenToWorld)  
[`VS.ComputeCameraVariables()`](#f_ComputeCameraVariables)  
[`VS.CalcFovY()`](#f_CalcFovY)  
[`VS.CalcFovX()`](#f_CalcFovX)  
[`VS.DrawFrustum()`](#f_DrawFrustum)  
[`VS.DrawViewFrustum()`](#f_DrawViewFrustum)  
[`VS.DrawBoxAngles()`](#f_DrawBoxAngles)  
[`VS.DrawSphere()`](#f_DrawSphere)  
[`VS.DrawCapsule()`](#f_DrawCapsule)  
[`VS.DrawHorzArrow()`](#f_DrawHorzArrow)  
[`VS.DrawVertArrow()`](#f_DrawVertArrow)  
[`enum INTERPOLATE`](#f_INTERPOLATE)  
[`VS.Interpolator_GetKochanekBartelsParams()`](#f_Interpolator_GetKochanekBartelsParams)  
[`VS.Interpolator_CurveInterpolate()`](#f_Interpolator_CurveInterpolate)  
[`VS.Interpolator_CurveInterpolate_NonNormalized()`](#f_Interpolator_CurveInterpolate_NonNormalized)  
[`VS.Spline_Normalize()`](#f_Spline_Normalize)  
[`VS.Catmull_Rom_Spline()`](#f_Catmull_Rom_Spline)  
[`VS.Catmull_Rom_Spline_Tangent()`](#f_Catmull_Rom_Spline_Tangent)  
[`VS.Catmull_Rom_Spline_Integral()`](#f_Catmull_Rom_Spline_Integral)  
[`VS.Catmull_Rom_Spline_Integral2()`](#f_Catmull_Rom_Spline_Integral2)  
[`VS.Catmull_Rom_Spline_Normalize()`](#f_Catmull_Rom_Spline_Normalize)  
[`VS.Catmull_Rom_Spline_Integral_Normalize()`](#f_Catmull_Rom_Spline_Integral_Normalize)  
[`VS.Catmull_Rom_Spline_NormalizeX()`](#f_Catmull_Rom_Spline_NormalizeX)  
[`VS.Hermite_Spline()`](#f_Hermite_Spline)  
[`VS.Hermite_SplineF()`](#f_Hermite_SplineF)  
[`VS.Hermite_SplineBasis()`](#f_Hermite_SplineBasis)  
[`VS.Hermite_Spline3V()`](#f_Hermite_Spline3V)  
[`VS.Hermite_Spline3F()`](#f_Hermite_Spline3F)  
[`VS.Hermite_Spline3Q()`](#f_Hermite_Spline3Q)  
[`VS.Kochanek_Bartels_Spline()`](#f_Kochanek_Bartels_Spline)  
[`VS.Kochanek_Bartels_Spline_NormalizeX()`](#f_Kochanek_Bartels_Spline_NormalizeX)  
[`VS.Cubic_Spline()`](#f_Cubic_Spline)  
[`VS.Cubic_Spline_NormalizeX()`](#f_Cubic_Spline_NormalizeX)  
[`VS.BSpline()`](#f_BSpline)  
[`VS.BSpline_NormalizeX()`](#f_BSpline_NormalizeX)  
[`VS.Parabolic_Spline()`](#f_Parabolic_Spline)  
[`VS.Parabolic_Spline_NormalizeX()`](#f_Parabolic_Spline_NormalizeX)  
[`VS.RangeCompressor()`](#f_RangeCompressor)  
[`VS.InterpolateAngles()`](#f_InterpolateAngles)  
[`VS.PointOnLineNearestPoint()`](#f_PointOnLineNearestPoint)  
[`VS.CalcSqrDistanceToAABB()`](#f_CalcSqrDistanceToAABB)  
[`VS.CalcClosestPointOnAABB()`](#f_CalcClosestPointOnAABB)  
[`Ray_t`](#f_Ray_t)  
[`VS.ComputeBoxOffset()`](#f_ComputeBoxOffset)  
[`VS.IntersectRayWithTriangle()`](#f_IntersectRayWithTriangle)  
[`VS.ComputeIntersectionBarycentricCoordinates()`](#f_ComputeIntersectionBarycentricCoordinates)  
[`VS.IsPointInBox()`](#f_IsPointInBox)  
[`VS.IsBoxIntersectingBox()`](#f_IsBoxIntersectingBox)  
[`VS.IsPointInCone()`](#f_IsPointInCone)  
[`VS.IsSphereIntersectingSphere()`](#f_IsSphereIntersectingSphere)  
[`VS.IsBoxIntersectingSphere()`](#f_IsBoxIntersectingSphere)  
[`VS.IsCircleIntersectingRectangle()`](#f_IsCircleIntersectingRectangle)  
[`VS.IsRayIntersectingSphere()`](#f_IsRayIntersectingSphere)  
[`VS.IntersectInfiniteRayWithSphere()`](#f_IntersectInfiniteRayWithSphere)  
[`VS.IsBoxIntersectingRay()`](#f_IsBoxIntersectingRay)  
[`VS.IsBoxIntersectingRay2()`](#f_IsBoxIntersectingRay2)  
[`VS.IntersectRayWithRay()`](#f_IntersectRayWithRay)  
[`VS.IntersectRayWithPlane()`](#f_IntersectRayWithPlane)  
[`VS.IntersectRayWithBox()`](#f_IntersectRayWithBox)  
[`VS.IntersectRayWithOBB()`](#f_IntersectRayWithOBB)  
[`VS.IsRayIntersectingOBB()`](#f_IsRayIntersectingOBB)  


### [vs_utility](#vs_utility-1)
[`Ent()`](#f_Ent)  
[`Entc()`](#f_Entc)  
[`delay()`](#f_delay)  
[`CenterPrintAll`](#f_CenterPrintAll)  
[`TextColor`](#f_TextColor)  
[`VecToString()`](#f_VecToString)  
[`ToExtendedPlayer()`](#f_ToExtendedPlayer)  
[`VS.TraceLine`](#f_TraceLine)  
[`VS.TraceLine.DidHit()`](#f_DidHit)  
[`VS.TraceLine.GetEnt()`](#f_GetEnt)  
[`VS.TraceLine.GetEntByName()`](#f_GetEntByName)  
[`VS.TraceLine.GetEntByClassname()`](#f_GetEntByClassname)  
[`VS.TraceLine.GetPos()`](#f_GetPos)  
[`VS.TraceLine.GetDist()`](#f_GetDist)  
[`VS.TraceLine.GetDistSqr()`](#f_GetDistSqr)  
[`VS.TraceLine.GetNormal()`](#f_GetNormal)  
[`VS.TraceDir()`](#f_TraceDir)  
[`VS.UniqueString()`](#f_UniqueString)  
[`VS.EventQueue.Clear()`](#f_EventQueueClear)  
[`VS.EventQueue.AddEvent()`](#f_EventQueueAddEvent)  
[`VS.EventQueue.CancelEventsByInput()`](#f_EventQueueCancelEventsByInput)  
[`VS.EventQueue.RemoveEvent()`](#f_EventQueueRemoveEvent)  
[`VS.EventQueue.Dump()`](#f_EventQueueDump)  
[`VS.DumpScope()`](#f_DumpScope)  
[`VS.DumpEnt()`](#f_DumpEnt)  
[`VS.DumpPlayers()`](#f_DumpPlayers)  
[`VS.ArrayToTable()`](#f_ArrayToTable)  
[`VS.PrintStack()`](#f_PrintStack)  
[`VS.GetCallerFunc()`](#f_GetCallerFunc)  
[`VS.GetCaller()`](#f_GetCaller)  
[`VS.GetVarName()`](#f_GetVarName)  


### [vs_entity](#vs_entity-1)
[`EntFireByHandle()`](#f_EntFireByHandle)  
[`PrecacheModel()`](#f_PrecacheModel)  
[`PrecacheScriptSound()`](#f_PrecacheScriptSound)  
[`VS.MakePersistent()`](#f_MakePersistent)  
[`VS.SetParent()`](#f_SetParent)  
[`VS.CreateTimer()`](#f_CreateTimer)  
[`VS.Timer()`](#f_Timer)  
[`VS.OnTimer()`](#f_OnTimer)  
[`VS.AddOutput()`](#f_AddOutput)  
[`VS.CreateEntity()`](#f_CreateEntity)  
[`VS.SetKeyValue()`](#f_SetKeyValue)  
[`VS.SetName()`](#f_SetName)  
[`VS.GetPlayersAndBots()`](#f_GetPlayersAndBots)  
[`VS.GetAllPlayers()`](#f_GetAllPlayers)  
[`VS.GetLocalPlayer()`](#f_GetLocalPlayer)  
[`VS.GetPlayerByIndex()`](#f_GetPlayerByIndex)  
[`VS.GetEntityByIndex()`](#f_GetEntityByIndex)  
[`VS.IsPointSized()`](#f_IsPointSized)  
[`VS.FindEntityClassNearestFacing()`](#f_FindEntityClassNearestFacing)  
[`VS.FindEntityNearestFacing()`](#f_FindEntityNearestFacing)  
[`VS.FindEntityClassNearestFacingNearest()`](#f_FindEntityClassNearestFacingNearest)  


### [vs_events](#vs_events-1)
[`VS.GetPlayerByUserid()`](#f_GetPlayerByUserid)  
[`VS.ListenToGameEvent()`](#f_ListenToGameEvent)  
[`VS.StopListeningToAllGameEvents()`](#f_StopListeningToAllGameEvents)  
[`VS.FixupEventListener()`](#f_FixupEventListener)  
[`VS.Events.InitTemplate()`](#f_InitTemplate)  


### [vs_log](#vs_log-1)
[`VS.Log.enabled`](#f_Logenabled)  
[`VS.Log.export`](#f_Logexport)  
[`VS.Log.file_prefix`](#f_Logfile_prefix)  
[`VS.Log.Add()`](#f_LogAdd)  
[`VS.Log.Pop()`](#f_LogPop)  
[`VS.Log.Clear()`](#f_LogClear)  
[`VS.Log.WriteKeyValues()`](#f_LogWriteKeyValues)  
[`VS.Log.Run()`](#f_LogRun)  
[`VS.Log.filter`](#f_Logfilter)  


________________________________

### [vs_math](https://github.com/samisalreadytaken/vs_library/blob/master/src/vs_math.nut)
________________________________

<a name="f_Quaternion"></a>
```cpp
class Quaternion
{
	float x, y, z, w;

	Quaternion();
	Quaternion( x, y, z, w );

	bool IsValid();
}
```
________________________________

<a name="f_matrix3x4_t"></a>
```cpp
class matrix3x4_t
{
	float m[3][4];

	matrix3x4_t();

	matrix3x4_t(
		m00, m01, m02, m03
		m10, m11, m12, m13
		m20, m21, m22, m23 );

	void Init(
		m00 = 0.0, m01 = 0.0, m02 = 0.0, m03 = 0.0,
		m10 = 0.0, m11 = 0.0, m12 = 0.0, m13 = 0.0,
		m20 = 0.0, m21 = 0.0, m22 = 0.0, m23 = 0.0 );
}
```
________________________________

<a name="f_VMatrix"></a>
```cpp
class VMatrix
{
	float m[4][4];

	VMatrix();

	VMatrix(
		m00, m01, m02, m03
		m10, m11, m12, m13
		m20, m21, m22, m23
		m30, m31, m32, m33 );

	void Init(
		m00 = 0.0, m01 = 0.0, m02 = 0.0, m03 = 0.0,
		m10 = 0.0, m11 = 0.0, m12 = 0.0, m13 = 0.0,
		m20 = 0.0, m21 = 0.0, m22 = 0.0, m23 = 0.0 );

	void Identity();
}
```
________________________________

<a name="f_max"></a>
```cpp
float max(float a, float b)
```
Return the larger of the two inputs
________________________________

<a name="f_min"></a>
```cpp
float min(float a, float b)
```
Return the smaller of the two inputs
________________________________

<a name="f_clamp"></a>
```cpp
float clamp(float value, float min, float max)
```
Clamp the value between min and max
________________________________

<a name="f_IsInteger"></a>
```cpp
bool VS::IsInteger(float input)
```
Check if float is an integer
________________________________

<a name="f_IsLookingAt"></a>
```cpp
bool VS::IsLookingAt(Vector source, Vector target, Vector direction, float tolerance)
```
<details><summary>Example</summary>

```cs
function Think()
{
	local bLooking
	local eyePos = player.EyePosition()
	local target = Vector()

	DebugDrawLine( player.GetOrigin(), target, 255,0,0,true, -1 )

	// only check if there is direct LOS with the target
	if ( !VS.TraceLine( eyePos, target, player.self ).DidHit() )
	{
		bLooking = VS.IsLookingAt( eyePos, target, player.EyeForward(), VIEW_FIELD_NARROW )
	}

	if ( bLooking )
	{
		m_hHudHint.__KeyValueFromString( "message", "LOOKING" );
		EntFireByHandle( m_hHudHint, "ShowHudHint", "", 0.0, player.self );

		DebugDrawBox( target, Vector(-8,-8,-8), Vector(8,8,8), 0,255,0,255, -1 )
	}
	else
	{
		m_hHudHint.__KeyValueFromString( "message", "NOT looking" );
		EntFireByHandle( m_hHudHint, "ShowHudHint", "", 0.0, player.self );

		DebugDrawBox( target, Vector(-8,-8,-8), Vector(8,8,8), 255,0,0,255, -1 )
	}
}
```

</details>

________________________________

<a name="f_GetAngle"></a>
```cpp
Vector VS::GetAngle(Vector from, Vector to)
```
Angle between 2 position vectors. Identical to `VS.VectorAngles( vTo - vFrom, pOut )`.
________________________________

<a name="f_VectorVectors"></a>
```cpp
void VS::VectorVectors(Vector forward, Vector& right, Vector& up)
```
Get right and up vectors from forward direction vector
________________________________

<a name="f_AngleVectors"></a>
```cpp
Vector VS::AngleVectors(QAngle angle, Vector& forward = _VEC, Vector& right = null, Vector& up = null)
```
Euler QAngle -> Basis Vectors. Each vector is optional. Return forward vector
________________________________

<a name="f_VectorAngles"></a>
```cpp
QAngle VS::VectorAngles(Vector forward, QAngle &out = _VEC)
```
Forward direction vector -> Euler QAngle
________________________________

<a name="f_VectorYawRotate"></a>
```cpp
Vector VS::VectorYawRotate(Vector input, float yaw, Vector& out = _VEC)
```
Rotate a vector around the Z axis (YAW)
________________________________

<a name="f_YawToVector"></a>
```cpp
Vector VS::YawToVector(flaot yaw)
```

________________________________

<a name="f_VecToYaw"></a>
```cpp
float VS::VecToYaw(Vector vec)
```

________________________________

<a name="f_VecToPitch"></a>
```cpp
float VS::VecToPitch(Vector vec)
```

________________________________

<a name="f_VectorIsZero"></a>
```cpp
bool VS::VectorIsZero(Vector vec)
```

________________________________

<a name="f_VectorsAreEqual"></a>
```cpp
bool VS::VectorsAreEqual(Vector a, Vector b, float tolerance = 0)
```

________________________________

<a name="f_AnglesAreEqual"></a>
```cpp
bool VS::AnglesAreEqual(float a, float b, float tolerance = 0)
```
Angle equality with tolerance
________________________________

<a name="f_CloseEnough"></a>
```cpp
bool VS::CloseEnough(float a, float b, float epsilon)
```
Equality with tolerance
________________________________

<a name="f_Approach"></a>
```cpp
float VS::Approach(float target, float value, float speed)
```

________________________________

<a name="f_ApproachVector"></a>
```cpp
Vector VS::ApproachVector(Vector target, Vector value, float speed)
```

________________________________

<a name="f_ApproachAngle"></a>
```cpp
float VS::ApproachAngle(float target, float value, float speed)
```

________________________________

<a name="f_AngleDiff"></a>
```cpp
float VS::AngleDiff(float destAngle, float srcAngle)
```

________________________________

<a name="f_AngleNormalize"></a>
```cpp
float VS::AngleNormalize(float angle)
```

________________________________

<a name="f_QAngleNormalize"></a>
```cpp
QAngle VS::QAngleNormalize(QAngle& angle)
```

________________________________

<a name="f_SnapDirectionToAxis"></a>
```cpp
Vector VS::SnapDirectionToAxis(Vector& direction, float epsilon = 0.002)
```
Snaps the input (normalised direction) vector to the closest axis

<details><summary>Example</summary>

```cs
function Think()
{
	local eye = player.EyePosition()
	local dir = player.EyeForward()

	// draw normal direction
	DebugDrawLine( eye, eye+dir*128, 255, 255, 255, false, -1 )
	DebugDrawBox( eye+dir*128, Vector(-2,-2,-2), Vector(2,2,2), 255, 255, 255, 128, -1 )

	// snap
	VS.SnapDirectionToAxis( dir, 0.5 )

	// draw snapped direction
	DebugDrawLine( eye, eye+dir*128, 255, 255, 255, false, -1 )
	DebugDrawBox( eye+dir*128, Vector(-2,-2,-2), Vector(2,2,2), 255, 255, 255, 128, -1 )

	// print snapped direction
	printl( VecToString(dir) )
}
```

</details>

________________________________

<a name="f_VectorNegate"></a>
```cpp
Vector VS::VectorNegate(Vector& vec)
```

________________________________

<a name="f_VectorCopy"></a>
```cpp
Vector VS::VectorCopy(Vector src, Vector& dst)
```
Copy source's values into destination
________________________________

<a name="f_VectorMin"></a>
```cpp
Vector VS::VectorMin(Vector a, Vector b, Vector& out = _VEC )
```
Store the min or max of each of x, y, and z into the result.
________________________________

<a name="f_VectorMax"></a>
```cpp
Vector VS::VectorMax(Vector a, Vector b, Vector& out = _VEC )
```
Store the min or max of each of x, y, and z into the result.
________________________________

<a name="f_VectorAbs"></a>
```cpp
Vector VS::VectorAbs(Vector& vec)
```

________________________________

<a name="f_VectorAdd"></a>
```cpp
Vector VS::VectorAdd(Vector a, Vector b, Vector& out )
```
Vector a + Vector b

________________________________

<a name="f_VectorSubtract"></a>
```cpp
Vector VS::VectorSubtract(Vector a, Vector b, Vector& out )
```
Vector a - Vector b
________________________________

<a name="f_VectorScale"></a>
```cpp
Vector VS::VectorScale(Vector a, float b, Vector& out )
```
Vector a * b
________________________________

<a name="f_VectorMultiply"></a>
```cpp
void VS::VectorMultiply( Vector a, Vector b, Vector& out )
```
Vector a * Vector b
________________________________

<a name="f_VectorDivide"></a>
```cpp
void VS::VectorDivide( Vector a, Vector b, Vector& out )
```
Vector a / Vector b
________________________________

<a name="f_VectorMA"></a>
```cpp
Vector VS::VectorMA(Vector start, float scale, Vector direction, Vector& dest = _VEC)
```
start + scale * direction
________________________________

<a name="f_ComputeVolume"></a>
```cpp
float VS::ComputeVolume(Vector vecMins, Vector vecMaxs)
```

________________________________

<a name="f_RandomVector"></a>
```cpp
Vector VS::RandomVector(float minVal = -RAND_MAX, float maxVal = RAND_MAX)
```
Get a random vector
________________________________

<a name="f_RandomVectorInUnitSphere"></a>
```cpp
float VS::RandomVectorInUnitSphere(Vector &out)
```
Guarantee uniform random distribution within a sphere
________________________________

<a name="f_RandomVectorOnUnitSphere"></a>
```cpp
void VS::RandomVectorOnUnitSphere(Vector &out)
```
Guarantee uniform random distribution on a sphere
________________________________

<a name="f_ExponentialDecay"></a>
```cpp
float VS::ExponentialDecay(float decayTo, float decayTime, float dt)
```
decayTo is factor the value should decay to in decayTime
________________________________

<a name="f_ExponentialDecay2"></a>
```cpp
float VS::ExponentialDecay2(float halflife, float dt)
```
halflife is time for value to reach 50%
________________________________

<a name="f_ExponentialDecayIntegral"></a>
```cpp
float VS::ExponentialDecayIntegral(float decayTo, float decayTime, float dt)
```
Get the integrated distanced traveled  
decayTo is factor the value should decay to in decayTime  
dt is the time relative to the last velocity update
________________________________

<a name="f_SimpleSpline"></a>
```cpp
float VS::SimpleSpline(float value)
```
hermite basis function for smooth interpolation  
very cheap to call  
value should be between 0 & 1 inclusive
________________________________

<a name="f_SimpleSplineRemapVal"></a>
```cpp
float VS::SimpleSplineRemapVal(float val, float A, float B, float C, float D)
```
remaps a value in `[startInterval, startInterval+rangeInterval]` from linear to spline using SimpleSpline
________________________________

<a name="f_SimpleSplineRemapValClamped"></a>
```cpp
float VS::SimpleSplineRemapValClamped(float val, float A, float B, float C, float D)
```
remaps a value in `[startInterval, startInterval+rangeInterval]` from linear to spline using SimpleSpline
________________________________

<a name="f_RemapVal"></a>
```cpp
float VS::RemapVal(float val, float A, float B, float C, float D)
```
Remap a value in the range [A,B] to [C,D]
________________________________

<a name="f_RemapValClamped"></a>
```cpp
float VS::RemapValClamped(float val, float A, float B, float C, float D)
```

________________________________

<a name="f_Bias"></a>
```cpp
float VS::Bias(float x, float biasAmt)
```

```
Bias takes an X value between 0 and 1 and returns another value between 0 and 1
The curve is biased towards 0 or 1 based on biasAmt, which is between 0 and 1.
Lower values of biasAmt bias the curve towards 0 and higher values bias it towards 1.

For example, with biasAmt = 0.2, the curve looks like this:

1
|                  *
|                  *
|                 *
|               **
|             **
|         ****
|*********
|___________________
0                   1


With biasAmt = 0.8, the curve looks like this:

1
|    **************
|  **
| *
| *
|*
|*
|*
|___________________
0                   1

With a biasAmt of 0.5, Bias returns X.
```

________________________________

<a name="f_Gain"></a>
```cpp
float VS::Gain(float x, float biasAmt)
```

```
Gain is similar to Bias, but biasAmt biases towards or away from 0.5.
Lower bias values bias towards 0.5 and higher bias values bias away from it.

For example, with biasAmt = 0.2, the curve looks like this:

1
|                  *
|                 *
|                **
|  ***************
| **
| *
|*
|___________________
0                   1


With biasAmt = 0.8, the curve looks like this:

1
|            *****
|         ***
|        *
|        *
|        *
|     ***
|*****
|___________________
0                   1
```

________________________________

<a name="f_SmoothCurve"></a>
```cpp
float VS::SmoothCurve(float x)
```

```
SmoothCurve maps a 0-1 value into another 0-1 value based on a cosine wave
where the derivatives of the function at 0 and 1 (and 0.5) are 0. This is useful for
any fadein/fadeout effect where it should start and end smoothly.

The curve looks like this:

1
|        **
|       *  *
|      *    *
|      *    *
|     *      *
|   **        **
|***            ***
|___________________
0                   1
```

________________________________

<a name="f_MovePeak"></a>
```cpp
float VS::MovePeak(float x, float flPeakPos)
```

________________________________

<a name="f_SmoothCurve_Tweak"></a>
```cpp
float VS::SmoothCurve_Tweak(float x, float flPeakPos, float flPeakSharpness)
```
This works like SmoothCurve, with two changes:  

1. Instead of the curve peaking at 0.5, it will peak at flPeakPos.  
   (So if you specify flPeakPos=0.2, then the peak will slide to the left).  

2. flPeakSharpness is a 0-1 value controlling the sharpness of the peak.  
   Low values blunt the peak and high values sharpen the peak.

________________________________

<a name="f_Lerp"></a>
```cpp
float VS::Lerp(float A, float B, float f)
```

________________________________

<a name="f_FLerp"></a>
```cpp
float VS::FLerp(float f1, float f2, float i1, float i2, float x)
```
```
5-argument floating point linear interpolation.  
FLerp(f1,f2,i1,i2,x)=  
   f1 at x=i1  
   f2 at x=i2  
  smooth lerp between f1 and f2 at x>i1 and x<i2  
  extrapolation for x<i1 or x>i2  

  If you know a function f(x)'s value (f1) at position i1, and its value (f2) at position i2,  
  the function can be linearly interpolated with FLerp(f1,f2,i1,i2,x)  
   i2=i1 will cause a divide by zero.
```
________________________________

<a name="f_VectorLerp"></a>
```cpp
Vector VS::VectorLerp(Vector v1, Vector v2, float f, Vector& out = _VEC)
```
________________________________

<a name="f_DotProductAbs"></a>
```cpp
float VS::DotProductAbs(Vector in1, Vector in2)
```

________________________________

<a name="f_QuaternionsAreEqual"></a>
```cpp
bool VS::QuaternionsAreEqual(Quaternion a, Quaternion b, float tolerance = 0.0)
```

________________________________

<a name="f_QuaternionNormalize"></a>
```cpp
float VS::QuaternionNormalize(Quaternion& q)
```
Make sure the quaternion is of unit length

Return radius
________________________________

<a name="f_QuaternionAlign"></a>
```cpp
Quaternion VS::QuaternionAlign(Quaternion p, Quaternion q, Quaternion& qt = _QUAT)
```
make sure quaternions are within 180 degrees of one another, if not, reverse q
________________________________

<a name="f_QuaternionMult"></a>
```cpp
Quaternion VS::QuaternionMult(Quaternion p, Quaternion q, Quaternion& qt = _QUAT)
```
`qt = p * q`
________________________________

<a name="f_QuaternionConjugate"></a>
```cpp
void VS::QuaternionConjugate(Quaternion p, Quaternion& q)
```

________________________________

<a name="f_QuaternionMA"></a>
```cpp
Quaternion VS::QuaternionMA(Quaternion p, float s, Quaternion q, Quaternion& qt = _QUAT)
```
`qt = p * ( s * q )`
________________________________

<a name="f_QuaternionAdd"></a>
```cpp
Quaternion VS::QuaternionAdd(Quaternion p, Quaternion q, Quaternion& qt = _QUAT)
```

________________________________

<a name="f_QuaternionDotProduct"></a>
```cpp
float VS::QuaternionDotProduct(Quaternion p, Quaternion q)
```

________________________________

<a name="f_QuaternionInvert"></a>
```cpp
void VS::QuaternionInvert(Quaternion p, Quaternion& q)
```

________________________________

<a name="f_QuaternionBlend"></a>
```cpp
Quaternion VS::QuaternionBlend(Quaternion p, Quaternion q, float t, Quaternion& qt = _QUAT)
```
Do a piecewise addition of the quaternion elements. This is a cheap way to simulate a slerp.
________________________________

<a name="f_QuaternionBlendNoAlign"></a>
```cpp
Quaternion VS::QuaternionBlendNoAlign(Quaternion p, Quaternion q, float t, Quaternion& qt = _QUAT)
```

________________________________

<a name="f_QuaternionIdentityBlend"></a>
```cpp
Quaternion VS::QuaternionIdentityBlend(Quaternion p, float t, Quaternion& qt = _QUAT)
```

________________________________

<a name="f_QuaternionSlerp"></a>
```cpp
Quaternion VS::QuaternionSlerp(Quaternion p, Quaternion q, float t, Quaternion& qt = _QUAT)
```
Quaternion sphereical linear interpolation
________________________________

<a name="f_QuaternionSlerpNoAlign"></a>
```cpp
Quaternion VS::QuaternionSlerpNoAlign(Quaternion p, Quaternion q, float t, Quaternion& qt = _QUAT)
```

________________________________

<a name="f_QuaternionLn"></a>
```cpp
void VS::QuaternionLn(Quaternion p, Quaternion &q)
```
Computes the natural logarithm of a given unit quaternion. If input is not a unit quaternion, the returned value is undefined.
________________________________

<a name="f_QuaternionExp"></a>
```cpp
void VS::QuaternionExp(Quaternion p, Quaternion &q)
```
Computes the exponential of a given pure quaternion. The w-component of the input quaternion is ignored in the calculation.
________________________________

<a name="f_QuaternionSquad"></a>
```cpp
void VS::QuaternionSquad(Quaternion q0, Quaternion q1, Quaternion q2, Quaternion q3, float t, Quaternion &qt)
```
Interpolates between quaternions Q1 to Q2, using spherical quadrangle interpolation.
________________________________

<a name="f_QuaternionAverageExponential"></a>
```cpp
void VS::QuaternionAverageExponential(Quaternion &q, int nCount, Quaternion[] stack)
```

________________________________

<a name="f_QuaternionAngleDiff"></a>
```cpp
float VS::QuaternionAngleDiff(Quaternion p, Quaternion q)
```
Returns the angular delta between the two normalized quaternions in degrees.
________________________________

<a name="f_QuaternionScale"></a>
```cpp
void VS::QuaternionScale(Quaternion p, float t, Quaternion &q)
```
________________________________

<a name="f_RotationDeltaAxisAngle"></a>
```cpp
float VS::RotationDeltaAxisAngle( QAngle srcAngles, QAngle destAngles, Vector &deltaAxis )
```
returns deltaAngle
________________________________

<a name="f_RotationDelta"></a>
```cpp
void VS::RotationDelta( QAngle srcAngles, QAngle destAngles, QAngle &out )
```

________________________________

<a name="f_QuaternionMatrix"></a>
```cpp
void VS::QuaternionMatrix(Quaternion q, Vector pos, matrix3x4_t& matrix)
```
Quaternion -> matrix3x4
________________________________

<a name="f_QuaternionAngles"></a>
```cpp
QAngle VS::QuaternionAngles(Quaternion q, Vector& angles = _VEC)
```
Quaternion -> QAngle
________________________________

<a name="f_QuaternionAxisAngle"></a>
```cpp
float VS::QuaternionAxisAngle(Quaternion q, Vector& axis)
```
Converts a quaternion to an axis / angle in degrees (exponential map)
________________________________

<a name="f_AxisAngleQuaternion"></a>
```cpp
Quaternion VS::AxisAngleQuaternion(Vector axis, float angle, Quaternion& q = _QUAT)
```
Converts an exponential map (ang/axis) to a quaternion
________________________________

<a name="f_AngleQuaternion"></a>
```cpp
Quaternion VS::AngleQuaternion(QAngle angles, Quaternion& out = _QUAT)
```
QAngle -> Quaternion

________________________________

<a name="f_MatrixQuaternion"></a>
```cpp
Quaternion VS::MatrixQuaternion(matrix3x4_t mat, Quaternion& q = _QUAT)
```
matrix3x4 -> Quaternion
________________________________

<a name="f_MatrixQuaternionFast"></a>
```cpp
Quaternion VS::MatrixQuaternionFast(matrix3x4_t matrix, Quaternion& angles)
```
matrix3x4 -> Quaternion
________________________________

<a name="f_BasisToQuaternion"></a>
```cpp
Quaternion VS::BasisToQuaternion(Vector forward, Vector right, Vector up, Quaternion& q = _QUAT)
```
Converts a basis to a quaternion
________________________________

<a name="f_MatrixAngles"></a>
```cpp
QAngle VS::MatrixAngles(matrix3x4_t matrix, Vector& angles = _VEC, Vector &position = null)
```
Generates QAngle given a left-handed orientation matrix.
________________________________

<a name="f_AngleMatrix"></a>
```cpp
void VS::AngleMatrix(QAngle angles, Vector position, matrix3x4_t& matrix)
```
QAngle -> matrix3x4 (left-handed)
________________________________

<a name="f_AngleIMatrix"></a>
```cpp
void VS::AngleIMatrix(QAngle angles, Vector position, matrix3x4_t& mat)
```

________________________________

<a name="f_VectorMatrix"></a>
```cpp
void VS::VectorMatrix(Vector forward, matrix3x4_t &matrix)
```

________________________________

<a name="f_MatrixVectors"></a>
```cpp
void VS::MatrixVectors(matrix3x4_t matrix, Vector& forward, Vector& right, Vector& up)
```
matrix3x4 -> basis

Matrix is right-handed x=forward, y=left, z=up.

Valve uses left-handed convention for vectors in the game code (forward, right, up)
________________________________

<a name="f_MatricesAreEqual"></a>
```cpp
bool VS::MatricesAreEqual(matrix3x4_t src1, matrix3x4_t src2, float flTolerance)
```

________________________________

<a name="f_MatrixCopy"></a>
```cpp
matrix3x4_t VS::MatrixCopy(matrix3x4_t src, matrix3x4_t& dst)
```

________________________________

<a name="f_MatrixInvert"></a>
```cpp
void VS::MatrixInvert(matrix3x4_t src, matrix3x4_t& dst)
```
NOTE: This is just the transpose not a general inverse
________________________________

<a name="f_MatrixInverseGeneral"></a>
```cpp
void VS::MatrixInverseGeneral(VMatrix src, VMatrix& dst)
```

________________________________

<a name="f_MatrixInverseTR"></a>
```cpp
void VS::MatrixInverseTR(VMatrix src, VMatrix& dst)
```
Does a fast inverse, assuming the matrix only contains translation and rotation.
________________________________

<a name="f_MatrixGetColumn"></a>
```cpp
Vector VS::MatrixGetColumn(matrix3x4_t in1, int column, Vector& out)
```

________________________________

<a name="f_MatrixSetColumn"></a>
```cpp
void VS::MatrixSetColumn(Vector in1, int column, matrix3x4_t& out)
```

________________________________

<a name="f_MatrixScaleBy"></a>
```cpp
void VS::MatrixScaleBy(float flScale, matrix3x4_t& out)
```

________________________________

<a name="f_MatrixScaleByZero"></a>
```cpp
void VS::MatrixScaleByZero(matrix3x4_t& out)
```

________________________________

<a name="f_SetIdentityMatrix"></a>
```cpp
void VS::SetIdentityMatrix(matrix3x4_t& matrix)
```

________________________________

<a name="f_SetScaleMatrix"></a>
```cpp
void VS::SetScaleMatrix(float x, float y, float z, matrix3x4_t& dst)
```
Builds a scale matrix
________________________________

<a name="f_ComputeCenterMatrix"></a>
```cpp
void VS::ComputeCenterMatrix(Vector origin, QAngle angles, Vector mins, Vector maxs, matrix3x4_t& matrix)
```
Compute a matrix that has the correct orientation but which has an origin at the center of the bounds
________________________________

<a name="f_ComputeCenterIMatrix"></a>
```cpp
void VS::ComputeCenterIMatrix(Vector origin, QAngle angles, Vector mins, Vector maxs, matrix3x4_t& matrix)
```

________________________________

<a name="f_ComputeAbsMatrix"></a>
```cpp
void VS::ComputeAbsMatrix(matrix3x4_t in1, matrix3x4_t& out)
```
Compute a matrix which is the absolute value of another
________________________________

<a name="f_ConcatRotations"></a>
```cpp
void VS::ConcatRotations(matrix3x4_t in1, matrix3x4_t in2, matrix3x4_t& out)
```

________________________________

<a name="f_ConcatTransforms"></a>
```cpp
void VS::ConcatTransforms(matrix3x4_t in1, matrix3x4_t in2, matrix3x4_t& out)
```
`MatrixMultiply`
________________________________

<a name="f_MatrixMultiply"></a>
```cpp
void VS::MatrixMultiply(VMatrix in1, VMatrix in2, VMatrix& out)
```

________________________________

<a name="f_MatrixBuildRotationAboutAxis"></a>
```cpp
void VS::MatrixBuildRotationAboutAxis(Vector vAxisOfRot, float angleDegrees, matrix3x4_t& dst)
```
Builds the matrix for a counterclockwise rotation about an arbitrary axis.
________________________________

<a name="f_MatrixBuildRotation"></a>
```cpp
void VS::MatrixBuildRotation( matrix3x4_t& dst, Vector initialDirection, Vector finalDirection )
```
Builds a rotation matrix that rotates one direction vector into another.
________________________________

<a name="f_VectorTransform"></a>
```cpp
Vector VS::VectorTransform(Vector in1, matrix3x4_t in2, Vector& out = _VEC)
```
transform in1 by the matrix in2
________________________________

<a name="f_VectorITransform"></a>
```cpp
Vector VS::VectorITransform(Vector in1, matrix3x4_t in2, Vector& out = _VEC)
```
assuming the matrix is orthonormal, transform in1 by the transpose (also the inverse in this case) of in2.
________________________________

<a name="f_VectorRotate"></a>
```cpp
Vector VS::VectorRotate(Vector in1, matrix3x4_t in2, Vector& out = _VEC)
```
assume in2 is a rotation and rotate the input vector
________________________________

<a name="f_VectorRotateByAngle"></a>
```cpp
Vector VS::VectorRotateByAngle(Vector in1, QAngle in2, Vector& out = _VEC)
```
assume in2 is a rotation and rotate the input vector
________________________________

<a name="f_VectorRotateByQuaternion"></a>
```cpp
Vector VS::VectorRotateByQuaternion(Vector in1, Quaternion in2, Vector& out = _VEC)
```
assume in2 is a rotation and rotate the input vector
________________________________

<a name="f_VectorIRotate"></a>
```cpp
Vector VS::VectorIRotate(Vector in1, matrix3x4_t in2, Vector& out = _VEC)
```
rotate by the inverse of the matrix
________________________________

<a name="f_Vector3DMultiplyProjective"></a>
```cpp
void VS::Vector3DMultiplyProjective( VMatrix src1, Vector src2, Vector &dst )
```
Vector3DMultiplyProjective treats src2 as if it's a direction and does the perspective divide at the end.
________________________________

<a name="f_Vector3DMultiplyPositionProjective"></a>
```cpp
void VS::Vector3DMultiplyPositionProjective( VMatrix src1, Vector src2, Vector &dst )
```
Vector3DMultiplyPositionProjective treats src2 as if it's a point and does the perspective divide at the end
________________________________

<a name="f_TransformAABB"></a>
```cpp
void VS::TransformAABB(matrix3x4_t transform, Vector vecMinsIn, Vector vecMaxsIn, Vector& vecMinsOut, Vector& vecMaxsOut)
```
Transforms a AABB into another space; which will inherently grow the box.
________________________________

<a name="f_ITransformAABB"></a>
```cpp
void VS::ITransformAABB(matrix3x4_t transform, Vector vecMinsIn, Vector vecMaxsIn, Vector& vecMinsOut, Vector& vecMaxsOut)
```
Uses the inverse transform of in1
________________________________

<a name="f_RotateAABB"></a>
```cpp
void VS::RotateAABB(matrix3x4_t transform, Vector vecMinsIn, Vector vecMaxsIn, Vector& vecMinsOut, Vector& vecMaxsOut)
```
Rotates a AABB into another space; which will inherently grow the box.

(same as TransformAABB, but doesn't take the translation into account)
________________________________

<a name="f_IRotateAABB"></a>
```cpp
void VS::IRotateAABB(matrix3x4_t transform, Vector vecMinsIn, Vector vecMaxsIn, Vector& vecMinsOut, Vector& vecMaxsOut)
```
________________________________

<a name="f_GetBoxVertices"></a>
```cpp
void VS::GetBoxVertices( Vector origin, QAngle angles, Vector mins, Vector maxs, Vector[8] pVertices )
```
Get the vertices of a rotated box.

```
+z
^   +y
|  /
| /
   ----> +x

   3-------7
  /|      /|
 / |     / |
1--2----5  6
| /     | /
|/      |/
0-------4
```
________________________________

<a name="f_MatrixBuildPerspective"></a>
```cpp
void VS::MatrixBuildPerspective( VMatrix& dst, float fovX, float flAspect, float zNear, float zFar )
```
Build a perspective matrix.  
zNear and zFar are assumed to be positive.  
You end up looking down positive Z, X is to the right, Y is up.  
X range: [0..1]  
Y range: [0..1]  
Z range: [0..1]
________________________________

<a name="f_ComputeViewMatrix"></a>
```cpp
void VS::ComputeViewMatrix( VMatrix &pWorldToView, Vector origin, Vector forward, Vector left, Vector up )
```

________________________________

<a name="f_ScreenToWorldMatrix"></a>
```cpp
void VS::ScreenToWorldMatrix( VMatrix& pOut, Vector origin, Vector forward, Vector right, Vector up, float fov, float flAspect, float zNear, float zFar )
```

________________________________

<a name="f_ScreenToWorld"></a>
```cpp
Vector VS::ScreenToWorld( float x, float y, VMatrix screenToWorld, Vector &pOut = _VEC )
```
```cs
{
	local x = 0.35
	local y = 0.65
	local eyeAng = player.EyeAngles()
	local eyePos = player.EyePosition()
	local mat = VMatrix();
	VS.ScreenToWorldMatrix(
		mat,
		eyePos,
		player.EyeForward(),
		player.EyeRight(),
		player.EyeUp(),
		90.0,
		16.0/9.0,
		1.0,
		16.0 );

	local worldPos = VS.ScreenToWorld( x, y, mat );

	local maxs = vec3_t( 0.0, 0.5, 0.5 );
	DrawBoxAnglesFilled( worldPos, -maxs, maxs, eyeAng, 0, 255, 255, 64, 5.0 );
}
```
________________________________

<a name="f_ComputeCameraVariables"></a>
```cpp
void VS::ComputeCameraVariables( Vector vecOrigin, Vector pVecForward, Vector pVecRight, Vector pVecUp, VMatrix &pMatCamInverse )
```
Compute camera matrix.

This returns the inverted inverse camera matrix to simplify its local usage - _technically_ it's not the camera matrix. This may have unwanted effects if not expected, but for the purposes of its usage here, it is fine.
________________________________

<a name="f_CalcFovY"></a>
```cpp
float VS::CalcFovY( float flFovX, float flAspect )
```
Computes Y fov from an X fov and a screen aspect ratio
________________________________

<a name="f_CalcFovX"></a>
```cpp
float VS::CalcFovX( float flFovY, float flAspect )
```
Computes X fov from an Y fov and a screen aspect ratio
________________________________

<a name="f_DrawFrustum"></a>
```cpp
void VS::DrawFrustum( VMatrix matWorldToView, int r, int g, int b, bool z, float time )
```
________________________________

<a name="f_DrawViewFrustum"></a>
```cpp
void VS::DrawViewFrustum( Vector vecOrigin, Vector vecForward, Vector vecRight, Vector vecUp,
		float flFovX, float flAspect, float zNear, float zFar, int r, int g, int b, bool z, float time )
```
________________________________

<a name="f_DrawBoxAngles"></a>
```cpp
void VS::DrawBoxAngles( Vector origin, Vector mins, Vector maxs, QAngle angles, int r, int g, int b, bool z, float time )
```
Draws an oriented box at the origin. Specify mins and maxs in local space.

The newly added `DebugDrawBoxAngles` can have filled textures, but its lines are always Z tested. This function can be used to draw oriented box lines behind walls.
________________________________

<a name="f_DrawSphere"></a>
```cpp
void VS::DrawSphere( Vector vCenter, float flRadius, int nTheta, int nPhi, int r, int g, int b, bool z, float time )
```
________________________________

<a name="f_DrawCapsule"></a>
```cpp
void VS::DrawCapsule( Vector start, Vector end, float radius, int r, int g, int b, bool z, float time )
```
________________________________

<a name="f_DrawHorzArrow"></a>
```cpp
void VS::DrawHorzArrow( Vector startPos, Vector endPos, float width, int r, int g, int b, bool noDepthTest, float flDuration )
```
________________________________

<a name="f_DrawVertArrow"></a>
```cpp
void VS::DrawVertArrow( Vector startPos, Vector endPos, float width, int r, int g, int b, bool noDepthTest, float flDuration )
```
________________________________

<a name="f_INTERPOLATE"></a>
```cpp
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
```

________________________________

<a name="f_Interpolator_GetKochanekBartelsParams"></a>
```cpp
void VS::Interpolator_GetKochanekBartelsParams(int interpolationType, float& tbc[3])
```

________________________________

<a name="f_Interpolator_CurveInterpolate"></a>
```cpp
Vector VS::Interpolator_CurveInterpolate(int interpolationType, Vector vPre, Vector vStart, Vector vEnd, Vector vNext, f, Vector& vOut)
```

________________________________

<a name="f_Interpolator_CurveInterpolate_NonNormalized"></a>
```cpp
Vector VS::Interpolator_CurveInterpolate_NonNormalized(int interpolationType, Vector vPre, Vector vStart, Vector vEnd, Vector vNext, f, Vector& vOut)
```

________________________________

<a name="f_Spline_Normalize"></a>
```cpp
void VS::Spline_Normalize(Vector p1, Vector p2, Vector p3, Vector p4, Vector p1n, Vector p4n)
```
A helper function to normalize p2.x->p1.x and p3.x->p4.x to be the same length as p2.x->p3.x
________________________________

<a name="f_Catmull_Rom_Spline"></a>
```cpp
Vector VS::Catmull_Rom_Spline(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```
Interpolate a Catmull-Rom spline.

t is a [0,1] value and interpolates a curve between p2 and p3.
________________________________

<a name="f_Catmull_Rom_Spline_Tangent"></a>
```cpp
Vector VS::Catmull_Rom_Spline_Tangent(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```
Interpolate a Catmull-Rom spline.

Returns the tangent of the point at t of the spline
________________________________

<a name="f_Catmull_Rom_Spline_Integral"></a>
```cpp
Vector VS::Catmull_Rom_Spline_Integral(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```
area under the curve [0..t]
________________________________

<a name="f_Catmull_Rom_Spline_Integral2"></a>
```cpp
Vector VS::Catmull_Rom_Spline_Integral2(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```
area under the curve [0..1]
________________________________

<a name="f_Catmull_Rom_Spline_Normalize"></a>
```cpp
Vector VS::Catmull_Rom_Spline_Normalize(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```
Interpolate a Catmull-Rom spline.

Normalize p2->p1 and p3->p4 to be the same length as p2->p3
________________________________

<a name="f_Catmull_Rom_Spline_Integral_Normalize"></a>
```cpp
Vector VS::Catmull_Rom_Spline_Integral_Normalize(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```
area under the curve [0..t]

Normalize p2->p1 and p3->p4 to be the same length as p2->p3
________________________________

<a name="f_Catmull_Rom_Spline_NormalizeX"></a>
```cpp
Vector VS::Catmull_Rom_Spline_NormalizeX(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```
Interpolate a Catmull-Rom spline.

Normalize p2.x->p1.x and p3.x->p4.x to be the same length as p2.x->p3.x
________________________________

<a name="f_Hermite_Spline"></a>
```cpp
Vector VS::Hermite_Spline(Vector p1, Vector p2, Vector d1, Vector d2, float t, Vector& output)
```
Basic hermite spline

t = 0 returns p1,  
t = 1 returns p2,  
d1 and d2 are used to entry and exit slope of curve
________________________________

<a name="f_Hermite_SplineF"></a>
```cpp
float VS::Hermite_SplineF(float p1, float p2, float d1, float d2, float t)
```

________________________________

<a name="f_Hermite_SplineBasis"></a>
```cpp
void VS::Hermite_SplineBasis(float t, float& basis[4])
```

________________________________

<a name="f_Hermite_Spline3V"></a>
```cpp
Vector VS::Hermite_Spline3V(Vector p0, Vector p1, Vector p2, float t, Vector& output)
```
Simple three data point hermite spline.

t = 0 returns p1, t = 1 returns p2,  
slopes are generated from the p0->p1 and p1->p2 segments  
this is reasonable C1 method when there's no "p3" data yet.
________________________________

<a name="f_Hermite_Spline3F"></a>
```cpp
float VS::Hermite_Spline3F(float p0, float p1, float p2, float t)
```

________________________________

<a name="f_Hermite_Spline3Q"></a>
```cpp
Quaternion VS::Hermite_Spline3Q(Quaternion q0, Quaternion q1, Quaternion q2, float t, Quaternion& output)
```

________________________________

<a name="f_Kochanek_Bartels_Spline"></a>
```cpp
Vector VS::Kochanek_Bartels_Spline(float tension, float bias, float continuity, Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```

See http://en.wikipedia.org/wiki/Kochanek-Bartels_curves

Tension:    -1 = Round -> 1 = Tight  
Bias:       -1 = Pre-shoot (bias left) -> 1 = Post-shoot (bias right)  
Continuity: -1 = Box corners -> 1 = Inverted corners

If T=B=C=0 it's the same matrix as Catmull-Rom.  
If T=1 & B=C=0 it's the same as Cubic.  
If T=B=0 & C=-1 it's just linear interpolation

See http://news.povray.org/povray.binaries.tutorials/attachment/%3CXns91B880592482seed7@povray.org%3E/Splines.bas.txt
for example code and descriptions of various spline types...

________________________________

<a name="f_Kochanek_Bartels_Spline_NormalizeX"></a>
```cpp
Vector VS::Kochanek_Bartels_Spline_NormalizeX(float tension, float bias, float continuity, Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```

________________________________

<a name="f_Cubic_Spline"></a>
```cpp
Vector VS::Cubic_Spline(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```
See link at Kochanek_Bartels_Spline for info on the basis matrix used
________________________________

<a name="f_Cubic_Spline_NormalizeX"></a>
```cpp
Vector VS::Cubic_Spline_NormalizeX(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```

________________________________

<a name="f_BSpline"></a>
```cpp
Vector VS::BSpline(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```
See link at Kochanek_Bartels_Spline for info on the basis matrix used
________________________________

<a name="f_BSpline_NormalizeX"></a>
```cpp
Vector VS::BSpline_NormalizeX(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```

________________________________

<a name="f_Parabolic_Spline"></a>
```cpp
Vector VS::Parabolic_Spline(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```
See link at Kochanek_Bartels_Spline for info on the basis matrix used
________________________________

<a name="f_Parabolic_Spline_NormalizeX"></a>
```cpp
Vector VS::Parabolic_Spline_NormalizeX(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```

________________________________

<a name="f_RangeCompressor"></a>
```cpp
float VS::RangeCompressor(float flValue, float flMin, float flMax, float flBase)
```
Compress the input values for a ranged result such that from 75% to 200% smoothly of the range maps
________________________________

<a name="f_InterpolateAngles"></a>
```cpp
QAngle VS::InterpolateAngles(QAngle v1, QAngle v2, float flPercent, QAngle &out)
```
QAngle slerp
________________________________

<a name="f_PointOnLineNearestPoint"></a>
```cpp
Vector VS::PointOnLineNearestPoint(Vector start, Vector end, Vector point)
```
________________________________

<a name="f_CalcSqrDistanceToAABB"></a>
```cpp
float VS::CalcSqrDistanceToAABB(Vector mins, Vector maxs, Vector point)
```
________________________________

<a name="f_CalcClosestPointOnAABB"></a>
```cpp
Vector VS::CalcClosestPointOnAABB(Vector mins, Vector maxs, Vector point, Vector& closestOut = _VEC)
```
________________________________

<a name="f_Ray_t"></a>
```cpp
class Ray_t
{
	Vector m_Start;
	Vector m_Delta;
	Vector m_StartOffset;
	Vector m_Extents;
	bool m_IsRay;
	bool m_IsSwept;

	void Init( Vector start, Vector end, Vector mins = null, Vector maxs = null );
}
```
________________________________

<a name="f_ComputeBoxOffset"></a>
```cpp
float VS::ComputeBoxOffset(Ray_t ray)
```
Compute the offset in t along the ray that we'll use for the collision
________________________________

<a name="f_IntersectRayWithTriangle"></a>
```cpp
float VS::IntersectRayWithTriangle( Ray_t ray, Vector v1, Vector v2, Vector v3, bool oneSided )
```
Intersects a swept box against a triangle.

t will be less than zero if no intersection occurred.

oneSided will cull collisions which approach the triangle from the back side, assuming the vertices are specified in counter-clockwise order.

The vertices need not be specified in that order if oneSided is not used
________________________________

<a name="f_ComputeIntersectionBarycentricCoordinates"></a>
```cpp
bool VS::ComputeIntersectionBarycentricCoordinates( Ray_t ray, Vector v1, Vector v2, Vector v3, float[3] uvt )
```
Figures out the barycentric coordinates (u,v) where a ray hits a triangle.

Note that this will ignore the ray extents, and it also ignores the ray length.

Note that the edge from v1->v2 represents u (v2: u = 1), and the edge from v1->v3 represents v (v3: v = 1).

It returns false if the ray is parallel to the triangle (or when t is specified if t is less than zero).
________________________________

<a name="f_IsPointInBox"></a>
```cpp
bool VS::IsPointInBox(Vector vec, Vector boxmin, Vector boxmax)
```
________________________________

<a name="f_IsBoxIntersectingBox"></a>
```cpp
bool VS::IsBoxIntersectingBox(Vector boxMin1, Vector boxMax1, Vector boxMin2, Vector boxMax2)
```
Return true of the boxes intersect (but not if they just touch)
________________________________

<a name="f_IsPointInCone"></a>
```cpp
bool VS::IsPointInCone(Vector pt, Vector origin, Vector axis, float cosAngle, float length)
```
returns true if pt intersects the truncated cone

origin - cone tip,  
axis - unit cone axis,  
cosAngle - cosine of cone axis to surface angle
________________________________

<a name="f_IsSphereIntersectingSphere"></a>
```cpp
bool VS::IsSphereIntersectingSphere(Vector center1, float radius1, Vector center2, float radius2)
```
Returns true if a box intersects with a sphere
________________________________

<a name="f_IsBoxIntersectingSphere"></a>
```cpp
bool VS::IsBoxIntersectingSphere(Vector boxMin, Vector boxMax, Vector center, float radius)
```
Returns true if a box intersects with a sphere
________________________________

<a name="f_IsCircleIntersectingRectangle"></a>
```cpp
bool VS::IsCircleIntersectingRectangle(Vector boxMin, Vector boxMax, Vector center, float radius)
```
Returns true if a rectangle intersects with a circle
________________________________

<a name="f_IsRayIntersectingSphere"></a>
```cpp
bool VS::IsRayIntersectingSphere(Vector vecRayOrigin, Vector vecRayDelta, Vector vecCenter, float flRadius, float flTolerance = 0.0)
```
returns true if there's an intersection between ray and sphere

`flTolerance [0..1]`
________________________________

<a name="f_IntersectInfiniteRayWithSphere"></a>
```cpp
bool VS::IntersectInfiniteRayWithSphere( Vector vecRayOrigin, Vector vecRayDelta, Vector vecSphereCenter, float flRadius, float pT[2] )
```
Returns whether or not there was an intersection. Returns the two intersection points.
________________________________

<a name="f_IsBoxIntersectingRay"></a>
```cpp
bool VS::IsBoxIntersectingRay(Vector boxMin, Vector boxMax, Vector origin, Vector vecDelta, float flTolerance = 0.0)
```
Intersects a ray with a AABB, return true if they intersect

Input  : worldMins, worldMaxs
________________________________

<a name="f_IsBoxIntersectingRay2"></a>
```cpp
bool VS::IsBoxIntersectingRay2(Vector origin, Vector vecBoxMin, Vector vecBoxMax, Ray_t ray, float flTolerance = 0.0)
```
Intersects a ray with a AABB, return true if they intersect

Input  : localMins, localMaxs
________________________________

<a name="f_IntersectRayWithRay"></a>
```cpp
bool VS::IntersectRayWithRay( Vector vecStart0, Vector vecDelta0, Vector vecStart1, Vector vecDelta1 )
```
Intersects a ray with a ray, return true if they intersect
________________________________

<a name="f_IntersectRayWithPlane"></a>
```cpp
float VS::IntersectRayWithPlane( Vector start, Vector dir, Vector normal, float dist )
```
returns distance along ray
________________________________

<a name="f_IntersectRayWithBox"></a>
```cpp
bool VS::IntersectRayWithBox( Vector vecRayStart, Vector vecRayDelta,
	Vector boxMins, Vector boxMaxs, float flTolerance, float[2] pTrace )
```
Intersects a ray against a box, returns t1 and t2
________________________________

<a name="f_IntersectRayWithOBB"></a>
```cpp
bool VS::IntersectRayWithOBB( Vector vecRayStart, Vector vecRayDelta, matrix3x4_t matOBBToWorld,
	Vector vecOBBMins, Vector vecOBBMaxs, float flTolerance, float[2] pTrace )
```
Intersects a ray against an OBB, returns t1 and t2
________________________________

<a name="f_IsRayIntersectingOBB"></a>
```cpp
bool VS::IsRayIntersectingOBB( Ray_t ray, Vector org, QAngle angles, Vector mins, Vector maxs )
```
Swept OBB test
________________________________


### [vs_utility](https://github.com/samisalreadytaken/vs_library/blob/master/src/vs_utility.nut)
________________________________

<a name="f_Ent"></a>
```cpp
handle Ent(string targetname, handle startEntity = null)
```
Find entity by targetname (wrapper function). Meant for initial entity getting without the text getting lengthy and harder to read using `Entities.FindByName`

E.g. compare the following

```cs
hEnt0 <- Ent("entname0")
hEnt1 <- Ent("entname1")
hEnt2 <- Ent("entname2")

hEnt0 <- Entities.FindByName(null,"entname0")
hEnt1 <- Entities.FindByName(null,"entname1")
hEnt2 <- Entities.FindByName(null,"entname2")
```
________________________________

<a name="f_Entc"></a>
```cpp
handle Entc(string classname, handle startEntity = null)
```
Find entity by classname (wrapper function). Read above
________________________________

<a name="f_delay"></a>
```cpp
void delay(string exec, float time = 0.0, handle ent = World, handle activator = null, handle caller = null)
```
Deprecated. Use [`VS.EventQueue.AddEvent`](#f_EventQueueAddEvent).

________________________________

<a name="f_Chat"></a>
```cpp
void Chat(string s)
```
Wrapper function for `ScriptPrintMessageChatAll`, but allows text colour to be the first character.

```
// colour will not work
ScriptPrintMessageChatAll(TextColor.Red + "lorem ipsum")

// will be coloured
Chat(TextColor.Red + "lorem ipsum")
```
________________________________

<a name="f_ChatTeam"></a>
```cpp
void ChatTeam(int team, string s)
```
Wrapper function for `ScriptPrintMessageChatTeam`. Read above
________________________________

<a name="f_Alert"></a>
```cpp
void Alert(string s)
```
Shorter name for `ScriptPrintMessageCenterAll`
________________________________

<a name="f_AlertTeam"></a>
```cpp
void AlertTeam(int team, string s)
```
Shorter name for `ScriptPrintMessageCenterTeam`
________________________________

<a name="f_CenterPrintAll"></a>
```cpp
void CenterPrintAll(string s)
```
```cpp
local v = VS.RandomVector();

CenterPrintAll(format( "\n<font color='#ff0000'>%.2f</font>\n<font color='#00ff00'>%.2f</font>\n<font color='#0000ff'>%.2f</font>", v.x, v.y, v.z ));
```
________________________________

<a name="f_TextColor"></a>
```cpp
TextColor
{
	Normal = 1,   // white
	Red,          // red
	Purple,       // purple
	Location,     // lime green
	Achievement,  // light green
	Award,        // green
	Penalty,      // light red
	Silver,       // grey
	Gold,         // yellow
	Common,       // grey blue
	Uncommon,     // light blue
	Rare,         // dark blue
	Mythical,     // dark grey
	Legendary,    // pink
	Ancient,      // orange red
	Immortal      // orange
}
```
`Chat( TextColor.Red + "RED" + TextColor.Gold + " YELLOW" + TextColor.Normal + " WHITE" )`
________________________________

<a name="f_VecToString"></a>
```cpp
string VecToString(Vector vec)
```
return `"Vector(0, 1, 2)"`
________________________________

<a name="f_ToExtendedPlayer"></a>
```cpp
class CExtendedPlayer
{
	const CBaseMultiplayerPlayer self;
	const int m_EntityIndex;
	const table m_ScriptScope;
	const int userid;
	const string networkid;
	const string name;
	const bool bot;

	bool IsBot();
	int GetUserid();
	string GetNetworkIDString();
	string GetPlayerName();

	QAngle EyeAngles();
	Vector EyeForward();
	Vector EyeRight();
	Vector EyeUp();

	void SetName( string targetname );
	void SetEffects( int n );
	void SetMoveType( int n );
	void SetFOV( int fov, float rate );
	void SetParent( CBaseEntity parent, string attachment );

	void SetInputCallback( string szInput, closure callback, table env );
}

CExtendedPlayer ToExtendedPlayer( CBaseMultiplayerPlayer player )
```

There is no performance penalty for using `CExtendedPlayer` exclusively.

One aspect to pay attention to is passing players to native functions such as `EntFireByHandle` or `CEntities::Next`. Use `CExtendedPlayer::self` for passing player parameters to native functions.

```cs
local ply = ToExtendedPlayer( VS.GetPlayerByIndex(1) );

EntFireByHandle( ply.self, "SetHealth", 1 );
```

The following members and their corresponding functions require event listener setup: `userid`, `networkid`, `name`, `bot`.

Player is passed as parameter to the `SetInputCallback` callback function. `szInput == null` turns off the input listener. `callback == null` removes the callback.

List of available inputs:
```
+use
+attack
-attack
+attack2
-attack2
+forward
-forward
+back
-back
+moveleft
-moveleft
+moveright
-moveright
```

```cs
VS.ListenToGameEvent( "player_spawn", function(ev)
{
	local ply = VS.GetPlayerByUserid( ev.userid );
	if (!ply)
		return;
	ply = ToExtendedPlayer( ply );

	if ( !ply.IsBot() )
	{
		ply.SetInputCallback( "+forward",  function(ply) { printl("+forward " + ply.GetPlayerName()) }, this );
		ply.SetInputCallback( "-forward",  function(ply) { printl("-forward " + ply.GetPlayerName()) }, this );
	};

	ply.SetInputCallback( "+attack", OnAttack, this );
}.bindenv(this), "" );

function OnAttack( ply )
{
	printl("+attack " + ply.GetPlayerName());

	local eyePos = ply.EyePosition();
	local org = ply.GetOrigin();
	org.z += 16.0;
	VS.DrawCapsule( org, org + Vector(0,0,48), 16.0, 0, 255, 255, false, 5.0 );

	VS.DrawViewFrustum( eyePos, ply.EyeForward(), ply.EyeRight(), ply.EyeUp(),
		90.0, 1.7778, 2.0, 16.0, 255, 0, 0, false, 5.0 );

	DebugDrawBoxAngles( eyePos, Vector(2,-1,-1), Vector(32,1,1), ply.EyeAngles(), 0, 255, 0, 16, 5.0 );
}
```

When a player disconnects, `CExtendedPlayer::IsValid()` returns false.

________________________________

<a name="f_TraceLine"></a>
```cpp
class VS::TraceLine
{
	Vector startpos;
	Vector endpos;
	CBaseEntity ignore;
	float fraction;
	Vector hitpos;
	Vector normal;
}
```
________________________________

```cpp
trace_t VS::TraceLine( Vector start, Vector end, handle ignore = null, int mask = MASK_NPCWORLDSTATIC )
```
Mask parameter can take `0x2000b` (`MASK_NPCWORLDSTATIC`) or `0x200400b` (`MASK_SOLID`).
________________________________

<a name="f_DidHit"></a>
```cpp
bool VS::TraceLine::DidHit()
```
if direct LOS return false
________________________________

<a name="f_GetEnt"></a>
```cpp
handle VS::TraceLine::GetEnt(float radius = 1.0)
```
return hit entity handle, null if none

Calling this again will try to find an entity again. Found entity is not saved.
________________________________

<a name="f_GetEntByName"></a>
```cpp
handle VS::TraceLine::GetEntByName(string targetname, float radius = 1.0)
```
GetEnt, find by name
________________________________

<a name="f_GetEntByClassname"></a>
```cpp
handle VS::TraceLine::GetEntByClassname(string classname, float radius = 1.0)
```
GetEnt, find by classname
________________________________

<a name="f_GetPos"></a>
```cpp
Vector VS::TraceLine::GetPos()
```
Calculate and return hit position (hitpos)

Calling this will save the position in `hitpos`, calling it again will not recompute.
________________________________

<a name="f_GetDist"></a>
```cpp
float VS::TraceLine::GetDist()
```
Get distance from startpos to hit position
________________________________

<a name="f_GetDistSqr"></a>
```cpp
float VS::TraceLine::GetDistSqr()
```
Get distance squared. Useful for comparisons
________________________________

<a name="f_GetNormal"></a>
```cpp
Vector VS::TraceLine::GetNormal()
```
Get surface normal.

This computes 2 extra traces.

Calling this will save the normal in `normal`, calling it again will not recompute.

<details><summary>Example</summary>

Draw the normal of a surface the player is looking at
```cs
function Think()
{
	local tr = VS.TraceDir( player.EyePosition(), player.EyeForward() );
	tr.GetNormal();
	tr.GetPos();

	DebugDrawLine( tr.hitpos, tr.normal * 16 + tr.hitpos, 255, 0, 255, false, 0.1 );
	DebugDrawBoxAngles( tr.hitpos, Vector(0,-1,-1), Vector(16,1,1), VS.VectorAngles(tr.normal), 0,0,255,255, 0.1 );
}
```

</details>

________________________________

<a name="f_TraceDir"></a>
```cpp
trace_t VS::TraceDir(Vector start, Vector direction, float maxdist = MAX_TRACE_LENGTH, handle ignore = null, int mask = MASK_NPCWORLDSTATIC)
```

<details><summary>Example</summary>

Example draw a cube at player aim (GOTV spectator like)
```lua
function Think()
{
	local eye = player.EyePosition()
	local pos = VS.TraceDir( eye, player.EyeForward() ).GetPos()

	DebugDrawLine(eye, pos, 255, 255, 255, false, -1)
	DebugDrawBox(pos, Vector(-2,-2,-2), Vector(2,2,2), 255, 255, 255, 125, -1)
}
```

</details>

________________________________

<a name="f_UniqueString"></a>
```cpp
string VS::UniqueString()
```
UniqueString without `_` in the end
________________________________

<a name="f_EventQueueClear"></a>
```cpp
void VS::EventQueue::Clear()
```
Reset the queue.
________________________________

<a name="f_EventQueueAddEvent"></a>
```cpp
EventQueuePrioritizedEvent_t VS::EventQueue::AddEvent( closure hFunc, float flDelay, table|array argv = null, handle activator = null, handle caller = null )
```
Add new function callback to the queue.

`argv` can be a table for call environment (e.g. `this`), or an array for parameters to pass to the function call.

The array parameter needs to have its first index as the call environment (e.g. `[this, "param1", "param2"]`).

```cs
function MyFunc()
{
	Msg("Message 1\n")
}

function MyFunc2( a, b, c )
{
	Msg(a + ", " + b + ", " + c + "\n")
}

VS.EventQueue.AddEvent( MyFunc, 2.0 )
VS.EventQueue.AddEvent( MyFunc, 2.5, this )
VS.EventQueue.AddEvent( Msg, 1.0, [null, "Message 2\n"] )
VS.EventQueue.AddEvent( MyFunc2, 4.0, [this, "x", "y", "z"] )
VS.EventQueue.AddEvent( function()
{
	Msg("Message 3\n")
}, 0.5, this )
```

The internal function can also be called with a premade event object using `VS.EventQueue.CreateEvent`.

```cs
local event = VS.EventQueue.CreateEvent( Msg, [null, "Message 2\n"] )

VS.EventQueue.AddEventInternal( event, delay )
```
________________________________

<a name="f_EventQueueCancelEventsByInput"></a>
```cpp
void VS::EventQueue::CancelEventsByInput( closure input )
```
Remove events in queue by matching callback function.
________________________________

<a name="f_EventQueueRemoveEvent"></a>
```cpp
void VS::EventQueue::RemoveEvent( EventQueuePrioritizedEvent_t input )
```
Remove event in queue.
________________________________

<a name="f_EventQueueDump"></a>
```cpp
void VS::EventQueue::Dump( bUseTicks = false, indent = 0 )
```
(debug) Dump events in the queue.
________________________________

<a name="f_DumpScope"></a>
```cpp
void VS::DumpScope(table table, bool printall = false, bool deepprint = true, bool guides = true, int depth = 0)
```
(debug) Usage: `VS.DumpScope(table)`
________________________________

<a name="f_DumpEnt"></a>
```cpp
void VS::DumpEnt(TYPE input = null)
```
(debug) Dump all entities whose script scopes are already created.

Input an entity handle or string to dump its scope.

`ent_script_dump`
________________________________

<a name="f_DumpPlayers"></a>
```cpp
void VS::DumpPlayers(bool dumpscope = false)
```
(debug) DumpEnt only players and bots

If bots have targetnames, they 'become' humans. If the event listeners are not set up, named bots will be shown as players.
________________________________

<a name="f_ArrayToTable"></a>
```cpp
table VS::ArrayToTable(array a)
```

________________________________

<a name="f_PrintStack"></a>
```cpp
void VS::PrintStack(int startlevel = 0)
```
Print stack
________________________________

<a name="f_GetCallerFunc"></a>
```cpp
string VS::GetCallerFunc()
```
(DEBUG) Get caller function as string
________________________________

<a name="f_GetCaller"></a>
```cpp
table VS::GetCaller()
```
Get caller table
________________________________

<a name="f_GetVarName"></a>
```cpp
string VS::GetVarName(TYPE v)
```
Does a linear search through the root table.

Doesn't work with primitive variables if there are multiple variables with the same value. But it can work if the value is unique, like a unique string.

<details><summary>Example</summary>

```cs
somestring <- "my unique string"
somefunc <- function(){}

// prints "somestring"
printl( VS.GetVarName(somestring) )

// prints "somefunc"
printl( VS.GetVarName(somefunc) )
```

</details>

________________________________


### [vs_entity](https://github.com/samisalreadytaken/vs_library/blob/master/src/vs_entity.nut)
________________________________

<a name="f_EntFireByHandle"></a>
```cpp
void EntFireByHandle(handle target, string action, string value = "", float delay = 0.0, handle activator = null, handle caller = null)
```
`EntFireByHandle(hEnt, "Use")`

The native function is `DoEntFireByInstanceHandle`

________________________________

<a name="f_PrecacheModel"></a>
```cpp
void PrecacheModel(string model)
```

________________________________

<a name="f_PrecacheScriptSound"></a>
```cpp
void PrecacheScriptSound(string sound)
```

________________________________

<a name="f_MakePersistent"></a>
```cpp
void VS::MakePersistent(handle ent)
```
Prevent the entity from being released every round
________________________________

<a name="f_SetParent"></a>
```cpp
void VS::SetParent(handle child, handle parent)
```
Set child's parent. if parent == null then unparent child
________________________________

<a name="f_CreateMeasure"></a>
```cpp
handle VS::CreateMeasure(string targetTargetname, string refTargetname = null, bool bMakePersistent = false, bool measureEye = true, float scale = 1.0)
```
Deprecated. Use `ToExtendedPlayer`.
________________________________

<a name="f_SetMeasure"></a>
```cpp
void VS::SetMeasure(handle logic_measure_movement, string targetTargetname)
```
Deprecated. Use `ToExtendedPlayer`.
________________________________

<a name="f_CreateTimer"></a>
```cpp
handle VS::CreateTimer(bool bDisabled, float flInterval, float flLower = null, float flUpper = null, bool bOscillator = false, bool bMakePersistent = false)
```
Create and return a logic_timer entity

if refire is `0` OR `null`, random time use `lower` AND `upper`
________________________________

<a name="f_Timer"></a>
```cpp
handle VS::Timer(bool bDisabled, float flInterval, TYPE func = null, table scope = null, bool bExecInEnt = false, bool bMakePersistent = false)
```
Create and return a timer that executes func

`TYPE`: `string|function|null`

`VS.Timer(true, 0.5)`  
`VS.Timer(false, 0.5, MyFunc)`  
`VS.Timer(false, 0.5, "MyFunc")`
________________________________

<a name="f_OnTimer"></a>
```cpp
table VS::OnTimer(handle ent, TYPE func, table scope = null, bool bExecInEnt = false)
```
Add OnTimer output to the timer entity to execute the input function

`TYPE`: `string|function`

```cs
VS.OnTimer(hTimer, MyFunc)

VS.OnTimer(hTimer, function()
{
	// do
})
```
________________________________

<a name="f_AddOutput"></a>
```cpp
table VS::AddOutput(handle ent, string output, TYPE func, table scope = null, bool bExecInEnt = false)
```
Add output in the chosen entity. Execute the given function in the given scope. Accepts function parameters.

Return entity scope

`TYPE`: `string|function`

<details><summary>Example</summary>

`VS.AddOutput( hButton, "OnPressed", MyFunction )`  
`VS.AddOutput( hButton, "OnPressed", "MyFunction" )`  
`VS.AddOutput( hButton, "OnPressed", "MyFunction(1)" )`

`bExecInEnt`: execute the function that is in `scope`, in the scope of `ent`

Example:
**Input:**
```lua
function MyFunction()
{
	print(self.GetName())
}

VS.AddOutput( hButton, "OnPressed", MyFunction, null, true )
```
**Output:**
```
<hButton.GetName()>
```
**Input:**
```lua
VS.AddOutput( hButton, "OnPressed", MyFunction )
```
**Output:**
```
<this.self.GetName()>
```

</details>

________________________________

<a name="f_CreateEntity"></a>
```cpp
handle VS::CreateEntity(string classname, table keyvalues = null, bool preserve = false)
```
CreateByClassname, set keyvalues, return handle

<details><summary><code>game_text</code></summary>

```cs
	VS.CreateEntity("game_text", 
	{
//		channel = 1,
//		color = "100 100 100",
//		color2 = "240 110 0",
//		effect = 0,
//		fadein = 1.5,
//		fadeout = 0.5,
//		fxtime = 0.25,
//		holdtime = 1.2,
//		x = -1,
//		y = -1,
//		spawnflags = 0,
//		message = ""
	});
```

</details>

<details><summary><code>point_worldtext</code></summary>

```cs
	VS.CreateEntity("point_worldtext", 
	{
//		spawnflags = 0,
//		origin = Vector(),
//		angles = Vector(),
//		message = "msg",
//		textsize = 10,
//		color = Vector(255,255,255)
	});
```

</details>

________________________________

<a name="f_SetKeyValue"></a>
```cpp
bool VS::SetKeyValue(handle ent, string key, TYPE val)
```
`KeyValueFrom`

Useful for when the value type is unknown
________________________________

<a name="f_SetName"></a>
```cpp
void VS::SetName(handle ent, string name)
```
Set targetname
________________________________

<a name="f_GetPlayersAndBots"></a>
```cpp
handle[2][] VS::GetPlayersAndBots()
```
Return an array of player and bot arrays.

If bots have targetnames, they 'become' humans.

If the event listeners are not set up, named bots will be shown as players.
________________________________

<a name="f_GetAllPlayers"></a>
```cpp
handle[] VS::GetAllPlayers()
```
Get every player and bot in a single array
________________________________

<a name="f_GetLocalPlayer"></a>
```cpp
handle VS::GetLocalPlayer(bool)
```
return the only / the first connected player in the server

if param is true, add to root:
`handle HPlayer`: player handle
________________________________

<a name="f_GetPlayerByIndex"></a>
```cpp
handle VS::GetPlayerByIndex(int entindex)
```
`PlayerInstanceFromIndex`

Not to be confused with [`GetPlayerByUserid`](#f_GetPlayerByUserid)
________________________________

<a name="f_GetEntityByIndex"></a>
```cpp
handle VS::GetEntityByIndex(int entindex, string classname = null)
```
`EntIndexToHScript`
________________________________

<a name="f_IsPointSized"></a>
```cpp
bool VS::IsPointSized(handle ent)
```

________________________________

<a name="f_FindEntityClassNearestFacing"></a>
```cpp
handle VS::FindEntityClassNearestFacing(Vector vOrigin, Vector vFacing, float fThreshold, string szClassname)
```

________________________________

<a name="f_FindEntityNearestFacing"></a>
```cpp
handle VS::FindEntityNearestFacing(Vector vOrigin, Vector vFacing, float fThreshold)
```

________________________________

<a name="f_FindEntityClassNearestFacingNearest"></a>
```cpp
handle VS::FindEntityClassNearestFacingNearest(Vector vOrigin, Vector vFacing, float fThreshold, string szClassname, float flRadius )
```
When two candidate entities are in front of each other, pick the closer one
________________________________


### [vs_events](https://github.com/samisalreadytaken/vs_library/blob/master/src/vs_events.nut)
________________________________

<a name="f_GetPlayerByUserid"></a>
```cpp
handle VS::GetPlayerByUserid(int userid)
```
If event listener setup is done, get the player handle from their userid.

Return null if no player is found.
________________________________

<a name="f_ListenToGameEvent"></a>
```cpp
void VS::ListenToGameEvent( string szEventname, closure fnCallback, string pContext )
```
Register a listener for a game event from script. Requires event listener setup.
________________________________

<a name="f_StopListeningToAllGameEvents"></a>
```cpp
void VS::StopListeningToAllGameEvents( string context )
```
Stop listening to all game events within a specific context.
________________________________

<a name="f_ForceValidateUserid"></a>
```cpp
void VS::ForceValidateUserid(handle player)
```
Deprecated. Manual calls to this are not necessary.
________________________________

<a name="f_ValidateUseridAll"></a>
```cpp
void VS::ValidateUseridAll()
```
Deprecated. Manual calls to this are not necessary.
________________________________

<a name="f_FixupEventListener"></a>
```cpp
void VS::FixupEventListener( handle eventlistener )
```
Not needed when event listeners are registered using `VS.ListenToGameEvent`.

Details:

While event listeners dump the event data whenever events are fired, entity outputs are added to the event queue to be executed in the next frame. Because of this delay, when an event is fired multiple times before the output is fired - before the script function is executed via the output - previous events would be lost.

This function catches each event data dump, saving it for the next time it is fetched by user script which is called by the event listener output. Because of this save-restore action, the event data can only be fetched once. This means there can only be 1 event listener output with event_data access.
________________________________

<a name="f_InitTemplate"></a>
```cpp
void VS::Events::InitTemplate( table entityScope )
```
Initialise point_template for automatic user data validation and dynamic event listening.
________________________________


### [vs_log](https://github.com/samisalreadytaken/vs_library/blob/master/src/vs_log.nut)

Print and export custom log lines.

Overrides the user con_filter settings but if the user cares about this at all, they would already have their own settings in an autoexec file.

Works for listen server host (local player) only.
________________________________

<a name="f_Logenabled"></a>
```cpp
VS.Log.enabled = true
```
Print the log?
________________________________

<a name="f_Logexport"></a>
```cpp
VS.Log.export = true
```
Export the log?

if( enabled && !export ) then print the log in the console
________________________________

<a name="f_Logfile_prefix"></a>
```cpp
VS.Log.file_prefix = "vs.log"
```
The exported log file name prefix.

By default, every file is appended with random strings to make each exported file unique. Putting `:` in the beginning will remove this suffix, and each export will overwrite the previously exported file. E.g.: `VS.Log.file_prefix = ":vs.log"`

The user can specify export directories by using `/`. E.g.: `VS.Log.file_prefix = "bin/vs.log"`

Example file name: `vs.log_c9ae41f5d8d.log`
________________________________

<a name="f_LogAdd"></a>
```cpp
void VS::Log::Add(string s)
```
Add new string to the internal log.
________________________________

<a name="f_LogPop"></a>
```cpp
void VS::Log::Pop()
```
Pop the last string from the internal log.
________________________________

<a name="f_LogClear"></a>
```cpp
void VS::Log::Clear()
```
Clear the internal log.
________________________________

<a name="f_LogWriteKeyValues"></a>
```cpp
void VS::Log::WriteKeyValues( szName, hTable )
```
Recursively write a script table as KeyValues into the internal log.

```cs
function test()
{
	local kv =
	{
		Key1 = "string value 1",
		Key2 = 2,
		[true] = Vector(1,1,1),
		[4] =
		{
			subkey1 = 5,
			subkey2 = 6
		},
		testarray = [ Vector(0,0,1), Vector(0,1,0), Vector(1,0,0) ]
	}

	VS.Log.Clear()
	VS.Log.export = false

	VS.Log.WriteKeyValues( "TestKV", kv )

	VS.Log.Run()
}
```
________________________________

<a name="f_LogRun"></a>
```cpp
string VS::Log::Run( data = null, function callback = null, table env = null )
```
If `data` is null, the internal log is used. `callback` is called after logging is complete. Exported file name is passed to the callback function.

If VS.Log.export is true, then export the log file to the game directory. Returns exported file name.

If VS.Log.export is false, then print in the console.

Do NOT call multiple times in a frame, or before the previous export is done.
________________________________

<a name="f_Logfilter"></a>
```cpp
VS.Log.filter = "L "
```
Export filter
________________________________

________________________________
**END OF DOC**
________________________________
