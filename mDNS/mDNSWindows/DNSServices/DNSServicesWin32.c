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
	$Id: DNSServicesWin32.c,v 1.1 2003/07/18 19:41:55 dean Exp $

	Contains:	DNS Services platform plugin for Win32.
	
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
    
        $Log: DNSServicesWin32.c,v $
        Revision 1.1  2003/07/18 19:41:55  dean
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

        Revision 1.3  2002/09/21 20:44:57  zarzycki
        Added APSL info

        Revision 1.2  2002/09/20 05:58:02  bradley
        DNS Services for Windows

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

#include	<stdlib.h>
#include	<string.h>

#include	"DNSServices.h"
#include	"DNSServicesPlatformSupport.h"

#include	"mDNSClientAPI.h"
#include	"mDNSPlatformFunctions.h"
#include	"mDNSWin32.h"

#include	"DNSServicesWin32.h"

//===========================================================================================================================
//	Macros
//===========================================================================================================================

// Emulate Mac OS debugging macros for non-Mac platforms.

#define check(assertion)
#define check_string( assertion, cstring )
#define check_noerr(err)
#define check_noerr_string( error, cstring )
#define debug_string( cstring )
#define require( assertion, label )                             	do { if( !(assertion) ) goto label; } while(0)
#define require_string( assertion, label, string )					require(assertion, label)
#define require_quiet( assertion, label )							require( assertion, label )
#define require_noerr( error, label )								do { if( (error) != 0 ) goto label; } while(0)
#define require_noerr_quiet( assertion, label )						require_noerr( assertion, label )
#define require_noerr_action( error, label, action )				do { if( (error) != 0 ) { {action;}; goto label; } } while(0)
#define require_noerr_action_quiet( assertion, label, action )		require_noerr_action( assertion, label, action )
#define require_action( assertion, label, action )					do { if( !(assertion) ) { {action;}; goto label; } } while(0)
#define require_action_quiet( assertion, label, action )			require_action( assertion, label, action )
#define require_action_string( assertion, label, action, cstring )	do { if( !(assertion) ) { {action;}; goto label; } } while(0)

#if 0
#pragma mark == Prototypes ==
#endif

//===========================================================================================================================
//	Prototypes
//===========================================================================================================================

extern void mDNSPlatformIdle(mDNS *const m);

#if 0
#pragma mark == Globals ==
#endif

//===========================================================================================================================
//	Globals
//===========================================================================================================================

static mDNS						gMDNS					= { 0 };
static mDNS_PlatformSupport		gMDNSPlatformSupport	= { 0 };
static ResourceRecord *			gMDNSCache = NULL;

#if 0
#pragma mark -
#pragma mark == Platform Support ==
#endif

//===========================================================================================================================
//	DNSPlatformInitialize
//===========================================================================================================================

DNSStatus	DNSPlatformInitialize( DNSFlags inFlags, DNSCount inCacheEntryCount, mDNS **outMDNS )
{
	DNSStatus		err;
	mDNSBool		advertise;
	
	memset( &gMDNSPlatformSupport, 0, sizeof( gMDNSPlatformSupport ) );
	
	// Allocate memory for the cache.
	
	err = DNSPlatformMemAlloc( sizeof( ResourceRecord ) * inCacheEntryCount, &gMDNSCache );
	require_noerr( err, exit );
	
	// Initialize mDNS and wait for it to complete.
	
	if( inFlags & kDNSFlagAdvertise )
	{
		advertise = mDNS_Init_AdvertiseLocalAddresses;
	}
	else
	{
		advertise = mDNS_Init_DontAdvertiseLocalAddresses;
	}
	gMDNSPlatformSupport.advertise = advertise;
	err = mDNS_Init( &gMDNS, &gMDNSPlatformSupport, gMDNSCache, inCacheEntryCount, advertise, NULL, NULL );
	require_noerr( err, exit );
	require_noerr_action( gMDNS.mDNSPlatformStatus, exit, err = gMDNS.mDNSPlatformStatus );
	
	*outMDNS = &gMDNS;
	
exit:
	if( err && gMDNSCache )
	{
		DNSPlatformMemFree( gMDNSCache );
		gMDNSCache = NULL;
	}
	return( err );
}

//===========================================================================================================================
//	DNSPlatformFinalize
//===========================================================================================================================

void	DNSPlatformFinalize( void )
{
	mDNS_Close( &gMDNS );
	if( gMDNSCache )
	{
		free( gMDNSCache );
		gMDNSCache = NULL;
	}
}

//===========================================================================================================================
//	DNSPlatformIdle
//===========================================================================================================================

void	DNSPlatformIdle( void )
{
	// No idling needed on Win32.
}

//===========================================================================================================================
//	DNSPlatformMemAlloc
//===========================================================================================================================

DNSStatus	DNSPlatformMemAlloc( unsigned long inSize, void *outMem )
{
	void *		mem;
	
	check( outMem );
	
	mem = malloc( inSize );
	*( (void **) outMem ) = mem;
	if( mem )
	{
		return( kDNSNoErr );
	}
	return( kDNSNoMemoryErr );
}

//===========================================================================================================================
//	DNSPlatformMemFree
//===========================================================================================================================

void	DNSPlatformMemFree( void *inMem )
{
	check( inMem );
	
	free( inMem );
}

//===========================================================================================================================
//	DNSPlatformLock
//===========================================================================================================================

void	DNSPlatformLock( void )
{
	mDNSPlatformLock( &gMDNS );
}

//===========================================================================================================================
//	DNSPlatformUnlock
//===========================================================================================================================

void	DNSPlatformUnlock( void )
{
	mDNSPlatformUnlock( &gMDNS );
}
