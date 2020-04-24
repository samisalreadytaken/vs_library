//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//
//                       github.com/samisalreadytaken
//
// This project is licensed under the terms of the MIT License.
// See <README.md> or <LICENSE> for details.
//-----------------------------------------------------------------------

/*
	DebugDrawLine( vec1, vec2, R, G, B, noDepthTest, time )

	DebugDrawBox( vecOri, vecMins, vecMaxs, R, G, B, A, time )
*/

::Ent  <- function( s, i = null ){ return::Entities.FindByName(i,s); }
::Entc <- function( s, i = null ){ return::Entities.FindByClassname(i,s); }

//-----------------------------------------------------------------------
// Input  : int / float
// Output : string - .tointeger() or .tofloat() can be used on the result
//-----------------------------------------------------------------------
function VS::FormatPrecision(f, n){ return::format("%." +n+"f",f); }
function VS::FormatExp(i, n)      { return::format("%." +n+"e",i); }

//-----------------------------------------------------------------------
// Input  : int
// Output : string - .tointeger() or .tofloat() can be used on the result
//-----------------------------------------------------------------------
function VS::FormatHex(i, n)      { return::format("%#0"+n+"x",i); }

//-----------------------------------------------------------------------
// Input  : str/int/float
//          int amount
//          0 or " "
// Output : string
//-----------------------------------------------------------------------
function VS::FormatWidth(i, n, s = " ") { return::format("%"+s+""+n+"s",i.tostring()); }

//-----------------------------------------------------------------------
// Input  : Vector
// Output : string
//-----------------------------------------------------------------------
::VecToString <- function( vec, prefix = "Vector(", separator = ",", suffix = ")" )
{
	return prefix + vec.x + separator + vec.y + separator + vec.z + suffix;
}

//-----------------------------------------------------------------------
// Draw entity's AABB
// ent_bbox
//-----------------------------------------------------------------------
function VS::DrawEntityBBox( time, ent, r = 255, g = 138, b = 0, a = 0 )
{
	::DebugDrawBox(ent.GetOrigin(),ent.GetBoundingMins(),ent.GetBoundingMaxs(),r,g,b,a,time);
}

//-----------------------------------------------------------------------
// Ray tracing
/*

local trace = VS.TraceLine( v1, v2 )

trace.DidHit()
trace.GetEnt( search_radius )
trace.GetPos()
trace.GetDist()
trace.GetNormal()

trace.fraction
trace.startpos
trace.endpos
trace.hitpos
trace.normal

*/
//-----------------------------------------------------------------------
class::VS.TraceLine
{
	constructor( start = null, end = null, ent = null )
	{
		if( !start )
		{
			local v = ::Vector();
			startpos = v;
			endpos = v;
			hIgnore = ent;
			fraction = 1.0;
			return;
		};

		startpos = start;
		endpos = end;
		hIgnore = ent;
		fraction = ::TraceLine( startpos, endpos, hIgnore );
	}

	// if direct LOS return false
	function DidHit()
	{
		return fraction < 1.0;
	}

	// return hit entity handle, null if none
	function GetEnt( radius = 1.0 )
	{
		return GetEntByClassname( "*", radius );
	}

	// GetEnt, find by name
	function GetEntByName( targetname, radius = 1.0 )
	{
		if( !hitpos ) GetPos();
		return::Entities.FindByNameNearest( targetname, hitpos, radius );
	}

	// GetEnt, find by classname
	function GetEntByClassname( classname, radius = 1.0 )
	{
		if( !hitpos ) GetPos();
		return::Entities.FindByClassnameNearest( classname, hitpos, radius );
	}

	// return hit position (hitpos)
	function GetPos()
	{
		if( !hitpos )
		{
			if( DidHit() ) hitpos = startpos + (endpos - startpos) * fraction;
			else hitpos = endpos;
		};
		return hitpos;
	}

	// Get distance from startpos to hit position
	function GetDist()
	{
		return::VS.Dist( startpos, GetPos() );
	}

	// Get distance squared. Useful for comparisons
	function GetDistSqr()
	{
		return::VS.DistSqr( startpos, GetPos() );
	}

	// Get surface normal
	function GetNormal()
	{
		if( !normal )
		{
			local u = ::Vector(0.0,0.0,0.5),
			      d = endpos - startpos;
			d.Norm();
			GetPos();
			normal = (hitpos-::VS.TraceDir(startpos+d.Cross(u),d).GetPos()).Cross(hitpos-::VS.TraceDir(startpos+u,d).GetPos());
			normal.Norm();
		};

		return normal;
	}

	function _cmp(d) { if( fraction < d.fraction ) return -1; if( fraction > d.fraction ) return 1; return 0; }
	function _add(d) { return fraction + d.fraction; }
	function _sub(d) { return fraction - d.fraction; }
	function _mul(d) { return fraction * d.fraction; }
	function _div(d) { return fraction / d.fraction; }
	function _modulo(d) { return fraction % d.fraction; }
	function _unm() { return -fraction; }
	function _typeof() { return "trace_t"; }

	startpos = null;
	endpos = null;
	hIgnore = null;
	fraction = 0.0;
	hitpos = null;
	normal = null;

	m_Delta = null;
	m_IsSwept = null;
	m_Extents = null;
	m_IsRay = null;
	m_StartOffset = null;
	m_Start = null;

	// initiate ray tracing
	function Ray( mins =::Vector(), maxs =::Vector() )
	{
		m_Delta = endpos - startpos;
		m_IsSwept = m_Delta.LengthSqr() != 0.0;
		m_Extents = (maxs - mins) * 0.5;
		m_IsRay = m_Extents.LengthSqr() < 1.e-6;
		m_StartOffset = (mins + maxs) * 0.5;
		m_Start = startpos + m_StartOffset;
		m_StartOffset *= -1.0;
		return this;
	}
}

//-----------------------------------------------------------------------
// Set 'f' to limit the max distance
// Input  : Vector [ start pos ]
//          Vector [ normalised direction ]
//          handle [ to ignore ]
// Output : instance [ VS.TraceLine ]
//-----------------------------------------------------------------------
function VS::TraceDir( v1, vDir, f = ::MAX_TRACE_LENGTH, hEnt = null )
{
	return TraceLine( v1, v1 + (vDir * f), hEnt );
}

//-----------------------------------------------------------------------
// UniqueString without _ in the end
//-----------------------------------------------------------------------
function VS::UniqueString()
{
	local s =::DoUniqueString("");
	return s.slice(0,s.len()-1);
}

//-----------------------------------------------------------------------
// FindInArray
// arr.find( val )
//
// linear search
// if value found in array, return index
// else return null
//-----------------------------------------------------------------------
function VS::arrayFind( arr, val )
{
	foreach( i, v in arr )
		if( v == val )
			return i;
	return null;
}

//-----------------------------------------------------------------------
// arr.apply( func(v) )
// apply the input function to every element in the input array
//-----------------------------------------------------------------------
function VS::arrayApply( arr, func )
{
	foreach( i, v in arr )
		arr[i] = func( v );
}

//-----------------------------------------------------------------------
// arr.map( func(v) )
// Same as arrayApply, but return a new array. Doesn't modify the input array
//-----------------------------------------------------------------------
function VS::arrayMap( arr, func )
{
	local new =::array(arr.len());

	foreach( i, v in arr )
		new[i] = func( v );

	return new;
}

//-----------------------------------------------------------------------
// < VS.DumpScope( input, 1, 1, 0, depth ) > is equivalent to < __DumpScope( depth, input ) >
//
// Input  : array/table [ array or table to dump ]
//          bool [ print default keys ]
//          bool [ expand nested tables and arrays ]
//          bool [ --- ]
//          integer [ indent ]
//-----------------------------------------------------------------------
function VS::DumpScope( table, printall = false, deepprint = true, guides = true, depth = 0 )
{
	local indent = function( count ){ for( local i = 0; i < count; ++i ) ::print("   ") }
	if( guides ) ::print(" ------------------------------\n");
	if( table )
	{
		foreach( key, val in table )
		{
			local isdefault = false;
			if( !printall ){ foreach( k in slots_default ) if( key == k ) isdefault = true }
			else if( key == "VS" || key == "Documentation" ) isdefault = true;;
			if( !isdefault )
			{
				indent(depth);
				::print(key);
				switch( typeof val )
				{
					case "table":
						::print("(TABLE) : "+val.len());
						if(!deepprint) break;
						::print("\n");
						indent(depth);
						::print("{\n");
						DumpScope( val, printall, deepprint, false, depth + 1 );
						indent(depth);
						::print("}");
						break;
					case "array":
						::print("(ARRAY) : "+val.len());
						if(!deepprint) break;
						::print("\n");
						indent(depth);
						::print("[\n");
						DumpScope( val, printall, deepprint, false, depth + 1 );
						indent(depth);
						::print("]");
						break;
					case "string":
						::print(" = \""+val+"\"");
						break;
					case "Vector":
						::print(" = "+::VecToString(val));
						break;
					default:
						::print(" = "+val);
				}
				::print("\n");
			};
		}
	}
	else ::print("null");
	if( guides ) ::print(" ------------------------------\n");
}

//-----------------------------------------------------------------------
// Quick and dirty method to use !in (not in) keyword with arrays
//
// Input  : array [ input ]
// Output : table [ clone of the input ]
//-----------------------------------------------------------------------
function VS::ArrayToTable( a )
{
	local t = {}
	foreach( i, v in a ) t[v] <- i;
	return t;
}

//-----------------------------------------------------------------------
// Put in the function you want to get stack info from
// if deepprint && scope not roottable, deepprint
/*
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
*/
//-----------------------------------------------------------------------
function VS::GetStackInfo( deepprint = false, printall = false )
{
	::print(" --- STACKINFO ----------------\n");
	local s, j = 2;
	while( s =::getstackinfos(j++) )
	{
		if( s.func == "pcall" && s.src == "NATIVE" ) break;
		::print(" ("+(j-1)+")\n");
		local w, m = s.locals;
		if( "this" in m && typeof m["this"] == "table" )
		{
			w = GetTableName( m["this"] );
			m[w] <- delete m["this"];
		};
		if( w == "roottable" ) DumpScope( s, printall, 0, 0 );
		else DumpScope( s, printall, deepprint, 0 );
		if(w)::print("scope = \""+w+"\"\n");
	}
	::print(" --- STACKINFO ----------------\n");
}

// return caller table
VS.GetCaller <- ::compilestring("return(getstackinfos(3)[\"locals\"][\"this\"])");

// (DEBUG) return caller function as string
VS.GetCallerFunc <- ::compilestring("return(getstackinfos(3)[\"func\"])");

// dump function infos
function VS::GetInfo( func )
{
	DumpScope(func.getinfos());
}

//-----------------------------------------------------------------------
// Get input table's name
//
// Input  : table [ unknown table ]
// Output : string [ table name ]
//-----------------------------------------------------------------------
function VS::GetTableName( table )
{if(typeof table!="table")throw("Invalid input type '"+(typeof table)+"' ; expected: 'table'");local r=_fb3k551r91t7(table);if(r)return r;return "roottable"}function VS::_fb3k551r91t7(t,l=::getroottable()){foreach(v,u in l)if(typeof u=="table")if(v!="VS"&&v!="Documentation")if(u!=t){local r=_fb3k551r91t7(t,u);if(r)return r}else return v}

//-----------------------------------------------------------------------
// Input  : table
// Output : array containing the input's directory
//-----------------------------------------------------------------------
function VS::GetTableDir( table )
{if(typeof table!="table")throw("Invalid input type '"+(typeof table)+"' ; expected: 'table'");bF.clear();local r=_f627f40d21a6(table);if(r)r.append("roottable");else r=["roottable"];r.reverse();return r}function VS::_f627f40d21a6(t,l=::getroottable()){foreach(v,u in l)if(typeof u=="table")if(v!="VS"&&v!="Documentation")if(u!=t){local r=_f627f40d21a6(t,u);if(r){bF.append(v);return r}}else{bF.append(v);return bF}}

//-----------------------------------------------------------------------
// Input  : string [ table ]
// Output : table
//-----------------------------------------------------------------------
function VS::FindTableByName( str )
{if(typeof str!="string")throw("Invalid input type '"+(typeof str)+"' ; expected: 'string'");local r=_fb3k55Ir91t7(str);if(r)return r;return::getroottable()}function VS::_fb3k55Ir91t7(t,l=::getroottable()){foreach(v,u in l)if(typeof u=="table")if(v!="VS"&&v!="Documentation")if(v!=t){local r=_fb3k55Ir91t7(t,u);if(r)return r}else return u}

//-----------------------------------------------------------------------
// Used to get the variable names of parameters passed into functions
//
// For functions, use VS.GetFuncName()
// For tables, use VS.GetTableName()
//
// Doesn't work with primitive variables if
// there are multiple variables with the same value.
// But it can work if the value is unique, like a unique string.
//-----------------------------------------------------------------------
function VS::GetVarName(v){local r=_fb3k5S1r91t7(typeof v,v);if(r)return r;return"null"}function VS::_fb3k5S1r91t7(t,i,s=::getroottable()){foreach(k,v in s){local y=typeof v;if(y==t){if(v==i)return k}else if(y=="table"){if(k!="VS"&&k!="Documentation"){local r=_fb3k5S1r91t7(t,i,v);if(r)return r}}}}

function VS::GetFuncName(f){return f.getinfos().name;}

/*
Frame times:

64.0  tick : 0.01562500
102.4 tick : 0.00976563
128.0 tick : 0.00781250

*/
function VS::GetTickrate()
{
	return 1.0 / ::FrameTime();
}

//-----------------------------------------------------------------------
// If you wish to delay the code in a specific entity scope,
// set the value
//  	::ENT_SCRIPT = self
//
// If you wish to delay the code in a specific scope,
// you need to know the name of the table.
// Using VS.DumpScope(VS.GetTableDir(tableInput)), you can find
// in which table your desired scope is and execute the code
//
// You can use activators and callers to easily access entity handles
//-----------------------------------------------------------------------
::delay     <- function( X, T = 0.0, E = ::ENT_SCRIPT, A = null, C = null )::DoEntFireByInstanceHandle( E, "runscriptcode", ""+X, T, A, C );

::Chat      <- function(s)::ScriptPrintMessageChatAll(" "+s);
::ChatTeam  <- function(i,s)::ScriptPrintMessageChatTeam(i," "+s);
::Alert     <- ::ScriptPrintMessageCenterAll;
::AlertTeam <- ::ScriptPrintMessageCenterTeam;
::ClearChat <- function(){ for( local i = 0; i < 9; ++i ) ::Chat(""); }

::txt <-
{
	invis      = "\x00",
	white      = "\x01",
	red        = "\x02",
	purple     = "\x03",
	green      = "\x04",
	lightgreen = "\x05",
	limegreen  = "\x06",
	lightred   = "\x07",
	grey       = "\x08",
	yellow     = "\x09",
	lightblue  = "\x0a",
	blue       = "\x0b",
	darkblue   = "\x0c",
	darkgrey   = "\x0d",
	pink       = "\x0e",
	orangered  = "\x0f",
	orange     = "\x10"
}
