/*
 * Copyright (c) 2002 Apple Computer, Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 * 
 * The contents of this file constitute Original Code as defined in and
 * are subject to the Apple Public Source License Version 1.2 (the
 * "License").  You may not use this file except in compliance with the
 * License.  Please obtain a copy of the License at
 * http://www.apple.com/publicsource and read it before using this file.
 * 
 * This Original Code and all software distributed under the License are
 * distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE OR NON-INFRINGEMENT.  Please see the
 * License for the specific language governing rights and limitations
 * under the License.
 * 
 * @APPLE_LICENSE_HEADER_END@
 */
/*
    $Id: mDNSWin32.c,v 1.1 2003/07/18 19:41:54 dean Exp $

    Contains:   Multicast DNS platform plugin for Win32.

    Written by: Bob Bradley

    Version:    Rendezvous, September 2002

    Copyright:  Copyright (C) 2002 by Apple Computer, Inc., All Rights Reserved.

    Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc.
                ("Apple") in consideration of your agreement to the following terms, and your
                use, installation, modification or redistribution of this Apple software
                constitutes acceptance of these terms.  If you do not agree with these terms,
                please do not use, install, modify or redistribute this Apple software.

                In consideration of your agreement to abide by the following terms, and subject
                to these terms, Apple grants you a personal, non-exclusive license, under Apple's
                copyrights in this original Apple software (the "Apple Software"), to use,
                reproduce, modify and redistribute the Apple Software, with or without
                modifications, in source and/or binary forms; provided that if you redistribute
                the Apple Software in its entirety and without modifications, you must retain
                this notice and the following text and disclaimers in all such redistributions of
                the Apple Software.  Neither the name, trademarks, service marks or logos of
                Apple Computer, Inc. may be used to endorse or promote products derived from the
                Apple Software without specific prior written permission from Apple.  Except as
                expressly stated in this notice, no other rights or licenses, express or implied,
                are granted by Apple herein, including but not limited to any patent rights that
                may be infringed by your derivative works or by other works in which the Apple
                Software may be incorporated.

                The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
                WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
                WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
                PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
                COMBINATION WITH YOUR PRODUCTS.

                IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
                CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
                GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
                ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION
                OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT
                (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN
                ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

    Change History (most recent first):
    
        $Log: mDNSWin32.c,v $
        Revision 1.1  2003/07/18 19:41:54  dean
        Initial revision

        Revision 1.1  2003/01/20 00:45:58  blackketter
        Adding support for advertising the SLIMP3 via zeroconf/mDNS/Rendezvous.

        Debugging via --d_mdns

        Requires a binary executable installed to be fork/exec'ed off for each
        instance advertised.  Need to add an option for disabling it.

        It advertises the web interface, the HTTP automation interface (which are
        the same now) and the CLI.  The latter two are _slimdevices_slimp3_http._tcp
        and _slimdevices_slimp3_cli._tcp respectively.

        This uses the Apple open source implementation of the mDNS
        command-line application mDNSResponderPosix.

        This source is included so folks can build the other posix implementations.
        Windows, as always, will require more work.

        Rumor has it that there will be a CPAN module for zeroconf, which would obsolete
        this implementation if pulled in.  That's ok, we'll take it out in that case.

        This introduces a new directory in slimp3/server which is bin.  bin contains
        subdirectories for each supported platform and is where we'd put executables
        we use (similar to the lib/CPAN arrangement.)

        Also added the submitted patch for ogginfo support. This gives ogg files the
        opportunity to be browsed by meta information.  This requires several ogg
        executables to be installed in the default path, which is too hard for the
        average user.  This should also be cleaned up.

        The Ogg patch also included a fix to make ogg files work with spaces in the
        filename.

        Tweaked the comments for the fix that Rob Moser added when I broke hiding
        . and .. on Win32 systems.

        Revision 1.4  2002/09/21 20:44:54  zarzycki
        Added APSL info

        Revision 1.3  2002/09/20 05:50:45  bradley
        Multicast DNS platform plugin for Win32

*/

#if 0
#pragma mark == Preprocessor ==
#endif

//===========================================================================================================================
//	Preprocessor
//===========================================================================================================================

#if( defined( _MSC_VER ) )
	#pragma warning( disable:4068 )		// Disable "unknown pragma" warning for "pragma unused".
	#pragma warning( disable:4127 )		// Disable "conditional expression is constant" warning for debug macros.
#endif

#define	WIN32_WINDOWS		0x0401		// Needed to use waitable timers.
#define	_WIN32_WINDOWS		0x0401		// Needed to use waitable timers.
#define	WIN32_LEAN_AND_MEAN				// Needed to avoid redefinitions by Windows interfaces.

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>

#include	<winsock2.h>
#include	<Ws2tcpip.h>
#include	<windows.h>

#include	"mDNSClientAPI.h"
#include	"mDNSPlatformFunctions.h"

#include	"mDNSWin32.h"

#if 0
#pragma mark == Constants ==
#endif

//===========================================================================================================================
//	Constants
//===========================================================================================================================

#define	DEBUG_NAME								"[mDNS] "

#if( !defined( MDNS_DEBUG_SIGNATURE ) )
	#define MDNS_DEBUG_SIGNATURE				"mDNS"
#endif

#define	kMDNSDefaultName						"My Computer"

#define	kFileTimeUnitsPerMillisecond			10000				// 100 nanosecond units. 1,000,000,000 / 100 / 1,000 = 1,000
#define	kThreadCleanupTimeout					( 10 * 1000 )		// 10 seconds

#define	kWaitListCancelEvent					WAIT_OBJECT_0
#define	kWaitListTimerEvent						( WAIT_OBJECT_0 + 1 )
#define	kWaitListInterfaceListChangedEvent		( WAIT_OBJECT_0 + 2 )
#define	kWaitListFixedItemCount					3

#if 0
#pragma mark == Types ==
#endif

//===========================================================================================================================
//	Types
//===========================================================================================================================

typedef struct	sockaddr 		SocketAddress;
typedef struct	sockaddr_in		SocketAddressInet;

#if 0
#pragma mark == Macros - Debug ==
#endif

//===========================================================================================================================
//	Macros - Debug
//===========================================================================================================================

#define MDNS_UNUSED( X )		(void)( X )
enum
{
	kDebugLevelChatty			= 100, 
	kDebugLevelVerbose			= 500, 
	kDebugLevelInfo 			= 1000, 
	kDebugLevelRareInfo			= 2000, 
	kDebugLevelAllowedError		= 3000, 
	kDebugLevelAssert 			= 4000, 
	kDebugLevelRequire			= 5000, 
	kDebugLevelError			= 6000, 
	kDebugLevelCriticalError	= 7000, 
	kDebugLevelTragic			= 8000, 
	kDebugLevelAny				= 0x7FFFFFFF
};

#if( defined( __MWERKS__ ) || defined( __GNUC__ ) )
	#define	__ROUTINE__		__FUNCTION__
#else
	// Apple and Symantec compilers don't support the C99/GCC extensions yet.
	
	#define	__ROUTINE__		NULL
#endif

#if( MDNS_DEBUGMSGS )
	#define	debug_print_assert( ASSERT_STRING, FILENAME, LINE_NUMBER, FUNCTION )										\
		DebugPrintAssert( MDNS_DEBUG_SIGNATURE, 0, ( ASSERT_STRING ), NULL, ( FILENAME ), ( LINE_NUMBER ), ( FUNCTION ) )
	
	#define	debug_print_assert_err( ERR, ASSERT_STRING, ERROR_STRING, FILENAME, LINE_NUMBER, FUNCTION )					\
		DebugPrintAssert( MDNS_DEBUG_SIGNATURE, ( ERR ), ( ASSERT_STRING ), ( ERROR_STRING ), 							\
						  ( FILENAME ), ( LINE_NUMBER ), ( FUNCTION ) )
	
	#define	dlog		DebugLog
#else
	#define	debug_print_assert( ASSERT_STRING, FILENAME, LINE_NUMBER, FUNCTION )
	
	#define	debug_print_assert_err( ERR, ASSERT_STRING, ERROR_STRING, FILENAME, LINE_NUMBER, FUNCTION )

	#define	dlog		while( 0 )
#endif

///
/// The following debugging macros emulate those available on Mac OS in AssertMacros.h/Debugging.h.
/// 

// checks

#define	check( X )																										\
	do {																												\
		if( !( X ) ) {																									\
			debug_print_assert( #X, __FILE__, __LINE__, __ROUTINE__ );													\
		}																												\
	} while( 0 )

#define	check_noerr( ERR )																								\
	do {																												\
		if( ( ERR ) != 0 ) {																							\
			debug_print_assert_err( ( ERR ), #ERR, NULL, __FILE__, __LINE__, __ROUTINE__ );								\
		}																												\
	} while( 0 )

#define	check_errno( ERR, ERRNO )																						\
	do {																												\
		int		localErr;																								\
																														\
		localErr = (int)( ERR );																						\
		if( localErr < 0 ) {																							\
			int		localErrno;																							\
																														\
			localErrno = ( ERRNO );																						\
			localErr = ( localErrno != 0 ) ? localErrno : localErr;														\
			debug_print_assert_err( localErr, #ERR, NULL, __FILE__, __LINE__, __ROUTINE__ );							\
		}																												\
	} while( 0 )

// requires

#define	require( X, LABEL )																								\
	do {																												\
		if( !( X ) ) {																									\
			debug_print_assert( #X, __FILE__, __LINE__, __ROUTINE__ );													\
			goto LABEL;																									\
		}																												\
	} while( 0 )

#define	require_quiet( X, LABEL )																						\
	do {																												\
		if( !( X ) ) {																									\
			goto LABEL;																									\
		}																												\
	} while( 0 )

#define	require_action( X, LABEL, ACTION )																				\
	do {																												\
		if( !( X ) ) {																									\
			debug_print_assert( #X, __FILE__, __LINE__, __ROUTINE__ );													\
			{ ACTION; }																									\
			goto LABEL;																									\
		}																												\
	} while( 0 )

#define	require_action_quiet( X, LABEL, ACTION )																		\
	do {																												\
		if( !( X ) ) {																									\
			{ ACTION; }																									\
			goto LABEL;																									\
		}																												\
	} while( 0 )

#define	require_noerr( ERR, LABEL )																						\
	do {																												\
		if( ( ERR ) != 0 ) {																							\
			debug_print_assert_err( ( ERR ), #ERR, NULL, __FILE__, __LINE__, __ROUTINE__ );								\
			goto LABEL;																									\
		}																												\
	} while( 0 )

#define	require_noerr_quiet( ERR, LABEL )																				\
	do {																												\
		if( ( ERR ) != 0 ) {																							\
			goto LABEL;																									\
		}																												\
	} while( 0 )

#define	require_errno( ERR, ERRNO, LABEL )																				\
	do {																												\
		int		localErr;																								\
																														\
		localErr = (int)( ERR );																						\
		if( localErr < 0 ) {																							\
			int		localErrno;																							\
																														\
			localErrno = ( ERRNO );																						\
			localErr = ( localErrno != 0 ) ? localErrno : localErr;														\
			debug_print_assert_err( localErr, #ERR, NULL, __FILE__, __LINE__, __ROUTINE__ );							\
			goto LABEL;																									\
		}																												\
	} while( 0 )

#define	require_errno_action( ERR, ERRNO, LABEL, ACTION )																\
	do {																												\
		int		localErr;																								\
																														\
		localErr = (int)( ERR );																						\
		if( localErr < 0 ) {																							\
			int		localErrno;																							\
																														\
			localErrno = ( ERRNO );																						\
			localErr = ( localErrno != 0 ) ? localErrno : localErr;														\
			debug_print_assert_err( localErr, #ERR, NULL, __FILE__, __LINE__, __ROUTINE__ );							\
			{ ACTION; }																									\
			goto LABEL;																									\
		}																												\
	} while( 0 )

#if 0
#pragma mark == Macros - General ==
#endif

//===========================================================================================================================
//	Macros - General
//===========================================================================================================================

#define	kInvalidSocketRef		INVALID_SOCKET
#define	IsValidSocket( X )		( ( X ) != INVALID_SOCKET )
#define	close_compat( X )		closesocket( X )
#define	errno_compat()			WSAGetLastError()

#if 0
#pragma mark == Prototypes ==
#endif

//===========================================================================================================================
//	Prototypes
//===========================================================================================================================

#if MDNS_DEBUGMSGS
static void 		DebugLog( unsigned long inLevel, const char *inFormat, ... );
static void			DebugPrintAssert( const char *		inSignature, 
									  long				inError, 
									  const char *		inAssertionString, 
									  const char *		inErrorString, 
									  const char *		inFileName, 
									  unsigned long		inLineNumber, 
									  const char *		inFunction );
#endif

static mStatus		Setup( mDNS * const inMDNS );
static mStatus		TearDown( mDNS * const inMDNS );
static mStatus		SetupSynchronizationObjects( mDNS * const inMDNS );
static mStatus		TearDownSynchronizationObjects( mDNS * const inMDNS );
static mStatus		SetupName( mDNS * const inMDNS );
static mStatus		SetupTimer( mDNS * const inMDNS );
static mStatus		TearDownTimer( mDNS * const inMDNS );

static mStatus		SetupInterfaceList( mDNS * const inMDNS );
static mStatus		TearDownInterfaceList( mDNS * const inMDNS );
static mStatus		SetupInterface( mDNS * const inMDNS, const SocketAddressInet *inAddress, mDNSInterfaceInfo **outInfoPtr );
static mStatus		TearDownInterface( mDNS * const inMDNS, mDNSInterfaceInfo *inInfoPtr );
static mStatus		SetupSocket( mDNS * const 				inMDNS, 
								 const SocketAddressInet *	inAddress, 
								 mDNSIPPort 				inPort, 
								 SocketRef *				outSocketRef  );
static mStatus		SetupNotifications( mDNS * const inMDNS );
static mStatus		TearDownNotifications( mDNS * const inMDNS );

static mStatus		SetupThread( mDNS *const inMDNS );
static mStatus		TearDownThread( const mDNS *const inMDNS );
static DWORD WINAPI	ProcessingThread( LPVOID inParam );
static mStatus		ProcessingThreadSetupWaitList( mDNS *const inMDNS, HANDLE **outWaitList, int *outWaitListCount );
static void			ProcessingThreadProcessPacket( mDNS *inMDNS, mDNSInterfaceInfo *inInfoPtr, SocketRef inSocketRef );
static void			ProcessingThreadInterfaceListChanged( mDNS *inMDNS );

static int			GetIndexedInterface( int inIndex, const void *inInterfaceListBuffer, SocketAddressInet *outAddr );
static int			GetRawInterfaceList( void *outBuffer, size_t *outBufferSize );

#if 0
#pragma mark == Globals ==
#endif

//===========================================================================================================================
//	Globals
//===========================================================================================================================

static mDNS *		gMDNSPtr				= NULL;

mDNSs32				mDNSPlatformOneSecond	= 0;

#if 0
#pragma mark -
#pragma mark == Platform Support APIs ==
#endif

//===========================================================================================================================
//	mDNSPlatformInit
//===========================================================================================================================

mStatus	mDNSPlatformInit( mDNS * const inMDNS )
{
	mStatus		err;
	
	dlog( kDebugLevelVerbose, DEBUG_NAME "platform init\n" );
	
	// Set everything up.
	
	err = Setup( inMDNS );
	require_noerr( err, exit );
	
	// Success.
	
	gMDNSPtr = inMDNS;
	err = mStatus_NoError;
	
exit:
	mDNSCoreInitComplete( inMDNS, err );
	dlog( kDebugLevelVerbose, DEBUG_NAME "platform init done (err=%ld)\n", err );
	return( err );
}

//===========================================================================================================================
//	mDNSPlatformClose
//===========================================================================================================================

void	mDNSPlatformClose( mDNS * const inMDNS )
{
	mStatus		err;
	
	dlog( kDebugLevelVerbose, DEBUG_NAME "platform close\n" );
	
	check( inMDNS );
	
	// Tear everything down.
	
	gMDNSPtr = NULL;
	err = TearDown( inMDNS );
	check_noerr( err );
	
	dlog( kDebugLevelVerbose, DEBUG_NAME "platform close done\n" );
}

//===========================================================================================================================
//	mDNSPlatformSendUDP
//===========================================================================================================================

mStatus	mDNSPlatformSendUDP( const mDNS * const			inMDNS, 
							 const DNSMessage * const	inMsg, 
							 const mDNSu8 * const		inMsgEnd, 
							 mDNSIPAddr 				inSrcIP, 
							 mDNSIPPort					inSrcPort, 
							 mDNSIPAddr					inDstIP, 
							 mDNSIPPort 				inDstPort )
{
	mStatus					err;
	mDNSInterfaceInfo *		infoPtr;
	SocketAddressInet		addr;
	int						n;
	
	MDNS_UNUSED( inSrcPort );
	
	dlog( kDebugLevelChatty, DEBUG_NAME "platform send UDP\n" );
	check( inMDNS );
	check( inMsg );
	check( inMsgEnd );
	
	// Send the packet out each interface.
	
	for( infoPtr = inMDNS->p->interfaceList; infoPtr; infoPtr = infoPtr->next )
	{		
		// Check if this packet is intended for this interface.
		
		if( inSrcIP.NotAnInteger != infoPtr->hostSet.ip.NotAnInteger )
		{
			continue;
		}
		
		// Send the packet.
		
		check( IsValidSocket( infoPtr->multicastSocketRef ) );
		
		addr.sin_family 		= AF_INET;
		addr.sin_port 			= inDstPort.NotAnInteger;
		addr.sin_addr.s_addr 	= inDstIP.NotAnInteger;
	
		n = (int)( inMsgEnd - ( (const mDNSu8 * const) inMsg ) );
		n = sendto( infoPtr->multicastSocketRef, (char *) inMsg, n, 0, ( SocketAddress * ) &addr, sizeof( addr ) );
		check_errno( n, errno_compat() );
		
		infoPtr->sendErrorCounter 		+= ( n < 0 );
		infoPtr->sendMulticastCounter 	+= ( inDstPort.NotAnInteger == MulticastDNSPort.NotAnInteger );
		infoPtr->sendUnicastCounter 	+= ( inDstPort.NotAnInteger != MulticastDNSPort.NotAnInteger );
	}
	err = mStatus_NoError;
	
	dlog( kDebugLevelChatty, DEBUG_NAME "platform send UDP done\n" );
	return( err );
}

//===========================================================================================================================
//	mDNSPlatformScheduleTask
//===========================================================================================================================

void	mDNSPlatformScheduleTask( const mDNS *const inMDNS, mDNSs32 inNextTaskTime )
{
	mDNSs32				deltaTime;
	LARGE_INTEGER		fireTime;
	DWORD				result;
	
	// Calculate the number of ticks until the task should run. If it is in the past, run it as soon as possible.
	
	deltaTime = inNextTaskTime - mDNSPlatformTimeNow();
	if( deltaTime > 0 )
	{
		SYSTEMTIME			sysTime;
		FILETIME			fileTime;
		LARGE_INTEGER		deltaTime64;
		
		// Get the current time, add the delta to it, and use that as the schedule time.
		
		GetSystemTime( &sysTime );
		SystemTimeToFileTime( &sysTime, &fileTime );
		
		fireTime 				= *( (LARGE_INTEGER *) &fileTime );
		deltaTime64.QuadPart  	= (LONGLONG) deltaTime;
		deltaTime64.QuadPart   *= (LONGLONG) kFileTimeUnitsPerMillisecond;
		fireTime.QuadPart 	   += deltaTime64.QuadPart;
	}
	else
	{
		// Next task time is in the past so set the fire time to the past so it runs the timer as soon as possible.
		
		fireTime.QuadPart = 0;
	}
	
	result = SetWaitableTimer( inMDNS->p->timer, &fireTime, 0, NULL, NULL, FALSE );
	check( result );
	
	dlog( kDebugLevelVerbose, DEBUG_NAME "platform schedule task in %ld milliseconds\n", deltaTime );
}

//===========================================================================================================================
//	mDNSPlatformLock
//===========================================================================================================================

void	mDNSPlatformLock( const mDNS *const inMDNS )
{
	EnterCriticalSection( &inMDNS->p->lock );
}

//===========================================================================================================================
//	mDNSPlatformUnlock
//===========================================================================================================================

void	mDNSPlatformUnlock( const mDNS *const inMDNS )
{
	LeaveCriticalSection( &inMDNS->p->lock );
}

//===========================================================================================================================
//	mDNSPlatformStrLen
//===========================================================================================================================

mDNSu32	mDNSPlatformStrLen( const void *inSrc )
{
	return( ( mDNSu32 ) strlen( (const char *) inSrc ) );
}

//===========================================================================================================================
//	mDNSPlatformStrCopy
//===========================================================================================================================

void	mDNSPlatformStrCopy( const void *inSrc, void *inDst )
{
	strcpy( inDst, inSrc );
}

//===========================================================================================================================
//	mDNSPlatformMemCopy
//===========================================================================================================================

void	mDNSPlatformMemCopy( const void *inSrc, void *inDst, mDNSu32 inSize )
{
	memcpy( inDst, inSrc, inSize );
}

//===========================================================================================================================
//	mDNSPlatformMemSame
//===========================================================================================================================

mDNSBool	mDNSPlatformMemSame( const void *inSrc, const void *inDst, mDNSu32 inSize )
{
	return( (mDNSBool)( memcmp( inSrc, inDst, inSize ) == 0 ) );
}

//===========================================================================================================================
//	mDNSPlatformMemZero
//===========================================================================================================================

void	mDNSPlatformMemZero( void *inDst, mDNSu32 inSize )
{
	memset( inDst, 0, inSize );
}

//===========================================================================================================================
//	mDNSPlatformTimeNow
//===========================================================================================================================

mDNSs32	mDNSPlatformTimeNow( void )
{
	// GetTickCount returns a 32-bit unsigned value. Since this value can exceed the range of a signed 32-bit 
	// value, the time is mod'd with the maximum signed 32-bit value to return a continuously rolling number.
	
	return( (mDNSs32)( GetTickCount() % 0x7FFFFFFFUL ) );
}

#if 0
#pragma mark -
#endif

#if( MDNS_DEBUGMSGS )
//===========================================================================================================================
//	debugf_
//===========================================================================================================================

void debugf_( const char *format, ... )
{
	char		buffer[ 512 ];
    va_list		args;
    int			length;
	
	va_start( args, format );
	length = mDNS_vsprintf( buffer, format, args );
	va_end( args );
	buffer[ length ] = '\0';
	
	fprintf( stderr, "%s\n", buffer );
	fflush( stderr );
}

//===========================================================================================================================
//	verbosedebugf_
//===========================================================================================================================

void verbosedebugf_( const char *format, ... )
{
	char		buffer[ 512 ];
    va_list		args;
    int			length;
	
	va_start( args, format );
	length = mDNS_vsprintf( buffer, format, args );
	va_end( args );
	buffer[ length ] = '\0';
	
	fprintf( stderr, "%s\n", buffer );
	fflush( stderr );
}

//===========================================================================================================================
//	DebugLog
//===========================================================================================================================

static void DebugLog( unsigned long inLevel, const char *inFormat, ... )
{
	va_list		args;
	
	MDNS_UNUSED( inLevel );
	 
	va_start( args, inFormat );
	vfprintf( stderr, inFormat, args );
	fflush( stderr );
	va_end( args );
}

//===========================================================================================================================
//	DebugPrintAssert
//===========================================================================================================================

static void	DebugPrintAssert( const char *		inSignature, 
							  long				inError, 
							  const char *		inAssertionString, 
							  const char *		inErrorString, 
							  const char *		inFileName, 
							  unsigned long		inLineNumber, 
							  const char *		inFunction )
{
	char *		dataPtr;
	char		buffer[ 512 ];
	char		tempSignatureChar;
		
	if( !inSignature )
	{
		tempSignatureChar = '\0';
		inSignature = &tempSignatureChar;
	}
	dataPtr = buffer;
	dataPtr += sprintf( dataPtr, "\n" );
	if( inError != 0 )
	{
		dataPtr += sprintf( dataPtr, "[%s] Error: %ld\n", inSignature, inError );
	}
	else
	{
		dataPtr += sprintf( dataPtr, "[%s] Assertion failed", inSignature );
		if( inAssertionString )
		{
			dataPtr += sprintf( dataPtr, ": %s", inAssertionString );
		}
		dataPtr += sprintf( dataPtr, "\n" );
	}
	if( inErrorString )
	{
		dataPtr += sprintf( dataPtr, "[%s]    %s\n", inSignature, inErrorString );
	}
	if( inFileName )
	{
		dataPtr += sprintf( dataPtr, "[%s]    file:     \"%s\"\n", inSignature, inFileName );
	}	
	if( inLineNumber )
	{
		dataPtr += sprintf( dataPtr, "[%s]    line:     %ld\n", inSignature, inLineNumber );
	}
	if( inFunction )
	{
		dataPtr += sprintf( dataPtr, "[%s]    function: \"%s\"\n", inSignature, inFunction );
	}
	dataPtr += sprintf( dataPtr, "\n" );
	fprintf( stderr, "%s", buffer );
	fflush( stderr );
}
#endif	// MDNS_DEBUGMSGS

#if 0
#pragma mark -
#pragma mark == Platform Internals  ==
#endif

//===========================================================================================================================
//	Setup
//===========================================================================================================================

static mStatus	Setup( mDNS * const inMDNS )
{
	mStatus		err;
	WSADATA		wsaData;
	int			supported;
	
	dlog( kDebugLevelVerbose, DEBUG_NAME "setting up\n" );
	
	// Initialize variables.
	
	inMDNS->p->interfaceListChangedSocketRef	= kInvalidSocketRef;
	mDNSPlatformOneSecond 						= 1000;
	
	// Set everything up.
	
	err = WSAStartup( MAKEWORD( 2, 0 ), &wsaData );
	require_noerr( err, exit );
	
	supported = ( ( LOBYTE( wsaData.wVersion ) == 2 ) && ( HIBYTE( wsaData.wVersion ) == 0 ) );
	require_action( supported, exit, err = mStatus_UnsupportedErr );
	
	err = SetupSynchronizationObjects( inMDNS );
	require_noerr( err, exit );
		
	err = SetupTimer( inMDNS );
	require_noerr( err, exit );
	
	err = SetupInterfaceList( inMDNS );
	require_noerr( err, exit );
	
	err = SetupThread( inMDNS );
	require_noerr( err, exit );
	
exit:
	if( err )
	{
		TearDown( inMDNS );
	}
	dlog( kDebugLevelVerbose, DEBUG_NAME "setting up done (err=%ld)\n", err );
	return( err );
}

//===========================================================================================================================
//	TearDown
//===========================================================================================================================

static mStatus	TearDown( mDNS * const inMDNS )
{
	mStatus		err;
	
	dlog( kDebugLevelVerbose, DEBUG_NAME "tearing down\n" );
	check( inMDNS );
	
	// Tear everything down in reverse order to how it was set up.
	
	err = TearDownThread( inMDNS );
	check_noerr( err );
	
	err = TearDownInterfaceList( inMDNS );
	check_noerr( err );
	
	err = TearDownTimer( inMDNS );
	check_noerr( err );
	
	err = TearDownSynchronizationObjects( inMDNS );
	check_noerr( err );
	
	WSACleanup();
	
	dlog( kDebugLevelVerbose, DEBUG_NAME "tearing down done (err=%ld)\n", err );
	return( err );
}

//===========================================================================================================================
//	SetupSynchronizationObjects
//===========================================================================================================================

static mStatus	SetupSynchronizationObjects( mDNS * const inMDNS )
{
	mStatus		err;
	
	dlog( kDebugLevelVerbose, DEBUG_NAME "setting up synchronization objects\n" );
	
	InitializeCriticalSection( &inMDNS->p->lock );
	inMDNS->p->lockInitialized = mDNStrue;
	
	inMDNS->p->cancelEvent = CreateEvent( NULL, FALSE, FALSE, NULL );
	require_action( inMDNS->p->cancelEvent, exit, err = mStatus_NoMemoryErr );
	
	inMDNS->p->quitEvent = CreateEvent( NULL, FALSE, FALSE, NULL );
	require_action( inMDNS->p->quitEvent, exit, err = mStatus_NoMemoryErr );
	
	inMDNS->p->interfaceListChangedEvent = CreateEvent( NULL, FALSE, FALSE, NULL );
	require_action( inMDNS->p->interfaceListChangedEvent, exit, err = mStatus_NoMemoryErr );
	
	err = mStatus_NoError;
	
exit:
	if( err )
	{
		TearDownSynchronizationObjects( inMDNS );
	}
	dlog( kDebugLevelVerbose, DEBUG_NAME "setting up synchronization objects done (err=%ld)\n", err );
	return( err );
}

//===========================================================================================================================
//	TearDownSynchronizationObjects
//===========================================================================================================================

static mStatus	TearDownSynchronizationObjects( mDNS * const inMDNS )
{
	mStatus		err;
	
	dlog( kDebugLevelVerbose, DEBUG_NAME "tearing down synchronization objects\n" );
	
	if( inMDNS->p->quitEvent )
	{
		CloseHandle( inMDNS->p->quitEvent );
		inMDNS->p->quitEvent = 0;
	}
	if( inMDNS->p->cancelEvent )
	{
		CloseHandle( inMDNS->p->cancelEvent );
		inMDNS->p->cancelEvent = 0;
	}
	if( inMDNS->p->interfaceListChangedEvent )
	{
		CloseHandle( inMDNS->p->interfaceListChangedEvent );
		inMDNS->p->interfaceListChangedEvent = 0;
	}
	if( inMDNS->p->lockInitialized )
	{
		DeleteCriticalSection( &inMDNS->p->lock );
		inMDNS->p->lockInitialized = mDNSfalse;
	}
	err = mStatus_NoError;
	
	dlog( kDebugLevelVerbose, DEBUG_NAME "tearing down synchronization objects done (err=%ld)\n", err );
	return( err );
}

//===========================================================================================================================
//	SetupName
//===========================================================================================================================

static mStatus	SetupName( mDNS * const inMDNS )
{
	mStatus		err;
	char		tempString[ 256 ];
	
	// Get the name of this machine.
	
	tempString[ 0 ] = '\0';
	err = gethostname( tempString, sizeof( tempString ) - 1 );
	check_errno( err, errno_compat() );
	if( err || ( tempString[ 0 ] == '\0' ) )
	{
		// Invalidate name so fall back to a default name.
		
		strcpy( tempString, kMDNSDefaultName );
	}
	tempString[ sizeof( tempString ) - 1 ] = '\0';
	
	// Set up the host name with mDNS.
	
	inMDNS->nicelabel.c[ 0 ] = (mDNSu8) strlen( tempString );
	memcpy( &inMDNS->nicelabel.c[ 1 ], tempString, inMDNS->nicelabel.c[ 0 ] );
	ConvertUTF8PstringToRFC1034HostLabel( inMDNS->nicelabel.c, &inMDNS->hostlabel );
	if( inMDNS->hostlabel.c[ 0 ] == 0 )
	{
		// Nice name has no characters that are representable as an RFC1034 name (e.g. Japanese) so use the default.
		
		ConvertCStringToDomainLabel( kMDNSDefaultName, &inMDNS->hostlabel );
	}
	check( inMDNS->nicelabel.c[ 0 ] != 0 );
	check( inMDNS->hostlabel.c[ 0 ] != 0 );
	
	mDNS_GenerateFQDN( inMDNS );
	
	dlog( kDebugLevelInfo, DEBUG_NAME "nice name \"%.*s\"\n", inMDNS->nicelabel.c[ 0 ], &inMDNS->nicelabel.c[ 1 ] );
	dlog( kDebugLevelInfo, DEBUG_NAME "host name \"%.*s\"\n", inMDNS->hostlabel.c[ 0 ], &inMDNS->hostlabel.c[ 1 ] );
	return( err );
}

//===========================================================================================================================
//	SetupTimer
//===========================================================================================================================

static mStatus	SetupTimer( mDNS * const inMDNS )
{
	mStatus		err;
	
	dlog( kDebugLevelVerbose, DEBUG_NAME "setting up timers\n" );
		
	// Set up the timer object to signal the thread.
	
	inMDNS->p->timer = CreateWaitableTimer( NULL, FALSE, NULL );
	require_action( inMDNS->p->timer, exit, err = mStatus_NoMemoryErr );
	
	err = 0;
	
exit:
	dlog( kDebugLevelVerbose, DEBUG_NAME "setting up timers done (err=%ld)\n", err );
	return( err );
}

//===========================================================================================================================
//	TearDownTimer
//===========================================================================================================================

static mStatus	TearDownTimer( mDNS * const inMDNS )
{
	mStatus		err;
	
	dlog( kDebugLevelVerbose, DEBUG_NAME "tearing down timer\n" );
	require_action_quiet( inMDNS->p->timer, exit, err = mStatus_NotInitializedErr );
	
	CloseHandle( inMDNS->p->timer );
	inMDNS->p->timer = 0;
	
	err = mStatus_NoError;
	
exit:
	dlog( kDebugLevelVerbose, DEBUG_NAME "tearing down timer done\n" );
	return( err );
}

#if 0
#pragma mark -
#endif

//===========================================================================================================================
//	SetupInterfaceList
//===========================================================================================================================

static mStatus	SetupInterfaceList( mDNS * const inMDNS )
{
	mStatus						err;
	mDNSInterfaceInfo **		nextPtr;
	mDNSInterfaceInfo *			infoPtr;
	void *						interfaceListBuffer;
	int							i;
	SocketAddressInet			addr;
	
	dlog( kDebugLevelVerbose, DEBUG_NAME "setting up interface list\n" );
	check( inMDNS );
	
	interfaceListBuffer = NULL;
	
	// Tear down any existing interfaces that may be set up.
	
	TearDownInterfaceList( inMDNS );
	
	// Set up the name of this machine.
	
	err = SetupName( inMDNS );
	check_noerr( err );
	
	// Set up the interface list change notification.
	
	err = SetupNotifications( inMDNS );
	check_noerr( err );
	
	// Get the list of interfaces and set up each one.
	
	inMDNS->p->interfaceCount = 0;
	inMDNS->p->interfaceList = NULL;
	nextPtr	= &inMDNS->p->interfaceList;
	
	err = GetRawInterfaceList( &interfaceListBuffer, NULL );
	require_noerr( err, exit );
	
	for( i = 1; GetIndexedInterface( i, interfaceListBuffer, &addr ) == 0; ++i )
	{
		err = SetupInterface( inMDNS, &addr, &infoPtr );
		require_noerr( err, exit );
		
		*nextPtr = infoPtr;
		nextPtr = &infoPtr->next;
		++inMDNS->p->interfaceCount;
	}
	
exit:
	if( err )
	{
		TearDownInterfaceList( inMDNS );
	}
	if( interfaceListBuffer )
	{
		free( interfaceListBuffer );
	}
	dlog( kDebugLevelVerbose, DEBUG_NAME "setting up interface list done (err=%ld)\n", err );
	return( err );
}

//===========================================================================================================================
//	TearDownInterfaceList
//===========================================================================================================================

static mStatus	TearDownInterfaceList( mDNS * const inMDNS )
{
	mStatus					err;
	mDNSInterfaceInfo *		infoPtr;
	
	dlog( kDebugLevelVerbose, DEBUG_NAME "tearing down interface list\n" );
	check( inMDNS );
	
	// Tear down interface list change notifications.
	
	err = TearDownNotifications( inMDNS );
	check_noerr( err );
	
	// Tear down all the interfaces.
	
	while( inMDNS->p->interfaceList )
	{
		infoPtr = inMDNS->p->interfaceList;
		inMDNS->p->interfaceList = infoPtr->next;
		
		TearDownInterface( inMDNS, infoPtr );
	}
	
	dlog( kDebugLevelVerbose, DEBUG_NAME "tearing down interface list done\n" );
	return( mStatus_NoError );
}

//===========================================================================================================================
//	SetupInterface
//===========================================================================================================================

static mStatus	SetupInterface( mDNS * const inMDNS, const SocketAddressInet *inAddress, mDNSInterfaceInfo **outInfoPtr )
{
	mStatus					err;
	mDNSInterfaceInfo *		infoPtr;
	SocketRef				socketRef;
	
	dlog( kDebugLevelVerbose, DEBUG_NAME "setting up interface\n" );
	check( inMDNS );
	check( inAddress );
	check( outInfoPtr );
	
	// Allocate memory for the info item.
	
	infoPtr = (mDNSInterfaceInfo *) calloc( 1, sizeof( *infoPtr ) );
	require_action( infoPtr, exit, err = mStatus_NoMemoryErr );
	infoPtr->multicastSocketRef = kInvalidSocketRef;
	infoPtr->unicastSocketRef 	= kInvalidSocketRef;
	
	///
	/// Set up multicast portion of interface.
	///
	
	// Set up the multicast DNS (port 5353) socket for this interface.
	
	err = SetupSocket( inMDNS, inAddress, MulticastDNSPort, &socketRef );
	require_noerr( err, exit );
	infoPtr->multicastSocketRef = socketRef;
	
	// Set up the read pending event and associate it so we can block until data is available for this socket.
	
	infoPtr->multicastReadPendingEvent = CreateEvent( NULL, FALSE, FALSE, NULL );
	require_action( infoPtr->multicastReadPendingEvent, exit, err = mStatus_NoMemoryErr );
	
	err = WSAEventSelect( infoPtr->multicastSocketRef, infoPtr->multicastReadPendingEvent, FD_READ );
	require_noerr( err, exit );
	
	///
	/// Set up unicast portion of interface.
	///
	
	// Set up the unicast DNS (port 53) socket for this interface (to handle normal DNS requests).
	
	err = SetupSocket( inMDNS, inAddress, UnicastDNSPort, &socketRef );
	require_noerr( err, exit );
	infoPtr->unicastSocketRef = socketRef;
	
	// Set up the read pending event and associate it so we can block until data is available for this socket.
	
	infoPtr->unicastReadPendingEvent = CreateEvent( NULL, FALSE, FALSE, NULL );
	require_action( infoPtr->unicastReadPendingEvent, exit, err = mStatus_NoMemoryErr );
	
	err = WSAEventSelect( infoPtr->unicastSocketRef, infoPtr->unicastReadPendingEvent, FD_READ );
	require_noerr( err, exit );
	
	// Register this interface with mDNS.
	
	infoPtr->hostSet.ip.NotAnInteger = inAddress->sin_addr.s_addr;
	infoPtr->hostSet.Advertise       = inMDNS->p->advertise;
	err = mDNS_RegisterInterface( inMDNS, &infoPtr->hostSet );
	require_noerr( err, exit );
	
	dlog( kDebugLevelInfo, DEBUG_NAME "Registered IP address: %d.%d.%d.%d\n", 
		  infoPtr->hostSet.ip.b[ 0 ], infoPtr->hostSet.ip.b[ 1 ], infoPtr->hostSet.ip.b[ 2 ], infoPtr->hostSet.ip.b[ 3 ] );
	
	// Success!
	
	*outInfoPtr = infoPtr;
	infoPtr = NULL;
	
exit:
	if( infoPtr )
	{
		if( infoPtr->multicastReadPendingEvent )
		{
			CloseHandle( infoPtr->multicastReadPendingEvent );
		}
		if( IsValidSocket( infoPtr->multicastSocketRef ) )
		{
			close_compat( infoPtr->multicastSocketRef );
		}
		if( infoPtr->unicastReadPendingEvent )
		{
			CloseHandle( infoPtr->unicastReadPendingEvent );
		}
		if( IsValidSocket( infoPtr->unicastSocketRef ) )
		{
			close_compat( infoPtr->unicastSocketRef );
		}
		free( infoPtr );
	}
	dlog( kDebugLevelVerbose, DEBUG_NAME "setting up interface done (err=%ld)\n", err );
	return( err );
}

//===========================================================================================================================
//	TearDownInterface
//===========================================================================================================================

static mStatus	TearDownInterface( mDNS * const inMDNS, mDNSInterfaceInfo *inInfoPtr )
{
	SocketRef		socketRef;
	
	check( inMDNS );
	check( inInfoPtr );
	
	// Deregister this interface with mDNS.
	
	dlog( kDebugLevelInfo, DEBUG_NAME "Deregistering IP address: %d.%d.%d.%d\n", 
		  inInfoPtr->hostSet.ip.b[ 0 ], inInfoPtr->hostSet.ip.b[ 1 ], inInfoPtr->hostSet.ip.b[ 2 ], inInfoPtr->hostSet.ip.b[ 3 ] );
	
	mDNS_DeregisterInterface( inMDNS, &inInfoPtr->hostSet );
	
	// Tear down the multicast socket.
	
	if( inInfoPtr->multicastReadPendingEvent )
	{
		CloseHandle( inInfoPtr->multicastReadPendingEvent );
		inInfoPtr->multicastReadPendingEvent = 0;
	}
	
	socketRef = inInfoPtr->multicastSocketRef;
	inInfoPtr->multicastSocketRef = kInvalidSocketRef;
	if( IsValidSocket( socketRef ) )
	{
		dlog( kDebugLevelVerbose, DEBUG_NAME "tearing down multicast socket %d\n", socketRef );
		close_compat( socketRef );
	}
	
	// Tear down the unicast socket.
	
	if( inInfoPtr->unicastReadPendingEvent )
	{
		CloseHandle( inInfoPtr->unicastReadPendingEvent );
		inInfoPtr->unicastReadPendingEvent = 0;
	}
	
	socketRef = inInfoPtr->unicastSocketRef;
	inInfoPtr->unicastSocketRef = kInvalidSocketRef;
	if( IsValidSocket( socketRef ) )
	{
		dlog( kDebugLevelVerbose, DEBUG_NAME "tearing down unicast socket %d\n", socketRef );
		close_compat( socketRef );
	}
	
	// Free the memory used by the interface info.
	
	free( inInfoPtr );	
	return( mStatus_NoError );
}

//===========================================================================================================================
//	SetupSocket
//===========================================================================================================================

static mStatus	SetupSocket( mDNS * const 				inMDNS, 
							 const SocketAddressInet *	inAddress, 
							 mDNSIPPort 				inPort, 
							 SocketRef *				outSocketRef  )
{
	mStatus					err;
	SocketRef				socketRef;
	int						option;
	struct ip_mreq			mreq;
	SocketAddressInet		addr;
	mDNSIPAddr				ip;
	
	MDNS_UNUSED( inMDNS );
	
	dlog( kDebugLevelVerbose, DEBUG_NAME "setting up socket done\n" );
	check( inMDNS );
	check( outSocketRef );
	
	// Set up a UDP socket. 
	
	socketRef = socket( AF_INET, SOCK_DGRAM, 0 );
	require_action( IsValidSocket( socketRef ), exit, err = mStatus_NoMemoryErr );
	
	// Turn on reuse address option so multiple servers can listen for Multicast DNS packets.
		
	option = 1;
	err = setsockopt( socketRef, SOL_SOCKET, SO_REUSEADDR, (char *) &option, sizeof( option ) );
	check_errno( err, errno_compat() );
	
	// Bind to the specified port (53 for unicast or 5353 for multicast).
	
	ip.NotAnInteger = inAddress->sin_addr.s_addr;
	memset( &addr, 0, sizeof( addr ) );
	addr.sin_family 		= AF_INET;
	addr.sin_port 			= inPort.NotAnInteger;
	addr.sin_addr.s_addr 	= ip.NotAnInteger;
	err = bind( socketRef, ( SocketAddress * ) &addr, sizeof( addr ) );
	if( err && ( inPort.NotAnInteger == UnicastDNSPort.NotAnInteger ) )
	{
		// Some systems prevent code without root permissions from binding to the DNS port so ignore this 
		// error since it is not critical. This should only occur with non-root processes.
		
		err = 0;
	}
	check_errno( err, errno_compat() );
	
	// Join the all-DNS multicast group so we receive Multicast DNS packets.
	
	if( inPort.NotAnInteger == MulticastDNSPort.NotAnInteger )
	{
		mreq.imr_multiaddr.s_addr 	= AllDNSLinkGroup.NotAnInteger;
		mreq.imr_interface.s_addr 	= ip.NotAnInteger;
		err = setsockopt( socketRef, IPPROTO_IP, IP_ADD_MEMBERSHIP, (char *) &mreq, sizeof( mreq ) );
		check_errno( err, errno_compat() );
	}
				
	// Direct multicast packets to the specified interface.
	
	addr.sin_addr.s_addr = ip.NotAnInteger;
	err = setsockopt( socketRef, IPPROTO_IP, IP_MULTICAST_IF, (char *) &addr.sin_addr, sizeof( addr.sin_addr ) );
	check_errno( err, errno_compat() );
		
	// Set the TTL of outgoing unicast packets to 255 (helps against spoofing).
		
	option = 255;
	err = setsockopt( socketRef, IPPROTO_IP, IP_TTL, (char *) &option, sizeof( option ) );
	check_errno( err, errno_compat() );
	
	// Set the TTL of outgoing multicast packets to 255 (helps against spoofing).
	
	option = 255;
	err = setsockopt( socketRef, IPPROTO_IP, IP_MULTICAST_TTL, (char *) &option, sizeof( option ) );
	check_errno( err, errno_compat() );
	
	// Success!
	
	dlog( kDebugLevelVerbose, DEBUG_NAME "setting up socket done (%u.%u.%u.%u:%u, %d)\n", 
		  ip.b[ 0 ], ip.b[ 1 ], ip.b[ 2 ], ip.b[ 3 ], ntohs( inPort.NotAnInteger ), socketRef );
	
	*outSocketRef = socketRef;
	socketRef = kInvalidSocketRef;
	err = mStatus_NoError;
	
exit:
	if( IsValidSocket( socketRef ) )
	{
		close_compat( socketRef );
	}
	return( err );
}

//===========================================================================================================================
//	SetupNotifications
//===========================================================================================================================

static mStatus	SetupNotifications( mDNS * const inMDNS )
{
	mStatus				err;
	SocketRef			socketRef;
	unsigned long		param;
	int					inBuffer;
	int					outBuffer;
	DWORD				outSize;
	
	// Register to listen for address list changes.
	
	socketRef = socket( AF_INET, SOCK_DGRAM, 0 );
	require_action( IsValidSocket( socketRef ), exit, err = mStatus_NoMemoryErr );
	inMDNS->p->interfaceListChangedSocketRef = socketRef;
	
	// Make the socket non-blocking so the WSAIoctl returns immediately with WSAEWOULDBLOCK. It will set the event 
	// when a change to the interface list is detected.
	
	param = 1;
	err = ioctlsocket( socketRef, FIONBIO, &param );
	require_errno( err, errno_compat(), exit );
	
	inBuffer	= 0;
	outBuffer	= 0;
	err = WSAIoctl( socketRef, SIO_ADDRESS_LIST_CHANGE, &inBuffer, 0, &outBuffer, 0, &outSize, NULL, NULL );
	if( err < 0 )
	{
		check( errno_compat() == WSAEWOULDBLOCK );
	}
	
	err = WSAEventSelect( socketRef, inMDNS->p->interfaceListChangedEvent, FD_ADDRESS_LIST_CHANGE );
	require_errno( err, errno_compat(), exit );

exit:
	if( err )
	{
		TearDownNotifications( inMDNS );
	}
	return( err );
}

//===========================================================================================================================
//	TearDownNotifications
//===========================================================================================================================

static mStatus	TearDownNotifications( mDNS * const inMDNS )
{
	SocketRef		socketRef;
	
	socketRef = inMDNS->p->interfaceListChangedSocketRef;
	inMDNS->p->interfaceListChangedSocketRef = kInvalidSocketRef;
	if( IsValidSocket( socketRef ) )
	{
		close_compat( socketRef );
	}
	return( mStatus_NoError );
}

#if 0
#pragma mark -
#endif

//===========================================================================================================================
//	SetupThread
//===========================================================================================================================

static mStatus	SetupThread( mDNS *const inMDNS )
{
	mStatus		err;
	DWORD		threadID;
	
	dlog( kDebugLevelVerbose, DEBUG_NAME "setting up thread\n" );
		
	// Create the thread and start it running.
	
	inMDNS->p->thread = CreateThread( NULL, 0, ProcessingThread, inMDNS, 0, &threadID );
	require_action( inMDNS->p->thread, exit, err = mStatus_NoMemoryErr );
	
	err = mStatus_NoError;
	
exit:
	dlog( kDebugLevelVerbose, DEBUG_NAME "setting up thread done (err=%ld)\n", err );
	return( err );
}

//===========================================================================================================================
//	TearDownThread
//===========================================================================================================================

static mStatus	TearDownThread( const mDNS *const inMDNS )
{
	BOOL		result;
	
	// Signal the cancel event to cause the thread to exit. Then wait for the quit event to be signal indicating it did 
	// exit. If the quit event is not signal in 10 seconds, just give up and close anyway sinec the thread is probably hung.
	
	if( inMDNS->p->cancelEvent )
	{
		result = SetEvent( inMDNS->p->cancelEvent );
		check( result );
		
		if( inMDNS->p->quitEvent )
		{
			result = WaitForSingleObject( inMDNS->p->quitEvent, kThreadCleanupTimeout );
			check( result == WAIT_OBJECT_0 );
		}
	}
	return( mStatus_NoError );
}

//===========================================================================================================================
//	ProcessingThread
//===========================================================================================================================

static DWORD	WINAPI ProcessingThread( LPVOID inParam )
{
	mDNS *			mdnsPtr;
	int				done;
	mStatus			err;
	HANDLE *		waitList;
	int				waitListCount;
	DWORD			result;
	
	check( inParam );
	mdnsPtr	= (mDNS *) inParam;
	done 	= 0;
	
	while( !done )
	{
		// Set up the list of objects we'll be waiting on.
		
		waitList 		= NULL;
		waitListCount	= 0;
		err = ProcessingThreadSetupWaitList( mdnsPtr, &waitList, &waitListCount );
		require_noerr( err, exit );
		
		// Main mDNS processing loop.
		
		for( ;; )
		{
			// Wait until something occurs (e.g. cancel, timer, or incoming packet).
			
			result = WaitForMultipleObjects( waitListCount, waitList, FALSE, INFINITE );
			if( result == kWaitListCancelEvent )
			{
				// Cancel event. Set the done flag and break to exit.
				
				dlog( kDebugLevelChatty, DEBUG_NAME "canceling...\n" );
				done = 1;
				break;
			}
			else if( result == kWaitListTimerEvent )
			{
				// Timer event
				
				dlog( kDebugLevelChatty, DEBUG_NAME "timer fired\n" );
				mDNSCoreTask( mdnsPtr );
			}
			else if( result == kWaitListInterfaceListChangedEvent )
			{
				// Interface list changed event.
				
				ProcessingThreadInterfaceListChanged( mdnsPtr );
				break;
			}
			else
			{
				int		waitItemIndex;
				
				// Socket data available event. Determine which socket and process the packet.
				
				dlog( kDebugLevelChatty, DEBUG_NAME "socket data available\n" );
				waitItemIndex = ( (int) result ) - WAIT_OBJECT_0;
				check( ( waitItemIndex >= 0 ) && ( waitItemIndex < waitListCount ) );
				if( ( waitItemIndex >= 0 ) && ( waitItemIndex < waitListCount ) )
				{
					HANDLE					signaledObject;
					int						n;
					mDNSInterfaceInfo *		infoPtr;
					
					signaledObject = waitList[ waitItemIndex ];
					
					n = 0;
					for( infoPtr = mdnsPtr->p->interfaceList; infoPtr; infoPtr = infoPtr->next )
					{
						if( infoPtr->multicastReadPendingEvent == signaledObject )
						{
							ProcessingThreadProcessPacket( mdnsPtr, infoPtr, infoPtr->multicastSocketRef );
							++n;
						}
						if( infoPtr->unicastReadPendingEvent == signaledObject )
						{
							ProcessingThreadProcessPacket( mdnsPtr, infoPtr, infoPtr->unicastSocketRef );
							++n;
						}
					}
					check( n > 0 );
				}
				else
				{
					// Unexpected wait result.
				
					dlog( kDebugLevelAllowedError, DEBUG_NAME "unexpected wait result (result=0x%08X)\n", result );
				}
			}
		}
		
		// Release the wait list.
		
		if( waitList )
		{
			free( waitList );
			waitList = NULL;
			waitListCount = 0;
		}
	}
	
	// Signal the quit event to indicate that the thread is finished.

exit:
	result = SetEvent( mdnsPtr->p->quitEvent );
	check( result );
	return( 0 );
}

//===========================================================================================================================
//	ProcessingThreadSetupWaitList
//===========================================================================================================================

static mStatus	ProcessingThreadSetupWaitList( mDNS *const inMDNS, HANDLE **outWaitList, int *outWaitListCount )
{
	mStatus					err;
	int						waitListCount;
	HANDLE *				waitList;
	HANDLE *				waitItemPtr;
	mDNSInterfaceInfo *		infoPtr;
	
	dlog( kDebugLevelVerbose, DEBUG_NAME "thread setting up wait list\n" );
	check( inMDNS );
	check( outWaitList );
	check( outWaitListCount );
	
	// Allocate an array to hold all the objects to wait on.
	
	waitListCount = kWaitListFixedItemCount + ( 2 * inMDNS->p->interfaceCount );
	waitList = (HANDLE *) malloc( waitListCount * sizeof( *waitList ) );
	require_action( waitList, exit, err = mStatus_NoMemoryErr );
	waitItemPtr = waitList;
	
	// Add the fixed wait items to the beginning of the list.
	
	*waitItemPtr++ = inMDNS->p->cancelEvent;
	*waitItemPtr++ = inMDNS->p->timer;
	*waitItemPtr++ = inMDNS->p->interfaceListChangedEvent;
	
	// Append all the dynamic wait items to the list.
	
	for( infoPtr = inMDNS->p->interfaceList; infoPtr; infoPtr = infoPtr->next )
	{
		*waitItemPtr++ = infoPtr->multicastReadPendingEvent;
		*waitItemPtr++ = infoPtr->unicastReadPendingEvent;
	}
	
	*outWaitList 		= waitList;
	*outWaitListCount	= waitListCount;
	err					= mStatus_NoError;
	
exit:
	if( err && waitList )
	{
		free( waitList );
	}
	dlog( kDebugLevelVerbose, DEBUG_NAME "thread setting up wait list done (err=%ld)\n", err );
	return( err );
}

//===========================================================================================================================
//	ProcessingThreadProcessPacket
//===========================================================================================================================

static void	ProcessingThreadProcessPacket( mDNS *inMDNS, mDNSInterfaceInfo *inInfoPtr, SocketRef inSocketRef )
{
	int						n;
	DNSMessage				packet;
	SocketAddressInet		addr;
	int						addrSize;
	mDNSu8 *				packetEndPtr;
	mDNSIPAddr				srcAddr;
	mDNSIPPort				srcPort;
	mDNSIPAddr				dstAddr;
	mDNSIPPort				dstPort;
	mDNSIPAddr				interfaceAddr;
	
	// Receive the packet.
	
	addrSize = sizeof( addr );
	n = recvfrom( inSocketRef, (char *) &packet, sizeof( packet ), 0, ( SocketAddress * ) &addr, &addrSize );
	check( n >= 0 );
	if( n >= 0 )
	{
		// Set up the src/dst/interface info.
		
		srcAddr.NotAnInteger 		= addr.sin_addr.s_addr;
		srcPort.NotAnInteger		= addr.sin_port;
		dstAddr						= ( inSocketRef == inInfoPtr->multicastSocketRef ) ? AllDNSLinkGroup  : inInfoPtr->hostSet.ip;
		dstPort						= ( inSocketRef == inInfoPtr->multicastSocketRef ) ? MulticastDNSPort : UnicastDNSPort;
		interfaceAddr.NotAnInteger	= inInfoPtr->hostSet.ip.NotAnInteger;
		
		dlog( kDebugLevelChatty, DEBUG_NAME "packet received\n" );
		dlog( kDebugLevelChatty, DEBUG_NAME "    size      = %d\n", n );
		dlog( kDebugLevelChatty, DEBUG_NAME "    src       = %d.%d.%d.%d:%d\n", 
			  srcAddr.b[ 0 ], srcAddr.b[ 1 ], srcAddr.b[ 2 ], srcAddr.b[ 3 ], ntohs( srcPort.NotAnInteger ) );
		dlog( kDebugLevelChatty, DEBUG_NAME "    dst       = %d.%d.%d.%d:%d\n", 
			  dstAddr.b[ 0 ], dstAddr.b[ 1 ], dstAddr.b[ 2 ], dstAddr.b[ 3 ], ntohs( dstPort.NotAnInteger ) );
		dlog( kDebugLevelChatty, DEBUG_NAME "    interface = %d.%d.%d.%d\n", 
			  interfaceAddr.b[ 0 ], interfaceAddr.b[ 1 ], interfaceAddr.b[ 2 ], interfaceAddr.b[ 3 ] );
		dlog( kDebugLevelChatty, DEBUG_NAME "--\n" );
		
		// Dispatch the packet to mDNS.
		
		packetEndPtr = ( (mDNSu8 *) &packet ) + n;
		mDNSCoreReceive( inMDNS, &packet, packetEndPtr, srcAddr, srcPort, dstAddr, dstPort, interfaceAddr );
	}
	
	// Update counters.
	
	inInfoPtr->recvMulticastCounter += ( inSocketRef == inInfoPtr->multicastSocketRef );
	inInfoPtr->recvUnicastCounter 	+= ( inSocketRef == inInfoPtr->unicastSocketRef );
	inInfoPtr->recvErrorCounter 	+= ( n < 0 );
}

//===========================================================================================================================
//	ProcessingThreadInterfaceListChanged
//===========================================================================================================================

static void	ProcessingThreadInterfaceListChanged( mDNS *inMDNS )
{
	mStatus		err;
	
	dlog( kDebugLevelInfo, DEBUG_NAME "interface list changed event\n" );
	check( inMDNS );
	
	mDNSPlatformLock( inMDNS );
	
	// Tear down the existing interfaces and set up new ones using the new IP info.
	
	err = TearDownInterfaceList( inMDNS );
	check_noerr( err );
	
	err = SetupInterfaceList( inMDNS );
	check_noerr( err );
		
	mDNSPlatformUnlock( inMDNS );
	
	// Force mDNS to update.
	
	mDNSCoreSleep( inMDNS, mDNSfalse );
}

#if 0
#pragma mark -
#pragma mark == Utilities ==
#endif

//===========================================================================================================================
//	GetIndexedInterface
//===========================================================================================================================

static int	GetIndexedInterface( int inIndex, const void *inInterfaceListBuffer, SocketAddressInet *outAddr )
{
	int							err;
	SOCKET_ADDRESS_LIST *		listPtr;
	SocketAddressInet *			addrPtr;
	
	// Make sure the index is valid.
	
	check( inInterfaceListBuffer );
	listPtr = (SOCKET_ADDRESS_LIST *) inInterfaceListBuffer;
	require_action( inIndex > 0, exit, err = mStatus_BadParamErr );
	require_action_quiet( inIndex <= listPtr->iAddressCount, exit, err = mStatus_BadParamErr );
	
	// Make sure the address is valid.
	
	addrPtr = (SocketAddressInet *) listPtr->Address[ inIndex - 1 ].lpSockaddr;
	require_action( addrPtr, exit, err = mStatus_BadParamErr );
	require_action( addrPtr->sin_family == AF_INET, exit, err = mStatus_BadParamErr );
	
	*outAddr = *addrPtr;
	err = 0;
	
exit:
	return( err );
}

//===========================================================================================================================
//	GetRawInterfaceList
//===========================================================================================================================

static int	GetRawInterfaceList( void *outBuffer, size_t *outBufferSize )
{
	int				err;
	SocketRef		socketRef;
	DWORD			size;
	void *			buffer;
	
	socketRef 	= kInvalidSocketRef;
	buffer 		= NULL;
	
	// Open a temporary socket because one is needed to use WSAIoctl (we'll close it before exiting this function).
	
	socketRef = socket( AF_INET, SOCK_DGRAM, 0 );
	require_action( IsValidSocket( socketRef ), exit, err = mStatus_NoMemoryErr );
	
	// Call WSAIoctl with SIO_ADDRESS_LIST_QUERY and pass a null buffer. This call will fail, but the size needed to 
	// for the request will be filled in. Once we know the size, allocate a buffer to hold the entire list.
	
	size = 0;
	WSAIoctl( socketRef, SIO_ADDRESS_LIST_QUERY, NULL, 0, NULL, 0, &size, NULL, NULL );
	require_action( size > 0, exit, err = -1 );
	
	buffer = malloc( size );
	require_action( buffer, exit, err = -1 );
	
	// We now know the size of the list and have a buffer to hold so call WSAIoctl again to get it.
	
	err = WSAIoctl( socketRef, SIO_ADDRESS_LIST_QUERY, NULL, 0, buffer, size, &size, NULL, NULL );
	require_noerr( err, exit );
	
	*( (void **) outBuffer ) = buffer;
	if( outBufferSize )
	{
		*outBufferSize = size;
	}
	buffer = NULL;
	
exit:
	if( IsValidSocket( socketRef ) )
	{
		close_compat( socketRef );
	}
	if( buffer )
	{
		free( buffer );
	}
	return( err );
}
