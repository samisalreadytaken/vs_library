//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//-----------------------------------------------------------------------
//
// Print and export custom log lines.
//
//-----------------------------------------------------------------------

local Log =
{
	export      = false,
	file_prefix = "vs.log",
	filter      = "L ",
	_dev        = null,
	_data       = null,
	_cb         = null,
	_file       = null,
	_inprogress = false
}

VS.Log <- Log;


VS.Log.Add <- function(s)
{
	return _data.append(s);
}.bindenv(VS.Log);


VS.Log.Pop <- function()
{
	return _data.pop();
}.bindenv(VS.Log);


VS.Log.Clear <- function()
{
	if ( _data )
	{
		_data.clear();
	}
	else
	{
		_data = [];
	}
}.bindenv(VS.Log);


local ClientCommand = SendToConsole;

VS.Log.Run <- function( callback = null, env = null ) : ( ClientCommand, developer, Fmt, TICK_INTERVAL )
{
	if ( !_data )
		return;

	if ( _inprogress )
		return;

	if ( typeof callback == "function" )
	{
		if ( env )
			callback = callback.bindenv( env );
		_cb = callback;
	};

	nL <- _data.len();
	nD <- 1984;
	// nS <- ceil( nL / nD.tofloat() );
	nC <- 0;
	nN <- nD < nL ? nD : nL;
	_inprogress = true;

	// _WR <- VS.EventQueue.CreateEvent( _Write, this );

	if ( export )
	{
		local file = _file = file_prefix[0] == ':' ? file_prefix.slice(1) : Fmt( "%s_%s", file_prefix, VS.UniqueString() );
		_dev = developer();
		ClientCommand(Fmt( "developer 0;con_filter_enable 1;con_filter_text_out\"%s\";con_filter_text\"\";con_logfile\"%s.log\";script VS.EventQueue.AddEvent(VS.Log._Write,%g,VS.Log)", filter, file, TICK_INTERVAL * 4.0 ));
		return file;
	}
	else
	{
		// Do it all on client
		ClientCommand("script VS.Log._Write()");
	};
}.bindenv(VS.Log);

/*
//
// Write Valve KeyValues file
//
local Fmt = format;
VS.Log.WriteKeyValues <- function( szName, hTable, curIndent = "" ) : ( Fmt )
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
VS.Log.WriteTable <- function( szName, hTable, indentLevel = 0, curIndent = "" ) : ( Fmt )
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



local EventQueueAdd = VS.EventQueue.AddEvent;

VS.Log._Write <- function() : ( Msg, EventQueueAdd, ClientCommand )
{
	{
	local t = filter, p = Msg, L = _data;
	if ( export )
		for ( local i = nC; i < nN; ++i ) p( t + L[i] );
	else
		for ( local i = nC; i < nN; ++i ) p( L[i] );
	}

	nC += nD;
	local i = nN + nD;
	if ( i < nL )
		nN = i;
	else
		nN = nL;

	// end
	if ( nC >= nN )
	{
		_data = nL = nD = nC = nN = null;
		_inprogress = false;

		if ( export )
		{
			ClientCommand("con_logfile\"\";con_filter_text_out\"\";con_filter_text\"\";con_filter_enable 0;developer "+_dev+";script VS.Log._Dispatch()");
		}
		else
		{
			_Dispatch();
		};

		return;
	};

	return EventQueueAdd( _Write, 0.002, this );
}

VS.Log._Dispatch <- function()
{
	if (_cb)
	{
		_cb(_file);
		_cb =
		_file = null;
	}
}
