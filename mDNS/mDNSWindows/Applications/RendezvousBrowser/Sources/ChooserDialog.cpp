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
	$Id: ChooserDialog.cpp,v 1.1 2003/07/18 19:41:54 dean Exp $

	Contains:	Rendezvous Browser for Windows.
	
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
    
        $Log: ChooserDialog.cpp,v $
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

        Revision 1.3  2002/09/21 20:44:55  zarzycki
        Added APSL info

        Revision 1.2  2002/09/20 08:39:21  bradley
        Make sure each resolved item matches the selected service type to handle resolved that may have
        been queued up on the Windows Message Loop. Reduce column to fit when scrollbar is present.

        Revision 1.1  2002/09/20 06:12:52  bradley
        Rendezvous Browser for Windows

*/

#include	<assert.h>
#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	<time.h>

#include	<algorithm>
#include	<memory>

#include	"stdafx.h"

#include	"DNSServices.h"

#include	"Application.h"
#include	"AboutDialog.h"
#include	"Resource.h"

#include	"ChooserDialog.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

#if 0
#pragma mark == Constants ==
#endif

//===========================================================================================================================
//	Constants
//===========================================================================================================================

// Menus

enum
{
	kChooserMenuIndexFile	= 0, 
	kChooserMenuIndexHelp	= 1 
};

// Domain List
	
#define kDomainListDefaultDomainColumnIndex			0
#define kDomainListDefaultDomainColumnWidth		 	140 
	
// Service List
	
#define kServiceListDefaultServiceColumnIndex		0
#define kServiceListDefaultServiceColumnWidth		140
	
// Chooser List
	
#define kChooserListDefaultNameColumnIndex			0
#define kChooserListDefaultNameColumnWidth			162
	
#define kChooserListDefaultIPColumnIndex			1
#define kChooserListDefaultIPColumnWidth			126

// Windows User Messages

#define	WM_USER_DOMAIN_ADD							( WM_USER + 0x100 )
#define	WM_USER_DOMAIN_REMOVE						( WM_USER + 0x101 )
#define	WM_USER_SERVICE_ADD							( WM_USER + 0x102 )
#define	WM_USER_SERVICE_REMOVE						( WM_USER + 0x103 )
#define	WM_USER_RESOLVE								( WM_USER + 0x104 )

#if 0
#pragma mark == Constants - Service Table ==
#endif

//===========================================================================================================================
//	Constants - Service Table
//===========================================================================================================================

struct	KnownServiceEntry
{
	const char *		serviceType;
	const char *		description;
	const char *		urlScheme;
	bool				useText;
};

static const KnownServiceEntry		kKnownServiceTable[] =
{
	{ "_airport._tcp.", 	"AirPort Base Station",				"acp://", 	false }, 
	{ "_afpovertcp._tcp.", 	"AppleShare Server", 				"afp://", 	false },
	{ "_ftp._tcp.", 		"File Transfer (FTP)", 				"ftp://", 	false }, 
	{ "_ichat._tcp.", 		"iChat",				 			"ichat://", false }, 
	{ "_printer._tcp.", 	"Printer (LPD)", 					"ldp://", 	false }, 
	{ "_eppc._tcp.", 		"Remote AppleEvents", 				"eppc://", 	false }, 
	{ "_ssh._tcp.", 		"Secure Shell (SSH)", 				"ssh://", 	false }, 
	{ "_tftp._tcp.", 		"Trivial File Transfer (TFTP)", 	"tftp://", 	false }, 
	{ "_http._tcp.", 		"Web Server (HTTP)", 				"http://", 	true  }, 
	{ "_smb._tcp.", 		"Windows File Sharing", 			"smb://", 	false }, 
	{ NULL,					NULL,								NULL,		false }, 
};

#if 0
#pragma mark == Structures ==
#endif

//===========================================================================================================================
//	Structures
//===========================================================================================================================

struct	DomainEventInfo
{
	DNSBrowserEventType		eventType;
	CString					domain;
	DNSNetworkAddress		ifIP;
};

struct	ServiceEventInfo
{
	DNSBrowserEventType		eventType;
	std::string				name;
	std::string				type;
	std::string				domain;
	DNSNetworkAddress		ifIP;
};

#if 0
#pragma mark == Prototypes ==
#endif

//===========================================================================================================================
//	Prototypes
//===========================================================================================================================

static void
	BrowserCallBack( 
		void *					inContext, 
		DNSBrowserRef			inRef, 
		DNSStatus				inStatusCode,
		const DNSBrowserEvent *	inEvent );

static char *	DNSNetworkAddressToString( const DNSNetworkAddress *inAddr, char *outString );

#if 0
#pragma mark == Message Map ==
#endif

//===========================================================================================================================
//	Message Map
//===========================================================================================================================

BEGIN_MESSAGE_MAP(ChooserDialog, CDialog)
	//{{AFX_MSG_MAP(ChooserDialog)
	ON_WM_SYSCOMMAND()
	ON_NOTIFY(LVN_ITEMCHANGED, IDC_DOMAIN_LIST, OnDomainListChanged)
	ON_NOTIFY(LVN_ITEMCHANGED, IDC_SERVICE_LIST, OnServiceListChanged)
	ON_NOTIFY(LVN_ITEMCHANGED, IDC_CHOOSER_LIST, OnChooserListChanged)
	ON_NOTIFY(NM_DBLCLK, IDC_CHOOSER_LIST, OnChooserListDoubleClick)
	ON_COMMAND(ID_HELP_ABOUT, OnAbout)
	ON_WM_INITMENUPOPUP()
	ON_WM_ACTIVATE()
	ON_COMMAND(ID_FILE_CLOSE, OnFileClose)
	ON_COMMAND(ID_FILE_EXIT, OnExit)
	ON_WM_CLOSE()
	ON_WM_NCDESTROY()
	//}}AFX_MSG_MAP
	ON_MESSAGE( WM_USER_DOMAIN_ADD, OnDomainAdd )
	ON_MESSAGE( WM_USER_DOMAIN_REMOVE, OnDomainRemove )
	ON_MESSAGE( WM_USER_SERVICE_ADD, OnServiceAdd )
	ON_MESSAGE( WM_USER_SERVICE_REMOVE, OnServiceRemove )
	ON_MESSAGE( WM_USER_RESOLVE, OnResolve )
END_MESSAGE_MAP()

#if 0
#pragma mark == Routines ==
#endif

//===========================================================================================================================
//	ChooserDialog
//===========================================================================================================================

ChooserDialog::ChooserDialog( CWnd *inParent )
	: CDialog( ChooserDialog::IDD, inParent)
{
	//{{AFX_DATA_INIT(ChooserDialog)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
	
	// Load menu accelerator table.

	mMenuAcceleratorTable = ::LoadAccelerators( AfxGetInstanceHandle(), MAKEINTRESOURCE( IDR_CHOOSER_DIALOG_MENU_ACCELERATORS ) );
	assert( mMenuAcceleratorTable );
	
	mBrowser 			= NULL;
	mIsServiceBrowsing	= false;
}

//===========================================================================================================================
//	~ChooserDialog
//===========================================================================================================================

ChooserDialog::~ChooserDialog( void )
{
	if( mBrowser )
	{
		DNSStatus		err;
		
		err = DNSBrowserRelease( mBrowser, 0 );
		assert( err == kDNSNoErr );
	}
}

//===========================================================================================================================
//	DoDataExchange
//===========================================================================================================================

void ChooserDialog::DoDataExchange( CDataExchange *pDX )
{
	CDialog::DoDataExchange(pDX);

	//{{AFX_DATA_MAP(ChooserDialog)
	DDX_Control(pDX, IDC_SERVICE_LIST, mServiceList);
	DDX_Control(pDX, IDC_DOMAIN_LIST, mDomainList);
	DDX_Control(pDX, IDC_CHOOSER_LIST, mChooserList);
	//}}AFX_DATA_MAP
}

//===========================================================================================================================
//	OnInitDialog
//===========================================================================================================================

BOOL	ChooserDialog::OnInitDialog( void )
{
	BOOL			result;
	CString			tempString;
	DNSStatus		err;
	
	// Initialize our parent.

	CDialog::OnInitDialog();

	// Set up the Domain List.
	
	result = tempString.LoadString( IDS_CHOOSER_DOMAIN_COLUMN_NAME );
	assert( result );
	mDomainList.InsertColumn( 0, tempString, LVCFMT_LEFT, kDomainListDefaultDomainColumnWidth );
	
	// Set up the Service List.
	
	result = tempString.LoadString( IDS_CHOOSER_SERVICE_COLUMN_NAME );
	assert( result );
	mServiceList.InsertColumn( 0, tempString, LVCFMT_LEFT, kServiceListDefaultServiceColumnWidth );
	
	PopulateServicesList();
	
	// Set up the Chooser List.
	
	result = tempString.LoadString( IDS_CHOOSER_CHOOSER_NAME_COLUMN_NAME );
	assert( result );
	mChooserList.InsertColumn( 0, tempString, LVCFMT_LEFT, kChooserListDefaultNameColumnWidth );
	
	result = tempString.LoadString( IDS_CHOOSER_CHOOSER_IP_COLUMN_NAME );
	assert( result );
	mChooserList.InsertColumn( 1, tempString, LVCFMT_LEFT, kChooserListDefaultIPColumnWidth );
	
	// Set up the other controls.
	
	UpdateInfoDisplay();
	
	// Start browsing for domains.
	
	err = DNSBrowserCreate( 0, BrowserCallBack, this, &mBrowser );
	assert( err == kDNSNoErr );
	
	err = DNSBrowserStartDomainSearch( mBrowser, 0 );
	assert( err == kDNSNoErr );
	
	return( true );
}

//===========================================================================================================================
//	OnFileClose
//===========================================================================================================================

void ChooserDialog::OnFileClose() 
{
	OnClose();
}

//===========================================================================================================================
//	OnActivate
//===========================================================================================================================

void ChooserDialog::OnActivate( UINT nState, CWnd* pWndOther, BOOL bMinimized )
{
	// Always make the active window the "main" window so modal dialogs work better and the app quits after closing 
	// the last window.

	gApp.m_pMainWnd = this;

	CDialog::OnActivate(nState, pWndOther, bMinimized);
}

//===========================================================================================================================
//	PostNcDestroy
//===========================================================================================================================

void	ChooserDialog::PostNcDestroy() 
{
	// Call the base class to do the normal cleanup.

	delete this;
}

//===========================================================================================================================
//	PreTranslateMessage
//===========================================================================================================================

BOOL	ChooserDialog::PreTranslateMessage(MSG* pMsg) 
{
	BOOL		result;
	
	result = false;
	assert( mMenuAcceleratorTable );
	if( mMenuAcceleratorTable )
	{
		result = ::TranslateAccelerator( m_hWnd, mMenuAcceleratorTable, pMsg );
	}
	if( !result )
	{
		result = CDialog::PreTranslateMessage( pMsg );
	}
	return( result );
}

//===========================================================================================================================
//	OnInitMenuPopup
//===========================================================================================================================

void	ChooserDialog::OnInitMenuPopup( CMenu *pPopupMenu, UINT nIndex, BOOL bSysMenu ) 
{
	CDialog::OnInitMenuPopup( pPopupMenu, nIndex, bSysMenu );

	switch( nIndex )
	{
		case kChooserMenuIndexFile:
			break;

		case kChooserMenuIndexHelp:
			break;

		default:
			break;
	}
}

//===========================================================================================================================
//	OnExit
//===========================================================================================================================

void ChooserDialog::OnExit() 
{
	AfxPostQuitMessage( 0 );
}

//===========================================================================================================================
//	OnAbout
//===========================================================================================================================

void	ChooserDialog::OnAbout() 
{
	AboutDialog		dialog;
	
	dialog.DoModal();
}

//===========================================================================================================================
//	OnSysCommand
//===========================================================================================================================

void	ChooserDialog::OnSysCommand( UINT inID, LPARAM inParam ) 
{
	CDialog::OnSysCommand( inID, inParam );
}

//===========================================================================================================================
//	OnClose
//===========================================================================================================================

void ChooserDialog::OnClose() 
{
	StopBrowsing();
	
	gApp.m_pMainWnd = this;
	DestroyWindow();
}

//===========================================================================================================================
//	OnNcDestroy
//===========================================================================================================================

void ChooserDialog::OnNcDestroy() 
{
	gApp.m_pMainWnd = this;

	CDialog::OnNcDestroy();
}

//===========================================================================================================================
//	OnDomainListChanged
//===========================================================================================================================

void	ChooserDialog::OnDomainListChanged( NMHDR *pNMHDR, LRESULT *pResult ) 
{
	UNUSED_ALWAYS( pNMHDR );
	
	// Domain list changes have similar effects to service list changes so reuse that code path by calling it here.
	
	OnServiceListChanged( NULL, NULL );
	
	*pResult = 0;
}

//===========================================================================================================================
//	OnServiceListChanged
//===========================================================================================================================

void	ChooserDialog::OnServiceListChanged( NMHDR *pNMHDR, LRESULT *pResult ) 
{
	int				selectedType;
	int				selectedDomain;
	
	UNUSED_ALWAYS( pNMHDR );
	
	// Stop any existing service search.
	
	StopBrowsing();
	
	// If a domain and service type are selected, start searching for the service type on the domain.
	
	selectedType 	= mServiceList.GetNextItem( -1, LVNI_SELECTED );
	selectedDomain 	= mDomainList.GetNextItem( -1, LVNI_SELECTED );
	
	if( ( selectedType >= 0 ) && ( selectedDomain >= 0 ) )
	{
		CString		type;
		CString		domain;
		
		type 	= mServiceTypes[ selectedType ].serviceType.c_str();
		domain 	= mDomainList.GetItemText( selectedDomain, 0 );
		
		StartBrowsing( type, domain );
	}
	
	if( pResult )
	{
		*pResult = 0;
	}
}

//===========================================================================================================================
//	OnChooserListChanged
//===========================================================================================================================

void	ChooserDialog::OnChooserListChanged( NMHDR *pNMHDR, LRESULT *pResult ) 
{
	UNUSED_ALWAYS( pNMHDR );
	
	UpdateInfoDisplay();
	*pResult = 0;
}

//===========================================================================================================================
//	OnChooserListDoubleClick
//===========================================================================================================================

void	ChooserDialog::OnChooserListDoubleClick( NMHDR *pNMHDR, LRESULT *pResult )
{
	int		selectedItem;
	
	UNUSED_ALWAYS( pNMHDR );
	
	// Display the service instance if it is selected. Otherwise, clear all the info.
	
	selectedItem = mChooserList.GetNextItem( -1, LVNI_SELECTED );
	if( selectedItem >= 0 )
	{
		ServiceInstanceInfo *			p;
		CString							url;
		const KnownServiceEntry *		service;
		
		assert( selectedItem < (int) mServiceInstances.size() );
		p = &mServiceInstances[ selectedItem ];
		
		// Search for a known service type entry that matches.
		
		for( service = kKnownServiceTable; service->serviceType; ++service )
		{
			if( p->type == service->serviceType )
			{
				break;
			}
		}
		if( service->serviceType )
		{
			// Create a URL representing the service instance. Special case for SMB (no port number).
			
			if( service->serviceType == "_smb._tcp" )
			{
				url.Format( "%s%s/", service->urlScheme, (const char *) p->ip.c_str() ); 
			}
			else
			{
				const char *		text;
				
				text = service->useText ? p->text.c_str() : "";
				url.Format( "%s%s/%s", service->urlScheme, (const char *) p->ip.c_str(), text ); 
			}
			
			// Let the system open the URL in the correct app.
			
			ShellExecute( NULL, "open", url, "", "c:\\", SW_SHOWNORMAL );
		}
	}
	*pResult = 0;
}

//===========================================================================================================================
//	OnCancel
//===========================================================================================================================

void ChooserDialog::OnCancel() 
{
	// Do nothing.
}

//===========================================================================================================================
//	PopulateServicesList
//===========================================================================================================================

void	ChooserDialog::PopulateServicesList( void )
{
	ServiceTypeVector::iterator		i;
	
	// Add a fixed list of known services.
	
	if( mServiceTypes.empty() )
	{
		const KnownServiceEntry *		service;
		
		for( service = kKnownServiceTable; service->serviceType; ++service )
		{
			ServiceTypeInfo		info;
			
			info.serviceType 	= service->serviceType;
			info.description 	= service->description;
			info.urlScheme 		= service->urlScheme;
			mServiceTypes.push_back( info );
		}
	}
	
	// Add each service to the list.
	
	for( i = mServiceTypes.begin(); i != mServiceTypes.end(); ++i )
	{
		mServiceList.InsertItem( mServiceList.GetItemCount(), ( *i ).description.c_str() );
	}
	
	// Select the first service type by default.
	
	if( !mServiceTypes.empty() )
	{
		mServiceList.SetItemState( 0, LVIS_SELECTED | LVIS_FOCUSED, LVIS_SELECTED | LVIS_FOCUSED );
	}
}

//===========================================================================================================================
//	UpdateInfoDisplay
//===========================================================================================================================

void	ChooserDialog::UpdateInfoDisplay( void )
{
	int				selectedItem;
	std::string		name;
	std::string		ip;
	std::string		ifIP;
	std::string		text;
	CWnd *			item;
	
	// Display the service instance if it is selected. Otherwise, clear all the info.
	
	selectedItem = mChooserList.GetNextItem( -1, LVNI_SELECTED );
	if( selectedItem >= 0 )
	{
		ServiceInstanceInfo *		p;
		
		assert( selectedItem < (int) mServiceInstances.size() );
		p = &mServiceInstances[ selectedItem ];
		
		name 	= p->name;
		ip 		= p->ip;
		ifIP 	= p->ifIP;
		text 	= p->text;
		
		// Sync up the list items with the actual data (IP address may change).
		
		mChooserList.SetItemText( selectedItem, 1, ip.c_str() );
	}
	
	// Name
	
	item = (CWnd *) this->GetDlgItem( IDC_INFO_NAME_TEXT );
	assert( item );
	item->SetWindowText( name.c_str() );
	
	// IP
	
	item = (CWnd *) this->GetDlgItem( IDC_INFO_IP_TEXT );
	assert( item );
	item->SetWindowText( ip.c_str() );
	
	// Interface
	
	item = (CWnd *) this->GetDlgItem( IDC_INFO_INTERFACE_TEXT );
	assert( item );
	item->SetWindowText( ifIP.c_str() );
	
	// Text
	
	if( text.size() > 255 )
	{
		text.resize( 255 );
	}
	item = (CWnd *) this->GetDlgItem( IDC_INFO_TEXT_TEXT );
	assert( item );
	item->SetWindowText( text.c_str() );
}

#if 0
#pragma mark -
#endif

//===========================================================================================================================
//	OnDomainAdd
//===========================================================================================================================

LONG	ChooserDialog::OnDomainAdd( WPARAM inWParam, LPARAM inLParam )
{
	DomainEventInfo *						p;
	std::auto_ptr < DomainEventInfo >		pAutoPtr;
	int										n;
	int										i;
	CString									domain;
	CString									s;
	bool									found;
	
	UNUSED_ALWAYS( inWParam );
	
	assert( inLParam );
	p = reinterpret_cast <DomainEventInfo *> ( inLParam );
	pAutoPtr.reset( p );
	
	// Search to see if we already know about this domain. If not, add it to the list.
	
	found = false;
	domain = p->domain;
	n = mDomainList.GetItemCount();
	for( i = 0; i < n; ++i )
	{
		s = mDomainList.GetItemText( i, 0 );
		if( s == domain )
		{
			found = true;
			break;
		}
	}
	if( !found )
	{
		int		selectedItem;
		
		mDomainList.InsertItem( n, domain );
		
		// If no domains are selected and the domain being added is a default domain, select it.
		
		selectedItem = mDomainList.GetNextItem( -1, LVNI_SELECTED );
		if( ( selectedItem < 0 ) && ( p->eventType == kDNSBrowserEventTypeAddDefaultDomain ) )
		{
			mDomainList.SetItemState( n, LVIS_SELECTED | LVIS_FOCUSED, LVIS_SELECTED | LVIS_FOCUSED );
		}
	}
	return( 0 );
}

//===========================================================================================================================
//	OnDomainRemove
//===========================================================================================================================

LONG	ChooserDialog::OnDomainRemove( WPARAM inWParam, LPARAM inLParam )
{
	DomainEventInfo *						p;
	std::auto_ptr < DomainEventInfo >		pAutoPtr;
	int										n;
	int										i;
	CString									domain;
	CString									s;
	bool									found;
	
	UNUSED_ALWAYS( inWParam );
	
	assert( inLParam );
	p = reinterpret_cast <DomainEventInfo *> ( inLParam );
	pAutoPtr.reset( p );
	
	// Search to see if we know about this domain. If so, remove it from the list.
	
	found = false;
	domain = p->domain;
	n = mDomainList.GetItemCount();
	for( i = 0; i < n; ++i )
	{
		s = mDomainList.GetItemText( i, 0 );
		if( s == domain )
		{
			found = true;
			break;
		}
	}
	if( found )
	{
		mDomainList.DeleteItem( i );
	}
	return( 0 );
}

//===========================================================================================================================
//	OnServiceAdd
//===========================================================================================================================

LONG	ChooserDialog::OnServiceAdd( WPARAM inWParam, LPARAM inLParam )
{
	ServiceEventInfo *						p;
	std::auto_ptr < ServiceEventInfo >		pAutoPtr;
	
	UNUSED_ALWAYS( inWParam );
	
	assert( inLParam );
	p = reinterpret_cast <ServiceEventInfo *> ( inLParam );
	pAutoPtr.reset( p );
	
	return( 0 );
}

//===========================================================================================================================
//	OnServiceRemove
//===========================================================================================================================

LONG	ChooserDialog::OnServiceRemove( WPARAM inWParam, LPARAM inLParam )
{
	ServiceEventInfo *						p;
	std::auto_ptr < ServiceEventInfo >		pAutoPtr;
	bool									found;
	int										n;
	int										i;
	
	UNUSED_ALWAYS( inWParam );
	
	assert( inLParam );
	p = reinterpret_cast <ServiceEventInfo *> ( inLParam );
	pAutoPtr.reset( p );
	
	// Search to see if we know about this service instance. If so, remove it from the list.
	
	found = false;
	n = (int) mServiceInstances.size();
	for( i = 0; i < n; ++i )
	{
		ServiceInstanceInfo *		q;
		
		// If the name, type, domain, and interface match, treat it as the same service instance.
		
		q = &mServiceInstances[ i ];
		if( ( p->name 	== q->name ) 	&& 
			( p->type 	== q->type ) 	&& 
			( p->domain	== q->domain ) )
		{
			found = true;
			break;
		}
	}
	if( found )
	{
		mChooserList.DeleteItem( i );
		assert( i < (int) mServiceInstances.size() );
		mServiceInstances.erase( mServiceInstances.begin() + i );
	}
	return( 0 );
}

//===========================================================================================================================
//	OnResolve
//===========================================================================================================================

LONG	ChooserDialog::OnResolve( WPARAM inWParam, LPARAM inLParam )
{
	ServiceInstanceInfo *						p;
	std::auto_ptr < ServiceInstanceInfo >		pAutoPtr;
	int											selectedType;
	int											n;
	int											i;
	bool										found;
	
	UNUSED_ALWAYS( inWParam );
	
	assert( inLParam );
	p = reinterpret_cast <ServiceInstanceInfo *> ( inLParam );
	pAutoPtr.reset( p );
	
	// Make sure it is for an item of the correct type. This handles any resolves that may have been queued up.
	
	selectedType = mServiceList.GetNextItem( -1, LVNI_SELECTED );
	assert( selectedType >= 0 );
	if( selectedType >= 0 )
	{
		assert( selectedType <= (int) mServiceTypes.size() );
		if( p->type != mServiceTypes[ selectedType ].serviceType )
		{
			goto exit;
		}
	}
	
	// Search to see if we know about this service instance. If so, update its info. Otherwise, add it to the list.
	
	found = false;
	n = (int) mServiceInstances.size();
	for( i = 0; i < n; ++i )
	{
		ServiceInstanceInfo *		q;
		
		// If the name, type, domain, and interface matches, treat it as the same service instance.
				
		q = &mServiceInstances[ i ];
		if( ( p->name 	== q->name ) 	&& 
			( p->type 	== q->type ) 	&& 
			( p->domain	== q->domain ) 	&& 
			( p->ifIP 	== q->ifIP ) )
		{
			found = true;
			break;
		}
	}
	if( found )
	{
		mServiceInstances[ i ] = *p;
	}
	else
	{
		mServiceInstances.push_back( *p );
		mChooserList.InsertItem( n, p->name.c_str() );
		mChooserList.SetItemText( n, 1, p->ip.c_str() );
		
		// If this is the only item, select it.
		
		if( n == 0 )
		{
			mChooserList.SetItemState( n, LVIS_SELECTED | LVIS_FOCUSED, LVIS_SELECTED | LVIS_FOCUSED );
		}
	}
	UpdateInfoDisplay();

exit:
	return( 0 );
}

//===========================================================================================================================
//	StartBrowsing
//===========================================================================================================================

void	ChooserDialog::StartBrowsing( const char *inType, const char *inDomain )
{
	DNSStatus		err;
	
	assert( mServiceInstances.empty() );
	assert( mChooserList.GetItemCount() == 0 );
	assert( !mIsServiceBrowsing );
	
	mChooserList.DeleteAllItems();
	mServiceInstances.clear();
	
	mIsServiceBrowsing = true;
	err = DNSBrowserStartServiceSearch( mBrowser, kDNSBrowserFlagAutoResolve, inType, inDomain );
	assert( err == kDNSNoErr );
}

//===========================================================================================================================
//	StopBrowsing
//===========================================================================================================================

void	ChooserDialog::StopBrowsing( void )
{
	// If searching, stop.
	
	if( mIsServiceBrowsing )
	{
		DNSStatus		err;
		
		mIsServiceBrowsing = false;
		err = DNSBrowserStopServiceSearch( mBrowser, 0 );
		assert( err == kDNSNoErr );
	}
	
	// Remove all service instances.
	
	mChooserList.DeleteAllItems();
	assert( mChooserList.GetItemCount() == 0 );
	mServiceInstances.clear();
	assert( mServiceInstances.empty() );
	UpdateInfoDisplay();
}

#if 0
#pragma mark -
#endif

//===========================================================================================================================
//	BrowserCallBack
//===========================================================================================================================

static void
	BrowserCallBack( 
		void *					inContext, 
		DNSBrowserRef			inRef, 
		DNSStatus				inStatusCode,
		const DNSBrowserEvent *	inEvent )
{
	ChooserDialog *		dialog;
	UINT 				message;
	BOOL				posted;
	
	UNUSED_ALWAYS( inStatusCode );
	UNUSED_ALWAYS( inRef );
	
	// Check parameters.
	
	assert( inContext );
	dialog = reinterpret_cast <ChooserDialog *> ( inContext );
	
	try
	{
		switch( inEvent->type )
		{
			case kDNSBrowserEventTypeRelease:
				break;
			
			// Domains
			
			case kDNSBrowserEventTypeAddDomain:
			case kDNSBrowserEventTypeAddDefaultDomain:
			case kDNSBrowserEventTypeRemoveDomain:
			{
				DomainEventInfo *						domain;
				std::auto_ptr < DomainEventInfo >		domainAutoPtr;
				
				domain = new DomainEventInfo;
				domainAutoPtr.reset( domain );
				
				domain->eventType 	= inEvent->type;
				domain->domain 		= inEvent->data.addDomain.domain;
				domain->ifIP		= inEvent->data.addDomain.interfaceAddr;
				
				message = ( inEvent->type == kDNSBrowserEventTypeRemoveDomain ) ? WM_USER_DOMAIN_REMOVE : WM_USER_DOMAIN_ADD;
				posted = ::PostMessage( dialog->GetSafeHwnd(), message, 0, (LPARAM) domain );
				assert( posted );
				if( posted )
				{
					domainAutoPtr.release();
				}
				break;
			}
			
			// Services
			
			case kDNSBrowserEventTypeAddService:
			case kDNSBrowserEventTypeRemoveService:
			{
				ServiceEventInfo *						service;
				std::auto_ptr < ServiceEventInfo >		serviceAutoPtr;
				
				service = new ServiceEventInfo;
				serviceAutoPtr.reset( service );
				
				service->eventType 	= inEvent->type;
				service->name 		= inEvent->data.addService.name;
				service->type 		= inEvent->data.addService.type;
				service->domain		= inEvent->data.addService.domain;
				service->ifIP		= inEvent->data.addService.interfaceAddr;
				
				message = ( inEvent->type == kDNSBrowserEventTypeAddService ) ? WM_USER_SERVICE_ADD : WM_USER_SERVICE_REMOVE;
				posted = ::PostMessage( dialog->GetSafeHwnd(), message, 0, (LPARAM) service );
				assert( posted );
				if( posted )
				{
					serviceAutoPtr.release();
				}
				break;
			}
			
			// Resolves
			
			case kDNSBrowserEventTypeResolved:
			{
				ServiceInstanceInfo *						serviceInstance;
				std::auto_ptr < ServiceInstanceInfo >		serviceInstanceAutoPtr;
				char										s[ 32 ];
				
				serviceInstance = new ServiceInstanceInfo;
				serviceInstanceAutoPtr.reset( serviceInstance );
				
				serviceInstance->name 	= inEvent->data.resolved->name;
				serviceInstance->type 	= inEvent->data.resolved->type;
				serviceInstance->domain = inEvent->data.resolved->domain;
				serviceInstance->ip		= DNSNetworkAddressToString( &inEvent->data.resolved->address, s );
				serviceInstance->ifIP	= DNSNetworkAddressToString( &inEvent->data.resolved->interfaceAddr, s );
				serviceInstance->text 	= inEvent->data.resolved->textRecord;
				
				posted = ::PostMessage( dialog->GetSafeHwnd(), WM_USER_RESOLVE, 0, (LPARAM) serviceInstance );
				assert( posted );
				if( posted )
				{
					serviceInstanceAutoPtr.release();
				}
				break;
			}
			
			default:
				break;
		}
	}
	catch( ... )
	{
		// Don't let exceptions escape.
	}
}

//===========================================================================================================================
//	DNSNetworkAddressToString
//
//	Note: Currently only supports IPv4 network addresses.
//===========================================================================================================================

static char *	DNSNetworkAddressToString( const DNSNetworkAddress *inAddr, char *outString )
{
	unsigned int		ip[ 4 ];
	
	ip[ 0 ] = ( inAddr->u.ipv4.address >> 24 ) & 0xFF;
	ip[ 1 ] = ( inAddr->u.ipv4.address >> 16 ) & 0xFF;
	ip[ 2 ] = ( inAddr->u.ipv4.address >>  8 ) & 0xFF;
	ip[ 3 ] = ( inAddr->u.ipv4.address >>  0 ) & 0xFF;
	
	if( inAddr->u.ipv4.port != kDNSPortInvalid )
	{
		sprintf( outString, "%u.%u.%u.%u:%u", ip[ 0 ], ip[ 1 ], ip[ 2 ], ip[ 3 ], inAddr->u.ipv4.port );
	}
	else
	{
		sprintf( outString, "%u.%u.%u.%u", ip[ 0 ], ip[ 1 ], ip[ 2 ], ip[ 3 ] );
	}
	return( outString );
}
