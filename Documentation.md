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
| `CBaseEntity`         | Generic entity script handle                                                        |
| `CBasePlayer`         | Player entity script handle                                                         |
| `CTimerEntity`        | `logic_timer` entity script handle                                                  |
| `Vector`, `vec3_t`    | `Vector()`                                                                          |
| `QAngle`              | `Vector(pitch, yaw, roll)` Euler angle. Vector, **not a different type**            |
| `Quaternion`          | `Quaternion()`                                                                      |
| `matrix3x4_t`         | `matrix3x4_t()`                                                                     |
| `VMatrix`             | `VMatrix()`                                                                         |
| `trace_t`             | `trace_t()`, `VS.TraceLine()`                                                       |
| `Ray_t`               | `Ray_t()`                                                                           |
| `ANY`                 | Any type                                                                            |

| Symbols | Description                                                                                                                                                                                                       |
| ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `&`     | instance reference. This means the input will be modified. Optional references can be omitted, but their result will be modified the next time another function with omitted reference parameter is called. |
| `[]`    | array. `float[3]` represents an array made of floats, with only 3 indices.                                                                                                                                        |

### Variables used in examples
| Variable       | Creation                          | Description                                           |
| -------------- | --------------------------------- | ----------------------------------------------------- |
| `player`       | `ToExtendedPlayer(VS.GetPlayerByIndex(1))`             | Local player in the server                            |
| `DisplayHint()`| `ScriptPrintMessageCenterAll()`   | Hud hint, show messages to the player                 |
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
| `MASK_SOLID`       | `0x200400b`                      |
| `MASK_NPCWORLDSTATIC` | `0x2000b`                     |
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
[`VS.RandomVector()`](#f_RandomVector)  
[`VS.RandomVectorInUnitSphere()`](#f_RandomVectorInUnitSphere)  
[`VS.RandomVectorOnUnitSphere()`](#f_RandomVectorOnUnitSphere)  
[`VS.ExponentialDecay()`](#f_ExponentialDecay)  
[`VS.ExponentialDecayHalf()`](#f_ExponentialDecayHalf)  
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
[`VS.MatrixBuildPerspectiveX()`](#f_MatrixBuildPerspectiveX)  
[`VS.WorldToScreenMatrix()`](#f_WorldToScreenMatrix)  
[`VS.ScreenToWorld()`](#f_ScreenToWorld)  
[`VS.WorldToScreen()`](#f_WorldToScreen)  
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
[`trace_t`](#f_trace_t)  
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
[`VS.ClipRayToBox()`](#f_ClipRayToBox)  
[`VS.ClipRayToBox2()`](#f_ClipRayToBox2)  
[`VS.IntersectRayWithOBB()`](#f_IntersectRayWithOBB)  
[`VS.ClipRayToOBB()`](#f_ClipRayToOBB)  
[`VS.ClipRayToOBB2()`](#f_ClipRayToOBB2)  
[`VS.IsRayIntersectingOBB()`](#f_IsRayIntersectingOBB)  
[`VS.IsOBBIntersectingOBB()`](#f_IsOBBIntersectingOBB)  
[`VS.ComputeSeparatingPlane()`](#f_ComputeSeparatingPlane)  


### [vs_utility](#vs_utility-1)
[`Ent()`](#f_Ent)  
[`Entc()`](#f_Entc)  
[`delay()`](#f_delay)  
[`CenterPrintAll`](#f_CenterPrintAll)  
[`TextColor`](#f_TextColor)  
[`VecToString()`](#f_VecToString)  
[`ToExtendedPlayer()`](#f_ToExtendedPlayer)  
[`VS.SetInputCallback`](#f_SetInputCallback)  
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
[`VS.GetPlayerByIndex()`](#f_GetPlayerByIndex)  
[`VS.GetEntityByIndex()`](#f_GetEntityByIndex)  
[`VS.IsPointSized()`](#f_IsPointSized)  


### [vs_events](#vs_events-1)
[`VS.GetPlayerByUserid()`](#f_GetPlayerByUserid)  
[`VS.ListenToGameEvent()`](#f_ListenToGameEvent)  
[`VS.StopListeningToAllGameEvents()`](#f_StopListeningToAllGameEvents)  
[`VS.Events.InitTemplate()`](#f_InitTemplate)  
[`VS.Events.DumpListeners()`](#f_DumpListeners)  


### [vs_log](#vs_log-1)
[`VS.Log.export`](#f_Logexport)  
[`VS.Log.file_prefix`](#f_Logfile_prefix)  
[`VS.Log.Add()`](#f_LogAdd)  
[`VS.Log.Pop()`](#f_LogPop)  
[`VS.Log.Clear()`](#f_LogClear)  
[`VS.Log.WriteKeyValues()`](#f_LogWriteKeyValues)  
[`VS.Log.Run()`](#f_LogRun)  
[`VS.Log._data`](#f_Logdata)  
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

	void Init();

	void Init(
		m00, m01, m02, m03,
		m10, m11, m12, m13,
		m20, m21, m22, m23 );

	// FLU
	void InitXYZ( Vector xAxis, Vector yAxis, Vector zAxis, Vector vOrigin );
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

	void Init();

	void Init(
		m00, m01, m02, m03,
		m10, m11, m12, m13,
		m20, m21, m22, m23 );

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
`IsIntegralValue`

Check if float is an integer.
________________________________

<a name="f_IsLookingAt"></a>
```cpp
bool VS::IsLookingAt(Vector source, Vector target, Vector direction, float tolerance)
```
See also [VS.IsBoxIntersectingRay](#f_IsBoxIntersectingRay), [VS.IsRayIntersectingSphere](#f_IsRayIntersectingSphere).

<details><summary>Example</summary>

```cs
function Think()
{
	local bLooking = false
	local eyePos = player.EyePosition()
	local target = Vector() // arbitrary world position to test

	DebugDrawLine( player.GetOrigin(), target, 255,0,0,true, -1 )

	// only check if there is direct LOS with the target
	if ( !VS.TraceLine( eyePos, target, player.self, MASK_SOLID ).DidHit() )
	{
		local lookThreshold = cos( DEG2RAD * 10.0 ) // 10 degrees

		bLooking = VS.IsLookingAt( eyePos, target, player.EyeForward(), lookThreshold )
	}

	if ( bLooking )
	{
		DisplayHint( "LOOKING" );
		DebugDrawBox( target, Vector(-8,-8,-8), Vector(8,8,8), 0,255,0,255, -1 )
	}
	else
	{
		DisplayHint( "NOT looking" );
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
Normalises the angle in -180,+180
________________________________

<a name="f_QAngleNormalize"></a>
```cpp
QAngle VS::QAngleNormalize(QAngle& angle)
```
Normalises the angle in -180,+180
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
Negates the vector in place.
________________________________

<a name="f_VectorCopy"></a>
```cpp
void VS::VectorCopy(Vector src, Vector& dst)
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
void VS::VectorAbs(Vector& vec)
```

________________________________

<a name="f_VectorAdd"></a>
```cpp
void VS::VectorAdd( Vector a, Vector b, Vector& out )
```
Vector a + Vector b

________________________________

<a name="f_VectorSubtract"></a>
```cpp
void VS::VectorSubtract( Vector a, Vector b, Vector& out )
```
Vector a - Vector b
________________________________

<a name="f_VectorScale"></a>
```cpp
void VS::VectorScale( Vector a, float b, Vector& out )
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
Guarantee uniform random distribution within a sphere. Returns the radius.
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

<a name="f_ExponentialDecayHalf"></a>
```cpp
float VS::ExponentialDecayHalf(float halflife, float dt)
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
float VS::Lerp(float A, float B, float t)
```
NOTE: The signature of this function differs from its Source Engine mathlib definition where it is (t, A, B)
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

Inputs are sequential, squad setup is done inside. This may change in the future.
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
void VS::MatrixQuaternionFast(matrix3x4_t matrix, Quaternion& angles)
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
void VS::MatrixCopy(matrix3x4_t src, matrix3x4_t& dst)
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
Vector VS::MatrixGetColumn(matrix3x4_t in1, int column, Vector& out = _VEC)
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
Builds a rotation matrix that rotates one direction vector into another. No rotation if the angle between the 2 vectors is less than 0.000061 degrees (this threshold is 0.0573 degrees in the Source Engine)
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

<a name="f_MatrixBuildPerspectiveX"></a>
```cpp
void VS::MatrixBuildPerspectiveX( VMatrix& dst, float fovX, float flAspect, float zNear, float zFar )
```
________________________________

<a name="f_WorldToScreenMatrix"></a>
```cpp
void VS::WorldToScreenMatrix( VMatrix& pOut, Vector origin, Vector forward, Vector right, Vector up, float fovX, float flAspect, float zNear, float zFar )
```
range [-1,1]
________________________________

<a name="f_ScreenToWorld"></a>
```cpp
Vector VS::ScreenToWorld( float x, float y, VMatrix screenToWorld, Vector &pOut = _VEC )
```
Input normalised screen position in [0,1] range.

```cs
local x = 0.75;
local y = 0.25;

local viewOrigin = player.EyePosition();
local viewAngles = player.EyeAngles();
local viewForward = player.EyeForward();
local viewRight = player.EyeRight();
local viewUp = player.EyeUp();
local aspectRatio = 16.0/9.0;
local fovx = VS.CalcFovX( player.GetFOV(), aspectRatio * (3.0/4.0) );

local screenToWorld = VMatrix();

VS.WorldToScreenMatrix(
	screenToWorld,
	viewOrigin,
	viewForward,
	viewRight,
	viewUp,
	fovx,
	aspectRatio,
	1.0,
	16.0 );

VS.MatrixInverseGeneral( screenToWorld, screenToWorld );

local worldPos = VS.ScreenToWorld( x, y, screenToWorld );

local maxs = Vector( 0.0, 0.5, 0.5 );
DebugDrawBoxAngles( worldPos, maxs*-1, maxs, viewAngles, 0, 255, 255, 64, 5.0 );

VS.DrawViewFrustum( viewOrigin, viewForward, viewRight, viewUp,
	fovx, aspectRatio, 2.0, 16.0, 255, 0, 0, false, 5.0 );
```
________________________________

<a name="f_WorldToScreen"></a>
```cpp
Vector VS::WorldToScreen( Vector worldPos, VMatrix worldToScreen, Vector &pOut = _VEC )
```
Returns screen position of a world position in [0,1] range.

Example detect if a world position is on a player's screen:

```cs
local targetPos = Vector();

// aspect ratio of the player's game (width/height)
local aspectRatio = 16.0/9.0;

local viewOrigin = player.EyePosition();
local viewAngles = player.EyeAngles();
local viewForward = player.EyeForward();
local viewRight = player.EyeRight();
local viewUp = player.EyeUp();
local fovx = VS.CalcFovX( player.GetFOV(), aspectRatio * (3.0/4.0) );

local worldToScreen = VMatrix();
VS.WorldToScreenMatrix(
	worldToScreen,
	viewOrigin,
	viewForward,
	viewRight,
	viewUp,
	fovx,
	aspectRatio,
	8.0,
	MAX_COORD_FLOAT );

local screen = VS.WorldToScreen( targetPos, worldToScreen );

local x = screen.x;
local y = screen.y;

// Target is off screen
if ( x < 0.0 || x > 1.0 || y < 0.0 || y > 1.0 || screen.z > 1.0 )
{

}
// Target is on screen
else
{

}
```
________________________________

<a name="f_ComputeCameraVariables"></a>
```cpp
void VS::ComputeCameraVariables( Vector vecOrigin, Vector pVecForward, Vector pVecRight, Vector pVecUp, VMatrix &pMatCamInverse )
```
Compute camera matrix where the camera looks down +z, +y is up, +x is right.

NOTE: In CS:GO, view render origin is offset from the eye position (origin+viewoffset). Use the following conversion to get more precision:

```cs
function MainViewOrigin()
{
	local viewOrigin = player.EyePosition();
	viewOrigin.z += 0.062561;
	return viewOrigin;
}
```
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
void VS::DrawFrustum( VMatrix matViewToWorld, int r, int g, int b, bool z, float time )
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
void VS::Interpolator_CurveInterpolate(int interpolationType, Vector vPre, Vector vStart, Vector vEnd, Vector vNext, f, Vector& vOut)
```

________________________________

<a name="f_Interpolator_CurveInterpolate_NonNormalized"></a>
```cpp
void VS::Interpolator_CurveInterpolate_NonNormalized(int interpolationType, Vector vPre, Vector vStart, Vector vEnd, Vector vNext, f, Vector& vOut)
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
void VS::Catmull_Rom_Spline(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```
Interpolate a Catmull-Rom spline.

t is a [0,1] value and interpolates a curve between p2 and p3.
________________________________

<a name="f_Catmull_Rom_Spline_Tangent"></a>
```cpp
void VS::Catmull_Rom_Spline_Tangent(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```
Interpolate a Catmull-Rom spline.

Returns the tangent of the point at t of the spline
________________________________

<a name="f_Catmull_Rom_Spline_Integral"></a>
```cpp
void VS::Catmull_Rom_Spline_Integral(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```
area under the curve [0..t]
________________________________

<a name="f_Catmull_Rom_Spline_Integral2"></a>
```cpp
void VS::Catmull_Rom_Spline_Integral2(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```
area under the curve [0..1]
________________________________

<a name="f_Catmull_Rom_Spline_Normalize"></a>
```cpp
void VS::Catmull_Rom_Spline_Normalize(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```
Interpolate a Catmull-Rom spline.

Normalize p2->p1 and p3->p4 to be the same length as p2->p3
________________________________

<a name="f_Catmull_Rom_Spline_Integral_Normalize"></a>
```cpp
void VS::Catmull_Rom_Spline_Integral_Normalize(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```
area under the curve [0..t]

Normalize p2->p1 and p3->p4 to be the same length as p2->p3
________________________________

<a name="f_Catmull_Rom_Spline_NormalizeX"></a>
```cpp
void VS::Catmull_Rom_Spline_NormalizeX(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```
Interpolate a Catmull-Rom spline.

Normalize p2.x->p1.x and p3.x->p4.x to be the same length as p2.x->p3.x
________________________________

<a name="f_Hermite_Spline"></a>
```cpp
void VS::Hermite_Spline(Vector p1, Vector p2, Vector d1, Vector d2, float t, Vector& output)
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

<a name="f_Hermite_Spline3V"></a>
```cpp
void VS::Hermite_Spline3V(Vector p0, Vector p1, Vector p2, float t, Vector& output)
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
void VS::Hermite_Spline3Q(Quaternion q0, Quaternion q1, Quaternion q2, float t, Quaternion& output)
```

________________________________

<a name="f_Kochanek_Bartels_Spline"></a>
```cpp
void VS::Kochanek_Bartels_Spline(float tension, float bias, float continuity, Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
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
void VS::Kochanek_Bartels_Spline_NormalizeX(float tension, float bias, float continuity, Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```

________________________________

<a name="f_Cubic_Spline"></a>
```cpp
void VS::Cubic_Spline(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```
See link at Kochanek_Bartels_Spline for info on the basis matrix used
________________________________

<a name="f_Cubic_Spline_NormalizeX"></a>
```cpp
void VS::Cubic_Spline_NormalizeX(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```

________________________________

<a name="f_BSpline"></a>
```cpp
void VS::BSpline(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```
See link at Kochanek_Bartels_Spline for info on the basis matrix used
________________________________

<a name="f_BSpline_NormalizeX"></a>
```cpp
void VS::BSpline_NormalizeX(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```

________________________________

<a name="f_Parabolic_Spline"></a>
```cpp
void VS::Parabolic_Spline(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
```
See link at Kochanek_Bartels_Spline for info on the basis matrix used
________________________________

<a name="f_Parabolic_Spline_NormalizeX"></a>
```cpp
void VS::Parabolic_Spline_NormalizeX(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output)
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
QAngle VS::InterpolateAngles(QAngle v1, QAngle v2, float flPercent, QAngle &out = _VEC)
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

	void Init( Vector start, Vector end );
	void Init( Vector start, Vector end, Vector mins, Vector maxs );
}
```
________________________________

<a name="f_trace_t"></a>
```cpp
class trace_t
{
	Vector startpos;
	Vector endpos;
	float fraction;
	bool allsolid;
	bool startsolid;

	cplane_t plane
	{
		Vector normal;
		float dist;
	}
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
bool VS::ComputeIntersectionBarycentricCoordinates( Ray_t ray, Vector v1, Vector v2, Vector v3, float uvt[3] )
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
Return true if the boxes intersect (but not if they just touch)
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
bool VS::IsBoxIntersectingRay(Vector boxMin, Vector boxMax, Vector vecRayStart, Vector vecRayDelta, float flTolerance = 0.0)
```
Intersects a ray with an AABB, return true if they intersect
________________________________

<a name="f_IsBoxIntersectingRay2"></a>
```cpp
bool VS::IsBoxIntersectingRay2( Vector vecBoxOrigin, Vector vecBoxMin, Vector vecBoxMax, Ray_t ray, float flTolerance = 0.0 )
```
Intersects a ray with an AABB, return true if they intersect

<details><summary>Example</summary>

```cs
// Box definitions
m_vecBoxOrigin <- Vector( 0, 0, 16 );
m_vecBoxMins <- Vector( 0, -8, -8 );
m_vecBoxMaxs <- Vector( 128, 8, 8 );

function Think()
{
	local vecEyePos = player.EyePosition();
	local vecEyeFwd = player.EyeForward();

	local ray = Ray_t();
	local rayHullMin = Vector(-2,-2,-2);
	local rayHullMax = Vector(2,2,2);
	ray.Init( vecEyePos, vecEyePos + vecEyeFwd * MAX_COORD_FLOAT, rayHullMin, rayHullMax );

	if ( VS.IsBoxIntersectingRay2( m_vecBoxOrigin, m_vecBoxMins, m_vecBoxMaxs, ray, 0.0 ) )
	{
		// green box
		DebugDrawBox( m_vecBoxOrigin, m_vecBoxMins, m_vecBoxMaxs, 0, 255, 0, 16, -1 );
	}
	else
	{
		// red box
		DebugDrawBox( m_vecBoxOrigin, m_vecBoxMins, m_vecBoxMaxs, 255, 0, 0, 16, -1 );
	}
}
```

</details>

________________________________

<a name="f_IntersectRayWithRay"></a>
```cpp
bool VS::IntersectRayWithRay( Vector vecStart0, Vector vecDelta0, Vector vecStart1, Vector vecDelta1, float pTrace[2] )
```
Intersects a ray with a ray, return true if they intersect

Returns (t,s) parameters of closest approach (if not intersecting!)
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
	Vector boxMins, Vector boxMaxs, float flTolerance, float pTrace[2] )
```
Intersects a ray against a box, returns t1 and t2
________________________________

<a name="f_ClipRayToBox"></a>
```cpp
bool VS::ClipRayToBox( Vector vecRayStart, Vector vecRayDelta,
	Vector boxMins, Vector boxMaxs, float flTolerance, trace_t &pTrace )
```
Intersects a ray against a box, returns trace_t info
________________________________

<a name="f_ClipRayToBox2"></a>
```cpp
bool VS::ClipRayToBox2( Ray_t ray, Vector boxMins, Vector boxMaxs, float flTolerance, trace_t &pTrace )
```
Intersects a ray against a box, returns trace_t info

<details><summary>Example</summary>

```cs
// Box definitions
m_vecBoxOrigin <- Vector( 0, 0, 48 );
m_vecBoxMins <- Vector( 0, -8, -8 );
m_vecBoxMaxs <- Vector( 32, 8, 8 );

function Think()
{
	local vecEyePos = player.EyePosition();
	local vecEyeFwd = player.EyeForward();

	local ray = Ray_t();
	local rayHullMin = Vector(-2,-2,-2);
	local rayHullMax = Vector(2,2,2);
	ray.Init( vecEyePos, vecEyePos + vecEyeFwd * MAX_COORD_FLOAT, rayHullMin, rayHullMax );

	local tr = trace_t();

	if ( VS.ClipRayToBox2( ray, m_vecBoxOrigin + m_vecBoxMins, m_vecBoxOrigin + m_vecBoxMaxs, 0.0, tr ) )
	{
		// green box
		DebugDrawBox( m_vecBoxOrigin, m_vecBoxMins, m_vecBoxMaxs, 0, 255, 0, 16, -1 );

		// surface normal
		DebugDrawLine( tr.endpos, tr.endpos + tr.plane.normal * 16, 0, 0, 255, true, -1 );
	}
	else
	{
		// red box
		DebugDrawBox( m_vecBoxOrigin, m_vecBoxMins, m_vecBoxMaxs, 255, 0, 0, 16, -1 );
	}

	// Draw the ray
	if ( ray.m_IsRay )
	{
		DebugDrawLine( ray.m_Start, ray.m_Start + ray.m_Delta, 255, 160, false, -1 );
	}
	else
	{
		rayHullMin.x = 0.0;
		rayHullMax.x = ray.m_Delta.Length();
		DebugDrawBoxAngles( ray.m_Start, rayHullMin, rayHullMax, VS.VectorAngles(ray.m_Delta), 255, 160, 0, 8, -1 );
	}
}
```

</details>

________________________________

<a name="f_IntersectRayWithOBB"></a>
```cpp
bool VS::IntersectRayWithOBB( Vector vecRayStart, Vector vecRayDelta, matrix3x4_t matOBBToWorld,
	Vector vecOBBMins, Vector vecOBBMaxs, float flTolerance, float pTrace[2] )
```
Intersects a ray against an OBB, returns t1 and t2
________________________________

<a name="f_ClipRayToOBB"></a>
```cpp
bool VS::ClipRayToOBB( Vector vecRayStart, Vector vecRayDelta, matrix3x4_t matOBBToWorld,
	Vector boxMins, Vector boxMaxs, float flTolerance, trace_t &pTrace )
```
Intersects a ray against an OBB, returns trace_t info
________________________________

<a name="f_ClipRayToOBB2"></a>
```cpp
bool VS::ClipRayToOBB2( Ray_t ray, matrix3x4_t matOBBToWorld, Vector boxMins, Vector boxMaxs, float flTolerance, trace_t &pTrace )
```
Intersects a ray against an OBB, returns trace_t info

<details><summary>Example</summary>

```cs
// Box definitions
m_vecBoxOrigin <- Vector( 0, 0, 48 );
m_vecBoxMins <- Vector( 0, -8, -8 );
m_vecBoxMaxs <- Vector( 32, 8, 8 );
m_vecBoxAngles <- Vector( 10, 15, 0 );
m_matBoxTransform <- matrix3x4_t();

VS.AngleMatrix( m_vecBoxAngles, m_vecBoxOrigin, m_matBoxTransform );

function Think()
{
	local vecEyePos = player.EyePosition();
	local vecEyeFwd = player.EyeForward();

	local ray = Ray_t();
	local rayHullMin = Vector(-2,-2,-2);
	local rayHullMax = Vector(2,2,2);
	ray.Init( vecEyePos, vecEyePos + vecEyeFwd * MAX_COORD_FLOAT, rayHullMin, rayHullMax );

	local tr = trace_t();

	if ( VS.ClipRayToOBB2( ray, m_matBoxTransform, m_vecBoxMins, m_vecBoxMaxs, 0.0, tr ) )
	{
		// green box
		DebugDrawBoxAngles( m_vecBoxOrigin, m_vecBoxMins, m_vecBoxMaxs, m_vecBoxAngles, 0, 255, 0, 16, -1 );

		// surface normal
		DebugDrawLine( tr.endpos, tr.endpos + tr.plane.normal * 16, 0, 0, 255, true, -1 );
	}
	else
	{
		// red box
		DebugDrawBoxAngles( m_vecBoxOrigin, m_vecBoxMins, m_vecBoxMaxs, m_vecBoxAngles, 255, 0, 0, 16, -1 );
	}

	// Draw the ray
	if ( ray.m_IsRay )
	{
		DebugDrawLine( ray.m_Start, ray.m_Start + ray.m_Delta, 255, 160, false, -1 );
	}
	else
	{
		rayHullMin.x = 0.0;
		rayHullMax.x = ray.m_Delta.Length();
		DebugDrawBoxAngles( ray.m_Start, rayHullMin, rayHullMax, VS.VectorAngles(ray.m_Delta), 255, 160, 0, 8, -1 );
	}
}
```

</details>

________________________________

<a name="f_IsRayIntersectingOBB"></a>
```cpp
bool VS::IsRayIntersectingOBB( Ray_t ray, Vector org, QAngle angles, Vector mins, Vector maxs )
```
Swept OBB test
________________________________

<a name="f_IsOBBIntersectingOBB"></a>
```cpp
bool VS::IsOBBIntersectingOBB( Vector org1, Vector ang1, Vector min1, Vector max1, Vector org2, Vector ang2, Vector min2, Vector max2, float tolerance )
```
Returns true if there's an intersection between two OBBs
________________________________

<a name="f_ComputeSeparatingPlane"></a>
```cpp
bool VS::ComputeSeparatingPlane( matrix3x4_t worldToBox1, matrix3x4_t box2ToWorld, Vector box1Size, Vector box2Size, float tolerance, Vector &pNormalOut = _VEC )
```
Compute a separating plane between two boxes (expensive!). Returns false if no separating plane exists
________________________________


### [vs_utility](https://github.com/samisalreadytaken/vs_library/blob/master/src/vs_utility.nut)
________________________________

<a name="f_Ent"></a>
```cpp
CBaseEntity Ent(string targetname, CBaseEntity startEntity = null)
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
CBaseEntity Entc(string classname, CBaseEntity startEntity = null)
```
Find entity by classname (wrapper function). Read above
________________________________

<a name="f_delay"></a>
```cpp
void delay()
```
Deprecated. Use [`VS.EventQueue.AddEvent`](#f_EventQueueAddEvent).

________________________________

<a name="f_Chat"></a>
```cpp
void Chat(string s)
```
Wrapper function for `ScriptPrintMessageChatAll`, but allows text colour to be the first character.

```
// will not be coloured
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
Show HTML colourable hint text to all players.

NOTE: Because of the hack this function uses, there will be a `$` in the beginning of the hint text in most languages, whereas in Czech, Japanese, Portuguese, Turkish and Ukrainian unrelated words will be displayed.

```cpp
local v = VS.RandomVector();

CenterPrintAll(format( "\n<font color='#ff0000'>%.2f</font>\n<font color='#00ff00'>%.2f</font>\n<font color='#0000ff'>%.2f</font>", v.x, v.y, v.z ));


function HintColour( msg, r, g, b )
{
	return CenterPrintAll(format( "<font color='#%02x%02x%02x'>%s</font>", r, g, b, msg ));
}
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

The `TextColor` enum is strings for concatenation. For formatting, use their char values with "%c".

`Chat(format( "%cRED %cYELLOW %cWHITE", TextColor.Red[0], TextColor.Gold[0], TextColor.Normal[0] ))`
________________________________

<a name="f_VecToString"></a>
```cpp
string VecToString(Vector vec)
```
return `"Vector(0, 1, 2)"`
________________________________

<a name="f_ToExtendedPlayer"></a>
```cpp
class CExtendedPlayer : CBaseMultiplayerPlayer
{
	const CBasePlayer self;
	const int m_EntityIndex;
	const table m_ScriptScope;

	const int userid;
	const string networkid;
	const string name;
	const bool fakeplayer;

	bool IsBot();
	int GetUserID();
	string GetNetworkIDString();
	string GetPlayerName();

	QAngle EyeAngles();		// view angles
	Vector EyeForward();	// view forward vector
	Vector EyeRight();		// view right vector
	Vector EyeUp();			// view up vector

	void SetName( string targetname );
	void SetEffects( int n );
	void SetMoveType( int n );
	int GetFOV();
	void SetFOV( int fov, float rate );
	void SetParent( CBaseEntity parent, string attachment );
}

CExtendedPlayer ToExtendedPlayer( CBasePlayer player );
```

There is no performance penalty for using `CExtendedPlayer` exclusively.

One aspect to pay attention to is passing players to native functions such as `EntFireByHandle` or `CEntities::Next`. Use `CExtendedPlayer::self` for passing player parameters to native functions.

```cs
local player = ToExtendedPlayer( VS.GetPlayerByIndex(1) );

EntFireByHandle( player.self, "SetHealth", 1 );

local tr = TraceLine( v1, v2, player.self, MASK_SOLID );
```

The following functions require event listener setup and do not work in Portal 2: `IsBot`, `GetUserID`, `GetNetworkIDString`, `GetPlayerName`.

When a player disconnects, `CExtendedPlayer::IsValid()` returns false.

NOTE: `GetFOV`/`SetFOV` functions require to be called once to be initialised, their initial calls will not return correct values. To ensure they are initialised, `player.GetFOV()` can be called on player_spawn game event.

NOTE: Use the `player_spawn` game event to extend the player as early as possible. Using, for example, a think function on map spawn will set the userids of players who were connected to the server before map change to `-1` until the players are spawned, only then `CExtendedPlayer::GetUserID()` will return the correct ID.

NOTE: The library keeps a strong ref to the player instance; neither `CExtendedPlayer` or `CBasePlayer` weak refs will ever be `null` after this is called. Always use `IsValid()` for player validity check.
________________________________

<a name="f_SetInputCallback"></a>
```cpp
void VS::SetInputCallback( CBasePlayer player, string szInput, closure( CExtendedPlayer ) callback, string context )
```
Player as `CExtendedPlayer` is passed as parameter to the `SetInputCallback` callback function. `szInput == null` turns off the input listener. `callback == null` removes the callback.

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
const PLAYER_INPUT_CONTEXT = "";

VS.ListenToGameEvent( "player_spawn", function(ev)
{
	local player = ToExtendedPlayer( VS.GetPlayerByUserid( ev.userid ) );
	if ( !player )
		return;

	if ( !player.IsBot() )
	{
		VS.SetInputCallback( player, "+forward",  OnForwardPressed, PLAYER_INPUT_CONTEXT );
		VS.SetInputCallback( player, "-forward",  OnForwardReleased, PLAYER_INPUT_CONTEXT );
	}

	VS.SetInputCallback( player, "+attack", OnAttack, PLAYER_INPUT_CONTEXT );
}.bindenv(this), "" );

function OnAttack( player )
{
	printl("+attack " + player.GetPlayerName());

	local eyePos = player.EyePosition();
	local org = player.GetOrigin();
	org.z += 16.0;
	VS.DrawCapsule( org, org + Vector(0,0,48), 16.0, 0, 255, 255, false, 5.0 );

	VS.DrawViewFrustum( eyePos, player.EyeForward(), player.EyeRight(), player.EyeUp(),
		90.0, 1.7778, 2.0, 16.0, 255, 0, 0, false, 5.0 );

	DebugDrawBoxAngles( eyePos, Vector(2,-1,-1), Vector(32,1,1), player.EyeAngles(), 0, 255, 0, 16, 5.0 );
}

function OnForwardPressed( player )
{
	printl("+forward " + player.GetPlayerName())
}

function OnForwardReleased( player )
{
	printl("-forward " + player.GetPlayerName())
}
```

NOTE: This at the moment disables player movement prediction while the listener is on due to the usage of game_ui entity as the input listener.

This can be retroactively fixed in the future without changing any old user code if necessary API is added to the game.
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
trace_t VS::TraceLine( Vector start, Vector end, CBaseEntity ignore = null, int mask = MASK_NPCWORLDSTATIC )
```
Mask parameter can take `MASK_NPCWORLDSTATIC` or `MASK_SOLID`
________________________________

<a name="f_DidHit"></a>
```cpp
bool VS::TraceLine::DidHit()
```
if direct LOS return false
________________________________

<a name="f_GetEnt"></a>
```cpp
CBaseEntity VS::TraceLine::GetEnt(float radius = 1.0)
```
Search for entity in radius and return entity handle, null if none.

Calling this again will try to find an entity again. Found entity is not saved.
________________________________

<a name="f_GetEntByName"></a>
```cpp
CBaseEntity VS::TraceLine::GetEntByName(string targetname, float radius = 1.0)
```
GetEnt, find by name
________________________________

<a name="f_GetEntByClassname"></a>
```cpp
CBaseEntity VS::TraceLine::GetEntByClassname(string classname, float radius = 1.0)
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
Get distance squared
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
	local tr = VS.TraceDir( player.EyePosition(), player.EyeForward(), MAX_COORD_FLOAT, player.self, MASK_SOLID );
	local normal = tr.GetNormal();
	local hitpos = tr.GetPos();

	DebugDrawLine( hitpos, hitpos + normal * 16, 255, 0, 255, false, 0.1 );
	DebugDrawBoxAngles( hitpos, Vector(0,-1,-1), Vector(16,1,1), VS.VectorAngles(normal), 0,0,255,255, 0.1 );
}
```

</details>

________________________________

<a name="f_TraceDir"></a>
```cpp
trace_t VS::TraceDir(Vector start, Vector direction, float maxdist = MAX_TRACE_LENGTH, CBaseEntity ignore = null, int mask = MASK_NPCWORLDSTATIC)
```
Trace from `start` to `start + direction * maxdist`.

<details><summary>Example</summary>

Example draw a cube at player aim
```lua
function Think()
{
	local eye = player.EyePosition()
	local pos = VS.TraceDir( eye, player.EyeForward(), 1024.0 ).GetPos()

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
EventQueuePrioritizedEvent_t VS::EventQueue::AddEvent( closure hFunc, float flDelay, table|array argv = null, CBaseEntity activator = null, CBaseEntity caller = null )
```
Execute input function after time in seconds.

`argv` can be a table as call environment (e.g. `this`), or an array of parameters to pass to the function call. The array parameter needs to have its first index as the call environment (e.g. `[this, "param1", "param2"]`).

NOTE: All queued events are reset at the start of every round, events cannot be carried across rounds. This is because of the usage of the game's internal event queue.

Examples:

Execute `MyFunc` after 2 seconds delay without passing any parameters:
```cs
function MyFunc()
{
	print("Message 1\n");
}

VS.EventQueue.AddEvent( MyFunc, 2.0, this );
```

Execute `MyFunc` after 3 seconds delay passing 1 parameter:
```cs
function MyFunc( a )
{
	print("Message "+ a +"\n");
}

VS.EventQueue.AddEvent( MyFunc, 3.0, [this, 2] );
```

Execute anonymous function after 0,5 second delay without passing any parameters:
```cs
VS.EventQueue.AddEvent( function()
{
	print("Message 3\n");
}, 0.5, this );
```

Freeze the movement of a player for 2 seconds:
```cs
local player = ToExtendedPlayer( VS.GetPlayerByIndex(1) );

local curHealth = player.GetHealth();

// freeze
player.SetMoveType( 0 );
player.SetHealth( 1 );

// unfreeze and restore health 2 seconds later
VS.EventQueue.AddEvent( player.SetMoveType, 2.0, [player, 2] );
VS.EventQueue.AddEvent( player.SetHealth, 2.0, [player, curHealth] );
```

Cancel all queued events of `MyFunc`
```cs
function MyFunc()
{
	print("Message 1\n")
}

// Multiple or unknown amount of events
VS.EventQueue.AddEvent( MyFunc, 0.5, this );
VS.EventQueue.AddEvent( MyFunc, 1.0, this );
VS.EventQueue.AddEvent( MyFunc, 2.0, this );

// Cancel all MyFunc events
VS.EventQueue.CancelEventsByInput( MyFunc );
```

Start the countdown to kill a player unless they jump:

```cs
function KillPlayer( player )
{
	EntFireByHandle( player, "SetHealth", 0 );
}

// Cancel the saved event when player jumps
VS.ListenToGameEvent( "player_jump", function( event )
{
	local player = VS.GetPlayerByUserid( event.userid );
	local scope = player.GetScriptScope();

	if ( "m_DeathEvent" in scope && scope.m_DeathEvent )
	{
		VS.EventQueue.RemoveEvent( scope.m_DeathEvent );
		scope.m_DeathEvent = null;
	}
}, "" );


local player = VS.GetPlayerByIndex(1);
local scope = player.GetScriptScope();

// Kill after 10 seconds
scope.m_DeathEvent <- VS.EventQueue.AddEvent( KillPlayer, 10.0, [this, player] );
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
void VS::DumpEnt(ANY input = null)
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
string VS::GetVarName(ANY v)
```
Does a linear search through the root table.

Doesn't work with primitive variables if there are multiple variables with the same value. But it can work if the value is unique, like a unique string.

Example:
```cs
somestring <- "my unique string"
somefunc <- function(){}

// prints "somestring"
printl( VS.GetVarName(somestring) )

// prints "somefunc"
printl( VS.GetVarName(somefunc) )
```

________________________________


### [vs_entity](https://github.com/samisalreadytaken/vs_library/blob/master/src/vs_entity.nut)
________________________________

<a name="f_EntFireByHandle"></a>
```cpp
void EntFireByHandle(CBaseEntity target, string action, string value = "", float delay = 0.0, CBaseEntity activator = null, CBaseEntity caller = null)
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
void VS::MakePersistent(CBaseEntity ent)
```
Prevent the entity from being released every round
________________________________

<a name="f_SetParent"></a>
```cpp
void VS::SetParent(CBaseEntity child, CBaseEntity parent)
```
Set child's parent. if parent == null then unparent child
________________________________

<a name="f_CreateTimer"></a>
```cpp
CTimerEntity VS::CreateTimer(bool bDisabled, float flInterval, float flLower = null, float flUpper = null, bool bOscillator = false, bool bMakePersistent = false)
```
Create and return a logic_timer entity

if refire is `0` OR `null`, random time use `lower` AND `upper`

Identical to:
```cs
local hEnt = Entities.CreateByClassname( "logic_timer" );
hEnt.__KeyValueFromFloat( "refiretime", flInterval );
// hEnt.__KeyValueFromInt( "UseRandomTime", 1 );
// hEnt.__KeyValueFromFloat( "LowerRandomBound", flLower );
// hEnt.__KeyValueFromFloat( "UpperRandomBound", flUpper );
// hEnt.__KeyValueFromInt( "spawnflags", bOscillator.tointeger() );

// VS.MakePersistent( hEnt, bMakePersistent );

// EntFireByHandle( hEnt, "Enable" );
```

________________________________

<a name="f_Timer"></a>
```cpp
CTimerEntity VS::Timer(bool bDisabled, float flInterval, closure func = null, table env = null, bool bExecInEnt = false, bool bMakePersistent = false)
```
Create and return a timer that executes func

Identical to:
```cs
local hTimer = VS.CreateTimer( bDisabled, flInterval )
VS.AddOutput( hTimer, "OnTimer", func, env )
```

Example:
```cs
function callback()
{
	print("callback()\n");
}

VS.Timer( false, 0.5, callback, this )
VS.Timer( false, 1.5, function() { print("anonymous timer callback\n") } )
```

Example: Animate a random vector on a sphere move towards another.
```cs
// Get 2 random direction vectors
v1 <- Vector();
v2 <- Vector();
VS.RandomVectorOnUnitSphere( v1 );
VS.RandomVectorOnUnitSphere( v2 );

// Draw it in front of the player
start_pos <- player.EyePosition() + player.EyeForward() * 32.0 - player.EyeUp() * 4.0;
start_time <- Time();

// Animate one vector moving towards the other every frame over 10 seconds
anim_timer <- VS.Timer( 0, 0.0, function()
{
	local time = 10.0;

	local frac = (Time() - start_time) / time;

	local radius = 16.0;

	// Draw the sphere
	VS.DrawSphere( start_pos, radius, 16, 16, 100, 100, 255, true, -1 );

	// Draw v1 (red)
	DebugDrawLine( start_pos, start_pos + v1 * radius, 255, 0, 0, true, -1 );

	// Draw v2 (green)
	DebugDrawLine( start_pos, start_pos + v2 * radius, 0, 255, 0, true, -1 );

	// Spherically interpolate direction vectors by turning them into angles
	local ang1 = Vector();
	local ang2 = Vector();
	VS.VectorAngles( v1, ang1 );
	VS.VectorAngles( v2, ang2 );

	// Interpolate
	local new_ang = VS.InterpolateAngles( ang1, ang2, frac );

	// Back to direction vector from interpolated angles
	local new_dir = VS.AngleVectors( new_ang );

	// Draw the new direction (yellow)
	local end_point = start_pos + new_dir * radius;
	DebugDrawLine( start_pos, end_point, 255, 255, 0, true, -1 );

	// Draw small points on the sphere to show the travel trajectory

	// Change colour from red to green
	local r = (1.0-frac)*255;
	local g = frac*255;

	DebugDrawBox( end_point, Vector(-0.25,-0.25,-0.25), Vector(0.25,0.25,0.25), r, g, 0, 255, (1.0-frac)*time );

	// if the journey is complete, kill the timer
	if ( frac > 0.9999 )
	{
		print("done!\n");
		anim_timer.Destroy();
	}
}, this );
```
________________________________

<a name="f_OnTimer"></a>
```cpp
void VS::OnTimer(CTimerEntity ent, function func, table env = null, bool bExecInEnt = false)
```
Add OnTimer output to the timer entity to execute the input function.

`bExecInEnt` allows referring to the timer as `self` in the callback function. Otherwise the timer handle needs to be accessed differently.

Identical to: `VS.AddOutput( ent, "OnTimer", func, env )`
________________________________

<a name="f_AddOutput"></a>
```cpp
void VS::AddOutput( CBaseEntity hEnt, string szOutput, string szTarget, string szInput = "", string szParameter = "", float flDelay = 0.0, int nTimes = -1 )
void VS::AddOutput( CBaseEntity hEnt, string szOutput, string|closure fnCallback, table env = this )
```
Adds output to the input entity. Passing a function parameter will add the action `!self > CallScriptFunction > OutputName`

Example:
```cs
function MyFunction( param = null )
{
	printl("MyFunction( "+param+" )")
}

VS.AddOutput( hButton, "OnPressed", MyFunction )
VS.AddOutput( hButton, "OnPressed", "MyFunction(1)" )
VS.AddOutput( hButton, "OnPressed", "player", "RunScriptCode", "printl(\"output 1\")" )
VS.AddOutput( hButton, "OnPressed", "player", "RunScriptCode", "printl(\"output 2\")", 1.0 )
VS.AddOutput( hButton, "OnPressed", "player", "RunScriptCode", "printl(\"output 3\")", 1.0, 1 )
```
________________________________

<a name="f_CreateEntity"></a>
```cpp
CBaseEntity VS::CreateEntity(string classname, table keyvalues = null, bool preserve = false)
```
CreateByClassname, set keyvalues, return entity handle

<details><summary><code>game_text</code></summary>

```cs
	VS.CreateEntity("game_text", 
	{
		channel = 1,
		color = "100 100 100",
		color2 = "240 110 0",
		effect = 0,
		fadein = 1.5,
		fadeout = 0.5,
		fxtime = 0.25,
		holdtime = 1.2,
		x = -1,
		y = -1,
		spawnflags = 0,
		message = ""
	});
```

</details>

<details><summary><code>point_worldtext</code></summary>

```cs
	VS.CreateEntity("point_worldtext", 
	{
		spawnflags = 0,
		origin = Vector(),
		angles = Vector(),
		message = "msg",
		textsize = 10,
		color = Vector(255,255,255)
	});
```

</details>

________________________________

<a name="f_SetKeyValue"></a>
```cpp
bool VS::SetKeyValue(CBaseEntity ent, string key, float|int|bool|string|Vector val)
```
`CBaseEntity::KeyValue`

Useful for when the value type is unknown
________________________________

<a name="f_SetName"></a>
```cpp
void VS::SetName(CBaseEntity ent, string name)
```
Set targetname
________________________________

<a name="f_GetPlayersAndBots"></a>
```cpp
CBasePlayer[2][] VS::GetPlayersAndBots()
```
Return an array of player and bot arrays.

If bots have targetnames, they 'become' humans.

If the event listeners are not set up, named bots will be shown as players.
________________________________

<a name="f_GetAllPlayers"></a>
```cpp
CBasePlayer[] VS::GetAllPlayers()
```
Get every player and bot in a single array
________________________________

<a name="f_GetPlayerByIndex"></a>
```cpp
CBasePlayer VS::GetPlayerByIndex(int entindex)
```
`PlayerInstanceFromIndex`

Not to be confused with [`GetPlayerByUserid`](#f_GetPlayerByUserid)
________________________________

<a name="f_GetEntityByIndex"></a>
```cpp
CBaseEntity VS::GetEntityByIndex(int entindex, string classname = null)
```
`EntIndexToHScript`
________________________________

<a name="f_IsPointSized"></a>
```cpp
bool VS::IsPointSized(CBaseEntity ent)
```

________________________________


### [vs_events](https://github.com/samisalreadytaken/vs_library/blob/master/src/vs_events.nut)
________________________________

<a name="f_GetPlayerByUserid"></a>
```cpp
CBasePlayer VS::GetPlayerByUserid(int userid)
```
If event listener setup is done, get the player handle from their userid.

Return null if no player is found.
________________________________

<a name="f_ListenToGameEvent"></a>
```cpp
void VS::ListenToGameEvent( string szEventname, closure fnCallback, string pContext, bool bSynchronous = false )
```
Register a listener for a game event from script. Requires entity setup in Hammer.

Event data is optionally passed to the user callback function.
```cs
VS.ListenToGameEvent( "player_hurt", function( event )
{
	local player = VS.GetPlayerByUserid( event.userid );
	printl( player.GetScriptScope().name + " is hurt!\n" );
	VS.DumpScope( event ) // debug
}, "" );
```

Contexts are used to identify event listeners; they can be used to register multiple listeners for the same event.
```cs
VS.ListenToGameEvent( "player_say", function() { print("-- 1\n") }, "context1" );
VS.ListenToGameEvent( "player_say", function() { print("-- 2\n") }, "context2" );
VS.ListenToGameEvent( "player_say", function() { print("-- 3\n") }, "context3" );
```

`bSynchronous` parameter sets the listener to be synchronous, and execute callbacks as events are fired instead of waiting for the next server frame where some information you are after may become irrelevant.

However note that synchronous event listener callbacks will not have error handlers to dump the call stack and line info to help you debug. Use this mindfully!

Example show the world position players disconnect from - this would not be possible with async callbacks as the player entity no longer exists in the frame after the player_disconnect event.
```cs
VS.ListenToGameEvent( "player_disconnect", function(ev)
{
	local player = VS.GetPlayerByUserid( ev.userid );
	local origin = player.GetOrigin();

	print(format( "Player disconnected at %f %f %f\n", origin.x, origin.y, origin.z ));
	DebugDrawBox( origin, Vector(-16,-16,0), Vector(16,16,72), 255, 0, 0, 127, 10.0 );

}, "ShowDisconnectLocation-Sync", 1 );

VS.ListenToGameEvent( "player_disconnect", function(ev)
{
	local player = VS.GetPlayerByUserid( ev.userid );
	if ( !player )
		print("Player does not exist, disconnected!\n");

}, "ShowDisconnectLocation-Async", 0 );
```
________________________________

<a name="f_StopListeningToAllGameEvents"></a>
```cpp
void VS::StopListeningToAllGameEvents( string context )
```
Stop listening to all game events within a specific context.
________________________________

<a name="f_InitTemplate"></a>
```cpp
void VS::Events::InitTemplate( table entityScope )
```
Initialise point_template for automatic user data validation and dynamic event listening.
________________________________

<a name="f_DumpListeners"></a>
```cpp
void VS::Events::DumpListeners()
```
Debug print all game event listeners. `script VS.Events.DumpListeners()`
________________________________


### [vs_log](https://github.com/samisalreadytaken/vs_library/blob/master/src/vs_log.nut)

Print and export custom log lines.

Overrides the user con_filter settings but if the user cares about this at all, they would already have their own settings in an autoexec file.

Works for listen server host (local player) only.
________________________________

<a name="f_Logexport"></a>
```cpp
VS.Log.export = true
```
Export the log?

if false then print the log in the console
________________________________

<a name="f_Logfile_prefix"></a>
```cpp
VS.Log.file_prefix = "vs.log"
```
Exported log file name prefix.

By default, every file is appended with random strings to make each exported file unique. Putting `:` in the beginning will remove this suffix, and each export will overwrite the previously exported file. E.g.: `VS.Log.file_prefix = ":vs.log"`

The user can specify export directories by using `/`. E.g.: `VS.Log.file_prefix = "bin/vs.log"`

Example file name: `vs.log_c9ae41f5d8d.log`
________________________________

<a name="f_LogAdd"></a>
```cpp
void VS::Log::Add(string s)
```
Add new string to the log.
________________________________

<a name="f_LogPop"></a>
```cpp
void VS::Log::Pop()
```
Pop the last string from the log.
________________________________

<a name="f_LogClear"></a>
```cpp
void VS::Log::Clear()
```
Clear the log.
________________________________

<a name="f_LogWriteKeyValues"></a>
```cpp
void VS::Log::WriteKeyValues( szName, hTable )
```
Recursively write a script table as KeyValues into the log.

```cs
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
```
________________________________

<a name="f_LogRun"></a>
```cpp
string VS::Log::Run( function callback = null, table env = null )
```
`callback` is called after export is complete. Exported file name is passed to the callback function.

If `VS.Log.export` is true, then export the log file to the game directory. Returns exported file name.

If `VS.Log.export` is false, then print in the console.

Multiple exports cannot be started at the same time.

```cs
VS.Log.Clear();
VS.Log.export = true;
VS.Log.file_prefix = ":cache/test";

VS.Log.Add( "Vivamus id laoreet felis.\n" );
VS.Log.Add( "Fusce maximus libero nec efficitur aliquet.\n" );

print( "Exporting log file...\n" );

VS.Log.Run( function( filename )
{
	printl( "Exported log file to: " + filename );
}, this );
```
________________________________

<a name="f_Logdata"></a>
```cpp
VS.Log._data = []
```
Data array to print
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
