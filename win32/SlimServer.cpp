// SlimServer.cpp : Defines the class behaviors for the application.

//
#include "stdafx.h"
#include "SlimServer.h"
#include "MainFrm.h"
#include "ChildFrm.h"
#include "SlimServerDoc.h"
#include "MyHtmlView.h"
#include "sinstance.h" 
#include "ControlSlim.h" 


#ifdef _DEBUG

#define new DEBUG_NEW

#endif





// CSlimServerApp



BEGIN_MESSAGE_MAP(CSlimServerApp, CWinApp)
	ON_COMMAND(ID_APP_ABOUT, OnAppAbout)

	// Standard file based document commands

	ON_COMMAND(ID_FILE_NEW, CWinApp::OnFileNew)
	ON_COMMAND(ID_FILE_OPEN, CWinApp::OnFileOpen)

	// Standard print setup command

	ON_COMMAND(ID_FILE_PRINT_SETUP, CWinApp::OnFilePrintSetup)

END_MESSAGE_MAP()





// CSlimServerApp construction



CSlimServerApp::CSlimServerApp()

{

	// TODO: add construction code here,

	// Place all significant initialization in InitInstance

}





// The one and only CSlimServerApp object



CSlimServerApp theApp;



// CSlimServerApp initialization

BOOL CSlimServerApp::InitInstance()

{


	CInstanceChecker instanceChecker;

	if (instanceChecker.PreviousInstanceRunning())
	{
		
		// attempt to run command line 
		CStringArray aCommands; 
		
		GetCommandLineCommands(aCommands); 

		if (aCommands.GetCount() > 0) {
			
			CControlSlim cs; 
			
			// all will explode if we do not do this 
			AfxSocketInit();

			for (int i=0;i<aCommands.GetCount();i++) {
				cs.SyncAdd(aCommands[i]); 
			} 

			//cs.SyncAdd(_T("playlist clear"));
			//cs.SyncAdd(_T("playlist append e:\\a.mp3"));
			//cs.SyncAdd(_T("playlist append e:\\b.mp3"));
			//cs.SyncAdd(_T("play"));

			
			cs.SyncExec(10000); 
		
		} else instanceChecker.ActivatePreviousInstance();
	 
		return FALSE;
	}

	// InitCommonControls() is required on Windows XP if an application
	// manifest specifies use of ComCtl32.dll version 6 or later to enable
	// visual styles.  Otherwise, any window creation will fail.

	InitCommonControls();
	CWinApp::InitInstance();


	if (!AfxSocketInit())
	{
		AfxMessageBox(IDP_SOCKETS_INIT_FAILED);
		return FALSE;
	}



	// Initialize OLE libraries

	if (!AfxOleInit())

	{
		AfxMessageBox(IDP_OLE_INIT_FAILED);
		return FALSE;
	}

	AfxEnableControlContainer();

	// Standard initialization

	SetRegistryKey(_T("SlimServer"));

	LoadStdProfileSettings(0);  // Load standard INI file options (including MRU)

	// Register the application's document templates.  Document templates

	//  serve as the connection between documents, frame windows and views

	CMultiDocTemplate* pDocTemplate;

	pDocTemplate = new CMultiDocTemplate(IDR_SlimServerTYPE,

		RUNTIME_CLASS(CSlimServerDoc),
		RUNTIME_CLASS(CChildFrame), // custom MDI child frame
		RUNTIME_CLASS(CMyHtmlView));

	AddDocTemplate(pDocTemplate);

	// create main MDI Frame window

	CMainFrame* pMainFrame = new CMainFrame;

	if (!pMainFrame->LoadFrame(IDR_MAINFRAME))
		return FALSE;

	m_pMainWnd = pMainFrame;

	// call DragAcceptFiles only if there's a suffix
	//  In an MDI app, this should occur immediately after setting m_pMainWnd
	// Parse command line for standard shell commands, DDE, file open
	CCommandLineInfo cmdInfo;
	ParseCommandLine(cmdInfo);

	// Dispatch commands specified on the command line.  Will return FALSE if
	// app was launched with /RegServer, /Register, /Unregserver or /Unregister.

	if (!ProcessShellCommand(cmdInfo))
		return FALSE;

	
	// If this is the first instance of our App then track it so any other instances can find it.
	if (!instanceChecker.PreviousInstanceRunning())
		instanceChecker.TrackFirstInstanceRunning();


	// The main window has been initialized, so show and update it
	m_nCmdShow = SW_HIDE; 

//	pMainFrame->ShowWindow(SW_SHOW);
	pMainFrame->ShowWindow(m_nCmdShow);
	pMainFrame->UpdateWindow();
	
	// show loading dialog 
	
	m_dLoading.Create(IDD_DIALOG_LOADING);
	m_dLoading.ShowWindow(SW_SHOW); 

	return TRUE;

}







// CAboutDlg dialog used for App About



class CAboutDlg : public CDialog

{

public:

	CAboutDlg();



// Dialog Data

	enum { IDD = IDD_ABOUTBOX };



protected:

	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support



// Implementation

protected:

	DECLARE_MESSAGE_MAP()

public:

	afx_msg void OnBnClickedOk();

};



CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)

{

}



void CAboutDlg::DoDataExchange(CDataExchange* pDX)

{

	CDialog::DoDataExchange(pDX);

}



BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)

	ON_BN_CLICKED(IDOK, OnBnClickedOk)

END_MESSAGE_MAP()



// App command to run the dialog

void CSlimServerApp::OnAppAbout()
{
	CAboutDlg aboutDlg;
	aboutDlg.DoModal();
}


CString CSlimServerApp::GetEXEPath() {  
	// this whole fiasco is done to avoid having a corrupt working dir 
	// especially since the working dir in visual studio is not ../
	// instead of ../debug 

	CString str = AfxGetApp()->m_pszExeName;
	str += ".exe";
	CString f1;
	AfxGetModuleShortFileName(AfxGetInstanceHandle(), f1);
	int l; 
	// convert to shortname length... 
	l = str.GetLength()>12?12:str.GetLength();
	CString d = f1.Left(f1.GetLength() - l);
	
	return(d); 

}

// returns a string array with all the commands 
// we should run on the slim 
void CSlimServerApp::GetCommandLineCommands(CStringArray & aCommands) {
	// before anything handle the two command line options 

	// 1. /ADD - to add songs to the list 
	// 2. /PLAY - to play a song or series of songs  

	// 

	bool bLongFile = false; 
	bool bPlay = false; 
	bool bAdd = false; 
	CStringArray aFiles; 
	CString sTemp; 
	CString sFileTemp; 
	CFileStatus fs; 
	
	int i; 

	for (i=1;i<__argc;i++) { 
		

		// simple parsing - im doing it here 
		// cause we really dont need to start up all the ole 
		// stuff etc and overriding the mfc command line looks 
		// a bit annoying 

		sTemp = __argv[i]; 
		sTemp.MakeLower();
		
		if (sTemp == _T("/play")) { 

			bPlay = true; 

		} else if (sTemp == _T("/add")) {

			bAdd = true;

		} else if ( (sTemp.Left(1)) == CString(_T("\""))  &&
			! (sTemp.Right(1)) == CString(_T("\"")) ) { 
		
			sFileTemp = sTemp; 
			bLongFile = true;
		
		} else if (bLongFile && sTemp.Right(1) == CString(_T("\"")) ) {
			sFileTemp += sTemp; 

			// test to see if its a file 
			if (CFile::GetStatus(sFileTemp,fs)) {
				// add without leading and trailing " 
				aFiles.Add(sFileTemp.Mid(1,sFileTemp.GetLength()-2));
			}
				
			sFileTemp.Empty();
			bLongFile = false;
		} else if (bLongFile) { 
			
			sFileTemp += sTemp; 
		
		} else {	
			
			if (CFile::GetStatus(sTemp,fs)) 
				aFiles.Add(sTemp);
		}
				 
	} 
	
	CString s; 

	if (bPlay) {
		s = _T("playlist clear");
		aCommands.Add(s); 
	} 
	
	for (i=0; i<aFiles.GetCount(); i++) { 
		s = _T("playlist append ") + URLEncode(aFiles[i]);
		aCommands.Add(s); 
	}

	if (bPlay) {
		s = _T("play");
		aCommands.Add(s); 
	} 

	return; 
} 

// CSlimServerApp message handlers




void CAboutDlg::OnBnClickedOk()

{

	// TODO: Add your control notification handler code here

	OnOK();

}

