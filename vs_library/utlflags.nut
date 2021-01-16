//-----------------------------------------------------------------------
//                     github.com/samisalreadytaken
//-----------------------------------------------------------------------
// Flag handling class, in the style used in Source Engine
//-----------------------------------------------------------------------

class::CUtlFlags
{
	m_nFlags = 0;

	constructor( nInitialFlags = 0 )
	{
		m_nFlags = nInitialFlags;
	}

	function SetFlag( nFlagMask )
	{
		m_nFlags = m_nFlags | nFlagMask;
	}

	function ClearFlag( nFlagMask )
	{
		m_nFlags = m_nFlags & ~nFlagMask;
	}

	function ClearAllFlags()
	{
		m_nFlags = 0;
	}

	function IsFlagSet( nFlagMask )
	{
		return ( m_nFlags & nFlagMask ) != 0;
	}

	function IsAnyFlagSet()
	{
		return m_nFlags != 0;
	}
}

//-----------------------------------------------------------------------
// Flag example
//-----------------------------------------------------------------------
/*
enum FLAG
{
	F0  = 0x0001,   // (1 << 0)      1
	F1  = 0x0002,   // (1 << 1)      2
	F2  = 0x0004,   // (1 << 2)      4
	F3  = 0x0008,   // (1 << 3)      8
	F4  = 0x0010,   // (1 << 4)      16
	F5  = 0x0020,   // (1 << 5)      32
	F6  = 0x0040,   // (1 << 6)      64
	F7  = 0x0080,   // (1 << 7)      128
	F8  = 0x0100,   // (1 << 8)      256
	F9  = 0x0200,   // (1 << 9)      512
	F10 = 0x0400,   // (1 << 10)     1024
	F11 = 0x0800,   // (1 << 11)     2048
	F12 = 0x1000,   // (1 << 12)     4096
	F13 = 0x2000,   // (1 << 13)     8192
	F14 = 0x4000,   // (1 << 14)     16384
	F15 = 0x8000,   // (1 << 15)     32768
	F16 = 0x10000   // (1 << 16)     65536
}
*/
