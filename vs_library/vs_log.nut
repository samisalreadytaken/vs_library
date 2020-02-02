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
	L.append( "L " + s )
}

function VS::Log::Clear()
{
	L.clear()
}

function VS::Log::Run()
{
	if( !condition ) return

	nL <- L.len()
	nD <- 2000
	// nS <- ceil( nL / nD.tofloat() )
	nC <- 0
	nN <- ::clamp( nD, 0, nL )

	if( export ) return _Start()
	else _Print( encryption )
}

// Encryption key
function VS::Log::SetKey(k)
{::_xa9b2df87ffe=k.tostring();_xffcd55c01dd=::_xa9b2df87ffe.len();}

// Basic XOR encryption
function VS::Log::Encrypt(q)
{if(typeof q!="string")throw"Invalid input";local s="";for(local i=0;i<q.len();i++)s+=VS.FormatWidth(0,(q[i]^::_xa9b2df87ffe[i%_xffcd55c01dd]).tostring(),3)+conn;return s}

// XOR decryption
function VS::Log::Decrypt(q)
{if(typeof q!="string")throw"Invalid input";local d=function(m){local s="";for(local i=0;i<m.len();i++)s+=(m[i].tointeger()^::_xa9b2df87ffe[i%_xffcd55c01dd]).tochar();return s}foreach(r in::split(q,filter))::print(d(::split(r,conn)))}

//-----------------------------------------------------------------------
// Internal functions. Do not call these
//-----------------------------------------------------------------------

function VS::Log::_Print( bEncrypt = false )
{
	if( bEncrypt ) if( !::_xa9b2df87ffe ) return::printl("\nPlease set an encryption key with: VS.Log.SetKey(string)")
	else __Print(0)
	else
	{
		if( !export )
			__Print(1)
		else
			__Print(2)
	}
}

function VS::Log::__Print(f)
{
	if( nC >= nN )
	{
		if( f == 2 ) _Stop()
		nL = null
		nD = null
		nC = null
		nN = null
		return
	}

	if( f == 0 )
		for( local i = nC; i < nN; i++ )::print( filter + Encrypt(L[i]) )
	else if( f == 1 )
		for( local i = nC; i < nN; i++ )::print( L[i] )
	else if( f == 2 )
		for( local i = nC; i < nN; i++ )::print( filter + L[i] )

	nC += nD
	nN = ::clamp( nN + nD, 0, nL )

	return::delay( "::VS.Log.__Print("+f+")", ::FrameTime() )
}

function VS::Log::_Start()
{
	local fname = filePrefix + "_" + ::VS.UniqueString()
	_d <- ::GetDeveloperLevel()
	::SendToConsole("developer 0;con_filter_enable 1;con_filter_text_out\""+filter+"\";con_filter_text\"\";con_logfile\""+fname+".log\";script delay(\"::VS.Log._Print(::VS.Log.encryption)\","+::FrameTime()*4+")")
	return fname
}

function VS::Log::_Stop()
{
	::SendToConsole("con_logfile\"\";con_filter_text_out\"\";con_filter_text\"\";con_filter_enable 0;developer "+_d)
}
