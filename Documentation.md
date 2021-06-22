# VScript Library Documentation
Documentation for [vs_library](https://github.com/samisalreadytaken/vs_library).

________________________________
<!-- U+2800 U+2514 U+2500 -->
### Table of Contents
└─ [**README**](#README)  
└─ [**Developer notes**](#developer-notes)  
└─ **Reference**  
⠀ ⠀└─ [Keywords, symbols and variables](#keywords-and-symbols-used-in-this-documentation)  
⠀ ⠀└─ **Base**  
⠀ ⠀ ⠀ ⠀└─ [Constants](#Constants)  
⠀ ⠀ ⠀ ⠀└─ [vs_math](#vs_math)  
⠀ ⠀ ⠀ ⠀└─ [vs_utility](#vs_utility)  
⠀ ⠀ ⠀ ⠀└─ [vs_entity](#vs_entity)  
⠀ ⠀ ⠀ ⠀└─ [vs_events](#vs_events)  
⠀ ⠀ ⠀ ⠀└─ [vs_log](#vs_log)  
⠀ ⠀└─ **Additional**  
⠀ ⠀ ⠀ ⠀└─ [vs_math2](#vs_math2)  
⠀ ⠀ ⠀ ⠀└─ [vs_collision](#vs_collision)  
⠀ ⠀ ⠀ ⠀└─ [vs_interp](#vs_interp)  
________________________________

## README

See [README.md](https://github.com/samisalreadytaken/vs_library/blob/master/README.md) for installation, downloading and usage.
________________________________

## Developer notes
* Wrapper functions such as EntFireByHandle return the final calls to take advantage of tail calls for improved performance.
* Variables are converted to strings using empty string concatenation instead of explicit `tostring()` calls for better performance; but long concatenations are instead formatted for better memory usage.
* Free variables are used with static values to reduce variable lookups.
* There will be some inconsistencies between the minified version and the source files:
* * Some functions that should be 'inline' such as max() and clamp() are manually replaced in the minified version to reduce function call overhead.
* * Constant variables such as PI and DEG2RAD are replaced with their values in the minified version to reduce variable lookups.
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
| `array`               | `[]`                                                                                |
| `closure`, `function` | function                                                                            |
| `handle`,`CBaseEntity`| Entity script handle                                                                |
| `Vector`, `vec3_t`    | `Vector(0,1,2)`                                                                     |
| `QAngle`              | `Vector(0,1,2)`, `(pitch, yaw, roll)` Euler angle. Vector, **not a different type** |
| `Quaternion`          | `Quaternion(0,1,2,3)`                                                               |
| `matrix3x4_t`         | `matrix3x4_t()`                                                                     |
| `VMatrix`             | `VMatrix()`                                                                     |
| `trace_t`             | `VS.TraceLine()`                                                                    |
| `ray_t`               | `VS.TraceLine().Ray()`, `trace_t`                                                   |
| `TYPE`                | Multiple types. Any unless specified in description                                 |

| Symbols | Description                                                                                                                                                                                                       |
| ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `&`     | instance reference. This means the input will be modified. Optional references can be omitted, but their result will be modified the next time another function with omitted reference parameter is called. |
| `[]`    | array. `float[3]` represents an array made of floats, with only 3 indices.                                                                                                                                        |

### Variables used in examples
| Variable       | Creation                          | Description                                           |
| -------------- | --------------------------------- | ----------------------------------------------------- |
| `HPlayer`      | `VS.GetLocalPlayer()`             | Local player in the server                            |
| `HPlayerEye`   | `VS.CreateMeasure(HPlayer.GetName())`      | Buffer to get player eye angles                       |
| `hHudHint`     | `VS.CreateEntity("env_hudhint")`  | Hud hint, show messages to the player                 |
| `Think()`      | `VS.Timer(0, 0.0, Think)`         | A function that is executed every frame               |
| `flFrameTime2` | `FrameTime() * 2`                 | Used in the Think function for displaying every frame |


## Base
Included in `vs_library.nut`

### Constants
| Variable           | Value                            |
| ------------------ | -------------------------------- |
| `CONST`            | `table` Squirrel constant table  |
| `MAX_COORD_FLOAT`  | `16384.0` (`1<<14`)              |
| `MAX_TRACE_LENGTH` | `56755.84086241`                 |
| `DEG2RAD`          | `0.01745329`                     |
| `RAD2DEG`          | `57.29577951`                    |
| `PI`               | `3.14159265`                     |
| `RAND_MAX`         | `0x7FFF`                         |


### [vs_math](#vs_math-1)
[`max()`](#f_max)  
[`min()`](#f_min)  
[`clamp()`](#f_clamp)  
[`VS.IsInteger()`](#f_IsInteger)  
[`VS.IsLookingAt()`](#f_IsLookingAt)  
[`VS.PointOnLineNearestPoint()`](#f_PointOnLineNearestPoint)  
[`VS.GetAngle()`](#f_GetAngle)  
[`VS.GetAngle2D()`](#f_GetAngle2D)  
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
[`VS.ComputeVolume()`](#f_ComputeVolume)  
[`VS.RandomVector()`](#f_RandomVector)  
[`VS.CalcSqrDistanceToAABB()`](#f_CalcSqrDistanceToAABB)  
[`VS.CalcClosestPointOnAABB()`](#f_CalcClosestPointOnAABB)  
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
[`VS.IsPointInBox()`](#f_IsPointInBox)  
[`VS.IsBoxIntersectingBox()`](#f_IsBoxIntersectingBox)  


### [vs_utility](#vs_utility-1)
[`Ent()`](#f_Ent)  
[`Entc()`](#f_Entc)  
[`delay()`](#f_delay)  
[`Chat()`](#f_Chat)  
[`ChatTeam()`](#f_ChatTeam)  
[`Alert()`](#f_Alert)  
[`AlertTeam()`](#f_AlertTeam)  
[`txt`](#f_txt)  
[`VecToString()`](#f_VecToString)  
[`VS.GetTickrate()`](#f_GetTickrate)  
[`VS.IsDedicatedServer()`](#f_IsDedicatedServer)  
[`VS.TraceLine`](#f_TraceLine)  
[`VS.TraceLine.DidHit()`](#f_DidHit)  
[`VS.TraceLine.GetEnt()`](#f_GetEnt)  
[`VS.TraceLine.GetEntByName()`](#f_GetEntByName)  
[`VS.TraceLine.GetEntByClassname()`](#f_GetEntByClassname)  
[`VS.TraceLine.GetPos()`](#f_GetPos)  
[`VS.TraceLine.GetDist()`](#f_GetDist)  
[`VS.TraceLine.GetDistSqr()`](#f_GetDistSqr)  
[`VS.TraceLine.GetNormal()`](#f_GetNormal)  
[`VS.TraceLine.Ray()`](#f_Ray)  
[`VS.TraceDir()`](#f_TraceDir)  
[`VS.UniqueString()`](#f_UniqueString)  
[`VS.EventQueue.Clear()`](#f_EventQueueClear)  
[`VS.EventQueue.AddEvent()`](#f_EventQueueAddEvent)  
[`VS.EventQueue.CancelEventsByInput()`](#f_EventQueueCancelEventsByInput)  
[`VS.EventQueue.RemoveEvent()`](#f_EventQueueRemoveEvent)  
[`VS.EventQueue.Dump()`](#f_EventQueueDump)  
[`VS.arrayFind()`](#f_arrayFind)  
[`VS.arrayApply()`](#f_arrayApply)  
[`VS.arrayMap()`](#f_arrayMap)  
[`VS.DumpScope()`](#f_DumpScope)  
[`VS.DumpEnt()`](#f_DumpEnt)  
[`VS.DumpPlayers()`](#f_DumpPlayers)  
[`VS.ArrayToTable()`](#f_ArrayToTable)  
[`VS.GetStackInfo()`](#f_GetStackInfo)  
[`VS.GetCallerFunc()`](#f_GetCallerFunc)  
[`VS.GetCaller()`](#f_GetCaller)  
[`VS.GetTableDir()`](#f_GetTableDir)  
[`VS.FindVarByName()`](#f_FindVarByName)  
[`VS.GetVarName()`](#f_GetVarName)  


### [vs_entity](#vs_entity-1)
[`EntFireByHandle()`](#f_EntFireByHandle)  
[`PrecacheModel()`](#f_PrecacheModel)  
[`PrecacheScriptSound()`](#f_PrecacheScriptSound)  
[`VS.MakePersistent()`](#f_MakePersistent)  
[`VS.SetParent()`](#f_SetParent)  
[`VS.ShowGameText()`](#f_ShowGameText)  
[`VS.ShowHudHint()`](#f_ShowHudHint)  
[`VS.HideHudHint()`](#f_HideHudHint)  
[`VS.CreateMeasure()`](#f_CreateMeasure)  
[`VS.SetMeasure()`](#f_SetMeasure)  
[`VS.CreateTimer()`](#f_CreateTimer)  
[`VS.Timer()`](#f_Timer)  
[`VS.OnTimer()`](#f_OnTimer)  
[`VS.AddOutput()`](#f_AddOutput)  
[`VS.AddOutput2()`](#f_AddOutput2)  
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
[`VS.ForceValidateUserid()`](#f_ForceValidateUserid)  
[`VS.ValidateUseridAll()`](#f_ValidateUseridAll)  
[`VS.FixupEventListener()`](#f_FixupEventListener)


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


## Additional
Not included in `vs_library.nut`

### [vs_math2](#vs_math2-1)
[`Quaternion`](#f_Quaternion)  
[`matrix3x4_t`](#f_matrix3x4_t)  
[`VMatrix`](#f_VMatrix)  
[`VS.InvRSquared()`](#f_InvRSquared)  
[`VS.a_swap()`](#f_a_swap)  
[`VS.MatrixRowDotProduct()`](#f_MatrixRowDotProduct)  
[`VS.MatrixColumnDotProduct()`](#f_MatrixColumnDotProduct)  
[`VS.DotProductAbs()`](#f_DotProductAbs)  
[`VS.VectorTransform()`](#f_VectorTransform)  
[`VS.VectorITransform()`](#f_VectorITransform)  
[`VS.VectorRotate()`](#f_VectorRotate)  
[`VS.VectorRotate2()`](#f_VectorRotate2)  
[`VS.VectorRotate3()`](#f_VectorRotate3)  
[`VS.VectorIRotate()`](#f_VectorIRotate)  
[`VS.VectorMA()`](#f_VectorMA)  
[`VS.QuaternionsAreEqual()`](#f_QuaternionsAreEqual)  
[`VS.QuaternionMA()`](#f_QuaternionMA)  
[`VS.QuaternionAdd()`](#f_QuaternionAdd)  
[`VS.QuaternionDotProduct()`](#f_QuaternionDotProduct)  
[`VS.QuaternionMult()`](#f_QuaternionMult)  
[`VS.QuaternionAlign()`](#f_QuaternionAlign)  
[`VS.QuaternionBlend()`](#f_QuaternionBlend)  
[`VS.QuaternionBlendNoAlign()`](#f_QuaternionBlendNoAlign)  
[`VS.QuaternionIdentityBlend()`](#f_QuaternionIdentityBlend)  
[`VS.QuaternionSlerp()`](#f_QuaternionSlerp)  
[`VS.QuaternionSlerpNoAlign()`](#f_QuaternionSlerpNoAlign)  
[`VS.QuaternionAverageExponential()`](#f_QuaternionAverageExponential)  
[`VS.QuaternionSquad()`](#f_QuaternionSquad)  
[`VS.QuaternionLn()`](#f_QuaternionLn)  
[`VS.QuaternionExp()`](#f_QuaternionExp)  
[`VS.QuaternionAngleDiff()`](#f_QuaternionAngleDiff)  
[`VS.QuaternionScale()`](#f_QuaternionScale)  
[`VS.QuaternionConjugate()`](#f_QuaternionConjugate)  
[`VS.QuaternionInvert()`](#f_QuaternionInvert)  
[`VS.QuaternionNormalize()`](#f_QuaternionNormalize)  
[`VS.QuaternionMatrix()`](#f_QuaternionMatrix)  
[`VS.QuaternionAngles()`](#f_QuaternionAngles)  
[`VS.QuaternionAxisAngle()`](#f_QuaternionAxisAngle)  
[`VS.AxisAngleQuaternion()`](#f_AxisAngleQuaternion)  
[`VS.AngleQuaternion()`](#f_AngleQuaternion)  
[`VS.RotationDeltaAxisAngle()`](#f_RotationDeltaAxisAngle)  
[`VS.RotationDelta()`](#f_RotationDelta)  
[`VS.MatrixQuaternion()`](#f_MatrixQuaternion)  
[`VS.BasisToQuaternion()`](#f_BasisToQuaternion)  
[`VS.MatrixAngles()`](#f_MatrixAngles)  
[`VS.MatrixQuaternionFast()`](#f_MatrixQuaternionFast)  
[`VS.AngleMatrix()`](#f_AngleMatrix)  
[`VS.AngleIMatrix()`](#f_AngleIMatrix)  
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
[`VS.Vector3DMultiplyProjective()`](#f_Vector3DMultiplyProjective)  
[`VS.Vector3DMultiplyPositionProjective()`](#f_Vector3DMultiplyPositionProjective)  
[`VS.TransformAABB()`](#f_TransformAABB)  
[`VS.ITransformAABB()`](#f_ITransformAABB)  
[`VS.RotateAABB()`](#f_RotateAABB)  
[`VS.IRotateAABB()`](#f_IRotateAABB)  
[`VS.GetBoxVertices()`](#f_GetBoxVertices)  
[`VS.MatrixBuildPerspective()`](#f_MatrixBuildPerspective)  
[`VS.ComputeViewMatrix()`](#f_ComputeViewMatrix)  
[`VS.ScreenToWorld()`](#f_ScreenToWorld)  
[`VS.ComputeCameraVariables()`](#f_ComputeCameraVariables)  
[`VS.CalcFovY()`](#f_CalcFovY)  
[`VS.CalcFovX()`](#f_CalcFovX)  
[`VS.DrawFrustum()`](#f_DrawFrustum)  
[`VS.DrawViewFrustum()`](#f_DrawViewFrustum)  
[`VS.DrawBoxAngles()`](#f_DrawBoxAngles)  
[`VS.DrawEntityBounds()`](#f_DrawEntityBounds)  
[`VS.DrawCapsule()`](#f_DrawCapsule)  
[`VS.DrawSphere()`](#f_DrawSphere)  


### [vs_collision](#vs_collision-1)
[`VS.Collision_ClearTrace()`](#f_Collision_ClearTrace)  
[`VS.ComputeBoxOffset()`](#f_ComputeBoxOffset)  
[`VS.IsPointInCone()`](#f_IsPointInCone)  
[`VS.IsSphereIntersectingSphere()`](#f_IsSphereIntersectingSphere)  
[`VS.IsBoxIntersectingSphere()`](#f_IsBoxIntersectingSphere)  
[`VS.IsCircleIntersectingRectangle()`](#f_IsCircleIntersectingRectangle)  
[`VS.IsRayIntersectingSphere()`](#f_IsRayIntersectingSphere)  
[`VS.IsBoxIntersectingRay()`](#f_IsBoxIntersectingRay)  
[`VS.IsBoxIntersectingRay2()`](#f_IsBoxIntersectingRay2)  


### [vs_interp](#vs_interp-1)
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

________________________________

### [vs_math](https://github.com/samisalreadytaken/vs_library/blob/master/vs_library/vs_math.nut)
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
Check if the float input is an integer
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
	local eye = HPlayer.EyePosition()
	local target = Vector()

	// only check if there is direct LOS with the target
	if( !VS.TraceLine( eye, target ).DidHit() )
	{
		bLooking = VS.IsLookingAt( eye, target, HPlayerEye.GetForwardVector(), VIEW_FIELD_NARROW )
	}

	if ( bLooking )
	{
		VS.ShowHudHint( hHudHint, HPlayer, "LOOKING" )
		DebugDrawBox( target, Vector(-8,-8,-8), Vector(8,8,8), 0,255,0,255, flFrameTime2 )
	}
	else
	{
		VS.ShowHudHint( hHudHint, HPlayer, "NOT looking" )
		DebugDrawBox( target, Vector(-8,-8,-8), Vector(8,8,8), 255,0,0,255, flFrameTime2 )
	}
}
```

</details>

________________________________

<a name="f_PointOnLineNearestPoint"></a>
```cpp
Vector VS::PointOnLineNearestPoint(Vector start, Vector end, Vector point)
```

________________________________

<a name="f_GetAngle"></a>
```cpp
Vector VS::GetAngle(Vector from, Vector to)
```
Angle between 2 position vectors
________________________________

<a name="f_GetAngle2D"></a>
```cpp
float VS::GetAngle2D(Vector from, Vector to)
```
Angle (yaw) between 2 position vectors
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
Vector VS::SnapDirectionToAxis(Vector& direction, float epsilon = 0.1)
```
Snaps the input (normalised direction) vector to the closest axis

<details><summary>Example</summary>

```cs
function Think()
{
	local eye = HPlayer.EyePosition()
	local dir = HPlayerEye.GetForwardVector()

	// draw normal direction
	DebugDrawLine( eye, eye+dir*128, 255, 255, 255, false, flFrameTime2 )
	DebugDrawBox( eye+dir*128, Vector(-2,-2,-2), Vector(2,2,2), 255, 255, 255, 128, flFrameTime2 )

	// snap
	VS.SnapDirectionToAxis( dir, 0.5 )

	// draw snapped direction
	DebugDrawLine( eye, eye+dir*128, 255, 255, 255, false, flFrameTime2 )
	DebugDrawBox( eye+dir*128, Vector(-2,-2,-2), Vector(2,2,2), 255, 255, 255, 128, flFrameTime2 )

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
Vector VS::VectorAdd(Vector a, Vector b, Vector& out = _VEC )
```
Vector a + Vector b

<details><summary>NOTE</summary>

```cs
//
// <vec1 + vec2> operation returns a new Vector instance
// <VS.VectorAdd(vec1, vec2, vec1)> stores the result in vec1
// When the third parameter is omitted, it acts the same as the overload operator
// (except when it doesn't, then you should either use the operator,
// or pass a new Vector instance in the third parameter)
//
// Example of how to mess up:

// in1, in2, in3, in4 are unique non-equal vectors

local v1 = VS.VectorAdd( in1, in2 )

// true
// VS.VectorsAreEqual( v1, in1+in2 )

local v2 = VS.VectorAdd( in3, in4 )

// false
// VS.VectorsAreEqual( v1, in1+in2 )

// true
// VS.VectorsAreEqual( v1, in3+in4 )

// true
// v1 == v2

// Overcoming this:

local v1 = VS.VectorAdd( in1, in2, Vector() )
local v2 = VS.VectorAdd( in3, in4, Vector() )

// This is because when the third parameter is omitted, they reference the same instance.
// While this may not be much of use in basic + - operations, it can be very helpful in
// complex functions in 'vs_math2', where you're using the value, not the instance.
// General idea is that if you're going to do more with the returned Vector instance,
// create a new one and pass that as a parameter.
```

</details>

________________________________

<a name="f_VectorSubtract"></a>
```cpp
Vector VS::VectorSubtract(Vector a, Vector b, Vector& out = _VEC )
```
Vector a - Vector b
________________________________

<a name="f_VectorScale"></a>
```cpp
Vector VS::VectorScale(Vector a, float b, Vector& out = _VEC )
```
Vector a * b
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
<details><summary>Details</summary>

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

</details>

________________________________

<a name="f_Gain"></a>
```cpp
float VS::Gain(float x, float biasAmt)
```
<details><summary>Details</summary>

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

</details>

________________________________

<a name="f_SmoothCurve"></a>
```cpp
float VS::SmoothCurve(float x)
```
<details><summary>Details</summary>

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

</details>

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
<details><summary>Details</summary>

This works like SmoothCurve, with two changes:  

1. Instead of the curve peaking at 0.5, it will peak at flPeakPos.  
   (So if you specify flPeakPos=0.2, then the peak will slide to the left).  

2. flPeakSharpness is a 0-1 value controlling the sharpness of the peak.  
   Low values blunt the peak and high values sharpen the peak.

</details>

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

### [vs_utility](https://github.com/samisalreadytaken/vs_library/blob/master/vs_library/vs_utility.nut)

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
ScriptPrintMessageChatAll(txt.red + "lorem ipsum")

// will be coloured
Chat(txt.red + "lorem ipsum")
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

<a name="f_txt"></a>
```cpp
txt
{
	invis
	white
	red
	purple
	green
	lightgreen
	limegreen
	lightred
	grey
	yellow
	lightblue
	blue
	darkblue
	darkgrey
	pink
	orangered
	orange
}
```
`Chat(txt.red + "RED" + txt.yellow + " YELLOW" + txt.white + " WHITE")`
________________________________

<a name="f_VecToString"></a>
```cpp
string VecToString(Vector vec, string prefix = "Vector(", string separator = ",", string suffix = ")")
```
return `"Vector(0, 1, 2)"`
________________________________

<a name="f_GetTickrate"></a>
```cpp
float VS::GetTickrate()
```
Get server tickrate
________________________________

<a name="f_IsDedicatedServer"></a>
```cpp
bool VS::IsDedicatedServer()
```
The initialisation of this function is asynchronous. It takes 6 seconds to finalise on map spawn auto-load, and 1-5 frames on manual execution on post map spawn. `VS.flCanCheckForDedicatedAfterSec` can be used for delayed initialisation needs.

`VS.EventQueue.AddEvent( Init, VS.flCanCheckForDedicatedAfterSec, this )`
________________________________

<a name="f_TraceLine"></a>
```cpp
class VS::TraceLine
{
	startpos
	endpos
	ignore
	fraction
	hitpos
	normal

	m_Delta
	m_IsSwept
	m_Extents
	m_IsRay
	m_StartOffset
	m_Start
}
```
________________________________

```cpp
trace_t VS::TraceLine(Vector start = null, Vector end = null, handle ignore = null)
```
Note: This doesn't hit entities. To calculate LOS with them, iterate through every entity type you want and trace individually.
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
Get surface normal

This computes 2 extra traces

Calling this will save the normal in `normal`, calling it again will not recompute.

<details><summary>Example</summary>

Draw the normal of a surface the player is looking at
```cs
function Think()
{
	local tr = VS.TraceDir(HPlayer.EyePosition(), HPlayerEye.GetForwardVector())

	tr.GetNormal()

	DebugDrawLine(tr.hitpos, tr.normal * 16 + tr.hitpos, 0, 0, 255, false, 0.1)
}
```

</details>

________________________________

<a name="f_Ray"></a>
```cpp
trace_t VS::TraceLine::Ray(Vector mins, Vector maxs)
```
Initiate ray tracing  
Used in collisions
________________________________

<a name="f_TraceDir"></a>
```cpp
trace_t VS::TraceDir(Vector start, Vector direction, float maxdist = MAX_TRACE_LENGTH, handle ignore = null)
```

<details><summary>Example</summary>

Example draw a cube at player aim (GOTV spectator like)
```lua
function Think()
{
	local eye = HPlayer.EyePosition()
	local pos = VS.TraceDir(eye, HPlayerEye.GetForwardVector()).GetPos()

	DebugDrawLine(eye, pos, 255, 255, 255, false, flFrameTime2)
	DebugDrawBox(pos, Vector(-2,-2,-2), Vector(2,2,2), 255, 255, 255, 125, flFrameTime2)
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

<a name="f_arrayFind"></a>
```cpp
int VS::arrayFind(array arr, TYPE val)
```
Linear search. If value found in array then return index, else return null

Checks using this function should be explicit, and not be implicit (`if(arrayFind())`); because the returned index value can be `0`, which equates to `false` in checks.

<details><summary>Example</summary>

```cs
local arr = ["a","b","c","d"]

// Wrong usage:

// index (1) is in array
// true
printl( VS.arrayFind(arr, "b") ? "true" : "false" )

// index (0) is in array
// false
printl( VS.arrayFind(arr, "a") ? "true" : "false" )

// index (null) is NOT in array
// false
printl( VS.arrayFind(arr, "x") ? "true" : "false" )


// Correct usage:

// Check if "a" is in array
// index (0) is in array
// true
printl( VS.arrayFind(arr, "a") != null )

// Check if "a" is NOT in array
// index (0) is in array
// false
printl( VS.arrayFind(arr, "a") == null )

// Check if "x" is NOT in array
// true
printl( VS.arrayFind(arr, "x") == null )

```

</details>

________________________________

<a name="f_arrayApply"></a>
```cpp
void VS::arrayApply(array arr, function func)
```
Apply the input function to every element in the input array
________________________________

<a name="f_arrayMap"></a>
```cpp
array VS::arrayMap(array arr, function func)
```
Same as arrayApply, but return a new array. Doesn't modify the input array
________________________________

<a name="f_DumpScope"></a>
```cpp
void VS::DumpScope(table table, bool printall = false, bool deepprint = true, bool guides = true, int depth = 0)
```
Usage: `VS.DumpScope(table)`
________________________________

<a name="f_DumpEnt"></a>
```cpp
void VS::DumpEnt(TYPE input = null)
```
Dump all entities whose script scopes are already created.

Input an entity handle or string to dump its scope.

`ent_script_dump`
________________________________

<a name="f_DumpPlayers"></a>
```cpp
void VS::DumpPlayers(bool dumpscope = false)
```
DumpEnt only players and bots

<details><summary>Details</summary>

If bots have targetnames, they 'become' humans

If the event listeners are not set up, named bots will be shown as players

</details>

________________________________

<a name="f_ArrayToTable"></a>
```cpp
table VS::ArrayToTable(array a)
```

________________________________

<a name="f_GetStackInfo"></a>
```cpp
void VS::GetStackInfo(bool deepprint = false, bool printall = false)
```
Print current stack info

Put in the function you want to get stack info from. if deepprint && scope not roottable then deepprint

<details><summary>Details</summary>

```
Engine function calls are done through Call(...), that's why these 2 stacks are excluded.
	 ---
	line = -1
	locals(TABLE) : 0
	src = "NATIVE"
	func = "pcall"
	 ---
	line = 360
	locals(TABLE) : 5
	{
	   i = 0
	   args(ARRAY) : 0
	   this = (instance : 0x00000000)
	   result = (null : 0x00000000)
	   func = (function : 0x00000000)
	}
	src = "unnamed"
	func = "Call"
	 ---
```

</details>

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

<a name="f_GetTableDir"></a>
```cpp
string[] VS::GetTableDir(table input)
```

<details><summary>Example</summary>

```cpp
::t1.t2.t3.t4 <- {}
VS.GetTableDir( t1.t2.t3.t4 )
VS.GetTableDir( VS.FindVarByName( "t4" ) )
-> both return ["roottable","t1","t2","t3","t4"]

You can quickly print the array with VS.DumpScope(output) for debug purposes
```

</details>

________________________________

<a name="f_FindVarByName"></a>
```cpp
TYPE VS::FindVarByName(string str)
```

<details><summary>Example</summary>

```cpp
::t1.t2.t3.t4 <- {}
VS.FindVarByName( "t4" )
-> returns table <t1.t2.t3.t4>
```

</details>

________________________________

<a name="f_GetVarName"></a>
```cpp
string VS::GetVarName(TYPE v)
```
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

### [vs_entity](https://github.com/samisalreadytaken/vs_library/blob/master/vs_library/vs_entity.nut)
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

<a name="f_ShowGameText"></a>
```cpp
void VS::ShowGameText(handle ent, handle target, string msg = null, float delay = 0.0)
```
Show gametext

if ent == handle then set msg
________________________________

<a name="f_ShowHudHint"></a>
```cpp
void VS::ShowHudHint(handle ent, handle target, string msg = null, float delay = 0.0)
```
Show hudhint

if ent == handle then set msg
________________________________

<a name="f_HideHudHint"></a>
```cpp
void VS::HideHudHint(handle ent, handle target, float delay = 0.0)
```
Hide hudhint
________________________________

<a name="f_CreateMeasure"></a>
```cpp
handle VS::CreateMeasure(string targetTargetname, string refTargetname = null, bool bMakePersistent = false, bool measureEye = true, float scale = 1.0)
```
Create and return an eye angle measuring entity

```lua
player_eye_reference <- VS.CreateMeasure("player_targetname")
```

If `measureEye` is false then measure `targetTargetname` and set `refTargetname` as reference (entity to move)

Starting to measure is asynchronous, you cannot measure the angles in the same frame as creating or setting the measure entity.

<details><summary>Example</summary>

Example get player eye angles:
```lua
function InitEntities()
{
	if ( "hPlayerEye" in this && hPlayerEye )
		return

	hPlayer <- VS.GetLocalPlayer().weakref()
	hPlayerEye <- VS.CreateMeasure( hPlayer.GetName() ).weakref()
}

function PrintEyeAngles()
{
	printl( "Player eye angles: " + VecToString( hPlayerEye.GetAngles() ) )
}
```

Init now, and print in the next frame
```cs
InitEntities()
VS.EventQueue.AddEvent( PrintEyeAngles, 0, this )
```

Example check to prevent spawning if the entities are already spawned
```lua
if( !Ent("refname") )
{
	hPlayerEye <- VS.CreateMeasure( "playername", "refname", true )
}
```

Or saving the handle in an unchanged container, e.g. the root table
```lua
if( !("hPlayerEye" in getroottable()) )
{
	::hPlayerEye <- VS.CreateMeasure( "playername", "refname", true )
}
```

You can disable the reference entity to stop the measure. The reference will keep the last measured values.

```lua
EntFireByHandle( hPlayerEye, "Disable" )
```

</details>

<details><summary>Details</summary>

This function creates an entity to measure player eye angles `logic_measure_movement : vs.ref_*`.

`"refname"` in the example above refers to the reference entity's targetname.

The `bMakePersistent` paramater ensures the entity is not released on round end. However, while using it, make sure to include a check to prevent spawning over and over again. Shown in the example above.

</details>

________________________________

<a name="f_SetMeasure"></a>
```cpp
void VS::SetMeasure(handle logic_measure_movement, string targetTargetname)
```
Start measuring new target

<details><summary>Example</summary>

```cs
hPlayer1 <- VS.GetLocalPlayer()
hPlayer2 <- GetSomeOtherPlayer()

// start measuring hPlayer1
hPlayerEye <- VS.CreateMeasure(hPlayer1.GetName())

printl("Player1 eye angles: " + VecToString(hPlayerEye.GetAngles()))

// start measuring hPlayer2
VS.SetMeasure( hPlayerEye, hPlayer2.GetName() )

printl("Player2 eye angles: " + VecToString(hPlayerEye.GetAngles()))
```

</details>

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

<a name="f_AddOutput2"></a>
```cpp
void VS::AddOutput2(handle ent, string output, string exec, table scope = null, bool bExecInEnt = false)
```

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

If changing the text from script, create in script (and make persistent); else if text is static, doesn't matter

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

### [vs_events](https://github.com/samisalreadytaken/vs_library/blob/master/vs_library/vs_events.nut)
________________________________

<a name="f_GetPlayerByUserid"></a>
```cpp
handle VS::GetPlayerByUserid(int userid)
```
If event listeners are correctly set up, get the player handle from their userid.

Return null if no player is found.

See [Setting up basis event listeners](#setting-up-basis-event-listeners)
________________________________

<a name="f_ForceValidateUserid"></a>
```cpp
void VS::ForceValidateUserid(handle player)
```
if something has gone wrong with automatic validation, force add userid.

Calling multiple times in a frame will cause problems; either delay, or use ValidateUseridAll.
________________________________

<a name="f_ValidateUseridAll"></a>
```cpp
void VS::ValidateUseridAll(bool force = false)
```
Make sure all player userids are validated. Asynchronous.
________________________________

<a name="f_FixupEventListener"></a>
```cpp
void VS::FixupEventListener( handle eventlistener )
```
Details:

While event listeners dump the event data whenever events are fired, entity outputs are added to the event queue to be executed in the next frame. Because of this delay, when an event is fired multiple times before the output is fired - before the script function is executed via the output - previous events would be lost.

This function catches each event data dump, saving it for the next time it is fetched by user script which is called by the event listener output. Because of this save-restore action, the event data can only be fetched once. This means there can only be 1 event listener output with event_data access.
________________________________

### [vs_log](https://github.com/samisalreadytaken/vs_library/blob/master/vs_library/vs_log.nut)

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
string VS::Log::Run( data = null, function callback = null )
```
If `data` is null, the internal log is used. `callback` is called after logging is complete.

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

### [vs_math2](https://github.com/samisalreadytaken/vs_library/blob/master/vs_library/vs_math2.nut)
________________________________

<a name="f_Quaternion"></a>
```cpp
class Quaternion
{
	x, y, z, w
}
```
________________________________

```cpp
Quaternion Quaternion()
Quaternion Quaternion(x, y, z, w)
```

________________________________

<a name="f_matrix3x4_t"></a>
```cpp
class matrix3x4_t
{
	m[3][4]

	void Init()
}
```

________________________________

```cpp
matrix3x4_t matrix3x4_t()
matrix3x4_t matrix3x4_t(Vector xAxis, Vector yAxis, Vector zAxis, Vector vecOrigin)
```
Creates a matrix where the X axis = forward  
the Y axis = left, and the Z axis = up
________________________________

<a name="f_VMatrix"></a>
```cpp
class VMatrix
{
	VMatrix()
	m[4][4]
}
```

________________________________

<a name="f_InvRSquared"></a>
```cpp
float VS::InvRSquared(Vector v)
```

________________________________

<a name="f_a_swap"></a>
```cpp
void VS::a_swap(array a1, int i1, array a2, int i2)
```

________________________________

<a name="f_MatrixRowDotProduct"></a>
```cpp
float VS::MatrixRowDotProduct(matrix3x4_t in1, int row, Vector in2)
```

________________________________

<a name="f_MatrixColumnDotProduct"></a>
```cpp
float VS::MatrixColumnDotProduct(matrix3x4_t in1, int col, Vector in2)
```

________________________________

<a name="f_DotProductAbs"></a>
```cpp
float VS::DotProductAbs(Vector in1, Vector in2)
```

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

<a name="f_VectorRotate2"></a>
```cpp
Vector VS::VectorRotate2(Vector in1, QAngle in2, Vector& out = _VEC)
```
assume in2 is a rotation and rotate the input vector
________________________________

<a name="f_VectorRotate3"></a>
```cpp
Vector VS::VectorRotate3(Vector in1, Quaternion in2, Vector& out = _VEC)
```
assume in2 is a rotation and rotate the input vector
________________________________

<a name="f_VectorIRotate"></a>
```cpp
Vector VS::VectorIRotate(Vector in1, matrix3x4_t in2, Vector& out = _VEC)
```
rotate by the inverse of the matrix
________________________________

<a name="f_VectorMA"></a>
```cpp
Vector VS::VectorMA(Vector start, float scale, Vector direction, Vector& dest = _VEC)
```

________________________________

<a name="f_QuaternionsAreEqual"></a>
```cpp
bool VS::QuaternionsAreEqual(Quaternion a, Quaternion b, float tolerance = 0.0)
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

<a name="f_QuaternionMult"></a>
```cpp
Quaternion VS::QuaternionMult(Quaternion p, Quaternion q, Quaternion& qt = _QUAT)
```
`qt = p * q`
________________________________

<a name="f_QuaternionAlign"></a>
```cpp
Quaternion VS::QuaternionAlign(Quaternion p, Quaternion q, Quaternion& qt = _QUAT)
```
make sure quaternions are within 180 degrees of one another, if not, reverse q
________________________________

<a name="f_QuaternionBlend"></a>
```cpp
Quaternion VS::QuaternionBlend(Quaternion p, Quaternion q, float t, Quaternion& qt = _QUAT)
```
Do a piecewise addition of the quaternion elements. This is a cheap way to simulate a slerp.

nlerp
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

<a name="f_QuaternionExp"></a>
```cpp
void VS::QuaternionExp(Quaternion p, Quaternion &q)
```
Computes the exponential of a given pure quaternion. The w-component of the input quaternion is ignored in the calculation.
________________________________

<a name="f_QuaternionLn"></a>
```cpp
void VS::QuaternionLn(Quaternion p, Quaternion &q)
```
Computes the natural logarithm of a given unit quaternion. If input is not a unit quaternion, the returned value is undefined.
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

<a name="f_QuaternionConjugate"></a>
```cpp
void VS::QuaternionConjugate(Quaternion p, Quaternion& q)
```

________________________________

<a name="f_QuaternionInvert"></a>
```cpp
void VS::QuaternionInvert(Quaternion p, Quaternion& q)
```

________________________________

<a name="f_QuaternionNormalize"></a>
```cpp
float VS::QuaternionNormalize(Quaternion& q)
```
Make sure the quaternion is of unit length

Return radius
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

<a name="f_RotationDeltaAxisAngle"></a>
```cpp
void VS::RotationDeltaAxisAngle( QAngle srcAngles, QAngle destAngles, Vector &deltaAxis, float deltaAngle )
```

________________________________

<a name="f_RotationDelta"></a>
```cpp
void VS::RotationDelta( QAngle srcAngles, QAngle destAngles, QAngle &out )
```

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

<a name="f_ScreenToWorld"></a>
```cpp
Vector VS::ScreenToWorld( float x, float y, Vector origin, Vector forward, Vector right, Vector up, float fov, float flAspect, float zFar )
```
```cs
{
	local x = 0.35
	local y = 0.65
	local eyeAng = playerEye.GetAngles()
	local eyePos = player.EyePosition()
	local worldPos = VS.ScreenToWorld( x, y,
		eyePos,
		playerEye.GetForwardVector(),
		playerEye.GetLeftVector(),
		playerEye.GetUpVector(),
		90.0, 16.0/9.0, 16.0 )

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
void VS::DrawFrustum( matWorldToView, r, g, b, z, time )
```
________________________________

<a name="f_DrawViewFrustum"></a>
```cpp
void VS::DrawViewFrustum( vecOrigin, vecForward, vecRight, vecUp,
		flFovX, flAspect, zNear, zFar, r, g, b, z, time )
```
________________________________

<a name="f_DrawBoxAngles"></a>
```cpp
void VS::DrawBoxAngles( origin, mins, maxs, angles, r, g, b, z, time )
```
________________________________

<a name="f_DrawEntityBounds"></a>
```cpp
void VS::DrawEntityBounds( ent, r, g, b, z, time )
```
________________________________

<a name="f_DrawSphere"></a>
```cpp
void VS::DrawSphere( Vector vCenter, float flRadius, int nTheta, int nPhi, int r, int g, int b, bool z, float time )
```
________________________________

<a name="f_DrawCapsule"></a>
```cpp
void VS::DrawCapsule( start, end, radius, r, g, b, z, time )
```
________________________________

### [vs_collision](https://github.com/samisalreadytaken/vs_library/blob/master/vs_library/vs_collision.nut)

Ray traces need to be initialised with `trace.Ray()`
________________________________

<a name="f_Collision_ClearTrace"></a>
```cpp
void VS::Collision_ClearTrace(Vector vecRayStart, Vector vecRayDelta, trace_t& pTrace)
```
Clears the trace
________________________________

<a name="f_ComputeBoxOffset"></a>
```cpp
float VS::ComputeBoxOffset(ray_t ray)
```
Compute the offset in t along the ray that we'll use for the collision
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
float VS::IsRayIntersectingSphere(Vector vecRayOrigin, Vector vecRayDelta, Vector vecCenter, float flRadius, float flTolerance)
```
returns true if there's an intersection between ray and sphere

`flTolerance [0..1]`
________________________________

<a name="f_IsBoxIntersectingRay"></a>
```cpp
bool VS::IsBoxIntersectingRay(Vector origin, Vector vecBoxMin, Vector vecBoxMax, ray_t ray, float flTolerance = 0.0)
```
Intersects a ray with a AABB, return true if they intersect

Input  : localMins, localMaxs
________________________________

<a name="f_IsBoxIntersectingRay2"></a>
```cpp
bool VS::IsBoxIntersectingRay2(Vector boxMin, Vector boxMax, Vector origin, Vector vecDelta, float flTolerance)
```
Intersects a ray with a AABB, return true if they intersect

Input  : worldMins, worldMaxs
________________________________

### [vs_interp](https://github.com/samisalreadytaken/vs_library/blob/master/vs_library/vs_interp.nut)
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

<details><summary>Details</summary>

See http://en.wikipedia.org/wiki/Kochanek-Bartels_curves

Tension:    -1 = Round -> 1 = Tight  
Bias:       -1 = Pre-shoot (bias left) -> 1 = Post-shoot (bias right)  
Continuity: -1 = Box corners -> 1 = Inverted corners

If T=B=C=0 it's the same matrix as Catmull-Rom.  
If T=1 & B=C=0 it's the same as Cubic.  
If T=B=0 & C=-1 it's just linear interpolation

See http://news.povray.org/povray.binaries.tutorials/attachment/%3CXns91B880592482seed7@povray.org%3E/Splines.bas.txt
for example code and descriptions of various spline types...

</details>

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
**END OF DOC**
________________________________
