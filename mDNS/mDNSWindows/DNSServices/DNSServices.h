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
	$Id: DNSServices.h,v 1.1 2003/07/18 19:41:55 dean Exp $

	Contains:	DNS Services interfaces.
	
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
    
        $Log: DNSServices.h,v $
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

//---------------------------------------------------------------------------------------------------------------------------
/*!	@header		DNSServices
	
	@abstract	DNS Services interfaces.
	
	@discussion	
	
	DNS Services provides DNS service registration, domain and service discovery, and name resolving services.
*/

#ifndef	__DNS_SERVICES__
#define	__DNS_SERVICES__

#ifdef	__cplusplus
	extern "C" {
#endif

#if 0
#pragma mark == General ==
#endif

// dns_check_compile_time - Lets you perform a compile-time check of something such as the size of an int.
//
// This declares a unique array with a size that is determined by dividing 1 by the result of the compile-time 
// expression passed to the macro. If the expression evaluates to 0, this expression results in a divide by 
// zero, which is illegal and generates a compile-time error.
//
// For example:
//
// dns_check_compile_time( sizeof( int ) == 4 )

#define	dns_check_compile_time( X )			extern int DNSDebugUniqueName[ 1 / ( int )( ( X ) ) ]
#define	DNSDebugUniqueName					DNSDebugMakeNameWrapper( __LINE__ )
#define	DNSDebugMakeNameWrapper( X )		DNSDebugMakeName( X )
#define	DNSDebugMakeName( X )				dns_check_compile_time_ ## X

//---------------------------------------------------------------------------------------------------------------------------
/*!	@typedef	DNSUInt8

	@abstract	8-bit unsigned data type.
*/

typedef unsigned char		DNSUInt8;

dns_check_compile_time( sizeof( DNSUInt8 ) == 1 );

//---------------------------------------------------------------------------------------------------------------------------
/*!	@typedef	DNSUInt16

	@abstract	16-bit unsigned data type.
*/

typedef unsigned short		DNSUInt16;

dns_check_compile_time( sizeof( DNSUInt16 ) == 2 );

//---------------------------------------------------------------------------------------------------------------------------
/*!	@typedef	DNSUInt32

	@abstract	32-bit unsigned data type.
*/

typedef unsigned long		DNSUInt32;

dns_check_compile_time( sizeof( DNSUInt32 ) == 4 );

//---------------------------------------------------------------------------------------------------------------------------
/*!	@typedef	DNSCount

	@abstract	Count of at least 32-bits.
*/

typedef DNSUInt32		DNSCount;

//---------------------------------------------------------------------------------------------------------------------------
/*!	@enum		DNSStatus

	@abstract	DNS Service status code.

	@constant	kDNSNoErr
					Success. No error occurred.

	@constant	kDNSUnknownErr
					An unknown error occurred.

	@constant	kDNSNoSuchNameErr
					The name could not be found on the network.

	@constant	kDNSNoMemoryErr
					Not enough memory was available.

	@constant	kDNSBadParamErr
					A invalid or inappropriate parameter was specified.

	@constant	kDNSBadReferenceErr
					A invalid or inappropriate reference was specified. For example, passing in a reference to an 
					object that has already been deleted.

	@constant	kDNSBadStateErr
					The current state does not allow the specified operation. For example, trying to stop browsing 
					when no browsing is currently occurring.

	@constant	kDNSBadFlagsErr
					An invalid, inappropriate, or unsupported flag was specified.

	@constant	kDNSUnsupportedErr
					The specified feature is not currently supported.

	@constant	kDNSNotInitializedErr
					DNS Service has not been initialized. No calls can be made until after initialization.

	@constant	kDNSNoCacheErr
					No cache was specified.

	@constant	kDNSAlreadyRegisteredErr
					Service or host name is already registered.

	@constant	kDNSNameConflictErr
					Name conflicts with another on the network.

	@constant	kDNSInvalidErr
					A general error to indicate something is invalid.
*/

typedef long				DNSStatus;
enum
{
	kDNSNoErr					= 0, 
	
	// DNS Services error codes are in the range FFFE FF00 (-65792) to FFFE FFFF (-65537).
	
	kDNSStartErr 				= -65537, 	// 0xFFFE FFFF
	
	kDNSUnknownErr				= -65537, 
	kDNSNoSuchNameErr			= -65538, 
	kDNSNoMemoryErr				= -65539, 
	kDNSBadParamErr				= -65540, 
	kDNSBadReferenceErr			= -65541, 
	kDNSBadStateErr				= -65542, 
	kDNSBadFlagsErr				= -65543, 
	kDNSUnsupportedErr			= -65544, 
	kDNSNotInitializedErr		= -65545, 
	kDNSNoCacheErr				= -65546, 
	kDNSAlreadyRegisteredErr	= -65547, 
	kDNSNameConflictErr			= -65548, 
	kDNSInvalidErr				= -65549, 
	
	kDNSEndErr					= -65792	// 0xFFFE FF00
};

//---------------------------------------------------------------------------------------------------------------------------
/*!	@enum		DNSFlags

	@abstract	Flags used control DNS Services.
	
	@constant	kDNSFlagAdvertise
					Indicates that interfaces should be advertised on the network. Software that only performs searches 
					do not need to set this flag.
*/

typedef DNSUInt32		DNSFlags;
enum
{
	kDNSFlagAdvertise = ( 1 << 0 )
};

//---------------------------------------------------------------------------------------------------------------------------
/*!	@enum		DNSPort

	@abstract	UDP/TCP port for DNS services.
	
	@constant	kDNSPortInvalid
					Invalid port.
	
	@constant	kDNSPortUnicastDNS
					TCP/UDP port for normal unicast DNS (see RFC 1035).

	@constant	kDNSPortMulticastDNS
					TCP/UDP port for Multicast DNS (see <http://www.multicastdns.org/>).
*/

typedef DNSUInt16		DNSPort;
enum
{
	kDNSPortInvalid			= 0, 
	kDNSPortUnicastDNS		= 53, 
	kDNSPortMulticastDNS	= 5353
};

//---------------------------------------------------------------------------------------------------------------------------
/*!	@enum		DNSNetworkAddressType

	@abstract	Type of address data within a DNSNetworkAddress.
	
	@constant	kDNSNetworkAddressTypeInvalid
					Invalid type.
	
	@constant	kDNSNetworkAddressTypeIPv4
					IPv4 address data.
*/

typedef DNSUInt32	DNSNetworkAddressType;
enum
{
	kDNSNetworkAddressTypeInvalid	= 0, 
	kDNSNetworkAddressTypeIPv4 		= 1
};

//---------------------------------------------------------------------------------------------------------------------------
/*!	@struct		DNSNetworkAddressIPv4

	@field		address
					32-bit IPv4 address in network byte order (e.g. 0x11FE03B7 -> 17.254.3.183).
	
	@field		port
					16-bit port number.
	
	@field		pad
					Reserved pad to 32-bit boundary. Must be zero.
*/

typedef struct	DNSNetworkAddressIPv4	DNSNetworkAddressIPv4;
struct	DNSNetworkAddressIPv4
{
	DNSUInt32		address;
	DNSUInt16		port;
	DNSUInt16		pad;
};

dns_check_compile_time( sizeof( DNSNetworkAddressIPv4 ) == 8 );

//---------------------------------------------------------------------------------------------------------------------------
/*!	@struct		DNSNetworkAddress

	@field		addressType
					Type of data contained within the address structure.
	
	@field		ipv4
					IPv4 address data.
					
	@field		reserved
					Reserved data (pads structure to allow for future growth). Unused portions must be zero.
*/

typedef struct	DNSNetworkAddress	DNSNetworkAddress;
struct	DNSNetworkAddress
{
	DNSNetworkAddressType			addressType;
	union
	{
		DNSNetworkAddressIPv4		ipv4;
		DNSUInt8					reserved[ 16 ];
	} u;
};

//---------------------------------------------------------------------------------------------------------------------------
/*!	@defined	kDNSLocalDomain

	@abstract	Local DNS domain name (local.).
*/

#define	kDNSLocalDomain		"local."

//---------------------------------------------------------------------------------------------------------------------------
/*!	@function	DNSServicesInitialize
	
	@abstract	Initializes DNS Services. This must be called before DNS Services functions can be used.
	
	@param		inFlags
					Flags to control DNS Services.

	@param		inCacheEntryCount
					Number of entries in the DNS record cache. Specify 0 to use the default.
					
	@result		Error code indicating failure reason or kDNSNoErr if successful.
*/

DNSStatus	DNSServicesInitialize( DNSFlags inFlags, DNSCount inCacheEntryCount );

//---------------------------------------------------------------------------------------------------------------------------
/*!	@function	DNSServicesFinalize

	@abstract	Finalizes DNS Services. No DNS Services functions may be called after this function is called.
*/

void	DNSServicesFinalize( void );

//---------------------------------------------------------------------------------------------------------------------------
/*!	@function	DNSServicesIdle

	@abstract	Gives DNS Services a chance to service any idle-time needs it may have.
	
	@discussion	Explicit idling is not normally needed, but can be useful to explicitly yield control on systems with 
				cooperative multitasking.
*/

void	DNSServicesIdle( void );

#if 0
#pragma mark == Resolving ==
#endif

//===========================================================================================================================
//	Resolving
//===========================================================================================================================

//---------------------------------------------------------------------------------------------------------------------------
/*!	@typedef	DNSBrowserRef

	@abstract	Reference to a DNS browser object.
	
	@discussion	
	
	A browser object is typically used by a graphical user application in a manner similar to the Macintosh "Chooser" 
	application. The application creates a browser object then starts domain and/or service searches to begin browsing.
	When domains and/or services are found, added, or removed, the application is notified via a callback routine.
*/

typedef struct	DNSBrowser *		DNSBrowserRef;

//---------------------------------------------------------------------------------------------------------------------------
/*!	@typedef	DNSResolverRef

	@abstract	Reference to a DNS resolver object.
		
	@discussion	
	
	A resolver object is used to resolve service names to IP addresses.
*/

typedef struct	DNSResolver *		DNSResolverRef;

//---------------------------------------------------------------------------------------------------------------------------
/*!	@enum		DNSResolverFlags

	@abstract	Flags used to control resolve operations.
	
	@constant	kDNSResolverFlagOneShot
					Used to indicate the resolver object should be automatically released after the first resolve.

	@constant	kDNSResolverFlagOnlyIfUnique
					Used to indicate the resolver object should only be created if it is unique. This makes it easy for
					resolver management to be handled automatically. For example, some software needs to keep active 
					resolving operations open constantly to detect things like the IP address changing (e.g. if 
					displaying it to the user), but when a service goes away then comes back, a new resolver object 
					will often be created, leaving two resolvers for the same name.

	@constant	kDNSResolverFlagAutoReleaseByName
					Used to indicate the resolver object should be automatically released when the service name 
					that is associated with it is no longer on the network. When a service is added to the network, 
					a resolver object may be created and kept around to detect things like IP address changes. When 
					the service goes off the network, this option causes the resolver associated with that service 
					name to be automatically released.
*/

typedef DNSUInt32		DNSResolverFlags;
enum
{
	kDNSResolverFlagOneShot 			= ( 1 << 0 ), 
	kDNSResolverFlagOnlyIfUnique		= ( 1 << 1 ), 
	kDNSResolverFlagAutoReleaseByName	= ( 1 << 2 )
};

//---------------------------------------------------------------------------------------------------------------------------
/*!	@enum		DNSResolverEventType

	@abstract	Type of resolver event being delivered.
	
	@constant	kDNSResolverEventTypeInvalid
					Invalid event type. Here for completeness.

	@constant	kDNSResolverEventTypeRelease
					Object is being released. No additional data is associated with this event.

	@constant	kDNSResolverEventTypeResolved
					Name resolved.
*/

typedef long		DNSResolverEventType;
enum
{
	kDNSResolverEventTypeInvalid 	= 0, 
	kDNSResolverEventTypeRelease	= 1, 
	kDNSResolverEventTypeResolved	= 10
};

//---------------------------------------------------------------------------------------------------------------------------
/*!	@struct		DNSResolverEventResolveData

	@abstract	Data structure passed to callback routine when a resolve-related event occurs.

	@field		name
					Ptr to UTF-8 string containing the resolved name of the service.

	@field		type
					Ptr to UTF-8 string containing the resolved type of the service.

	@field		domain
					Ptr to UTF-8 string containing the resolved domain of the service.

	@field		interfaceAddr
					Network address of the interface that received the resolver information.
	
	@field		address
					Network address of the service. Used to communicate with the service.

	@field		textRecord
					Ptr to UTF-8 string containing any additional text information supplied by the service provider.

	@field		flags
					Flags used to augment the event data.
*/

typedef struct	DNSResolverEventResolveData		DNSResolverEventResolveData;
struct	DNSResolverEventResolveData
{
	const char *			name;
	const char *			type;
	const char *			domain;
	DNSNetworkAddress		interfaceAddr;
	DNSNetworkAddress		address;
	const char *			textRecord;
	DNSResolverFlags		flags;
};

//---------------------------------------------------------------------------------------------------------------------------
/*!	@struct		DNSResolverEvent

	@abstract	Data structure passed to callback routines when a resolver event occurs.

	@field		type
					Type of event. The type determines which portion of the data union to use. Types and data union 
					fields are named such as the data union field is the same as the event type. For example, a 
					"resolved" event type (kDNSResolverEventTypeResolved) would refer to data union field "resolved".
	
	@field		resolved
					Data associated with kDNSResolverEventTypeResolved event.
*/

typedef struct	DNSResolverEvent		DNSResolverEvent;
struct	DNSResolverEvent
{
	DNSResolverEventType				type;
	
	union
	{
		DNSResolverEventResolveData		resolved;
	
	} data;
};

//---------------------------------------------------------------------------------------------------------------------------
/*!	@function	DNSResolverCallBack

	@abstract	CallBack routine used to indicate a resolver event.
	
	@param		inContext
					User-supplied context for callback (specified when browser is created).

	@param		inRef
					Reference to resolver object generating the event.

	@param		inStatusCode
					Status of the event.

	@param		inEvent
					Data associated with the event.	
*/

typedef void
	( *DNSResolverCallBack )( 
		void *						inContext, 
		DNSResolverRef				inRef, 
		DNSStatus					inStatusCode, 
		const DNSResolverEvent *	inEvent );

//---------------------------------------------------------------------------------------------------------------------------
/*!	@function	DNSResolverCreate

	@abstract	Creates a resolver object and start resolving a service name.

	@param		inFlags
					Flags to control the resolving process.

	@param		inName
					Ptr to UTF-8 string containing the service name to resolve.
	
	@param		inType
					Ptr to UTF-8 string containing the service type of the service to resolve.

	@param		inDomain
					Ptr to UTF-8 string containing the domain of the service to resolve.

	@param		inCallBack
					CallBack routine to call when a resolver event occurs.

	@param		inCallBackContext
					Context pointer to pass to CallBack routine when an event occurs. Not inspected by DNS Services.

	@param		inOwner
					Reference to browser object related to this resolver. If a browser object is specified and is 
					later released, this resolver object will automatically be released too. May be null.

	@param		outRef
					Ptr to receive reference to resolver object. If the kDNSResolverFlagOnlyIfUnique flag is specified 
					and there is already a resolver for the name, a NULL reference is returned in this parameter to let 
					the caller know that no resolver was created. May be null.

	@result		Error code indicating failure reason or kDNSNoErr if successful.
*/

DNSStatus
	DNSResolverCreate( 
		DNSResolverFlags		inFlags, 
		const char *			inName, 
		const char *			inType, 
		const char *			inDomain, 
		DNSResolverCallBack		inCallBack, 
		void *					inCallBackContext, 
		DNSBrowserRef			inOwner, 
		DNSResolverRef *		outRef );

//---------------------------------------------------------------------------------------------------------------------------
/*!	@function	DNSResolverRelease

	@abstract	Releases a resolver object.
	
	@param		inRef
					Reference to the resolver object to release.

	@param		inFlags
					Flags to control the release process.

	@result		Error code indicating failure reason or kDNSNoErr if successful.
*/

DNSStatus	DNSResolverRelease( DNSResolverRef inRef, DNSResolverFlags inFlags );

#if 0
#pragma mark == Browsing ==
#endif

//===========================================================================================================================
//	Browsing
//===========================================================================================================================

//---------------------------------------------------------------------------------------------------------------------------
/*!	@enum		DNSBrowserFlags

	@abstract	Flags used to control browser operations.
	
	@constant	kDNSBrowserFlagRegistrationDomainsOnly
					Used to indicate the client is browsing only for domains to publish services. When the client wishes
					to publish a service, a domain browse operation would be started, with this flag specified, to find 
					the domain used to register the service. Only valid when passed to DNSBrowserStartDomainSearch.

	@constant	kDNSBrowserFlagAutoResolve
					Used to indicate discovered names should be automatically resolved. This eliminates the need to 
					manually create a resolver to get the IP address and other information. Only valid when passed to 
					DNSBrowserStartServiceSearch. When this option is used, it is important to avoid manually resolving
					names because this option causes DNS Services to automatically resolve and multiple resolvers for 
					the same name will lead to unnecessary network bandwidth usage. It is also important to note that 
					the notification behavior of the browser is otherwise not affected by this option so browser callback
					will still receive the same add/remove domain/service events it normally would.
*/

typedef DNSUInt32		DNSBrowserFlags;
enum
{
	kDNSBrowserFlagRegistrationDomainsOnly	= ( 1 << 0 ), 
	kDNSBrowserFlagAutoResolve				= ( 1 << 1 )
};

//---------------------------------------------------------------------------------------------------------------------------
/*!	@enum		DNSBrowserEventType

	@abstract	Type of browser event being delivered.
	
	@constant	kDNSBrowserEventTypeInvalid
					Invalid event type. Here for completeness.

	@constant	kDNSBrowserEventTypeRelease
					Object is being released. No additional data is associated with this event.
	
	@constant	kDNSBrowserEventTypeAddDomain
					Domain added/found. 

	@constant	kDNSBrowserEventTypeAddDefaultDomain
					Default domain added/found. This domain should be selected as the default.

	@constant	kDNSBrowserEventTypeRemoveDomain
					Domain removed.

	@constant	kDNSBrowserEventTypeAddService
					Service added/found.

	@constant	kDNSBrowserEventTypeRemoveService
					Service removed.

	@constant	kDNSBrowserEventTypeResolved
					Name resolved. This is only delivered if the kDNSBrowserFlagAutoResolve option is used with 
					DNSBrowserStartServiceSearch.
*/

typedef long		DNSBrowserEventType;
enum
{
	kDNSBrowserEventTypeInvalid 			= 0, 
	kDNSBrowserEventTypeRelease				= 1, 
	kDNSBrowserEventTypeAddDomain	 		= 10, 
	kDNSBrowserEventTypeAddDefaultDomain	= 11, 
	kDNSBrowserEventTypeRemoveDomain 		= 12, 
	kDNSBrowserEventTypeAddService 			= 20, 
	kDNSBrowserEventTypeRemoveService		= 21, 
	kDNSBrowserEventTypeResolved			= 30
};

//---------------------------------------------------------------------------------------------------------------------------
/*!	@struct		DNSBrowserEventDomainData

	@abstract	Data structure referenced by callback routines when a domain-related event occurs.

	@field		interfaceAddr
					Address of the interface that received the browser event.
					
	@field		domain
					Ptr to UTF-8 string containing the domain name. NULL if no domain name is available or applicable.

	@field		flags
					Flags used to augment the event data.
*/

typedef struct	DNSBrowserEventDomainData	DNSBrowserEventDomainData;
struct	DNSBrowserEventDomainData
{
	DNSNetworkAddress		interfaceAddr;
	const char *			domain;
	DNSBrowserFlags			flags;
};

//---------------------------------------------------------------------------------------------------------------------------
/*!	@struct		DNSBrowserEventServiceData

	@abstract	Data structure passed to callback routines when a service-related event occurs.
	
	@field		interfaceAddr
					Address of the interface that received the browser event.
	
	@field		name
					Ptr to UTF-8 string containing the service name. NULL if no service name is available or applicable.
	
	@field		type
					Ptr to UTF-8 string containing the service type. NULL if no service type is available or applicable.

	@field		domain
					Ptr to UTF-8 string containing the domain name. NULL if no domain name is available or applicable.

	@field		flags
					Flags used to augment the event data.
*/

typedef struct	DNSBrowserEventServiceData	DNSBrowserEventServiceData;
struct	DNSBrowserEventServiceData
{
	DNSNetworkAddress		interfaceAddr;
	const char *			name;
	const char *			type;
	const char *			domain;
	DNSBrowserFlags			flags;
};

//---------------------------------------------------------------------------------------------------------------------------
/*!	@struct		DNSBrowserEvent

	@abstract	Data structure passed to callback routines when a browser event occurs.

	@field		type
					Type of event. The type determines which portion of the data union to use. Types and data union 
					fields are named such as the data union field is the same as the event type. For example, an 
					"add domain" event type (kDNSBrowserEventTypeAddDomain) would refer to data union field "addDomain".
	
	@field		addDomain
					Data associated with kDNSBrowserEventTypeAddDomain event.

	@field		addDefaultDomain
					Data associated with kDNSBrowserEventTypeAddDefaultDomain event.

	@field		removeDomain
					Data associated with kDNSBrowserEventTypeRemoveDomain event.

	@field		addService
					Data associated with kDNSBrowserEventTypeAddService event.

	@field		removeService
					Data associated with kDNSBrowserEventTypeRemoveService event.

	@field		resolved
					Data associated with kDNSBrowserEventTypeResolved event.
*/

typedef struct	DNSBrowserEvent		DNSBrowserEvent;
struct	DNSBrowserEvent
{
	DNSBrowserEventType							type;
	
	union
	{
		DNSBrowserEventDomainData				addDomain;
		DNSBrowserEventDomainData				addDefaultDomain;
		DNSBrowserEventDomainData				removeDomain;
		DNSBrowserEventServiceData				addService;
		DNSBrowserEventServiceData				removeService;
		const DNSResolverEventResolveData *		resolved;
		
	} data;
};

//---------------------------------------------------------------------------------------------------------------------------
/*!	@function	DNSBrowserCallBack

	@abstract	CallBack routine used to indicate a browser event.
	
	@param		inContext
					User-supplied context for callback (specified when browser is created).

	@param		inRef
					Reference to browser object generating the event.

	@param		inStatusCode
					Status of the event.

	@param		inEvent
					Data associated with the event.
*/

typedef void
	( *DNSBrowserCallBack )( 
		void *					inContext, 
		DNSBrowserRef			inRef, 
		DNSStatus				inStatusCode, 
		const DNSBrowserEvent *	inEvent );

//---------------------------------------------------------------------------------------------------------------------------
/*!	@function	DNSBrowserCreate

	@abstract	Creates a browser object.
	
	@param		inFlags
					Flags to control the creation process.

	@param		inCallBack
					CallBack routine to call when a browser event occurs.

	@param		inCallBackContext
					Context pointer to pass to CallBack routine when an event occurs. Not inspected by DNS Services.

	@param		outRef
					Ptr to receive reference to the created browser object. May be null.

	@result		Error code indicating failure reason or kDNSNoErr if successful.
*/

DNSStatus
	DNSBrowserCreate( 
		DNSBrowserFlags 	inFlags, 
		DNSBrowserCallBack	inCallBack, 
		void *				inCallBackContext, 
		DNSBrowserRef *		outRef );

//---------------------------------------------------------------------------------------------------------------------------
/*!	@function	DNSBrowserRelease

	@abstract	Releases a browser object.
	
	@param		inRef
					Reference to the browser object to release.

	@param		inFlags
					Flags to control the release process.

	@result		Error code indicating failure reason or kDNSNoErr if successful.
*/

DNSStatus	DNSBrowserRelease( DNSBrowserRef inRef, DNSBrowserFlags inFlags );

//---------------------------------------------------------------------------------------------------------------------------
/*!	@function	DNSBrowserStartDomainSearch

	@abstract	Starts a domain name search.
	
	@param		inRef
					Reference to browser object to start the search on.

	@param		inFlags
					Flags to control the search process.

	@result		Error code indicating failure reason or kDNSNoErr if successful.
*/

DNSStatus	DNSBrowserStartDomainSearch( DNSBrowserRef inRef, DNSBrowserFlags inFlags );

//---------------------------------------------------------------------------------------------------------------------------
/*!	@function	DNSBrowserStopDomainSearch

	@abstract	Stops a domain name search.
	
	@param		inRef
					Reference to browser object to stop the search on.

	@param		inFlags
					Flags to control the stopping process.

	@result		Error code indicating failure reason or kDNSNoErr if successful.
*/

DNSStatus	DNSBrowserStopDomainSearch( DNSBrowserRef inRef, DNSBrowserFlags inFlags );

//---------------------------------------------------------------------------------------------------------------------------
/*!	@function	DNSBrowserStartServiceSearch

	@abstract	Starts a service search.
	
	@param		inRef
					Reference to browser object to start the search on.

	@param		inFlags
					Flags to control the search process.

	@param		inType
					Ptr to UTF-8 string containing the service type to search for.

	@param		inDomain
					Ptr to UTF-8 string containing the domain to search in.

	@result		Error code indicating failure reason or kDNSNoErr if successful.
*/

DNSStatus
	DNSBrowserStartServiceSearch( 
		DNSBrowserRef 		inRef, 
		DNSBrowserFlags 	inFlags, 
		const char * 		inType, 
		const char *		inDomain );

//---------------------------------------------------------------------------------------------------------------------------
/*!	@function	DNSBrowserStopServiceSearch

	@abstract	Stops a service search.
	
	@param		inRef
					Reference to browser object to stop the search on.

	@param		inFlags
					Flags to control the stopping process.

	@result		Error code indicating failure reason or kDNSNoErr if successful.
*/

DNSStatus	DNSBrowserStopServiceSearch( DNSBrowserRef inRef, DNSBrowserFlags inFlags );

#if 0
#pragma mark == Registration ==
#endif

//===========================================================================================================================
//	Registration
//===========================================================================================================================

//---------------------------------------------------------------------------------------------------------------------------
/*!	@typedef	DNSRegistrationRef

	@abstract	Reference to a DNS registration object.
*/

typedef struct	DNSRegistration *		DNSRegistrationRef;

//---------------------------------------------------------------------------------------------------------------------------
/*!	@enum		DNSRegistrationFlags

	@abstract	Flags used to control registration operations.
*/

typedef DNSUInt32		DNSRegistrationFlags;
enum
{
	kDNSRegistrationFlagNone = 0
};

//---------------------------------------------------------------------------------------------------------------------------
/*!	@enum		DNSRegistrationEventType

	@abstract	Type of registration event being delivered.
	
	@constant	kDNSResolverEventTypeInvalid
					Invalid event type. Here for completeness.

	@constant	kDNSRegistrationEventTypeRelease
					Object is being released. No additional data is associated with this event.
					
	@constant	kDNSRegistrationEventTypeRegistered
					Name has been successfully registered.

	@constant	kDNSRegistrationEventTypeNameCollision
					Name collision. The registration is no longer valid. A new registration must be created if needed.
*/

typedef long		DNSRegistrationEventType;
enum
{
	kDNSRegistrationEventTypeInvalid 			= 0, 
	kDNSRegistrationEventTypeRelease 			= 1,
	kDNSRegistrationEventTypeRegistered	 		= 10, 
	kDNSRegistrationEventTypeNameCollision		= 11
};

//---------------------------------------------------------------------------------------------------------------------------
/*!	@struct		DNSRegistrationEvent

	@abstract	Data structure passed to callback routines when a registration event occurs.

	@field		type
					Type of event. The type determines which portion of the data union to use. Types and data union 
					fields are named such as the data union field is the same as the event type.
	
	@field		reserved
					Reserved for future use.
*/

typedef struct	DNSRegistrationEvent		DNSRegistrationEvent;
struct	DNSRegistrationEvent
{
	DNSRegistrationEventType		type;
	
	union
	{
		DNSUInt32					reserved;
	
	}	data;
};

//---------------------------------------------------------------------------------------------------------------------------
/*!	@function	DNSRegistrationCallBack

	@abstract	CallBack routine used to indicate a registration event.
	
	@param		inContext
					User-supplied context for callback (specified when registration is created).

	@param		inRef
					Reference to registration object generating the event.

	@param		inStatusCode
					Status of the event.

	@param		inEvent
					Data associated with the event.
*/

typedef void
	( *DNSRegistrationCallBack )( 
		void *							inContext, 
		DNSRegistrationRef				inRef, 
		DNSStatus						inStatusCode, 
		const DNSRegistrationEvent *	inEvent );

//---------------------------------------------------------------------------------------------------------------------------
/*!	@function	DNSRegistrationCreate

	@abstract	Creates a registration object and publish the registration.

	@param		inFlags
					Flags to control the registration process.

	@param		inName
					Ptr to UTF-8 string containing the service name to register.
	
	@param		inType
					Ptr to UTF-8 string containing the service type of the service to registration.

	@param		inDomain
					Ptr to UTF-8 string containing the domain of the service to register.
	
	@param		inPort
					TCP/UDP port where the service is being offered.

	@param		inTextRecord
					Ptr to UTF-8 string containing any additional text to provide when the service is resolved.

	@param		inCallBack
					CallBack routine to call when a registration event occurs.

	@param		inCallBackContext
					Context pointer to pass to CallBack routine when an event occurs. Not inspected by DNS Services.

	@param		outRef
					Ptr to receive reference to registration object. May be null.

	@result		Error code indicating failure reason or kDNSNoErr if successful.			
*/

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
		DNSRegistrationRef *	outRef );

//---------------------------------------------------------------------------------------------------------------------------
/*!	@function	DNSRegistrationRelease

	@abstract	Releases a registration object.
	
	@param		inRef
					Reference to the registration object to release.

	@param		inFlags
					Flags to control the release process.

	@result		Error code indicating failure reason or kDNSNoErr if successful.
*/

DNSStatus	DNSRegistrationRelease( DNSRegistrationRef inRef, DNSRegistrationFlags inFlags );

#if 0
#pragma mark == Domain Registration ==
#endif

//===========================================================================================================================
//	Domain Registration
//===========================================================================================================================

//---------------------------------------------------------------------------------------------------------------------------
/*!	@typedef	DNSDomainRegistrationRef

	@abstract	Reference to a DNS registration object.
*/

typedef struct	DNSDomainRegistration *		DNSDomainRegistrationRef;

//---------------------------------------------------------------------------------------------------------------------------
/*!	@enum		DNSDomainRegistrationFlags

	@abstract	Flags used to control registration operations.
*/

typedef DNSUInt32		DNSDomainRegistrationFlags;
enum
{
	kDNSDomainRegistrationFlagNone = 0
};

//---------------------------------------------------------------------------------------------------------------------------
/*!	@enum		DNSDomainRegistrationType

	@abstract	Type of domain registration.
	
	@constant	kDNSDomainRegistrationTypeBrowse
					Registration for domain browsing.

	@constant	kDNSDomainRegistrationTypeBrowseDefault
					Registration for the domain browsing domain.
					
	@constant	kDNSDomainRegistrationTypeRegistration
					Registration for domain registration.

	@constant	kDNSDomainRegistrationTypeRegistrationDefault
					Registration for the domain registration domain.
*/

typedef DNSUInt32		DNSDomainRegistrationType;
enum
{
	kDNSDomainRegistrationTypeBrowse				= 0, 
	kDNSDomainRegistrationTypeBrowseDefault			= 1, 
	kDNSDomainRegistrationTypeRegistration			= 2, 
	kDNSDomainRegistrationTypeRegistrationDefault	= 3, 
	
	kDNSDomainRegistrationTypeMax					= 4
};

//---------------------------------------------------------------------------------------------------------------------------
/*!	@function	DNSDomainRegistrationCreate

	@abstract	Creates a domain registration object and publish the domain.

	@param		inFlags
					Flags to control the registration process.

	@param		inName
					Ptr to string containing the domain name to register.
	
	@param		inType
					Type of domain registration.

	@param		outRef
					Ptr to receive reference to domain registration object. May be null.

	@result		Error code indicating failure reason or kDNSNoErr if successful.			
*/

DNSStatus
	DNSDomainRegistrationCreate( 
		DNSDomainRegistrationFlags		inFlags, 
		const char *					inName, 
		DNSDomainRegistrationType		inType, 
		DNSDomainRegistrationRef *		outRef );

//---------------------------------------------------------------------------------------------------------------------------
/*!	@function	DNSDomainRegistrationRelease

	@abstract	Releases a domain registration object.
	
	@param		inRef
					Reference to the domain registration object to release.

	@param		inFlags
					Flags to control the release process.

	@result		Error code indicating failure reason or kDNSNoErr if successful.
*/

DNSStatus	DNSDomainRegistrationRelease( DNSDomainRegistrationRef inRef, DNSDomainRegistrationFlags inFlags );

#ifdef	__cplusplus
	}
#endif

#endif	// __DNS_SERVICES__
