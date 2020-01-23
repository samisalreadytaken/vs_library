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
// Overrides the user con_filter settings
// but if the user cares about this at all,
// they would already have their own settings in an autoexec file.
//
//
//
// Add new string to the log. "\n" not included.
//  	VS.Log.Add( string )
//
// Add the input array to the log.
//  	VS.Log.Array( array )
//
// Clear the log.
//  	VS.Log.Clear()
//
// export the log file to the game directory ( if VS.Log.export == true )
// return exported file name
// if VS.Log.export == false, then print in the console
//  	VS.Log.Run()
//
// Set encryption key. ( used if VS.Log.encryption == true )
//  	VS.Log.SetKey( string )
//
// VS.Log.conn = " " // (default)
// encrypted log output: 023 021 022 008 010
//
// VS.Log.conn = "x"
// encrypted log output: 023x021x022x008x010
//
//-----------------------------------------------------------------------

// Encrypt the log?
VS.Log.encryption <- false

// Print the log?
VS.Log.condition <- false

// Export the log?
VS.Log.export <- false

// The log export file name prefix.
VS.Log.filePrefix <- "vs.log"

// if( condition && !export ) then print the log in the console

//-----------------------------------------------------------------------

function VS::Log::Add( s )
{
	L.append( "L " + s )
}

function VS::Log::Array( a )
{
	foreach( k in a ) Add(k)
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

function VS::Log::_Print( encrypt = false )
{
	if( encrypt ) if( !::_xa9b2df87ffe ) return::printl("\nPlease set an encryption key with: VS.Log.SetKey(string)")
	else __print(0)
	else
	{
		if( !export )
			__print(1)
		else
			__print(2)
	}
}

function VS::Log::__print(f)
{
	if( nC >= nN )
	{
		if( f == 2 ) _Stop()
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

	return::delay( "::VS.Log.__print("+f+")", ::FrameTime() )
}

function VS::Log::_Start()
{
	local fname = filePrefix + "_" + ::VS.UniqueString()
	_d = ::GetDeveloperLevel()
	::SendToConsole("developer 0;con_filter_enable 1;con_filter_text_out\""+filter+"\";con_filter_text\"\";con_logfile\""+fname+".log\";script delay(\"VS.Log._Print(VS.Log.encryption)\","+::FrameTime()*4+")")
	return fname
}

function VS::Log::_Stop()
{
	::SendToConsole("con_logfile\"\";con_filter_text_out\"\";con_filter_text\"\";con_filter_enable 0;developer "+_d)
}
