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
	$Id: Tool.c,v 1.1 2003/07/18 19:41:54 dean Exp $

	Contains:	Rendezvous Test Tool for Windows.
	
	Written by: Bob Bradley
	
    Version:    Rendezvous, September 2002

    Copyright:  Copyright (c) 2002 by Apple Computer, Inc., All Rights Reserved.

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
    
        $Log: Tool.c,v $
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

        Revision 1.2  2002/09/21 20:44:56  zarzycki
        Added APSL info

        Revision 1.1  2002/09/20 06:07:55  bradley
        Rendezvous Test Tool for Windows

*/

#include	<stdint.h>
#include	<stdio.h>

#define	WIN32_LEAN_AND_MEAN

#include	<windows.h>

#include	"DNSServices.h"

//===========================================================================================================================
//	Macros
//===========================================================================================================================

#define	require_action_string( X, LABEL, ACTION, STR )				\
	do 																\
	{																\
		if( !( X ) ) 												\
		{															\
			fprintf( stderr, "%s\n", ( STR ) );						\
			{ ACTION; }												\
			goto LABEL;												\
		}															\
	} while( 0 )

#define	require_string( X, LABEL, STR )								\
	do 																\
	{																\
		if( !( X ) ) 												\
		{															\
			fprintf( stderr, "%s\n", ( STR ) );						\
			goto LABEL;												\
																	\
		}															\
	} while( 0 )

#define	require_noerr_string( ERR, LABEL, STR )						\
	do 																\
	{																\
		if( ( ERR ) != 0 ) 											\
		{															\
			fprintf( stderr, "%s (%ld)\n", ( STR ), ( ERR ) );		\
			goto LABEL;												\
		}															\
	} while( 0 )

//===========================================================================================================================
//	Prototypes
//===========================================================================================================================

int 				main( int argc, char* argv[] );
static void			Usage( void );
static BOOL WINAPI	ConsoleControlHandler( DWORD inControlEvent );
static void 		BrowserCallBack( void *inContext, DNSBrowserRef inRef, DNSStatus inStatusCode, const DNSBrowserEvent *inEvent );
static void 		ResolverCallBack( void *inContext, DNSResolverRef inRef, DNSStatus inStatusCode, const DNSResolverEvent *inEvent );
static void
	RegistrationCallBack( 
		void *							inContext, 
		DNSRegistrationRef				inRef, 
		DNSStatus						inStatusCode, 
		const DNSRegistrationEvent *	inEvent );
static char *	IPv4ToString( DNSUInt32 inIP, char *outString );

//===========================================================================================================================
//	Globals
//===========================================================================================================================

static volatile int		gQuit = 0;

//===========================================================================================================================
//	main
//===========================================================================================================================

int main( int argc, char* argv[] )
{	
	DNSStatus						err;
	int								i;
	const char *					name;
	const char *					type;
	const char *					domain;
	int								port;
	const char *					text;
	DNSBrowserRef					browser;
	DNSResolverFlags				resolverFlags;
	DNSDomainRegistrationType		domainType;
	const char *					label;
	
	// Set up DNS Services and install a Console Control Handler to handle things like control-c signals.
	
	err = DNSServicesInitialize( kDNSFlagAdvertise, 0 );
	require_noerr_string( err, exit, "could not initialize Rendezvous" );
	
	SetConsoleCtrlHandler( ConsoleControlHandler, TRUE );
	
	// Parse the command line arguments (ignore first argument since it's just the program name).
	
	require_action_string( argc >= 2, exit, err = kDNSBadParamErr, "no arguments specified" );
	
	for( i = 1; i < argc; ++i )
	{
		if( strcmp( argv[ i ], "-bbd" ) == 0 )
		{
			// 'b'rowse for 'b'rowsing 'd'omains
			
			fprintf( stdout, "browsing for browsing domains\n" );
			
			err = DNSBrowserCreate( 0, BrowserCallBack, NULL, &browser );
			require_noerr_string( err, exit, "create browser failed" );
			
			err = DNSBrowserStartDomainSearch( browser, 0 );
			require_noerr_string( err, exit, "start domain search failed" );
		}
		else if( strcmp( argv[ i ], "-brd" ) == 0 )
		{
			// 'b'rowse for 'r'egistration 'd'omains
			
			fprintf( stdout, "browsing for registration domains\n" );
			
			err = DNSBrowserCreate( 0, BrowserCallBack, NULL, &browser );
			require_noerr_string( err, exit, "create browser failed" );
			
			err = DNSBrowserStartDomainSearch( browser, kDNSBrowserFlagRegistrationDomainsOnly );
			require_noerr_string( err, exit, "start domain search failed" );
		}
		else if( strcmp( argv[ i ], "-bs" ) == 0 )
		{
			// 'b'rowse for 's'ervices <type> <domain>
						
			require_action_string( argc > ( i + 2 ), exit, err = kDNSBadParamErr, "missing arguments" );
			++i;
			type 	= argv[ i++ ];
			domain 	= argv[ i ];
			if( ( domain[ 0 ] == '.' ) && ( domain[ 1 ] == '\0' ) )
			{
				domain = "local.";
			}
			fprintf( stdout, "browsing for \"%s.%s\"\n", type, domain );
			
			err = DNSBrowserCreate( 0, BrowserCallBack, NULL, &browser );
			require_noerr_string( err, exit, "create browser failed" );
			
			err = DNSBrowserStartServiceSearch( browser, kDNSBrowserFlagAutoResolve, type, domain );
			require_noerr_string( err, exit, "start service search failed" );
		}
		else if( strcmp( argv[ i ], "-lsi" ) == 0 )
		{
			// 'l'ookup 's'ervice 'i'nstance <name> <type> <domain>
			
			require_action_string( argc > ( i + 3 ), exit, err = kDNSBadParamErr, "missing arguments" );
			++i;
			name 	= argv[ i++ ];
			type 	= argv[ i++ ];
			domain 	= argv[ i ];
			if( ( domain[ 0 ] == '.' ) && ( domain[ 1 ] == '\0' ) )
			{
				domain = "local.";
			}
			fprintf( stdout, "resolving \"%s.%s.%s\"\n", name, type, domain );
			
			resolverFlags = kDNSResolverFlagOnlyIfUnique | 
							kDNSResolverFlagAutoReleaseByName;
			err = DNSResolverCreate( resolverFlags, name, type, domain, ResolverCallBack, 0, NULL, NULL );
			require_noerr_string( err, exit, "create resolver failed" );
		}
		else if( ( strcmp( argv[ i ], "-rdb" ) == 0 ) || ( strcmp( argv[ i ], "-rdbd" ) == 0 ) )
		{
			// 'r'egister 'd'omain for 'b'rowsing ['d'efault] <domain>
						
			require_action_string( argc > ( i + 1 ), exit, err = kDNSBadParamErr, "missing arguments" );
			if( strcmp( argv[ i ], "-rdb" ) == 0 )
			{
				domainType = kDNSDomainRegistrationTypeBrowse;
				label = "";
			}
			else
			{
				domainType = kDNSDomainRegistrationTypeBrowseDefault;
				label = "default ";
			}
			++i;
			domain = argv[ i ];
			if( ( domain[ 0 ] == '.' ) && ( domain[ 1 ] == '\0' ) )
			{
				domain = "local.";
			}
			fprintf( stdout, "registering \"%s\" as %sbrowse domain\n", domain, label );
			
			err = DNSDomainRegistrationCreate( 0, domain, domainType, NULL );
			require_noerr_string( err, exit, "create domain registration failed" );
		}
		else if( ( strcmp( argv[ i ], "-rdr" ) == 0 ) || ( strcmp( argv[ i ], "-rdrd" ) == 0 ) )
		{
			// 'r'egister 'd'omain for 'r'egistration ['d'efault] <domain>
			
			require_action_string( argc > ( i + 1 ), exit, err = kDNSBadParamErr, "missing arguments" );
			if( strcmp( argv[ i ], "-rdr" ) == 0 )
			{
				domainType = kDNSDomainRegistrationTypeRegistration;
				label = "";
			}
			else
			{
				domainType = kDNSDomainRegistrationTypeRegistrationDefault;
				label = "default ";
			}
			++i;
			domain = argv[ i ];
			if( ( domain[ 0 ] == '.' ) && ( domain[ 1 ] == '\0' ) )
			{
				domain = "local.";
			}
			fprintf( stdout, "registering \"%s\" as %sregistration domain\n", domain, label );
			
			err = DNSDomainRegistrationCreate( 0, domain, domainType, NULL );
			require_noerr_string( err, exit, "create domain registration failed" );
		}
		else if( strcmp( argv[ i ], "-rs" ) == 0 )
		{
			// 'r'egister 's'ervice <name> <type> <domain> <port> <txt>
						
			require_action_string( argc > ( i + 5 ), exit, err = kDNSBadParamErr, "missing arguments" );
			++i;
			name 	= argv[ i++ ];
			type 	= argv[ i++ ];
			domain 	= argv[ i++ ];
			port 	= atoi( argv[ i++ ] );
			text 	= argv[ i ];
			if( ( domain[ 0 ] == '.' ) && ( domain[ 1 ] == '\0' ) )
			{
				domain = "local.";
			}
			fprintf( stdout, "registering service \"%s.%s.%s\" port %d text \"%s\"\n", name, type, domain, port, text );
			
			err = DNSRegistrationCreate( 0, name, type, domain, port, text, RegistrationCallBack, NULL, NULL );
			require_noerr_string( err, exit, "create registration failed" );
		}
		else if( ( strcmp( argv[ i ], "-help" ) == 0 ) || ( strcmp( argv[ i ], "-h" ) == 0 ) )
		{
			// Help
			
			Usage();
			goto exit;
		}
		else
		{
			// Unknown parameter.
			
			require_action_string( 0, exit, err = kDNSBadParamErr, "unknown parameter" );
			goto exit;
		}
	}
	
	// Sleep until control-c'd.
	
	while( !gQuit )
	{
		Sleep( 200 );
	}
	
exit:
	if( err )
	{
		Usage();
	}
	DNSServicesFinalize();
	return( err );
}

//===========================================================================================================================
//	Usage
//===========================================================================================================================

static void	Usage( void )
{
	fprintf( stderr, "\n" );
	fprintf( stderr, "rendezvous - Rendezvous Tool for Windows 1.0d1\n" );
	fprintf( stderr, "\n" );
	fprintf( stderr, "  -bbd                                       'b'rowse for 'b'rowsing 'd'omains\n" );
	fprintf( stderr, "  -brd                                       'b'rowse for 'r'egistration 'd'omains\n" );
	fprintf( stderr, "  -bs <type> <domain>                        'b'rowse for 's'ervices\n" );
	fprintf( stderr, "  -lsi <name> <type> <domain>                'l'ookup 's'ervice 'i'nstance\n" );
	fprintf( stderr, "  -rdb[d] <domain>                           'r'egister 'd'omain for 'b'rowsing ['d'efault]\n" );
	fprintf( stderr, "  -rdr[d] <domain>                           'r'egister 'd'omain for 'r'egistration ['d'efault]\n" );
	fprintf( stderr, "  -rs <name> <type> <domain> <port> <txt>    'r'egister 's'ervice\n" );
	fprintf( stderr, "  -h[elp]                                    'h'elp\n" );
	fprintf( stderr, "\n" );
	fprintf( stderr, "Examples:\n" );
	fprintf( stderr, "\n" );
	fprintf( stderr, "  rendezvous -bbd\n" );
	fprintf( stderr, "  rendezvous -bs \"_airport._tcp\" \"local.\"\n" );
	fprintf( stderr, "  rendezvous -lsi \"My Base Station\" \"_airport._tcp\" \"local.\"\n" );
	fprintf( stderr, "  rendezvous -rdb \"apple.com\"\n" );
	fprintf( stderr, "  rendezvous -rs \"My Computer\" \"_airport._tcp\" \"local.\" 1234 \"My Info\"\n" );
	fprintf( stderr, "\n" );
}

//===========================================================================================================================
//	ConsoleControlHandler
//===========================================================================================================================

static BOOL WINAPI	ConsoleControlHandler( DWORD inControlEvent )
{
	BOOL		handled;
	
	handled = 0;
	switch( inControlEvent )
	{
		case CTRL_C_EVENT:
		case CTRL_BREAK_EVENT:
		case CTRL_CLOSE_EVENT:
		case CTRL_LOGOFF_EVENT:
		case CTRL_SHUTDOWN_EVENT:
			gQuit = 1;
			handled = 1;
			break;
		
		default:
			break;
	}
	return( handled );
}

//===========================================================================================================================
//	BrowserCallBack
//===========================================================================================================================

static void BrowserCallBack( void *inContext, DNSBrowserRef inRef, DNSStatus inStatusCode, const DNSBrowserEvent *inEvent )
{
	#pragma unused( inContext, inRef, inStatusCode )
	
	char		ifIP[ 32 ];
	char		ip[ 32 ];
	
	switch( inEvent->type )
	{
		case kDNSBrowserEventTypeRelease:
			break;
			
		case kDNSBrowserEventTypeAddDomain:			
			fprintf( stdout, "domain \"%s\" added on interface %s\n", 
					 inEvent->data.addDomain.domain, 
					 IPv4ToString( inEvent->data.addDomain.interfaceAddr.u.ipv4.address, ifIP ) );
			break;
		
		case kDNSBrowserEventTypeAddDefaultDomain:
			fprintf( stdout, "default domain \"%s\" added on interface %s\n", 
					 inEvent->data.addDefaultDomain.domain, 
					 IPv4ToString( inEvent->data.addDefaultDomain.interfaceAddr.u.ipv4.address, ifIP ) );
			break;
		
		case kDNSBrowserEventTypeRemoveDomain:
			fprintf( stdout, "domain \"%s\" removed on interface %s\n", 
					 inEvent->data.removeDomain.domain, 
					 IPv4ToString( inEvent->data.removeDomain.interfaceAddr.u.ipv4.address, ifIP ) );
			break;
		
		case kDNSBrowserEventTypeAddService:
			fprintf( stdout, "service \"%s.%s%s\" added on interface %s\n", 
					 inEvent->data.addService.name, 
					 inEvent->data.addService.type, 
					 inEvent->data.addService.domain, 
					 IPv4ToString( inEvent->data.addService.interfaceAddr.u.ipv4.address, ifIP ) );
			break;
		
		case kDNSBrowserEventTypeRemoveService:
			fprintf( stdout, "service \"%s.%s%s\" removed on interface %s\n", 
					 inEvent->data.removeService.name, 
					 inEvent->data.removeService.type, 
					 inEvent->data.removeService.domain, 
					 IPv4ToString( inEvent->data.removeService.interfaceAddr.u.ipv4.address, ifIP ) );
			break;
		
		case kDNSBrowserEventTypeResolved:
			fprintf( stdout, "resolved \"%s.%s%s\" to %s:%u on interface %s with text \"%s\"\n", 
					 inEvent->data.resolved->name, 
					 inEvent->data.resolved->type, 
					 inEvent->data.resolved->domain, 
					 IPv4ToString( inEvent->data.resolved->address.u.ipv4.address, ip ), 
					 inEvent->data.resolved->address.u.ipv4.port, 
					 IPv4ToString( inEvent->data.resolved->interfaceAddr.u.ipv4.address, ifIP ), 
					 inEvent->data.resolved->textRecord );
			break;
		
		default:
			break;
	}
}

//===========================================================================================================================
//	ResolverCallBack
//===========================================================================================================================

static void ResolverCallBack( void *inContext, DNSResolverRef inRef, DNSStatus inStatusCode, const DNSResolverEvent *inEvent )
{
	#pragma unused( inContext, inRef, inStatusCode )
	
	char		ifIP[ 32 ];
	char		ip[ 32 ];
	
	switch( inEvent->type )
	{
		case kDNSResolverEventTypeResolved:
			fprintf( stdout, "resolved \"%s.%s.%s\" to %s:%u on interface %s with text \"%s\"\n", 
					 inEvent->data.resolved.name, 
					 inEvent->data.resolved.type, 
					 inEvent->data.resolved.domain, 
					 IPv4ToString( inEvent->data.resolved.address.u.ipv4.address, ip ), 
					 inEvent->data.resolved.interfaceAddr.u.ipv4.port, 
					 IPv4ToString( inEvent->data.resolved.interfaceAddr.u.ipv4.address, ifIP ), 
					 inEvent->data.resolved.textRecord );
			break;
		
		case kDNSResolverEventTypeRelease:
			break;
		
		default:
			break;
	}
}

//===========================================================================================================================
//	RegistrationCallBack
//===========================================================================================================================

static void
	RegistrationCallBack( 
		void *							inContext, 
		DNSRegistrationRef				inRef, 
		DNSStatus						inStatusCode, 
		const DNSRegistrationEvent *	inEvent )
{
	#pragma unused( inContext, inRef, inStatusCode )
	
	switch( inEvent->type )
	{
		case kDNSRegistrationEventTypeRelease:	
			break;
		
		case kDNSRegistrationEventTypeRegistered:
			fprintf( stdout, "name registered and active\n" );
			break;

		case kDNSRegistrationEventTypeNameCollision:
			fprintf( stdout, "name in use, please choose another name\n" );
			break;
		
		default:
			break;
	}
}

//===========================================================================================================================
//	IPv4ToString
//===========================================================================================================================

static char *	IPv4ToString( DNSUInt32 inIP, char *outString )
{
	unsigned int		ip[ 4 ];
		
	ip[ 0 ] = ( inIP >> 24 ) & 0xFF;
	ip[ 1 ] = ( inIP >> 16 ) & 0xFF;
	ip[ 2 ] = ( inIP >>  8 ) & 0xFF;
	ip[ 3 ] = ( inIP >>  0 ) & 0xFF;
	
	sprintf( outString, "%u.%u.%u.%u", ip[ 0 ], ip[ 1 ], ip[ 2 ], ip[ 3 ] );
	return( outString );
}
