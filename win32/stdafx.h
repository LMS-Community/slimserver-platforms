// stdafx.h : include file for standard system include files,

// or project specific include files that are used frequently,

// but are changed infrequently



#pragma once



#ifndef VC_EXTRALEAN

#define VC_EXTRALEAN		// Exclude rarely-used stuff from Windows headers

#endif



// Modify the following defines if you have to target a platform prior to the ones specified below.

// Refer to MSDN for the latest info on corresponding values for different platforms.

#ifndef WINVER				// Allow use of features specific to Windows 95 and Windows NT 4 or later.

#define WINVER 0x0400		// Change this to the appropriate value to target Windows 98 and Windows 2000 or later.

#endif



#ifndef _WIN32_WINNT		// Allow use of features specific to Windows NT 4 or later.

#define _WIN32_WINNT 0x0400		// Change this to the appropriate value to target Windows 98 and Windows 2000 or later.

#endif						



#ifndef _WIN32_WINDOWS		// Allow use of features specific to Windows 98 or later.

#define _WIN32_WINDOWS 0x0410 // Change this to the appropriate value to target Windows Me or later.

#endif



#ifndef _WIN32_IE			// Allow use of features specific to IE 4.0 or later.

#define _WIN32_IE 0x0400	// Change this to the appropriate value to target IE 5.0 or later.

#endif



#define _ATL_CSTRING_EXPLICIT_CONSTRUCTORS	// some CString constructors will be explicit



// turns off MFC's hiding of some common and often safely ignored warning messages

#define _AFX_ALL_WARNINGS







#include <afxwin.h>         // MFC core and standard components

#include <afxext.h>         // MFC extensions

#include <afxdisp.h>        // MFC Automation classes



#include <afxdtctl.h>		// MFC support for Internet Explorer 4 Common Controls

#ifndef _AFX_NO_AFXCMN_SUPPORT

#include <afxcmn.h>			// MFC support for Windows Common Controls

#endif // _AFX_NO_AFXCMN_SUPPORT



// #include <afxsock.h>		// MFC socket extensions -  maybe in future ... 

#include <afxhtml.h>



#include <afxpriv.h>			// used to get current dir
#include <afxsock.h>


#define WM_USER_NOTIFYICON	(WM_USER + 100)			// notify message from shell
#define WM_USER_HTTP_STARTED (WM_USER + 101)		// notify that http has started 
#define WM_USER_CONTROL_STARTED (WM_USER + 102)

// registry stuff - confirm on exit and hide on minimize 

// in future we may add window position 

#define REGISTRY_VERSION				_T("Version 1.0")
#define REGISTRY_CONFIRM_ON_EXIT		_T("Confirm On Exit")
#define REGISTRY_STOP_SERVER_ON_EXIT			_T("Stop Server On Exit")
#define REGISTRY_HIDE_WHEN_MINIMIZED	_T("Hide When Minimized") 
#define REGISTRY_ASSOCIATE_MP3			_T("Associate MP3 Files")


// the name of the slim  server application
#define SLIM_APP_NAME					_T("slim.exe")

// the name of the slim server service
#define SLIM_SVC_NAME					_T("slimsvc.exe")

// timers used to poll stdout from slim 
#define TIMER_DEBUG			1
// timer used to poll app while server is loading
#define TIMER_LOADING		2

// timer used to retry connection to http server 
#define TIMER_RECONNECT		3
