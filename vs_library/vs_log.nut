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

function VS::Log::Add( s )
{
	L.append(s);
}

function VS::Log::Clear()
{
	L.clear();
}

function VS::Log::Run()
{
	if( !condition ) return;

	return _Start();
}

//-----------------------------------------------------------------------
// Internal functions. Do not call these
//-----------------------------------------------------------------------

function VS::Log::_Print(f)
{
	if( nC >= nN )
	{
		if( f ) _Stop();
		nL = null;
		nD = null;
		nC = null;
		nN = null;
		return;
	};

	local t = filter, p = ::print;

	if( !f )
		for( local i = nC; i < nN; ++i )p( L[i] );
	else
		for( local i = nC; i < nN; ++i )p( t + L[i] );;

	nC += nD;
	nN = ::clamp( nN + nD, 0, nL );

	return::delay( "::VS.Log._Print("+f+")", ::FrameTime() );
}

function VS::Log::_Start()
{
	nL <- L.len();
	nD <- 2000;
	// nS <- ceil( nL / nD.tofloat() );
	nC <- 0;
	nN <- ::clamp( nD, 0, nL );

	if( export )
	{
		local file = filePrefix[0] == 58 ? filePrefix.slice(1) : filePrefix + "_" + ::VS.UniqueString();
		_d <- ::developer();
		::SendToConsole("developer 0;con_filter_enable 1;con_filter_text_out\""+filter+"\";con_filter_text\"\";con_logfile\""+file+".log\";script delay(\"::VS.Log._Print(1)\","+::FrameTime()*4.0+")");
		return file;
	}
	else
	{
		_Print(0);
	};
}

function VS::Log::_Stop()
{
	::SendToConsole("con_logfile\"\";con_filter_text_out\"\";con_filter_text\"\";con_filter_enable 0;developer "+_d);
}
