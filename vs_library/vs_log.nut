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
	L           = []
}

local L = ::VS.Log.L;

function VS::Log::Add(s):(L)
{
	L.append(s);
}

function VS::Log::Clear():(L)
{
	L.clear();
}

if (PORTAL2){

function VS::Log::Run()
{
	if ( !enabled )
		return;

	return _Start();
}

}else{ // !PORTAL2

function VS::Log::Run()
{
	if ( ::VS.IsDedicatedServer() )
		::Msg("!!! VS.Log unavailable on dedicated servers\n");

	if ( !enabled )
		return;

	return _Start();
}

}; // PORTAL2

//-----------------------------------------------------------------------
// Internal functions. Do not call these
//-----------------------------------------------------------------------

local Msg = ::Msg;
local delay = ::VS.EventQueue.AddEvent;
local flFrameTime = ::FrameTime();
local developer = ::developer;
local ClientCommand = ::SendToConsole;
local clamp = ::clamp;
local Fmt = ::format;

function VS::Log::_Print() : ( Msg, L, delay, clamp )
{
	local t = filter, p = Msg, L = L;

	if ( !export )
		for ( local i = nC; i < nN; ++i ) p( L[i] );
	else
		for ( local i = nC; i < nN; ++i ) p( t + L[i] );

	nC += nD;
	nN = clamp( nN + nD, 0, nL );

	if ( nC >= nN )
	{
		if ( export ) _Stop();
		nL = null;
		nD = null;
		nC = null;
		nN = null;
		return;
	};

	return delay( _Print, 0.0, this );
}

function VS::Log::_Start() : ( ClientCommand, developer, clamp, Fmt, flFrameTime )
{
	nL <- L.len();
	nD <- 2000;
	// nS <- ceil( nL / nD.tofloat() );
	nC <- 0;
	nN <- clamp( nD, 0, nL );

	if ( export )
	{
		local file = file_prefix[0] == ':' ? file_prefix.slice(1) : Fmt( "%s_%s", file_prefix, ::VS.UniqueString() );
		_d <- developer();
		ClientCommand(Fmt( "developer 0;con_filter_enable 1;con_filter_text_out\"%s\";con_filter_text\"\";con_logfile\"%s.log\";script VS.EventQueue.AddEvent(VS.Log._Print,%g,VS.Log)", filter, file, (flFrameTime*4.0) ));
		return file;
	}
	else
	{
		// Do it all on client so I can remove the DS exception
		ClientCommand("script VS.Log._Print(0)");
	};
}

function VS::Log::_Stop():(ClientCommand)
{
	ClientCommand("con_logfile\"\";con_filter_text_out\"\";con_filter_text\"\";con_filter_enable 0;developer "+_d);
}
