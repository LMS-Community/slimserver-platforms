// SlimServer.h : main header file for the SlimServer application

//

#pragma once



#ifndef __AFXWIN_H__

	#error include 'stdafx.h' before including this file for PCH

#endif



#include "resource.h"       // main symbols
#include "DlgLoading.h"

// CSlimServerApp:
// See SlimServer.cpp for the implementation of this class
//

class CSlimServerApp : public CWinApp

{

public:

	CSlimServerApp();
	
	CString GetEXEPath();   
	CDlgLoading m_dLoading;
	
	// returns a string array with all the commands 
	// we should run on the slim 
	void GetCommandLineCommands(CStringArray & aCommands);  


// Overrides


public:

	virtual BOOL InitInstance();


// Implementation

	afx_msg void OnAppAbout();
	DECLARE_MESSAGE_MAP()

};



extern CSlimServerApp theApp;