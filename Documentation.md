# VScript Library Documentation
Documentation for [vs_library](https://github.com/samisalreadytaken/vs_library).

________________________________
<!-- U+2800 U+2514 U+2500 -->
### Table of Contents
└─ [**Installation**](#Installation)  
└─ [**Usage**](#Usage)  
⠀ ⠀└─ [Setting up basis event listeners](#setting-up-basis-event-listeners)  
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

## Installation
Place `vs_library.nut` in your vscripts directory `/csgo/scripts/vscripts/`

### Downloading
**Method 1.**
Manually download the library by right clicking [**HERE**](https://raw.githubusercontent.com/samisalreadytaken/vs_library/master/vs_library.nut), and choosing _"Save Link As..."_.  
After acquiring the file, place it in your vscripts directory: `/csgo/scripts/vscripts/`

**Method 2.**
On Windows 10 17063 or later, run the [`install_vs_library.bat`](https://raw.githubusercontent.com/samisalreadytaken/vs_library/master/install_vs_library.bat) file to automatically download the library into your game files. It can also be used to update the library.

**Method 3.**
In bash, after changing the directory below to your Steam game library directory, use the following commands to install the library into your game files.
```
cd "C:/Program Files/Steam/steamapps/common/Counter-Strike Global Offensive/csgo/scripts/vscripts/" && 
curl -O https://raw.githubusercontent.com/samisalreadytaken/vs_library/master/vs_library.nut
```

## Usage
Add this following line in the beginning of your script: `IncludeScript("vs_library")`

Done!

It only needs to be included once in the lifetime of the map running in the server. Including it more than once does not affect the performance. 

### Setting up basis event listeners
Set up these event listeners to automatically validate player userids. This will let you access player userid, SteamID, and Steam names.

Entity targetnames are arbitrary.
```
logic_eventlistener:
	targetname: player_connect
	EventName:  player_connect
	FetchEventData: Yes

	OnEventFired > player_connect > RunScriptCode > ::VS.Events.player_connect(event_data)

logic_eventlistener:
	targetname: player_spawn
	EventName:  player_spawn
	FetchEventData: Yes

	OnEventFired > player_spawn   > RunScriptCode > ::VS.Events.player_spawn(event_data)
```

You can get the player handle from their userid.
```lua
local player = VS.GetPlayerByUserid(userid)
```

You can access the player data via their scope.
```cs
player.GetScriptScope().userid
player.GetScriptScope().networkid
player.GetScriptScope().name
```

Use `VS.DumpPlayers(1)` to see every player data.
```
] script VS.DumpPlayers(1)

=======================================
1 players found
2 bots found
[BOT]    - ([2] player) :: 8b4f4f2f171_player
--- Script dump for entity ([2] player)
   networkid = "BOT"
   userid = 24
   name = "Chet"
--- End script dump
[BOT]    - ([3] player) :: b02f4f5e377_player
--- Script dump for entity ([3] player)
   networkid = "BOT"
   userid = 25
   name = "Vitaliy"
--- End script dump
[PLAYER] - ([1] player) :: b3ff40ba523_player
--- Script dump for entity ([1] player)
   networkid = "STEAM_1:0:11101"
   userid = 14
   name = "Sam"
--- End script dump
=======================================
```
________________________________

## Developer notes
* Some wrapper functions such as EntFireByHandle return the final calls to take advantage of tail calls for better performance.
* Variables in large loops are saved in local variables to reduce variable lookups.
* There will be some inconsistencies between the minified version and the source files.
* * Some functions that should be 'inline' such as max() are manually replaced in the minified version to reduce function call overhead.
* * Constant variables such as PI and DEG2RAD are replaced with their values in the minified version to reduce variable lookups.

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
| `handle`              | Entity script handle                                                                |
| `Vector`, `vec3_t`    | `Vector(0,1,2)`                                                                     |
| `QAngle`              | `Vector(0,1,2)`, `(pitch, yaw, roll)` Euler angle. Vector, **not a different type** |
| `Quaternion`          | `Quaternion(0,1,2,3)`                                                               |
| `matrix3x4_t`         | `matrix3x4()`                                                                       |
| `trace_t`             | `VS.TraceLine()`                                                                    |
| `ray_t`               | `VS.TraceLine().Ray()`, `trace_t`                                                   |
| `TYPE`                | Multiple types. Any unless specified in description                                 |

| Symbols | Description                                                                                                                                                                                                       |
| ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `&`     | pointer, reference, instance. This means the input will be modified. Optional pointers can be omitted, but their result will be modified the next time another function with omitted pointer parameter is called. |
| `[]`    | array. `float[3]` represents an array made of floats, with only 3 indices.                                                                                                                                        |

### Variables used in examples
| Variable       | Creation                          | Description                                           |
| -------------- | --------------------------------- | ----------------------------------------------------- |
| `HPlayer`      | `VS.GetLocalPlayer()`             | Local player in the server                            |
| `HPlayerEye`   | `VS.CreateMeasure(HPlayer.GetName())`      | Buffer to get player eye angles                       |
| `hHudHint`     | `VS.CreateEntity("env_hudhint")`  | Hud hint, show messages to the player                 |
| `Think()`      | `VS.Timer(0, FrameTime(), Think)` | A function that is executed every frame               |
| `flFrameTime2` | `FrameTime() * 2`                 | Used in the Think function for displaying every frame |


## Base
Included in `vs_library.nut`

### Constants
| Variable           | Value                            |
| ------------------ | -------------------------------- |
| `CONST`            | `table` Squirrel constant table  |
| `vs_library`       | `string` VScript Library version |
| `MAX_COORD_FLOAT`  | `16384.0`                        |
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
[`VS.Dist()`](#f_Dist)  
[`VS.DistSqr()`](#f_DistSqr)  
[`VS.VectorCopy()`](#f_VectorCopy)  
[`VS.VectorMin()`](#f_VectorMin)  
[`VS.VectorMax()`](#f_VectorMax)  
[`VS.VectorAbs()`](#f_VectorAbs)  
[`VS.VectorAdd()`](#f_VectorAdd)  
[`VS.VectorSubtract()`](#f_VectorSubtract)  
[`VS.VectorMultiply()`](#f_VectorMultiply)  
[`VS.VectorMultiply2()`](#f_VectorMultiply2)  
[`VS.VectorDivide()`](#f_VectorDivide)  
[`VS.VectorDivide2()`](#f_VectorDivide2)  
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
[`ClearChat()`](#f_ClearChat)  
[`txt`](#f_txt)  
[`VecToString()`](#f_VecToString)  
[`VS.GetTickrate()`](#f_GetTickrate)  
[`VS.FormatPrecision()`](#f_FormatPrecision)  
[`VS.FormatHex()`](#f_FormatHex)  
[`VS.FormatExp()`](#f_FormatExp)  
[`VS.FormatWidth()`](#f_FormatWidth)  
[`VS.DrawEntityBBox()`](#f_DrawEntityBBox)  
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
[`VS.ForceReload()`](#f_ForceReload)  


### [vs_entity](#vs_entity-1)
[`EntFireByHandle()`](#f_EntFireByHandle)  
[`PrecacheModel()`](#f_PrecacheModel)  
[`PrecacheScriptSound()`](#f_PrecacheScriptSound)  
[`VS.MakePermanent()`](#f_MakePermanent)  
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
[`VS.SetKey()`](#f_SetKey)  
[`VS.SetName()`](#f_SetName)  
[`VS.GetPlayersAndBots()`](#f_GetPlayersAndBots)  
[`VS.GetAllPlayers()`](#f_GetAllPlayers)  
[`VS.GetLocalPlayer()`](#f_GetLocalPlayer)  
[`VS.GetPlayerByIndex()`](#f_GetPlayerByIndex)  
[`VS.FindEntityByIndex()`](#f_FindEntityByIndex)  
[`VS.FindEntityByString()`](#f_FindEntityByString)  
[`VS.IsPointSized()`](#f_IsPointSized)  
[`VS.FindEntityClassNearestFacing()`](#f_FindEntityClassNearestFacing)  
[`VS.FindEntityNearestFacing()`](#f_FindEntityNearestFacing)  
[`VS.FindEntityClassNearestFacingNearest()`](#f_FindEntityClassNearestFacingNearest)  


### [vs_events](#vs_events-1)
[`VS.GetPlayerByUserid()`](#f_GetPlayerByUserid)  
[`VS.AddEventCallback()`](#f_AddEventCallback)  
[`VS.Events.ForceValidateUserid()`](#f_ForceValidateUserid)


### [vs_log](#vs_log-1)
[`VS.Log.condition`](#f_Logcondition)  
[`VS.Log.export`](#f_Logexport)  
[`VS.Log.filePrefix`](#f_LogfilePrefix)  
[`VS.Log.Add()`](#f_LogAdd)  
[`VS.Log.Clear()`](#f_LogClear)  
[`VS.Log.Run()`](#f_LogRun)  
[`VS.Log.filter`](#f_Logfilter)  


## Additional
Not included in `vs_library.nut`

### [vs_math2](#vs_math2-1)
[`Quaternion`](#f_Quaternion)  
[`matrix3x4`](#f_matrix3x4)  
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
[`VS.VectorNegate()`](#f_VectorNegate)  
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
[`VS.QuaternionAngleDiff()`](#f_QuaternionAngleDiff)  
[`VS.QuaternionConjugate()`](#f_QuaternionConjugate)  
[`VS.QuaternionInvert()`](#f_QuaternionInvert)  
[`VS.QuaternionNormalize()`](#f_QuaternionNormalize)  
[`VS.QuaternionMatrix()`](#f_QuaternionMatrix)  
[`VS.QuaternionMatrix2()`](#f_QuaternionMatrix2)  
[`VS.QuaternionAngles()`](#f_QuaternionAngles)  
[`VS.QuaternionAxisAngle()`](#f_QuaternionAxisAngle)  
[`VS.AxisAngleQuaternion()`](#f_AxisAngleQuaternion)  
[`VS.AngleQuaternion()`](#f_AngleQuaternion)  
[`VS.MatrixQuaternion()`](#f_MatrixQuaternion)  
[`VS.BasisToQuaternion()`](#f_BasisToQuaternion)  
[`VS.MatrixAngles()`](#f_MatrixAngles)  
[`VS.MatrixAnglesQ()`](#f_MatrixAnglesQ)  
[`VS.AngleMatrix()`](#f_AngleMatrix)  
[`VS.AngleMatrix2()`](#f_AngleMatrix2)  
[`VS.AngleIMatrix()`](#f_AngleIMatrix)  
[`VS.AngleIMatrix2()`](#f_AngleIMatrix2)  
[`VS.MatrixVectors()`](#f_MatrixVectors)  
[`VS.MatricesAreEqual()`](#f_MatricesAreEqual)  
[`VS.MatrixCopy()`](#f_MatrixCopy)  
[`VS.MatrixInvert()`](#f_MatrixInvert)  
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
[`VS.MatrixBuildRotationAboutAxis()`](#f_MatrixBuildRotationAboutAxis)  
[`VS.TransformAABB()`](#f_TransformAABB)  
[`VS.ITransformAABB()`](#f_ITransformAABB)  
[`VS.RotateAABB()`](#f_RotateAABB)  
[`VS.IRotateAABB()`](#f_IRotateAABB)  


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
[`VS.IntersectRayWithRay()`](#f_IntersectRayWithRay)  
[`VS.IsRayIntersectingOBB()`](#f_IsRayIntersectingOBB)  
[`VS.ComputeSeparatingPlane()`](#f_ComputeSeparatingPlane)  
[`VS.ComputeSeparatingPlane2()`](#f_ComputeSeparatingPlane2)  


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
[`VS.Catmull_Rom_SplineQ()`](#f_Catmull_Rom_SplineQ)  
[`VS.Catmull_Rom_SplineQ_Tangent()`](#f_Catmull_Rom_SplineQ_Tangent)  
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
[`VS.QAngleLerp()`](#f_QAngleLerp)  

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
	local looking, eye = HPlayer.EyePosition(),
	      target = Vector(-530.289490,-753.231506,123.932724)

	// only check if there is direct LOS with the target
	if( !VS.TraceLine( eye, target ).DidHit() )
		looking = VS.IsLookingAt( eye, target, HPlayerEye.GetForwardVector(), 0.9 )

	VS.ShowHudHint( hHudHint, HPlayer, looking ? "LOOKING" : "NOT looking" )

	DebugDrawBox( target, Vector(-8,-8,-8), Vector(8,8,8), 255, 255, 255, 255, flFrameTime2 )
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
QAngle VS::VectorAngles(Vector forward)
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
Vector VS::QAngleNormalize(Vector& angle)
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

<a name="f_Dist"></a>
```cpp
float VS::Dist(Vector v1, Vector v2)
```
Distance between 2 vectors
________________________________

<a name="f_DistSqr"></a>
```cpp
float VS::DistSqr(Vector v1, Vector v2)
```
Distance squared between 2 vectors. Use for comparisons, cheaper than getting actual length
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

```cpp
//
// <vec1 + vec2> operation returns a new Vector instance
// <VS.VectorAdd(vec1, vec2, vec1)> stores the result in vec1
// When the third parameter is omitted, it acts the same as the overload operator
// (except when it doesn't, then you should either use the operator,
// or pass a new Vector instance in the third parameter)
//
// Example of how to mess up:
/*

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

// This is because when the third parameter is omitted, they reference the same instance
// While this may not be much of use in basic + - operations, it can be very helpful in
// complex functions in 'vs_math2', where you're using the value, not the instance.
// General idea is that if you're going to do more with the returned Vector instance,
// create a new one and pass that as a parameter.
*/
```

</details>

________________________________

<a name="f_VectorSubtract"></a>
```cpp
Vector VS::VectorSubtract(Vector a, Vector b, Vector& out = _VEC )
```
Vector a - Vector b
________________________________

<a name="f_VectorMultiply"></a>
```cpp
Vector VS::VectorMultiply(Vector a, float b, Vector& out = _VEC )
```
Vector a * b
________________________________

<a name="f_VectorMultiply2"></a>
```cpp
Vector VS::VectorMultiply2(Vector a, Vector b, Vector& out = _VEC )
```
Vector a * Vector b
________________________________

<a name="f_VectorDivide"></a>
```cpp
Vector VS::VectorDivide(Vector a, float b, Vector& out = _VEC )
```
Vector a / b
________________________________

<a name="f_VectorDivide2"></a>
```cpp
Vector VS::VectorDivide2(Vector a, Vector b, Vector& out = _VEC )
```
Vector a / Vector b
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
<details><summary>Details</summary>

5-argument floating point linear interpolation.  
FLerp(f1,f2,i1,i2,x)=  
   f1 at x=i1  
   f2 at x=i2  
  smooth lerp between f1 and f2 at x>i1 and x<i2  
  extrapolation for x<i1 or x>i2  

  If you know a function f(x)'s value (f1) at position i1, and its value (f2) at position i2,  
  the function can be linearly interpolated with FLerp(f1,f2,i1,i2,x)  
   i2=i1 will cause a divide by zero.

</details>

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

<details><summary>Snippet</summary>

```cs
// Reload the script file this is put in once again
// Can be used to "apply" the const variables compiled from another file
/*

if(!("__reloading"in::getroottable()))::__reloading<-false;;if(::__reloading)delete::__reloading;else{local _=function(){};::__reloading=true;return::DoIncludeScript(_.getinfos().src,this)};;

*/
```

</details>

________________________________

<a name="f_Ent"></a>
```cpp
handle Ent(string targetname, handle startEntity = null)
```
Find entity by targetname
________________________________

<a name="f_Entc"></a>
```cpp
handle Entc(string classname, handle startEntity = null)
```
Find entity by classname
________________________________

<a name="f_delay"></a>
```cpp
void delay(string exec, float time = 0.0, handle ent = ENT_SCRIPT, handle activator = null, handle caller = null)
```
Execute `exec` in the scope of `ent`

`delay( "SomeFunc()", 2.5 )`

<details><summary>Details</summary>

If you wish to delay the code in a specific entity scope, set the third parameter to the entity, or 'self'.

If you wish to delay the code in a specific scope, you need to know the name of the table. Using `VS.DumpScope(VS.GetTableDir(tableInput))`, you can find in which table your desired scope is, and execute the code.

You can use activators and callers to easily access entity handles

```cs
local vec = Vector(4,6,0)

delay( "activator.SetOrigin("+ VecToString(vec) +")", 2.5, ENT_SCRIPT, hSomeEntity )
```

</details>

<details><summary>Snippet</summary>

Paste the line below to the console to test target time -> server time conversion. Change `0.1` in the end to your time

```cs
script local _=function(i){delay("printl("+i+"+\" -> \"+(Time()-"+VS.FormatPrecision(Time(),9)+"))",i.tofloat())}( 0.1 )
```

</details>

________________________________

<a name="f_Chat"></a>
```cpp
void Chat(string s)
```

________________________________

<a name="f_ChatTeam"></a>
```cpp
void ChatTeam(int team, string s)
```

________________________________

<a name="f_Alert"></a>
```cpp
void Alert(string s)
```

________________________________

<a name="f_AlertTeam"></a>
```cpp
void AlertTeam(int team, string s)
```

________________________________

<a name="f_ClearChat"></a>
```cpp
void ClearChat()
```

________________________________

<a name="f_txt"></a>
```cpp
txt {
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
`Chat( txt.red + "RED" + txt.yellow + " YELLOW" + txt.white + " WHITE" )`
________________________________

<a name="f_VecToString"></a>
```cpp
string VecToString(Vector vec, string prefix = "Vector(", string separator = ",", string suffix = ")")
```
return `"Vector(0,1,2)"`
________________________________

<a name="f_GetTickrate"></a>
```cpp
float VS::GetTickrate()
```
Get server tickrate
________________________________

<a name="f_FormatPrecision"></a>
```cpp
string VS::FormatPrecision(float f, int n)
```
.tointeger() or .tofloat() can be used on the result

<details><summary>Example</summary>

```lua
local res = VS.FormatPrecision( 1.234, 6 )

printl(res)
```
**Output:**
```cpp
1.234000
```

</details>

________________________________

<a name="f_FormatHex"></a>
```cpp
string VS::FormatHex(int i, int n)
```
.tointeger() or .tofloat() can be used on the result

<details><summary>Example</summary>

```lua
local res  = VS.FormatHex( 62342, 8 )
local res2 = VS.FormatHex( 62342, 0 )

printl(res)
printl(res2)
```
**Output:**
```cpp
0x00f386
0xf386
```

</details>

________________________________

<a name="f_FormatExp"></a>
```cpp
string VS::FormatExp(float f, int n)
```
.tointeger() or .tofloat() can be used on the result

<details><summary>Example</summary>

```lua
local res  = VS.FormatExp( 62342, 8 )
local res2 = VS.FormatExp( 62342, 0 )

printl(res)
printl(res2)
```
**Output:**
```cpp
6.23420000e+04
6e+04
```

</details>

________________________________

<a name="f_FormatWidth"></a>
```cpp
string VS::FormatWidth(string i, int n, string s = " ")
```
Parameter `s` can be either `0` or `" "`

<details><summary>Example</summary>

```lua
local res  = VS.FormatWidth("test", 5, 0   )
local res2 = VS.FormatWidth(123,    6, 0   )
local res3 = VS.FormatWidth(123,    6, " " )

printl(res)
printl(res2)
printl(res3)
```
**Output:**
```cpp
0test
00123
  123
```
</details>

________________________________

<a name="f_DrawEntityBBox"></a>
```cpp
void VS::DrawEntityBBox(float time, handle ent, int r = 255, int g = 138, int b = 0, int alpha = 0)
```
Draw entity's AABB

Equivalent to the command `ent_bbox`
________________________________

<a name="f_TraceLine"></a>
```cpp
class VS::TraceLine
{
	startpos
	endpos
	hIgnore
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
Note: This doesn't hit entities. To calculate LOS with them, iterate through every entity type you want and trace individually  
Example: https://github.com/samisalreadytaken/vscripts/blob/master/aimbot/aimbot.nut#L291
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
	local tr = VS.TraceDir( HPlayer.EyePosition(), HPlayerEye.GetForwardVector() )

	tr.GetNormal()

	DebugDrawLine( tr.hitpos, tr.normal * 16 + tr.hitpos, 0, 0, 255, false, 10 )
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
	local v1 = VS.TraceDir( eye, HPlayerEye.GetForwardVector() ).GetPos()

	DebugDrawLine( eye, v1, 255, 255, 255, false, flFrameTime2 )
	DebugDrawBox( v1, Vector(-2,-2,-2), Vector(2,2,2), 255, 255, 255, 125, flFrameTime2 )
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

<a name="f_arrayFind"></a>
```cpp
int VS::arrayFind(array arr, TYPE val)
```
Linear search  
if value found in array, return index  
else return null

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

Put in the function you want to get stack info from  
if deepprint && scope not roottable, deepprint

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
	   this = (instance : pointer)
	   result = (null : 0x00000000)
	   func = (function : pointer)
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
Doesn't work with primitive variables if  
there are multiple variables with the same value.  
But it can work if the value is unique, like a unique string.

<details><summary>Example</summary>

```cs
::somestring <- "my unique string"
::somefunc <- function(){}

// prints "somestring"
printl( VS.GetVarName(somestring) )

// prints "somefunc"
printl( VS.GetVarName(somefunc) )
```

</details>

________________________________

<a name="f_ForceReload"></a>
```cpp
void VS::ForceReload()
```
Force reload the library
________________________________

### [vs_entity](https://github.com/samisalreadytaken/vs_library/blob/master/vs_library/vs_entity.nut)
________________________________

<a name="f_EntFireByHandle"></a>
```cpp
void EntFireByHandle(handle target, string action, string value = "", float delay = 0.0, handle activator = null, handle caller = null)
```
`EntFireByHandle( hEnt, "Use" )`

<details><summary>More</summary>

The native function is `DoEntFireByInstanceHandle`

</details>

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

<a name="f_MakePermanent"></a>
```cpp
void VS::MakePermanent(handle ent)
```
Prevent the entity from being released every round
________________________________

<a name="f_SetParent"></a>
```cpp
void VS::SetParent(handle child, handle parent)
```
Set child's parent  
if parent == null, unparent child
________________________________

<a name="f_ShowGameText"></a>
```cpp
void VS::ShowGameText(handle ent, handle target, string msg = null, float delay = 0.0)
```
Show gametext

if ent == handle, set msg
________________________________

<a name="f_ShowHudHint"></a>
```cpp
void VS::ShowHudHint(handle ent, handle target, string msg = null, float delay = 0.0)
```
Show hudhint

if ent == handle, set msg
________________________________

<a name="f_HideHudHint"></a>
```cpp
void VS::HideHudHint(handle ent, handle target, float delay = 0.0)
```
Hide hudhint
________________________________

<a name="f_CreateMeasure"></a>
```cpp
handle VS::CreateMeasure(string targetTargetname, string refTargetname = null, bool makePermanent = false, bool measureEye = true, float scale = 1.0)
```
Create and return an eye angle measuring entity

```lua
player_eye_reference <- VS.CreateMeasure("player_targetname")
```

If `measureEye` is false, measure `targetTargetname`, set `refTargetname` as reference (entity to move)

<details><summary>Example</summary>

Example get player eye angles:
```lua
hPlayer <- VS.GetLocalPlayer()
hPlayerEye <- VS.CreateMeasure(hPlayer.GetName())

printl("Player eye angles: " + VecToString(hPlayerEye.GetAngles()))
```

Example check to prevent spawning if the entities are already spawned
```lua
if( !Ent("vs.ref_*") )
{
	hPlayerEye <- VS.CreateMeasure( "playername", null, true )
}
```

Or being specific
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

You can disable the reference entity to stop the measure.  
The reference will keep the last measured values.

```lua
EntFireByHandle( hPlayerEye, "disable" )
```

</details>

<details><summary>Details</summary>

This function creates an entity to measure player eye angles `logic_measure_movement : vs.ref_*`.

`"refname"` in the example above refers to the reference entity's targetname.

The `makePermanent` paramater ensures the entity is not released on round end. However, while using it, make sure to include a check to prevent spawning over and over again. Shown in the example above.

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
handle VS::CreateTimer(bool bDisabled, float flInterval, float flLower = null, float flUpper = null, bool bOscillator = false, bool bMakePerm = false)
```
Create and return a logic_timer entity

if refire is `0` OR `null`, random time use `lower` AND `upper`
________________________________

<a name="f_Timer"></a>
```cpp
handle VS::Timer(bool bDisabled, float flInterval, TYPE func = null, table scope = null, bool bExecInEnt = false, bool bMakePerm = false)
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
Adds output in the chosen entity  
Executes the given function in the given scope  
Accepts function parameters

Returns entity scope

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
handle VS::CreateEntity(string classname, table keyvalues = null, bool perm = false)
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

If changing the text from script, create in script (and make perm); else if text is static, doesn't matter

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

<a name="f_SetKey"></a>
```cpp
bool VS::SetKey(handle ent, string key, TYPE val)
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

<details><summary>Details</summary>

If bots have targetnames, they 'become' humans

If the event listeners are not set up, named bots will be shown as players

</details>

________________________________

<a name="f_GetAllPlayers"></a>
```cpp
handle[] VS::GetAllPlayers()
```
Get every player and bot in a single array
________________________________

<a name="f_GetLocalPlayer"></a>
```cpp
handle VS::GetLocalPlayer()
```
return the only / the first connected player in the server

exposes:  
`handle HPlayer`: player handle  
`table  SPlayer`: player scope
________________________________

<a name="f_GetPlayerByIndex"></a>
```cpp
handle VS::GetPlayerByIndex(int entindex)
```
Not to be confused with [`GetPlayerByUserid`](#f_GetPlayerByUserid)
________________________________

<a name="f_FindEntityByIndex"></a>
```cpp
handle VS::FindEntityByIndex(int entindex, string classname = null)
```

________________________________

<a name="f_FindEntityByString"></a>
```cpp
handle VS::FindEntityByString(string str)
```
String input such as `"([2] player)"` and `"([88] func_button: targetname)"`

<details><summary>Example</summary>

```cs
local str = HPlayer.tostring()

printl(typeof str)
printl(str)

local handle = VS.FindEntityByString( str )

printl(typeof handle)
printl(handle)
```
**Output:**
```
string
([1] player)

instance
([1] player)
```

</details>

________________________________

<a name="f_IsPointSized"></a>
```cpp
bool VS::IsPointSized(handle ent)
```

________________________________

<a name="f_FindEntityClassNearestFacing"></a>
```cpp
handle VS::FindEntityClassNearestFacing(Vector vOrigin, Vector vFacing, float fThreshold, string sClassname)
```

________________________________

<a name="f_FindEntityNearestFacing"></a>
```cpp
handle VS::FindEntityNearestFacing(Vector vOrigin, Vector vFacing, float fThreshold)
```

________________________________

<a name="f_FindEntityClassNearestFacingNearest"></a>
```cpp
handle VS::FindEntityClassNearestFacingNearest(Vector vOrigin, Vector vFacing, float fThreshold, string sClassname, float flRadius )
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

<a name="f_AddEventCallback"></a>
```cpp
void VS::AddEventCallback(string event, closure function, table scope = null)
```
Bind the input function to global _OnGameEvent\__ function in _scope_, _this_ by default.
________________________________

<a name="f_ForceValidateUserid"></a>
```cpp
void VS::Events::ForceValidateUserid(handle player)
```
_This is currently not included in `vs_library.nut`._

if something has gone wrong with automatic validation, force add userid. 

Requires player_info eventlistener that has the output:

`OnEventFired > player_info > RunScriptCode > ::VS.Events.player_info(event_data)`
________________________________

### [vs_log](https://github.com/samisalreadytaken/vs_library/blob/master/vs_library/vs_log.nut)

Print and export custom log lines.

Overrides the user con_filter settings but if the user cares about this at all, they would already have their own settings in an autoexec file.

Works for listen server host (local player) only.
________________________________

<a name="f_Logcondition"></a>
```cpp
VS.Log.condition = true
```
Print the log?
________________________________

<a name="f_Logexport"></a>
```cpp
VS.Log.export = true
```
Export the log?

if( condition && !export ) then print the log in the console
________________________________

<a name="f_LogfilePrefix"></a>
```cpp
VS.Log.filePrefix = "vs.log"
```
The exported log file name prefix.

By default, every file is appended with random strings to make each exported file unique. Putting `:` in the beginning will remove this suffix, and each export will overwrite the previously exported file. E.g.: `VS.Log.filePrefix = ":vs.log"`

The user can specify export directories by using `/`. E.g.: `VS.Log.filePrefix = "bin/vs.log"`

Example file name: `vs.log_c9ae41f5d8d.log`
________________________________

<a name="f_LogAdd"></a>
```cpp
void VS::Log::Add(string s)
```
Add new string to the log. Newline (`\n`) not included.

`VS.Log.L.append(string s)`
________________________________

<a name="f_LogClear"></a>
```cpp
void VS::Log::Clear()
```
Clear the log.
________________________________

<a name="f_LogRun"></a>
```cpp
string VS::Log::Run()
```
if VS.Log.export == true, then export the log file to the game directory

return exported file name

if VS.Log.export == false, then print in the console

When exporting, do NOT call multiple times in a frame, or before the previous exporting is done.
________________________________

<a name="f_Logfilter"></a>
```cpp
VS.Log.filter = "VFLTR"
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

<a name="f_matrix3x4"></a>
```cpp
class matrix3x4
{
	m_flMatVal[3][4]

	void Init()
}
```

________________________________

```cpp
matrix3x4_t matrix3x4()
matrix3x4_t matrix3x4(Vector xAxis, Vector yAxis, Vector zAxis, Vector vecOrigin)
```
Creates a matrix where the X axis = forward  
the Y axis = left, and the Z axis = up
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

<a name="f_VectorNegate"></a>
```cpp
Vector VS::VectorNegate(Vector& vec)
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

<a name="f_QuaternionAngleDiff"></a>
```cpp
float VS::QuaternionAngleDiff(Quaternion p, Quaternion q)
```
Returns the angular delta between the two normalized quaternions in degrees.
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

<a name="f_QuaternionMatrix2"></a>
```cpp
void VS::QuaternionMatrix2(Quaternion q, matrix3x4_t& matrix)
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

<a name="f_BasisToQuaternion"></a>
```cpp
Quaternion VS::BasisToQuaternion(Vector forward, Vector right, Vector up, Quaternion& q = _QUAT)
```
Converts a basis to a quaternion
________________________________

<a name="f_MatrixAngles"></a>
```cpp
QAngle VS::MatrixAngles(matrix3x4_t matrix, Vector& angles = _VEC, Vector position = null)
```
Generates QAngle given a left-handed orientation matrix.
________________________________

<a name="f_MatrixAnglesQ"></a>
```cpp
Quaternion VS::MatrixAnglesQ(matrix3x4_t matrix, Quaternion& angles = _QUAT, Vector position = null)
```
matrix3x4 -> Quaternion
________________________________

<a name="f_AngleMatrix"></a>
```cpp
void VS::AngleMatrix(QAngle angles, Vector position, matrix3x4_t& matrix)
```
QAngle -> matrix3x4 (left-handed)
________________________________

<a name="f_AngleMatrix2"></a>
```cpp
void VS::AngleMatrix2(QAngle angles, matrix3x4_t& matrix)
```
QAngle -> matrix3x4 (left-handed)
________________________________

<a name="f_AngleIMatrix"></a>
```cpp
void VS::AngleIMatrix(QAngle angles, Vector position, matrix3x4_t& mat)
```

________________________________

<a name="f_AngleIMatrix2"></a>
```cpp
void VS::AngleIMatrix2(QAngle angles, matrix3x4_t& mat)
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
void VS::MatrixInvert(matrix3x4_t in1, matrix3x4_t& out)
```
NOTE: This is just the transpose not a general inverse
________________________________

<a name="f_MatrixGetColumn"></a>
```cpp
Vector VS::MatrixGetColumn(matrix3x4_t in1, int column, Vector& out = _VEC)
```

________________________________

<a name="f_MatrixSetColumn"></a>
```cpp
void VS::MatrixSetColumn(Vector in1, int column, matrix3x4_t& out = _VEC)
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

<a name="f_MatrixBuildRotationAboutAxis"></a>
```cpp
void VS::MatrixBuildRotationAboutAxis(Vector vAxisOfRot, float angleDegrees, matrix3x4_t& dst)
```
Builds the matrix for a counterclockwise rotation about an arbitrary axis.
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

<a name="f_IntersectRayWithRay"></a>
```cpp
bool VS::IntersectRayWithRay(ray_t ray0, ray_t ray1)
```
Intersects a ray with a ray, return true if they intersect
________________________________

<a name="f_IsRayIntersectingOBB"></a>
```cpp
bool VS::IsRayIntersectingOBB(ray_t ray, Vector org, QAngle angles, Vector mins, Vector maxs, float flTolerance)
```
Swept OBB test

Input  : localMins, localMaxs
________________________________

<a name="f_ComputeSeparatingPlane"></a>
```cpp
bool VS::ComputeSeparatingPlane(matrix3x4_t worldToBox1, matrix3x4_t box2ToWorld, Vector box1Size, Vector box2Size, float tolerance)
```
Compute a separating plane between two boxes (expensive!)  
Returns false if no separating plane exists
________________________________

<a name="f_ComputeSeparatingPlane2"></a>
```cpp
VS::ComputeSeparatingPlane2(Vector org1, QAngle angles1, Vector min1, Vector max1, Vector org2, QAngle angles2, Vector min2, Vector max2, float tolerance)
```

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
Vector VS::Interpolator_CurveInterpolate(int interpolationType, Vector vPre, Vector vStart, Vector vEnd, Vector vNext, f, Vector& vOut = _VEC)
```

________________________________

<a name="f_Interpolator_CurveInterpolate_NonNormalized"></a>
```cpp
Vector VS::Interpolator_CurveInterpolate_NonNormalized(int interpolationType, Vector vPre, Vector vStart, Vector vEnd, Vector vNext, f, Vector& vOut = _VEC)
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
Vector VS::Catmull_Rom_Spline(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output = _VEC)
```
Interpolate a Catmull-Rom spline.

t is a [0,1] value and interpolates a curve between p2 and p3.
________________________________

<a name="f_Catmull_Rom_Spline_Tangent"></a>
```cpp
Vector VS::Catmull_Rom_Spline_Tangent(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output = _VEC)
```
Interpolate a Catmull-Rom spline.

Returns the tangent of the point at t of the spline
________________________________

<a name="f_Catmull_Rom_Spline_Integral"></a>
```cpp
Vector VS::Catmull_Rom_Spline_Integral(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output = _VEC)
```
area under the curve [0..t]
________________________________

<a name="f_Catmull_Rom_Spline_Integral2"></a>
```cpp
Vector VS::Catmull_Rom_Spline_Integral2(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output = _VEC)
```
area under the curve [0..1]
________________________________

<a name="f_Catmull_Rom_Spline_Normalize"></a>
```cpp
Vector VS::Catmull_Rom_Spline_Normalize(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output = _VEC)
```
Interpolate a Catmull-Rom spline.

Normalize p2->p1 and p3->p4 to be the same length as p2->p3
________________________________

<a name="f_Catmull_Rom_Spline_Integral_Normalize"></a>
```cpp
Vector VS::Catmull_Rom_Spline_Integral_Normalize(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output = _VEC)
```
area under the curve [0..t]

Normalize p2->p1 and p3->p4 to be the same length as p2->p3
________________________________

<a name="f_Catmull_Rom_Spline_NormalizeX"></a>
```cpp
Vector VS::Catmull_Rom_Spline_NormalizeX(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output = _VEC)
```
Interpolate a Catmull-Rom spline.

Normalize p2.x->p1.x and p3.x->p4.x to be the same length as p2.x->p3.x
________________________________

<a name="f_Catmull_Rom_SplineQ"></a>
```cpp
Quaternion VS::Catmull_Rom_SplineQ(Quaternion p1, Quaternion p2, Quaternion p3, Quaternion p4, float t, Quaternion& output)
```
Interpolate a Catmull-Rom spline.
________________________________

<a name="f_Catmull_Rom_SplineQ_Tangent"></a>
```cpp
Quaternion VS::Catmull_Rom_SplineQ_Tangent(Quaternion p1, Quaternion p2, Quaternion p3, Quaternion p4, float t, Quaternion& output)
```
Interpolate a Catmull-Rom spline.

Returns the tangent of the point at t of the spline
________________________________

<a name="f_Hermite_Spline"></a>
```cpp
Vector VS::Hermite_Spline(Vector p1, Vector p2, Vector d1, Vector d2, float t, Vector& output = _VEC)
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
Vector VS::Hermite_Spline3V(Vector p0, Vector p1, Vector p2, float t, Vector& output = _VEC)
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
Quaternion VS::Hermite_Spline3Q(Quaternion q0, Quaternion q1, Quaternion q2, float t, Quaternion& output = _QUAT)
```

________________________________

<a name="f_Kochanek_Bartels_Spline"></a>
```cpp
Vector VS::Kochanek_Bartels_Spline(float tension, float bias, float continuity, Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output = _VEC)
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
Vector VS::Kochanek_Bartels_Spline_NormalizeX(float tension, float bias, float continuity, Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output = _VEC)
```

________________________________

<a name="f_Cubic_Spline"></a>
```cpp
Vector VS::Cubic_Spline(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output = _VEC)
```
See link at Kochanek_Bartels_Spline for info on the basis matrix used
________________________________

<a name="f_Cubic_Spline_NormalizeX"></a>
```cpp
Vector VS::Cubic_Spline_NormalizeX(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output = _VEC)
```

________________________________

<a name="f_BSpline"></a>
```cpp
Vector VS::BSpline(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output = _VEC)
```
See link at Kochanek_Bartels_Spline for info on the basis matrix used
________________________________

<a name="f_BSpline_NormalizeX"></a>
```cpp
Vector VS::BSpline_NormalizeX(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output = _VEC)
```

________________________________

<a name="f_Parabolic_Spline"></a>
```cpp
Vector VS::Parabolic_Spline(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output = _VEC)
```
See link at Kochanek_Bartels_Spline for info on the basis matrix used
________________________________

<a name="f_Parabolic_Spline_NormalizeX"></a>
```cpp
Vector VS::Parabolic_Spline_NormalizeX(Vector p1, Vector p2, Vector p3, Vector p4, float t, Vector& output = _VEC)
```

________________________________

<a name="f_RangeCompressor"></a>
```cpp
float VS::RangeCompressor(float flValue, float flMin, float flMax, float flBase)
```
Compress the input values for a ranged result such that from 75% to 200% smoothly of the range maps
________________________________

<a name="f_QAngleLerp"></a>
```cpp
QAngle VS::QAngleLerp(QAngle v1, QAngle v2, float flPercent)
```
Slerp
________________________________
**END OF DOC**
________________________________
