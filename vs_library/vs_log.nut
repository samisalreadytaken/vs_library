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
	filter      = "L",
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

//-----------------------------------------------------------------------
// Internal functions. Do not call these
//-----------------------------------------------------------------------

local Msg = ::Msg;
local delay = ::VS.EventQueue.AddEvent;
local flFrameTime = TICK_INTERVAL * 4.0;
local developer = ::developer;
local ClientCommand = ::SendToConsole;
local clamp = ::clamp;
local Fmt = ::format;

function VS::Log::_Print() : ( Msg, delay, clamp )
{
	local t = filter, p = Msg, L = _data;

	if ( !export )
		for ( local i = nC; i < nN; ++i ) p( L[i] );
	else
		for ( local i = nC; i < nN; ++i ) p( t + L[i] );

	nC += nD;
	nN = clamp( nN + nD, 0, nL );

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

	return delay( _Print, 0.0, this );
}

function VS::Log::_Start() : ( ClientCommand, developer, clamp, Fmt, flFrameTime )
{
	nL <- _data.len();
	nD <- 2000;
	// nS <- ceil( nL / nD.tofloat() );
	nC <- 0;
	nN <- clamp( nD, 0, nL );

	//if ( !( "_PRINT" in this ) )
	//	_PRINT <- VS.EventQueue.CreateEvent( _Print, this );

	if ( export )
	{
		local file = file_prefix[0] == ':' ? file_prefix.slice(1) : Fmt( "%s_%s", file_prefix, VS.UniqueString() );
		_d <- developer();
		ClientCommand(Fmt( "developer 0;con_filter_enable 1;con_filter_text_out\"%s\";con_filter_text\"\";con_logfile\"%s.log\";script VS.EventQueue.AddEvent(VS.Log._Print,%g,VS.Log)", filter, file, flFrameTime ));
		return file;
	}
	else
	{
		// Do it all on client
		ClientCommand("script VS.Log._Print(0)");
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
