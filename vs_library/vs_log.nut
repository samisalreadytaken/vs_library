//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//-----------------------------------------------------------------------
//
// Print and export custom log lines.
//
//-----------------------------------------------------------------------

VS.Log <-
{
	enabled     = false,
	export      = false,
	file_prefix = "vs.log",
	filter      = "L ",
	m_data      = [],   // internal data
	_data       = null, // data to print
	_cb         = null,
	_env        = null
	// _file       = null
}

VS.Log._data = VS.Log.m_data.weakref();


VS.Log.Add <- function(s)
{
	local L = _data;
	// logs may have thousands of entries, allocate memory size+1 instead of size*2
	L.insert( L.len(), s );
}.bindenv(VS.Log)



VS.Log.Pop <- function()
{
	return _data.pop();
}.bindenv(VS.Log)



VS.Log.Clear <- function()
{
	_data.clear();
}.bindenv(VS.Log)



VS.Log.Run <- function( data = null, callback = null )
{
	if ( VS.IsDedicatedServer() )
		Msg("!!! VS.Log unavailable on dedicated servers\n");

	if ( !enabled )
		return;

	_data = data ? data.weakref() : m_data.weakref();
	_cb = typeof callback == "function" ? callback : null;
	_env = _cb ? VS.GetCaller() : null;

	return _Start();
}.bindenv(VS.Log)

/*
//
// Write Valve KeyValues file
//
local Fmt = format;
function VS::Log::WriteKeyValues( szName, hTable, curIndent = "" ) : ( Fmt )
{
	local nextIndent = curIndent + "\t";

	// header
	Add(Fmt( "%s\"%s\"\n%s{\n", curIndent, szName, curIndent ));

	foreach( key, val in hTable )
	{
		local szKey;
		switch ( typeof key )
		{
			case "bool":
			case "integer":
			case "string":		szKey = "" + key;	break;
			case "float":		szKey = Fmt( "%f", key );	break;
			default:			continue;
		}

		switch ( typeof val )
		{
			case "class":
			case "array":
			case "table":
			{
				WriteKeyValues( szKey, val, nextIndent );
				break;
			}
			case "string":
			{
				//if ( s.len() > 2047 )
				//	Msg("WriteKeyValues: log is too large, it will be truncated! '"+val+"'\n")
				Add(Fmt( "%s\"%s\"\t\t\"%s\"\n", nextIndent, szKey, val ));
				break;
			}
			case "null": val = 0;
			case "bool": val = val.tointeger();
			case "integer":
			{
				Add(Fmt( "%s\"%s\"\t\t\"%i\"\n", nextIndent, szKey, val ));
				break;
			}
			case "float":
			{
				Add(Fmt( "%s\"%s\"\t\t\"%f\"\n", nextIndent, szKey, val ));
				break;
			}
			case "Vector":
			{
				Add(Fmt( "%s\"%s\"\t\t\"%f %f %f\"\n", nextIndent, szKey, val.x, val.y, val.z ));
				break;
			}
			// case "Quaternion":
		}
	}

	// tail
	Add( curIndent + "}\n" );
}
*/
/*
//
// Write squirrel 2.2 readable table (with assignments)
//
function VS::Log::WriteTable( szName, hTable, indentLevel = 0, curIndent = "" ) : ( Fmt )
{
	local nextIndent = curIndent + "\t";
	local bIsArray = typeof hTable == "array";

	local header = ( indentLevel == 0 ) ? "%s%s =\n%s%s\n" : "%s%s\n%s%s\n";
	Add(Fmt( header, curIndent, szName, curIndent, (bIsArray ? "[" : "{") ));

	foreach( key, val in hTable )
	{
		local szKey;
		if ( !bIsArray )
		{
			switch ( typeof key )
			{
				case "string":		szKey = key + " = ";	break;
				case "float":		szKey = Fmt( "[%f] = ", key );	break;
				case "integer":		szKey = Fmt( "[%i] = ", key );	break;
				case "bool":		szKey = Fmt( key ? "[true] = " : "[false] = " );	break;
				default:			continue;
			}
		}
		else
		{
			// skip indices in arrays
			szKey = "";
		};

		switch ( typeof val )
		{
			case "array":
			case "table":
			{
				WriteTable( szKey, val, indentLevel + 1, nextIndent );
				break;
			}
			case "string":
			{
				Add(Fmt( "%s%s\"%s\",\n", nextIndent, szKey, val ));
				break;
			}
			case "null":
			{
				Add(Fmt( "%s%snull,\n", nextIndent, szKey ));
				break;
			}
			case "bool": val = val.tointeger();
			case "integer":
			{
				Add(Fmt( "%s%s%i,\n", nextIndent, szKey, val ));
				break;
			}
			case "float":
			{
				Add(Fmt( "%s%s%f,\n", nextIndent, szKey, val ));
				break;
			}
			case "Vector":
			{
				Add(Fmt( "%s%sVector(%f, %f, %f),\n", nextIndent, szKey, val.x, val.y, val.z ));
				break;
			}
		}
	}

	// strip trailing comma
	Add( Pop().slice( 0, -2 ) + "\n" );

	// tail
	Add(Fmt( (bIsArray ? "%s]%s" : "%s}%s"), curIndent, (( indentLevel == 0 ) ? "\n" : ",\n") ));
}
*/



//-----------------------------------------------------------------------
// Internal functions. Do not call these
//-----------------------------------------------------------------------

local delay = VS.EventQueue.AddEvent;
local flFrameTime = TICK_INTERVAL * 4.0;
local ClientCommand = SendToConsole;

function VS::Log::_Write() : ( Msg, delay )
{
	local t = filter, p = Msg, L = _data;

	if ( !export )
		for ( local i = nC; i < nN; ++i ) p( L[i] );
	else
		for ( local i = nC; i < nN; ++i ) p( t + L[i] );

	nC += nD;
	nN = min( nN + nD, nL );

	if ( nC >= nN )
	{
		_data = m_data.weakref(); // revert to default
		nL = null;
		nD = null;
		nC = null;
		nN = null;
		_Stop();
		return;
	};

	return delay( _Write, 0.001, this );
}

function VS::Log::_Start() : ( ClientCommand, developer, Fmt, flFrameTime )
{
	nL <- _data.len();
	nD <- 2000;
	// nS <- ceil( nL / nD.tofloat() );
	nC <- 0;
	nN <- min( nD, nL );

	//if ( !( "_WR" in this ) )
	//	_WR <- VS.EventQueue.CreateEvent( _Write, this );

	if ( export )
	{
		local file = file_prefix[0] == ':' ? file_prefix.slice(1) : Fmt( "%s_%s", file_prefix, VS.UniqueString() );
		_d <- developer();
		ClientCommand(Fmt( "developer 0;con_filter_enable 1;con_filter_text_out\"%s\";con_filter_text\"\";con_logfile\"%s.log\";script VS.EventQueue.AddEvent(VS.Log._Write,%g,VS.Log)", filter, file, flFrameTime ));
		return file;
	}
	else
	{
		// Do it all on client
		ClientCommand("script VS.Log._Write()");
	};
}

function VS::Log::_Stop():(ClientCommand)
{
	if (export)
	{
		ClientCommand("con_logfile\"\";con_filter_text_out\"\";con_filter_text\"\";con_filter_enable 0;developer "+_d+";script VS.Log._Dispatch()");
	}
	else
	{
		_Dispatch();
	}
}

function VS::Log::_Dispatch()
{
	if (_cb)
	{
		_cb.pcall(_env);
		_cb = null;
		_env = null;
	}
}
