//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//
//                       github.com/samisalreadytaken
//
// This project is licensed under the terms of the MIT License.
// See <README.md> or <LICENSE> for details.
//-----------------------------------------------------------------------
//
// Print and export custom log lines.
//
//-----------------------------------------------------------------------

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
	if( !enabled )
		return;

	return _Start();
}

}else{ // !PORTAL2

function VS::Log::Run()
{
	if( ::VS.IsDedicatedServer() )
		::Msg("!!! VS.Log unavailable on dedicated servers\n");

	if( !enabled )
		return;

	return _Start();
}

};; // PORTAL2

//-----------------------------------------------------------------------
// Internal functions. Do not call these
//-----------------------------------------------------------------------

local Msg = ::Msg;
local delay = ::delay;
local flFrameTime = ::FrameTime();

function VS::Log::_Print(f):(Msg,L,delay,flFrameTime)
{
	local t = filter, p = Msg, L = L;

	if( !f )
		for( local i = nC; i < nN; ++i )p( L[i] );
	else
		for( local i = nC; i < nN; ++i )p( t + L[i] );

	nC += nD;
	nN = ::clamp( nN + nD, 0, nL );

	if( nC >= nN )
	{
		if( f ) _Stop();
		nL = null;
		nD = null;
		nC = null;
		nN = null;
		return;
	};

	return delay("::VS.Log._Print("+f+")", flFrameTime);
}

function VS::Log::_Start():(flFrameTime)
{
	nL <- L.len();
	nD <- 2000;
	// nS <- ceil( nL / nD.tofloat() );
	nC <- 0;
	nN <- ::clamp( nD, 0, nL );

	if( export )
	{
		local file = file_prefix[0] == ':' ? file_prefix.slice(1) : file_prefix + "_" + ::VS.UniqueString();
		_d <- ::developer();
		::SendToConsole("developer 0;con_filter_enable 1;con_filter_text_out\""+filter+"\";con_filter_text\"\";con_logfile\""+file+".log\";script delay(\"::VS.Log._Print(1)\","+flFrameTime*4.0+")");
		return file;
	}
	else
	{
		// Do it all on client so I can remove the DS exception
		::SendToConsole("script VS.Log._Print(0)");
	};
}

function VS::Log::_Stop()
{
	::SendToConsole("con_logfile\"\";con_filter_text_out\"\";con_filter_text\"\";con_filter_enable 0;developer "+_d);
}
