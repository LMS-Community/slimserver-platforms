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
	$Id: DNSServices.c,v 1.1 2003/07/18 19:41:55 dean Exp $

	Contains:	DNS Services implementation.
	
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
    
        $Log: DNSServices.c,v $
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

        Revision 1.4  2002/09/21 20:44:56  zarzycki
        Added APSL info

        Revision 1.3  2002/09/20 08:36:50  bradley
        Fixed debug messages to output the correct information when resolving.

        Revision 1.2  2002/09/20 05:58:01  bradley
        DNS Services for Windows

*/

#include	<string.h>

#if( __MACH__ )
	#include	<CoreServices/CoreServices.h>
#endif

#include	"DNSServicesPlatformSupport.h"
#include	"mDNSPlatformFunctions.h"

#include	"DNSServices.h"

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

#if 0
#pragma mark == Constants ==
#endif

//===========================================================================================================================
//	Constants
//===========================================================================================================================

#define	DEBUG_NAME		"[DNSServices] "

enum
{
	kDNSInitializeValidFlags 				= kDNSFlagAdvertise, 
	kDNSBrowserCreateValidFlags 			= 0, 
	kDNSBrowserReleaseValidFlags 			= 0, 
	kDNSBrowserStartDomainSearchValidFlags 	= kDNSBrowserFlagRegistrationDomainsOnly, 
	kDNSBrowserStopDomainSearchValidFlags 	= 0, 
	kDNSBrowserStartServiceSearchValidFlags = kDNSBrowserFlagAutoResolve, 
	kDNSBrowserStopServiceSearchValidFlags 	= 0, 
	kDNSResolverCreateValidFlags		 	= kDNSResolverFlagOneShot 			| 
											  kDNSResolverFlagOnlyIfUnique 		| 
											  kDNSResolverFlagAutoReleaseByName, 
	kDNSResolverReleaseValidFlags		 	= 0, 
	kDNSRegistrationCreateValidFlags	 	= 0, 
	kDNSRegistrationReleaseValidFlags	 	= 0, 
	kDNSDomainRegistrationCreateValidFlags	= 0, 
	kDNSDomainRegistrationReleaseValidFlags	= 0
};

#define	kDNSCountCacheEntryCountDefault		64

#if 0
#pragma mark == Structures ==
#endif

//===========================================================================================================================
//	Structures
//===========================================================================================================================

// Browser

typedef struct	DNSBrowser	DNSBrowser;
struct	DNSBrowser
{
	DNSBrowser *			next;
	DNSBrowserFlags			flags;
	DNSBrowserCallBack		callback;
	void *					callbackContext;
	mDNSBool				isDomainBrowsing;
	DNSQuestion				domainQuestion;
	DNSQuestion				defaultDomainQuestion;
	DNSBrowserFlags			domainSearchFlags;
	mDNSBool				isServiceBrowsing;
	DNSQuestion				serviceBrowseQuestion;
	DNSBrowserFlags			serviceSearchFlags;
	char					searchDomain[ 256 ];
	char					searchServiceType[ 256 ];
};

// Resolver

typedef struct	DNSResolver	DNSResolver;
struct	DNSResolver
{
	DNSResolver *			next;
	DNSResolverFlags		flags;
	DNSResolverCallBack		callback;
	void *					callbackContext;
	DNSBrowserRef			owner;
	ServiceInfoQuery		query;
	ServiceInfo				info;
	mDNSBool				isResolving;
	char					resolveName[ 256 ];
	char					resolveType[ 256 ];
	char					resolveDomain[ 256 ];
};

// Registration

typedef struct	DNSRegistration	DNSRegistration;
struct	DNSRegistration
{
	DNSRegistration *			next;
	DNSRegistrationFlags		flags;
	DNSRegistrationCallBack		callback;
	void *						callbackContext;
	ServiceRecordSet			set;
};

// Domain Registration

typedef struct	DNSDomainRegistration	DNSDomainRegistration;
struct	DNSDomainRegistration
{
	DNSDomainRegistration *			next;
	DNSDomainRegistrationFlags		flags;
	ResourceRecord					rr;
};

#if 0
#pragma mark == Macros ==
#endif

//===========================================================================================================================
//	Macros
//===========================================================================================================================

#define	DNS_UNUSED( X )		(void)( X )

// Emulate Mac OS debugging macros for non-Mac platforms.

#if( !TARGET_OS_MAC )
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
#endif

#if 0
#pragma mark == Prototypes ==
#endif

//===========================================================================================================================
//	Prototypes
//===========================================================================================================================

// General

mDNSlocal void	DNSServicesLock( void );
mDNSlocal void	DNSServicesUnlock( void );
mDNSlocal void	DNSServicesMDNSCallBack( mDNS *const inMDNS, mStatus inStatus );

// Browser

mDNSlocal void
	DNSBrowserPrivateCallBack( 
		mDNS * const 					inMDNS, 
		DNSQuestion *					inQuestion, 
		const ResourceRecord * const 	inAnswer );

mDNSlocal void
	DNSBrowserPrivateResolverCallBack( 
		void *						inContext, 
		DNSResolverRef 				inRef, 
		DNSStatus 					inStatusCode, 
		const DNSResolverEvent *	inEvent );

mDNSlocal DNSBrowserRef	DNSBrowserFindObject( DNSBrowserRef inRef );
mDNSlocal DNSBrowserRef	DNSBrowserRemoveObject( DNSBrowserRef inRef );

// Resolver

mDNSlocal void				DNSResolverPrivateCallBack( mDNS * const inMDNS, ServiceInfoQuery *inQuery );
mDNSlocal DNSResolverRef	DNSResolverFindObject( DNSResolverRef inRef );
mDNSlocal DNSResolverRef	DNSResolverRemoveObject( DNSResolverRef inRef );
mDNSlocal void				DNSResolverRemoveDependentByBrowser( DNSBrowserRef inBrowserRef );
mDNSlocal void				DNSResolverRemoveDependentByName( const domainname *inName );
mDNSlocal DNSResolverRef	DNSResolverFindObjectByName( const domainname *inName );

// Registration

mDNSlocal void
	DNSRegistrationPrivateCallBack( 
		mDNS * const 				inMDNS, 
		ServiceRecordSet * const 	inSet, 
		mStatus 					inResult );

mDNSlocal DNSRegistrationRef	DNSRegistrationRemoveObject( DNSRegistrationRef inRef );

// Domain Registration

mDNSlocal DNSDomainRegistrationRef	DNSDomainRegistrationRemoveObject( DNSDomainRegistrationRef inRef );

#if 0
#pragma mark == Globals ==
#endif

//===========================================================================================================================
//	Globals
//===========================================================================================================================

mDNSlocal mDNS *						gMDNSPtr 					= mDNSNULL;
mDNSlocal DNSBrowserRef					gDNSBrowserList				= mDNSNULL;
mDNSlocal DNSResolverRef				gDNSResolverList			= mDNSNULL;
mDNSlocal DNSRegistrationRef			gDNSRegistrationList		= mDNSNULL;
mDNSlocal DNSDomainRegistrationRef		gDNSDomainRegistrationList	= mDNSNULL;

#if 0
#pragma mark -
#pragma mark == General ==
#endif

//===========================================================================================================================
//	DNSServicesInitialize
//===========================================================================================================================

DNSStatus	DNSServicesInitialize( DNSFlags inFlags, DNSCount inCacheEntryCount )
{
	DNSStatus		err;
	
	require_action( ( inFlags & ~kDNSInitializeValidFlags ) == 0, exit, err = kDNSBadFlagsErr );
	
	if( inCacheEntryCount == 0 )
	{
		inCacheEntryCount = kDNSCountCacheEntryCountDefault;
	}
	err = DNSPlatformInitialize( inFlags, inCacheEntryCount, &gMDNSPtr );
	require_noerr( err, exit );
	
	gMDNSPtr->Callback = DNSServicesMDNSCallBack;
	
exit:
	return( err );
}

//===========================================================================================================================
//	DNSServicesFinalize
//===========================================================================================================================

void	DNSServicesFinalize( void )
{
	check( gMDNSPtr );
	if( gMDNSPtr )
	{
		DNSRegistrationRef		registrationRef;
		DNSBrowserRef			browserRef;
		DNSResolverRef			resolverRef;
		
		DNSPlatformLock();
		
		// Clean up any dangling registrations.
		
		while( gDNSRegistrationList )
		{
			registrationRef = gDNSRegistrationList;
			DNSRegistrationRelease( registrationRef, 0 );
			check_string( registrationRef != gDNSRegistrationList, "dangling registration cannot be cleaned up" );
		}
		
		// Clean up any dangling browsers.
		
		while( gDNSBrowserList )
		{
			browserRef = gDNSBrowserList;
			DNSBrowserRelease( browserRef, 0 );
			check_string( browserRef != gDNSBrowserList, "dangling browser cannot be cleaned up" );
		}
		
		// Clean up any dangling resolvers.
		
		while( gDNSResolverList )
		{
			resolverRef = gDNSResolverList;
			DNSResolverRelease( resolverRef, 0 );
			check_string( resolverRef != gDNSResolverList, "dangling resolver cannot be cleaned up" );
		}
		
		// Null out our MDNS ptr before releasing the lock so no other threads can sneak in and start operations.
		
		gMDNSPtr = mDNSNULL;
		DNSPlatformUnlock();
		
		// Tell the platform layer to clean up.
		
		DNSPlatformFinalize();
	}
}

//===========================================================================================================================
//	DNSServicesIdle
//===========================================================================================================================

void	DNSServicesIdle( void )
{
	check( gMDNSPtr );
	if( gMDNSPtr )
	{
		DNSPlatformIdle();
		mDNSCoreTask( gMDNSPtr );
	}
}

//===========================================================================================================================
//	DNSServicesLock
//===========================================================================================================================

mDNSlocal void	DNSServicesLock( void )
{
	if( gMDNSPtr )
	{
		DNSPlatformLock();
	}
}

//===========================================================================================================================
//	DNSServicesUnlock
//===========================================================================================================================

mDNSlocal void	DNSServicesUnlock( void )
{
	if( gMDNSPtr )
	{
		DNSPlatformUnlock();
	}
}

//===========================================================================================================================
//	DNSServicesMDNSCallBack
//===========================================================================================================================

mDNSlocal void	DNSServicesMDNSCallBack( mDNS *const inMDNS, mStatus inStatus )
{
	DNS_UNUSED( inMDNS );
	DNS_UNUSED( inStatus );
	check( inMDNS );
	
	debugf( DEBUG_NAME "MDNS callback (status=%ld)", inStatus );
}

#if 0
#pragma mark -
#pragma mark == Browser ==
#endif

//===========================================================================================================================
//	DNSBrowserCreate
//===========================================================================================================================

DNSStatus
	DNSBrowserCreate( 
		DNSBrowserFlags 	inFlags, 
		DNSBrowserCallBack	inCallBack, 
		void *				inCallBackContext, 
		DNSBrowserRef *		outRef )
{
	DNSStatus			err;
	DNSBrowser *		objectPtr;
	
	DNSServicesLock();
	require_action( gMDNSPtr, exit, err = kDNSNotInitializedErr );
	require_action( ( inFlags & ~kDNSBrowserCreateValidFlags ) == 0, exit, err = kDNSBadFlagsErr );
	require_action( inCallBack, exit, err = kDNSBadParamErr );
	
	// Allocate the object and set it up.
	
	err = DNSPlatformMemAlloc( sizeof( *objectPtr ), &objectPtr );
	require_noerr( err, exit );
	memset( objectPtr, 0, sizeof( *objectPtr ) );
	
	objectPtr->flags 			= inFlags;
	objectPtr->callback 		= inCallBack;
	objectPtr->callbackContext 	= inCallBackContext;
	
	// Add the object to the list.
	
	objectPtr->next = gDNSBrowserList;
	gDNSBrowserList = objectPtr;
	
	if( outRef )
	{
		*outRef = objectPtr;
	}
	
exit:
	DNSServicesUnlock();
	return( err );
}

//===========================================================================================================================
//	DNSBrowserRelease
//===========================================================================================================================

DNSStatus	DNSBrowserRelease( DNSBrowserRef inRef, DNSBrowserFlags inFlags )
{
	DNSStatus			err;
	DNSBrowserEvent		event;
	
	DNSServicesLock();
	require_action( gMDNSPtr, exit, err = kDNSNotInitializedErr );
	require_action( inRef, exit, err = kDNSBadReferenceErr );
	require_action( ( inFlags & ~kDNSBrowserReleaseValidFlags ) == 0, exit, err = kDNSBadFlagsErr );
	
	// Stop service and domain browsing and remove any resolvers dependent on this browser.
	
	DNSBrowserStopDomainSearch( inRef, 0 );
	DNSBrowserStopServiceSearch( inRef, 0 );	
	DNSResolverRemoveDependentByBrowser( inRef );
	
	// Remove the object from the list.
	
	inRef = DNSBrowserRemoveObject( inRef );
	require_action( inRef, exit, err = kDNSBadReferenceErr );
	
	// Call the callback with a release event.
	
	check( inRef->callback );
	memset( &event, 0, sizeof( event ) );
	event.type = kDNSBrowserEventTypeRelease;
	inRef->callback( inRef->callbackContext, inRef, kDNSNoErr, &event );
	
	// Release the memory used by the object.
	
	DNSPlatformMemFree( inRef );
	err = kDNSNoErr;
	
exit:
	DNSServicesUnlock();
	return( err );
}

//===========================================================================================================================
//	DNSBrowserStartDomainSearch
//===========================================================================================================================

DNSStatus	DNSBrowserStartDomainSearch( DNSBrowserRef inRef, DNSBrowserFlags inFlags )
{
	DNSStatus			err;
	mDNS_DomainType		type;
	mDNS_DomainType		defaultType;
	DNSBrowserEvent		event;
	mDNSBool			isDomainBrowsing;
	
	isDomainBrowsing = mDNSfalse;
	
	DNSServicesLock();
	require_action( gMDNSPtr, exit, err = kDNSNotInitializedErr );
	require_action( inRef && DNSBrowserFindObject( inRef ), exit, err = kDNSBadReferenceErr );
	require_action( ( inFlags & ~kDNSBrowserStartDomainSearchValidFlags ) == 0, exit, err = kDNSBadFlagsErr );
	require_action( !inRef->isDomainBrowsing, exit, err = kDNSBadStateErr );
		
	// Determine whether to browse for normal domains or registration domains.
	
	if( inFlags & kDNSBrowserFlagRegistrationDomainsOnly )
	{
		type 		= mDNS_DomainTypeRegistration;
		defaultType	= mDNS_DomainTypeRegistrationDefault;
	}
	else
	{
		type 		= mDNS_DomainTypeBrowse;
		defaultType	= mDNS_DomainTypeBrowseDefault;
	}
	
	// Start the browse operations.
	
	err = mDNS_GetDomains( gMDNSPtr, &inRef->domainQuestion, type, zeroIPAddr, DNSBrowserPrivateCallBack, inRef );
	require_noerr( err, exit );
	isDomainBrowsing = mDNStrue;
	
	err = mDNS_GetDomains( gMDNSPtr, &inRef->defaultDomainQuestion, defaultType, zeroIPAddr, DNSBrowserPrivateCallBack, inRef );
	require_noerr( err, exit );
	
	inRef->domainSearchFlags 	= inFlags;
	inRef->isDomainBrowsing 	= mDNStrue;
	
	// Call back immediately with "local." since that is always available for all types of browsing.
	
	memset( &event, 0, sizeof( event ) );
	event.type							= kDNSBrowserEventTypeAddDefaultDomain;
	event.data.addDefaultDomain.domain 	= kDNSLocalDomain;
	event.data.addDefaultDomain.flags 	= 0;
	inRef->callback( inRef->callbackContext, inRef, kDNSNoErr, &event );
	
exit:
	if( err && isDomainBrowsing )
	{
		mDNS_StopGetDomains( gMDNSPtr, &inRef->domainQuestion );
	}
	DNSServicesUnlock();
	return( err );
}

//===========================================================================================================================
//	DNSBrowserStopDomainSearch
//===========================================================================================================================

DNSStatus	DNSBrowserStopDomainSearch( DNSBrowserRef inRef, DNSBrowserFlags inFlags )
{
	DNSStatus		err;
	
	DNSServicesLock();
	require_action( gMDNSPtr, exit, err = kDNSNotInitializedErr );
	require_action( inRef && DNSBrowserFindObject( inRef ), exit, err = kDNSBadReferenceErr );
	require_action( ( inFlags & ~kDNSBrowserStopDomainSearchValidFlags ) == 0, exit, err = kDNSBadFlagsErr );
	require_action( inRef->isDomainBrowsing, exit, err = kDNSBadStateErr );
	
	// Stop the browse operations.
	
	mDNS_StopGetDomains( gMDNSPtr, &inRef->defaultDomainQuestion );
	mDNS_StopGetDomains( gMDNSPtr, &inRef->domainQuestion );
	inRef->isDomainBrowsing = mDNSfalse;
	err = kDNSNoErr;
	
exit:
	DNSServicesUnlock();
	return( err );
}

//===========================================================================================================================
//	DNSBrowserStartServiceSearch
//===========================================================================================================================

DNSStatus
	DNSBrowserStartServiceSearch( 
		DNSBrowserRef 		inRef, 
		DNSBrowserFlags 	inFlags, 
		const char * 		inType, 
		const char *		inDomain )
{
	DNSStatus		err;
	domainname		type;
	domainname		domain;
	
	DNSServicesLock();
	require_action( gMDNSPtr, exit, err = kDNSNotInitializedErr );
	require_action( inRef && DNSBrowserFindObject( inRef ), exit, err = kDNSBadReferenceErr );
	require_action( ( inFlags & ~kDNSBrowserStartServiceSearchValidFlags ) == 0, exit, err = kDNSBadFlagsErr );
	require_action( !inRef->isServiceBrowsing, exit, err = kDNSBadStateErr );
	require_action( inType, exit, err = kDNSBadParamErr );
	
	// Default to the local domain when null is passed in.
	
	if( !inDomain || ( inDomain[ 0 ] == '\0' ) || ( inDomain[ 0 ] == '.' ) )
	{
		inDomain = kDNSLocalDomain;
	}
	
	// Save off the search criteria (in case it needs to be automatically restarted later).
	
	inRef->serviceSearchFlags = inFlags;
	
	strncpy( inRef->searchServiceType, inType, sizeof( inRef->searchServiceType ) - 1 );
	inRef->searchServiceType[ sizeof( inRef->searchServiceType ) - 1 ] = '\0';
	
	strncpy( inRef->searchDomain, inDomain, sizeof( inRef->searchDomain ) - 1 );
	inRef->searchDomain[ sizeof( inRef->searchDomain ) - 1 ] = '\0';
	
	// Start the browse operation with mDNS using our private callback.
	
	ConvertCStringToDomainName( inType, &type );
	ConvertCStringToDomainName( inDomain, &domain );
	
	err = mDNS_StartBrowse( gMDNSPtr, &inRef->serviceBrowseQuestion, &type, &domain, zeroIPAddr, 
							DNSBrowserPrivateCallBack, inRef );
	require_noerr( err, exit );
	
	inRef->isServiceBrowsing = mDNStrue;
	
exit:
	DNSServicesUnlock();
	return( err );
}

//===========================================================================================================================
//	DNSBrowserStopServiceSearch
//===========================================================================================================================

DNSStatus	DNSBrowserStopServiceSearch( DNSBrowserRef inRef, DNSBrowserFlags inFlags )
{
	DNSStatus		err;
	
	DNSServicesLock();
	require_action( gMDNSPtr, exit, err = kDNSNotInitializedErr );
	require_action( inRef && DNSBrowserFindObject( inRef ), exit, err = kDNSBadReferenceErr );
	require_action( ( inFlags & ~kDNSBrowserStopServiceSearchValidFlags ) == 0, exit, err = kDNSBadFlagsErr );
	require_action( inRef->isServiceBrowsing, exit, err = kDNSBadStateErr );
	
	// Stop the browse operation with mDNS. Remove any resolvers dependent on browser since we are no longer searching.
	
	mDNS_StopBrowse( gMDNSPtr, &inRef->serviceBrowseQuestion );
	DNSResolverRemoveDependentByBrowser( inRef );
	inRef->isServiceBrowsing = mDNSfalse;
	err = kDNSNoErr;
	
exit:
	DNSServicesUnlock();
	return( err );
}

//===========================================================================================================================
//	DNSBrowserPrivateCallBack
//===========================================================================================================================

mDNSlocal void
	DNSBrowserPrivateCallBack( 
		mDNS * const 					inMDNS, 
		DNSQuestion *					inQuestion, 
		const ResourceRecord * const 	inAnswer )
{
	DNSBrowserRef		objectPtr;
	domainlabel			name;
	domainname			type;
	domainname			domain;
	char				nameString[ 256 ];
	char				typeString[ 256 ];
	char				domainString[ 256 ];
	DNSBrowserEvent		event;
	
	DNS_UNUSED( inMDNS );
	check( inMDNS );
	check( inQuestion );
	check( inAnswer );
	
	DNSServicesLock();
	
	// Exclude non-PTR answers.
	
	require( inAnswer->rrtype == kDNSType_PTR, exit );
	
	// Exit if object is no longer valid. Should never happen.
	
	objectPtr = DNSBrowserFindObject( (DNSBrowserRef) inQuestion->Context );
	require( objectPtr, exit );
	
	// Determine what type of callback it is based on the question.
	
	memset( &event, 0, sizeof( event ) );
	if( inQuestion == &objectPtr->serviceBrowseQuestion )
	{
		DNSBrowserEventServiceData *		serviceDataPtr;
		DNSBrowserFlags						browserFlags;
		
		// Extract name, type, and domain from the resource record.
	
		DeconstructServiceName( &inAnswer->rdata->u.name, &name, &type, &domain );
		ConvertDomainLabelToCString_unescaped( &name, nameString );
		ConvertDomainNameToCString( &type, typeString );
		ConvertDomainNameToCString( &domain, domainString );
		
		// Fill in the event data. A TTL of zero means the service is no longer available. If the service instance is going
		// away (ttl == 0), remove any resolvers dependent on the name since it is no longer valid.
		
		if( inAnswer->rrremainingttl == 0 )
		{
			DNSResolverRemoveDependentByName( &inAnswer->rdata->u.name );
			
			event.type		= kDNSBrowserEventTypeRemoveService;
			serviceDataPtr 	= &event.data.removeService;
		}
		else
		{
			event.type 		= kDNSBrowserEventTypeAddService;
			serviceDataPtr 	= &event.data.addService;
		}
		serviceDataPtr->interfaceAddr.addressType		= kDNSNetworkAddressTypeIPv4;
		serviceDataPtr->interfaceAddr.u.ipv4.address 	= (DNSUInt32)
														  ( inAnswer->InterfaceAddr.b[ 0 ] << 24 ) | 
														  ( inAnswer->InterfaceAddr.b[ 1 ] << 16 ) | 
														  ( inAnswer->InterfaceAddr.b[ 2 ] <<  8 ) | 
														  ( inAnswer->InterfaceAddr.b[ 3 ] <<  0 );
		serviceDataPtr->name							= nameString;
		serviceDataPtr->type 							= typeString;
		serviceDataPtr->domain 							= domainString;
		serviceDataPtr->flags 							= 0;
		
		// Call the callback.
		
		browserFlags = objectPtr->serviceSearchFlags;
		objectPtr->callback( objectPtr->callbackContext, objectPtr, kDNSNoErr, &event );
		
		// Automatically resolve newly discovered names if the auto-resolve option is enabled.
		
		if( ( browserFlags & kDNSBrowserFlagAutoResolve ) && ( inAnswer->rrremainingttl != 0 ) )
		{
			DNSStatus				err;
			DNSResolverFlags		flags;
			
			flags = kDNSResolverFlagOnlyIfUnique | kDNSResolverFlagAutoReleaseByName;
			err = DNSResolverCreate( flags, nameString, typeString, domainString, DNSBrowserPrivateResolverCallBack, 
									 mDNSNULL, objectPtr, mDNSNULL );
			check_noerr( err );
		}
	}
	else
	{
		DNSBrowserEventDomainData *		domainDataPtr;
		
		// Determine the event type. A TTL of zero means the domain is no longer available.
		
		domainDataPtr = mDNSNULL;
		if( inQuestion == &objectPtr->domainQuestion )
		{
			if( inAnswer->rrremainingttl == 0 )
			{
				event.type = kDNSBrowserEventTypeRemoveDomain;
				domainDataPtr = &event.data.removeDomain;
			}
			else
			{
				event.type = kDNSBrowserEventTypeAddDomain;
				domainDataPtr = &event.data.addDomain;
			}
		}
		else if( inQuestion == &objectPtr->defaultDomainQuestion )
		{
			if( inAnswer->rrremainingttl == 0 )
			{
				event.type = kDNSBrowserEventTypeRemoveDomain;
				domainDataPtr = &event.data.removeDomain;
			}
			else
			{
				event.type = kDNSBrowserEventTypeAddDefaultDomain;
				domainDataPtr = &event.data.addDefaultDomain;
			}
		}
		require_string( domainDataPtr, exit, "domain response for unknown question" );
		
		// Extract domain name from the resource record and fill in the event data.
		
		ConvertDomainNameToCString( &inAnswer->rdata->u.name, domainString );
		domainDataPtr->interfaceAddr.addressType	= kDNSNetworkAddressTypeIPv4;
		domainDataPtr->interfaceAddr.u.ipv4.address = (DNSUInt32)
													  ( inAnswer->InterfaceAddr.b[ 0 ] << 24 ) | 
													  ( inAnswer->InterfaceAddr.b[ 1 ] << 16 ) | 
													  ( inAnswer->InterfaceAddr.b[ 2 ] <<  8 ) | 
													  ( inAnswer->InterfaceAddr.b[ 3 ] <<  0 );
		domainDataPtr->domain 						= domainString;
		domainDataPtr->flags						= 0;
		
		// Call the callback.
		
		objectPtr->callback( objectPtr->callbackContext, objectPtr, kDNSNoErr, &event );
	}

exit:
	DNSServicesUnlock();
}

//===========================================================================================================================
//	DNSBrowserPrivateResolverCallBack
//===========================================================================================================================

mDNSlocal void
	DNSBrowserPrivateResolverCallBack( 
		void *						inContext, 
		DNSResolverRef 				inRef, 
		DNSStatus 					inStatusCode, 
		const DNSResolverEvent *	inEvent )
{
	DNSBrowserRef		objectPtr;
	DNSBrowserEvent		event;
	
	DNS_UNUSED( inContext );
	DNS_UNUSED( inStatusCode );
	
	DNSServicesLock();
	
	// Exit if object is no longer valid. Should never happen.
	
	objectPtr = inRef->owner;
	require( objectPtr, exit );
	
	switch( inEvent->type )
	{
		case kDNSResolverEventTypeResolved:
			verbosedebugf( DEBUG_NAME "private resolver callback: resolved (ref=0x%08X)", inRef );
			verbosedebugf( DEBUG_NAME "    name:   \"%s\"", 	inEvent->data.resolved.name );
			verbosedebugf( DEBUG_NAME "    type:   \"%s\"", 	inEvent->data.resolved.type );
			verbosedebugf( DEBUG_NAME "    domain: \"%s\"", 	inEvent->data.resolved.domain );
			verbosedebugf( DEBUG_NAME "    if:     %.4a", 		&inEvent->data.resolved.interfaceAddr.u.ipv4.address );
			verbosedebugf( DEBUG_NAME "    ip:     %.4a:%u", 	&inEvent->data.resolved.address.u.ipv4.address, 
															 	inEvent->data.resolved.address.u.ipv4.port );
			verbosedebugf( DEBUG_NAME "    text:   \"%s\"", 	inEvent->data.resolved.textRecord );
			
			// Re-package the resolver event as a browser event and call the callback.
			
			memset( &event, 0, sizeof( event ) );
			event.type = kDNSBrowserEventTypeResolved;
			event.data.resolved = &inEvent->data.resolved;
			
			objectPtr->callback( objectPtr->callbackContext, objectPtr, kDNSNoErr, &event );
			break;
		
		case kDNSResolverEventTypeRelease:
			verbosedebugf( DEBUG_NAME "private resolver callback: release (ref=0x%08X)", inRef );
			break;
		
		default:
			verbosedebugf( DEBUG_NAME "private resolver callback: unknown event (ref=0x%08X, event=%ld)", inRef, inEvent->type );
			break;
	}

exit:
	DNSServicesUnlock();
}

//===========================================================================================================================
//	DNSBrowserFindObject
//
//	Warning: Assumes the DNS lock is held.
//===========================================================================================================================

mDNSlocal DNSBrowserRef	DNSBrowserFindObject( DNSBrowserRef inRef )
{
	DNSBrowser *		p;
	
	check( inRef );
		
	// Find the object in the list.
	
	for( p = gDNSBrowserList; p; p = p->next )
	{
		if( p == inRef )
		{
			break;
		}
	}
	return( p );
}

//===========================================================================================================================
//	DNSBrowserRemoveObject
//
//	Warning: Assumes the DNS lock is held.
//===========================================================================================================================

mDNSlocal DNSBrowserRef	DNSBrowserRemoveObject( DNSBrowserRef inRef )
{
	DNSBrowser **		p;
	DNSBrowser *		found;
	
	for( p = &gDNSBrowserList; *p; p = &( *p )->next )
	{
		if( *p == inRef )
		{
			break;
		}
	}
	found = *p;
	if( found )
	{
		*p = found->next;
	}
	return( found );
}

#if 0
#pragma mark -
#pragma mark == Resolver ==
#endif

//===========================================================================================================================
//	DNSResolverCreate
//===========================================================================================================================

DNSStatus
	DNSResolverCreate( 
		DNSResolverFlags		inFlags, 
		const char *			inName, 
		const char *			inType, 
		const char *			inDomain, 
		DNSResolverCallBack		inCallBack, 
		void *					inCallBackContext, 
		DNSBrowserRef			inOwner, 
		DNSResolverRef *		outRef )
{	
	DNSStatus			err;
	int					isAutoRelease;
	DNSResolver *		objectPtr;
	domainlabel			name;
	domainname			type;
	domainname			domain;
	domainname			fullName;
	
	objectPtr = mDNSNULL;
	
	// Check parameters.
	
	DNSServicesLock();
	require_action( gMDNSPtr, exit, err = kDNSNotInitializedErr );
	require_action( ( inFlags & ~kDNSResolverCreateValidFlags ) == 0, exit, err = kDNSBadFlagsErr );
	require_action( inName, exit, err = kDNSBadParamErr );
	require_action( inType, exit, err = kDNSBadParamErr );
	require_action( inDomain, exit, err = kDNSBadParamErr );
	require_action( inCallBack, exit, err = kDNSBadParamErr );
	isAutoRelease = inOwner || ( inFlags & ( kDNSResolverFlagOneShot | kDNSResolverFlagAutoReleaseByName ) );
	require_action( outRef || isAutoRelease, exit, err = kDNSBadParamErr );
	require_action( !inOwner || DNSBrowserFindObject( inOwner ), exit, err = kDNSBadReferenceErr );
	
	// Convert and package up the name, type, and domain into a single fully-qualified domain name to resolve.
	
	ConvertCStringToDomainLabel( inName, &name );
	ConvertCStringToDomainName( inType, &type );
	ConvertCStringToDomainName( inDomain, &domain );
	ConstructServiceName( &fullName, &name, &type, &domain );
	
	// If the caller only wants to add unique resolvers, check if a resolver for this name is already present.
	
	if( inFlags & kDNSResolverFlagOnlyIfUnique )
	{
		if( DNSResolverFindObjectByName( &fullName ) )
		{
			if( outRef )
			{
				*outRef = mDNSNULL;
			}
			err = kDNSNoErr;
			goto exit;
		}
	}
	
	// Allocate the object and set it up.
	
	err = DNSPlatformMemAlloc( sizeof( *objectPtr ), &objectPtr );
	require_noerr( err, exit );
	memset( objectPtr, 0, sizeof( *objectPtr ) );
	
	objectPtr->flags 				= inFlags;
	objectPtr->callback 			= inCallBack;
	objectPtr->callbackContext 		= inCallBackContext;
	objectPtr->owner				= inOwner;
	objectPtr->info.name			= fullName;
	objectPtr->info.InterfaceAddr 	= zeroIPAddr;
	
	// Save off the resolve info so the callback can get it.
	
	strncpy( objectPtr->resolveName, inName, sizeof( objectPtr->resolveName ) - 1 );
	objectPtr->resolveName[ sizeof( objectPtr->resolveName ) - 1 ] = '\0';
	
	strncpy( objectPtr->resolveType, inType, sizeof( objectPtr->resolveType ) - 1 );
	objectPtr->resolveType[ sizeof( objectPtr->resolveType ) - 1 ] = '\0';
	
	strncpy( objectPtr->resolveDomain, inDomain, sizeof( objectPtr->resolveDomain ) - 1 );
	objectPtr->resolveDomain[ sizeof( objectPtr->resolveDomain ) - 1 ] = '\0';
	
	// Add the object to the list.
	
	objectPtr->next = gDNSResolverList;
	gDNSResolverList = objectPtr;
	
	// Start the resolving process.
	
	objectPtr->isResolving = mDNStrue;
	err = mDNS_StartResolveService( gMDNSPtr, &objectPtr->query, &objectPtr->info, DNSResolverPrivateCallBack, objectPtr );
	require_noerr( err, exit );
	
	if( outRef )
	{
		*outRef = objectPtr;
	}
	
exit:
	if( err && objectPtr )
	{
		DNSResolverRemoveObject( objectPtr );
		DNSPlatformMemFree( objectPtr );
	}
	DNSServicesUnlock();
	return( err );
}

//===========================================================================================================================
//	DNSResolverRelease
//===========================================================================================================================

DNSStatus	DNSResolverRelease( DNSResolverRef inRef, DNSResolverFlags inFlags )
{
	DNSStatus				err;
	DNSResolverEvent		event;
	
	DNSServicesLock();
	require_action( gMDNSPtr, exit, err = kDNSNotInitializedErr );
	require_action( ( inFlags & ~kDNSResolverReleaseValidFlags ) == 0, exit, err = kDNSBadFlagsErr );
	
	// Remove the object from the list.
	
	inRef = DNSResolverRemoveObject( inRef );
	require_action( inRef, exit, err = kDNSBadReferenceErr );
	
	// Stop the resolving process.
	
	if( inRef->isResolving )
	{
		inRef->isResolving = mDNSfalse;
		mDNS_StopResolveService( gMDNSPtr, &inRef->query );
	}
	
	// Call the callback with a release event.
	
	check( inRef->callback );
	memset( &event, 0, sizeof( event ) );
	event.type = kDNSResolverEventTypeRelease;
	inRef->callback( inRef->callbackContext, inRef, kDNSNoErr, &event );
	
	// Release the memory used by the object.
	
	DNSPlatformMemFree( inRef );
	err = kDNSNoErr;
	
exit:
	DNSServicesUnlock();
	return( err );
}

//===========================================================================================================================
//	DNSResolverFindObject
//
//	Warning: Assumes the DNS lock is held.
//===========================================================================================================================

mDNSlocal DNSResolverRef	DNSResolverFindObject( DNSResolverRef inRef )
{
	DNSResolver *		p;
	
	check( inRef );
		
	// Find the object in the list.
	
	for( p = gDNSResolverList; p; p = p->next )
	{
		if( p == inRef )
		{
			break;
		}
	}
	return( p );
}
//===========================================================================================================================
//	DNSResolverFindObjectByName
//
//	Warning: Assumes the DNS lock is held.
//===========================================================================================================================

mDNSlocal DNSResolverRef	DNSResolverFindObjectByName( const domainname *inName )
{
	DNSResolver *		p;
	
	check( inName );
	
	for( p = gDNSResolverList; p; p = p->next )
	{
		if( SameDomainName( &p->info.name, inName ) )
		{
			break;
		}
	}
	return( p );
}

//===========================================================================================================================
//	DNSResolverPrivateCallBack
//===========================================================================================================================

mDNSlocal void	DNSResolverPrivateCallBack( mDNS * const inMDNS, ServiceInfoQuery *inQuery )
{
	DNSResolverRef			objectPtr;
	DNSResolverEvent		event;
	char					s[ 256 ];
	const mDNSu8 *			p;
	size_t					n;
	
	DNS_UNUSED( inMDNS );
	
	DNSServicesLock();
	
	// Exit if object is no longer valid. Should never happen.
	
	objectPtr = DNSResolverFindObject( (DNSResolverRef) inQuery->Context );
	require( objectPtr, exit );
	
	// Copy the sized buffer of text to a local null terminated string. Older versions of Rendezvous treated the TXT 
	// record as a raw chunk of text rather than a packed array of length-prefixed strings so check if the total size
	// of the TXT record is exactly 1 more than the length-prefix byte and if so, assume it is an old-style record.
	// Old-style TXT records will never be larger than 255 bytes so assume a new-style if it is larger than that too.
	
	p = inQuery->info->TXTinfo;
	n = inQuery->info->TXTlen;
	if( n > 0 )
	{
		if( ( n > 255 ) || ( n == (size_t)( inQuery->info->TXTinfo[ 0 ] + 1 ) ) )
		{
			++p;
			--n;
		}
	}
	check( n < sizeof( s ) );
	n = ( n < sizeof( s ) ) ? n : ( sizeof( s ) - 1 );
	memcpy( s, p, n );
	s[ n ] = '\0';
	
	// Package up the results and call the callback.
	
	memset( &event, 0, sizeof( event ) );
	event.type 											= kDNSResolverEventTypeResolved;
	event.data.resolved.name							= objectPtr->resolveName;
	event.data.resolved.type							= objectPtr->resolveType;
	event.data.resolved.domain							= objectPtr->resolveDomain;
	event.data.resolved.interfaceAddr.addressType		= kDNSNetworkAddressTypeIPv4;
	event.data.resolved.interfaceAddr.u.ipv4.address 	= (DNSUInt32)
														  ( inQuery->info->InterfaceAddr.b[ 0 ] << 24 ) | 
														  ( inQuery->info->InterfaceAddr.b[ 1 ] << 16 ) | 
														  ( inQuery->info->InterfaceAddr.b[ 2 ] <<  8 ) | 
														  ( inQuery->info->InterfaceAddr.b[ 3 ] <<  0 );
	event.data.resolved.address.addressType				= kDNSNetworkAddressTypeIPv4;
	event.data.resolved.address.u.ipv4.address 			= (DNSUInt32)
														  ( inQuery->info->ip.b[ 0 ] << 24 ) | 
														  ( inQuery->info->ip.b[ 1 ] << 16 ) | 
														  ( inQuery->info->ip.b[ 2 ] <<  8 ) | 
														  ( inQuery->info->ip.b[ 3 ] <<  0 );
	event.data.resolved.address.u.ipv4.port				= (DNSUInt16)
														  ( ( inQuery->info->port.b[ 0 ] << 8 ) | 
															( inQuery->info->port.b[ 1 ] << 0 ) );
	event.data.resolved.address.u.ipv4.pad				= 0;
	event.data.resolved.textRecord						= s;
	event.data.resolved.flags 							= 0;
	objectPtr->callback( objectPtr->callbackContext, objectPtr, kDNSNoErr, &event );
	
	// Auto-release the object if needed.
	
	if( objectPtr->flags & kDNSResolverFlagOneShot )
	{
		DNSResolverRelease( objectPtr, 0 );
	}

exit:
	DNSServicesUnlock();
}

//===========================================================================================================================
//	DNSResolverRemoveObject
//
//	Warning: Assumes the DNS lock is held.
//===========================================================================================================================

mDNSlocal DNSResolverRef	DNSResolverRemoveObject( DNSResolverRef inRef )
{
	DNSResolver **		p;
	DNSResolver *		found;
	
	for( p = &gDNSResolverList; *p; p = &( *p )->next )
	{
		if( *p == inRef )
		{
			break;
		}
	}
	found = *p;
	if( found )
	{
		*p = found->next;
	}
	return( found );
}

//===========================================================================================================================
//	DNSResolverRemoveDependentByBrowser
//
//	Warning: Assumes the DNS lock is held.
//===========================================================================================================================

mDNSlocal void	DNSResolverRemoveDependentByBrowser( DNSBrowserRef inBrowserRef )
{
	DNSResolver *		p;
		
	check( inBrowserRef );
			
	// Removes all the resolver objects dependent on the specified browser. Restart the search from the beginning of the 
	// list after each removal to handle the list changing in possible callbacks that may be invoked.
	
	do
	{
		for( p = gDNSResolverList; p; p = p->next )
		{
			if( p->owner == inBrowserRef )
			{
				DNSResolverRelease( p, 0 );
				break;
			}
		}
		
	}	while( p );
}

//===========================================================================================================================
//	DNSResolverRemoveDependentByName
//
//	Warning: Assumes the DNS lock is held.
//===========================================================================================================================

mDNSlocal void	DNSResolverRemoveDependentByName( const domainname *inName )
{
	DNSResolver *		p;
		
	check( inName );
		
	// Removes all the resolver objects dependent on the specified name that want to be auto-released by name. Restart 
	// the search from the beginning of the list after each removal to handle the list changing in possible callbacks 
	// that may be invoked.
	
	do
	{
		for( p = gDNSResolverList; p; p = p->next )
		{
			if( ( p->flags & kDNSResolverFlagAutoReleaseByName ) && SameDomainName( &p->info.name, inName ) )
			{
				DNSResolverRelease( p, 0 );
				break;
			}
		}
		
	}	while( p );
}

#if 0
#pragma mark -
#pragma mark == Registration ==
#endif

//===========================================================================================================================
//	DNSRegistrationCreate
//===========================================================================================================================

DNSStatus
	DNSRegistrationCreate( 
		DNSRegistrationFlags	inFlags, 
		const char *			inName, 
		const char *			inType, 
		const char *			inDomain, 
		DNSPort					inPort, 
		const char *			inTextRecord, 
		DNSRegistrationCallBack	inCallBack, 
		void *					inCallBackContext, 
		DNSRegistrationRef *	outRef )
{	
	DNSStatus				err;
	DNSRegistration *		objectPtr;
	domainlabel				name;
	domainname				type;
	domainname				domain;
	mDNSIPPort				port;
	mDNSu8					text[ 256 ];
	mDNSu8 *				textPtr;
	mDNSu16					textSize;
	
	objectPtr = mDNSNULL;
	
	// Check parameters.
	
	DNSServicesLock();
	require_action( gMDNSPtr, exit, err = kDNSNotInitializedErr );
	require_action( ( inFlags & ~kDNSRegistrationCreateValidFlags ) == 0, exit, err = kDNSBadFlagsErr );
	require_action( inName, exit, err = kDNSBadParamErr );
	require_action( inType, exit, err = kDNSBadParamErr );
	require_action( inCallBack, exit, err = kDNSBadParamErr );
		
	// Default to the local domain when null is passed in.
	
	if( !inDomain )
	{
		inDomain = kDNSLocalDomain;
	}
	
	// Convert the input text record null-terminated string to a length-prefixed string.

	textPtr	 = mDNSNULL;
	textSize = 0;
	if( inTextRecord )
	{
		mDNSu8 *		p;
		
		text[ 0 ] = 0;
		p = text;
		while( *inTextRecord != '\0' )
		{
			++textSize;
			require_action( textSize < sizeof( text ), exit, err = kDNSBadParamErr );
			require_action( p[ 0 ] < 255, exit, err = kDNSBadParamErr );
			
			p[ ++p[ 0 ] ] = *inTextRecord++;
		}
		++textSize;
	}
	
	// Allocate the object and set it up.
	
	err = DNSPlatformMemAlloc( sizeof( *objectPtr ), &objectPtr );
	require_noerr( err, exit );
	memset( objectPtr, 0, sizeof( *objectPtr ) );
	
	objectPtr->flags 			= inFlags;
	objectPtr->callback 		= inCallBack;
	objectPtr->callbackContext 	= inCallBackContext;
	
	// Add the object to the list.
	
	objectPtr->next = gDNSRegistrationList;
	gDNSRegistrationList = objectPtr;
	
	// Convert the name, type, domain, and port for mDNS.
	
	ConvertCStringToDomainLabel( inName, &name );
	ConvertCStringToDomainName( inType, &type );
	ConvertCStringToDomainName( inDomain, &domain );
	port.b[ 0 ] = ( mDNSu8 )( inPort >> 8 );
	port.b[ 1 ] = ( mDNSu8 )( inPort >> 0 );
		
	// Register the service with mDNS.
	
	err = mDNS_RegisterService( gMDNSPtr, &objectPtr->set, &name, &type, &domain, mDNSNULL, port, 
								text, textSize, DNSRegistrationPrivateCallBack, objectPtr );
	require_noerr( err, exit );
	
	if( outRef )
	{
		*outRef = objectPtr;
	}
	
exit:
	if( err && objectPtr )
	{
		DNSRegistrationRemoveObject( objectPtr );
		DNSPlatformMemFree( objectPtr );
	}
	DNSServicesUnlock();
	return( err );
}

//===========================================================================================================================
//	DNSRegistrationRelease
//===========================================================================================================================

DNSStatus	DNSRegistrationRelease( DNSRegistrationRef inRef, DNSRegistrationFlags inFlags )
{
	DNSStatus					err;
	DNSRegistrationEvent		event;
	
	DNSServicesLock();
	require_action( gMDNSPtr, exit, err = kDNSNotInitializedErr );
	require_action( inRef, exit, err = kDNSBadReferenceErr );
	require_action( ( inFlags & ~kDNSRegistrationReleaseValidFlags ) == 0, exit, err = kDNSBadFlagsErr );
	
	// Notify the client of the registration release. Remove the object first so they cannot try to use it in the callback.
	
	inRef = DNSRegistrationRemoveObject( inRef );
	require_action( inRef, exit, err = kDNSBadReferenceErr );
		
	memset( &event, 0, sizeof( event ) );
	event.type = kDNSRegistrationEventTypeRelease;
	check( inRef->callback );
	inRef->callback( inRef->callbackContext, inRef, kDNSNoErr, &event );
	
	// Deregister from mDNS after everything else since it will call us back to free the memory.
	
	mDNS_DeregisterService( gMDNSPtr, &inRef->set );
	err = kDNSNoErr;
	
	// Note: Don't free here. Wait for mDNS to call us back with a mem free result.
	
exit:
	DNSServicesUnlock();
	return( err );
}

//===========================================================================================================================
//	DNSRegistrationPrivateCallBack
//===========================================================================================================================

mDNSlocal void	DNSRegistrationPrivateCallBack( mDNS * const inMDNS, ServiceRecordSet * const inSet, mStatus inResult )
{	
	DNSRegistrationRef			object;
	DNSRegistrationEvent		event;
	
	DNS_UNUSED( inMDNS );
	
	DNSServicesLock();
	
	// Exit if object is no longer valid. Should never happen.
	
	object = (DNSRegistrationRef) inSet->Context;
	require( object, exit );
	
	// Dispatch based on the status code.
	
	switch( inResult )
	{
		case mStatus_NoError:
			debugf( DEBUG_NAME "registration callback: \"%##s\" name successfully registered", inSet->RR_SRV.name.c );
			
			// Notify the client of a successful registration.
			
			memset( &event, 0, sizeof( event ) );
			event.type = kDNSRegistrationEventTypeRegistered;
			check( object->callback );
			object->callback( object->callbackContext, object, kDNSNoErr, &event );			
			break;
		
		case mStatus_NameConflict:
			debugf( DEBUG_NAME "registration callback: \"%##s\" name conflict", inSet->RR_SRV.name.c );
			
			// Notify the client of the name conflict. Remove the object first so they cannot try to use it in the callback.
			
			object = DNSRegistrationRemoveObject( object );
			require( object, exit );
		
			memset( &event, 0, sizeof( event ) );
			event.type = kDNSRegistrationEventTypeNameCollision;
			check( object->callback );
			object->callback( object->callbackContext, object, kDNSNoErr, &event );
			
			// Notify the client that the registration is being released.
			
			memset( &event, 0, sizeof( event ) );
			event.type = kDNSRegistrationEventTypeRelease;
			check( object->callback );
			object->callback( object->callbackContext, object, kDNSNoErr, &event );
			
			// When a name conflict occurs, mDNS will not send a separate mem free result so free the memory here.
			
			DNSPlatformMemFree( object );
			break;
		
		case mStatus_MemFree:
			debugf( DEBUG_NAME "registration callback: \"%##s\" memory free", inSet->RR_SRV.name.c );
			
			DNSPlatformMemFree( object );
			break;
		
		default:
			debugf( DEBUG_NAME "registration callback: \"%##s\" unknown result %d", inSet->RR_SRV.name.c, inResult );
			break;
	}

exit:
	DNSServicesUnlock();
}

//===========================================================================================================================
//	DNSRegistrationRemoveObject
//
//	Warning: Assumes the DNS lock is held.
//===========================================================================================================================

mDNSlocal DNSRegistrationRef	DNSRegistrationRemoveObject( DNSRegistrationRef inRef )
{
	DNSRegistration **		p;
	DNSRegistration *		found;
	
	for( p = &gDNSRegistrationList; *p; p = &( *p )->next )
	{
		if( *p == inRef )
		{
			break;
		}
	}
	found = *p;
	if( found )
	{
		*p = found->next;
	}
	return( found );
}

#if 0
#pragma mark -
#pragma mark == Domain Registration ==
#endif

//===========================================================================================================================
//	DNSDomainRegistrationCreate
//===========================================================================================================================

DNSStatus
	DNSDomainRegistrationCreate( 
		DNSDomainRegistrationFlags		inFlags, 
		const char *					inName, 
		DNSDomainRegistrationType		inType, 
		DNSDomainRegistrationRef *		outRef )
{
	DNSStatus					err;
	DNSDomainRegistration *		objectPtr;
		
	objectPtr = mDNSNULL;
	
	// Check parameters.
	
	DNSServicesLock();
	require_action( gMDNSPtr, exit, err = kDNSNotInitializedErr );
	require_action( ( inFlags & ~kDNSDomainRegistrationCreateValidFlags ) == 0, exit, err = kDNSBadFlagsErr );
	require_action( inName, exit, err = kDNSBadParamErr );
	require_action( inType < kDNSDomainRegistrationTypeMax, exit, err = kDNSBadParamErr );
	
	// Allocate the object and set it up.
	
	err = DNSPlatformMemAlloc( sizeof( *objectPtr ), &objectPtr );
	require_noerr( err, exit );
	memset( objectPtr, 0, sizeof( *objectPtr ) );
	
	objectPtr->flags = inFlags;
	
	// Add the object to the list.
	
	objectPtr->next = gDNSDomainRegistrationList;
	gDNSDomainRegistrationList = objectPtr;
	
	// Register the domain with mDNS.
	
	err = mDNS_AdvertiseDomains( gMDNSPtr, &objectPtr->rr, (mDNSu8) inType, zeroIPAddr, (char *) inName );
	require_noerr( err, exit );
	
	if( outRef )
	{
		*outRef = objectPtr;
	}
	
exit:
	if( err && objectPtr )
	{
		DNSDomainRegistrationRemoveObject( objectPtr );
		DNSPlatformMemFree( objectPtr );
	}
	DNSServicesUnlock();
	return( err );
}

//===========================================================================================================================
//	DNSDomainRegistrationRelease
//===========================================================================================================================

DNSStatus	DNSDomainRegistrationRelease( DNSDomainRegistrationRef inRef, DNSDomainRegistrationFlags inFlags )
{
	DNSStatus		err;
	
	DNSServicesLock();
	require_action( gMDNSPtr, exit, err = kDNSNotInitializedErr );
	require_action( inRef, exit, err = kDNSBadReferenceErr );
	require_action( ( inFlags & ~kDNSDomainRegistrationReleaseValidFlags ) == 0, exit, err = kDNSBadFlagsErr );
	
	// Notify the client of the registration release. Remove the object first so they cannot try to use it in the callback.
	
	inRef = DNSDomainRegistrationRemoveObject( inRef );
	require_action( inRef, exit, err = kDNSBadReferenceErr );
	
	// Deregister domain with mDNS.
	
	mDNS_StopAdvertiseDomains( gMDNSPtr, &inRef->rr );
	
	// Release the memory used by the object.
	
	DNSPlatformMemFree( inRef );
	err = kDNSNoErr;
	
exit:
	DNSServicesUnlock();
	return( err );
}

//===========================================================================================================================
//	DNSDomainRegistrationRemoveObject
//
//	Warning: Assumes the DNS lock is held.
//===========================================================================================================================

mDNSlocal DNSDomainRegistrationRef	DNSDomainRegistrationRemoveObject( DNSDomainRegistrationRef inRef )
{
	DNSDomainRegistration **		p;
	DNSDomainRegistration *			found;
	
	for( p = &gDNSDomainRegistrationList; *p; p = &( *p )->next )
	{
		if( *p == inRef )
		{
			break;
		}
	}
	found = *p;
	if( found )
	{
		*p = found->next;
	}
	return( found );
}
