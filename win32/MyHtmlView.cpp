// MyHtmlView.cpp : implementation file
//

#include "stdafx.h"
#include "SlimServer.h"
#include "MyHtmlView.h"
#include "slimprefs.h"



// CMyHtmlView



IMPLEMENT_DYNCREATE(CMyHtmlView, CHtmlView)



CMyHtmlView::CMyHtmlView()

{
	m_iRetries = 0;
	m_bDisableNavigation = false; 
	m_bAppStarted = false;
	
	// get the name of the pref file 
	CString filename = theApp.GetEXEPath(); 
	filename += _T("\\server\\slimserver.pref"); 
	
	CSlimPrefs prefs (filename); 

	m_iHttpPort = prefs.GetSlimHttpPort();		
}



CMyHtmlView::~CMyHtmlView()

{

}



void CMyHtmlView::DoDataExchange(CDataExchange* pDX)

{

	CHtmlView::DoDataExchange(pDX);

}



BEGIN_MESSAGE_MAP(CMyHtmlView, CHtmlView)

	ON_COMMAND(ID_GO_BACK, OnGoBack)
	ON_COMMAND(ID_GO_FORWARD, OnGoForward)
	ON_COMMAND(ID_GO_START_PAGE, OnHome)
	ON_COMMAND(ID_VIEW_REFRESH, OnRefresh)
	ON_COMMAND(ID_HELP_USINGTHESLIMREMOTE, OnHelpUsingtheslimremote)
	ON_COMMAND(ID_HELP_GETTINGSTARTED, OnHelpGettingstarted)
	ON_COMMAND(ID_HELP_PLAYERSETUP, OnHelpPlayersetup)
	ON_COMMAND(ID_HELP_FREQUENTLYASKEDQUESTIONS, OnHelpFAQ)
	ON_COMMAND(ID_HELP_REMOTECONTROLREFERENCE, OnHelpRemotecontrolreference)
	ON_COMMAND(ID_HELP_TECHNICALINFORMATION, OnHelpTechnicalinformation)
	ON_COMMAND(ID_FILE_RESCANLIBRARY, OnRescan)
	ON_COMMAND(ID_OPTIONS_SETMUSICFOLDER, OnOptionsSetmusicfolder)
	ON_COMMAND(ID_OPTIONS_SETPLAYLISTFOLDER, OnOptionsSetplaylistfolder)
	ON_MESSAGE(WM_USER_HTTP_STARTED ,OnStartHTTP)   

	ON_WM_TIMER()
END_MESSAGE_MAP()





// CMyHtmlView diagnostics



#ifdef _DEBUG

void CMyHtmlView::AssertValid() const

{

	CHtmlView::AssertValid();

}



void CMyHtmlView::Dump(CDumpContext& dc) const

{

	CHtmlView::Dump(dc);

}

#endif //_DEBUG





// CMyHtmlView message handlers


void CMyHtmlView::OnInitialUpdate()
{


//	TRACE ("%s/n",((CMDIFrameWnd *)AfxGetMainWnd())->FlashWindow(TRUE)); 

//	AfxGetMainWnd()->ShowWindow(SW_MINIMIZE);

	// test the http connection 
	m_controlSocket.Start(m_hWnd); 
	m_controlSocket.TestHTTP(m_iHttpPort); 
	CHtmlView::OnInitialUpdate();
}



void CMyHtmlView::OnGoBack()

{
	//m_controlSocket.ExecCommand("playlist clear");
	//m_controlSocket.ExecCommand("playlist append e:\\a.mp3 ");
	//m_controlSocket.ExecCommand("play");

	GoBack(); 
}



void CMyHtmlView::OnGoForward()

{
	GoForward(); 
}



void CMyHtmlView::OnHome()

{
	Navigate2(GetHTTP_URL()); 
}



void CMyHtmlView::OnRefresh()
{
	Refresh(); 
}


void CMyHtmlView::OnRescan()
{
	CString prf; 

	prf = _T("rescan");  
	m_controlSocket.ExecCommand(prf);

}

void CMyHtmlView::OnHelpUsingtheslimremote()
{
	Navigate2(GetHTTP_URL() + _T("/html/docs/interface.html"));
}



void CMyHtmlView::OnHelpGettingstarted()
{
	Navigate2(GetHTTP_URL() + _T("/html/docs/quickstart.html"));
}



void CMyHtmlView::OnHelpPlayersetup()
{
	Navigate2(GetHTTP_URL() + _T("/html/docs/ipconfig.html")); 
}

void CMyHtmlView::OnHelpFAQ()
{
	Navigate2(GetHTTP_URL() + _T("/html/docs/faq.html")); 
}


void CMyHtmlView::OnHelpRemotecontrolreference()
{
	Navigate2(GetHTTP_URL() + _T("/html/help_remote.html"));
}



void CMyHtmlView::OnHelpTechnicalinformation()
{
	Navigate2(GetHTTP_URL() + _T("/html/docs/index.html"));
}


void CMyHtmlView::OnNavigateError(LPCTSTR lpszURL, LPCTSTR lpszFrame, DWORD dwError, BOOL *pbCancel)
{
	// TODO: 5 is page not found - should probaly add proper includes ... 
	// will retry 6 times before showing page not found - this is important when the 
	// server is loading to ensure front page still shows up when there is a slow load time 

	if (HRESULT_CODE(dwError) == 5 && m_iRetries++ < 60 ) {
		SetTimer(TIMER_LOADING,500,NULL); 
		TRACE ("\nRetries = %i\n",m_iRetries);
	
	} 
	
	CHtmlView::OnNavigateError(lpszURL, lpszFrame, dwError, pbCancel);
}

void CMyHtmlView::OnOptionsSetmusicfolder()
{

	// get the name of the pref file 
	CString filename = theApp.GetEXEPath(); 
	filename += _T("\\server\\slimserver.pref"); 
	
	CSlimPrefs prefs (filename); 


	CString curDir;
	CString newDir;
	curDir = prefs.GetMusicFolder();

	if (GetFolder(&newDir,_T("Select Your Music Folder"), this->m_hWnd,NULL,curDir)) {
		CString prf; 

		prf = _T("pref audiodir ");  
		prf += URLEncode(newDir);

		m_controlSocket.ExecCommand(prf);

	//	url = GetHTTP_URL() + _T("/setup.html?page=server&mp3dir="); 
	//	url += URLEncode(newDir); 

	//	Navigate2(LPCTSTR(url),0,_T("browser"));
	} 	
}

void CMyHtmlView::OnOptionsSetplaylistfolder()
{
	
	// get the name of the pref file 
	CString filename = theApp.GetEXEPath(); 
	filename += _T("\\server\\slimserver.pref"); 
	
	CSlimPrefs prefs (filename); 

	CString curDir;
	CString newDir;
	curDir = prefs.GetPlaylistFolder();

	if (GetFolder(&newDir,_T("Select Your Play List Folder"), this->m_hWnd,NULL,curDir)) {
		
		CString prf; 

		prf = _T("pref playlistdir "); 
		prf += URLEncode(newDir); 

		m_controlSocket.ExecCommand(prf);

		//CString url; 

		//url = GetHTTP_URL() + _T("/setup.html?page=server&playlistdir="); 
		//url += URLEncode(newDir); 

		//Navigate2(LPCTSTR(url),0,_T("browser"));
	} 	
}

// refreshs the player status window 
void CMyHtmlView::RefreshPlayer(boolean bRefresh) {
	
	if (m_bDisableNavigation != bRefresh) { 
		
		m_bDisableNavigation = bRefresh; 
// Disabling this for now, as this URL is incorrect.
//		if (!m_bDisableNavigation) 
//			Navigate2(GetHTTP_URL() + _T("/status.html"),0,_T("status"));
	}
} 


void CMyHtmlView::OnBeforeNavigate2(LPCTSTR lpszURL, DWORD nFlags, LPCTSTR lpszTargetFrameName, CByteArray& baPostedData, LPCTSTR lpszHeaders, BOOL* pbCancel)
{
	TRACE (_T("Before navigate 2\n"));

	if (m_bDisableNavigation) {
		*pbCancel = TRUE; 
		TRACE (_T("navigation cancelled\n"));
	}
	else {
		CHtmlView::OnBeforeNavigate2(lpszURL, nFlags, lpszTargetFrameName, baPostedData, lpszHeaders, pbCancel);
		TRACE (_T("navigation successful\n"));
	}
}

void CMyHtmlView::OnDocumentComplete(LPCTSTR lpszURL)
{
	TRACE (_T("Document complete\n"));
	CHtmlView::OnDocumentComplete(lpszURL);
	if (!m_bAppStarted) {
		CString index =  GetHTTP_URL() + '/';
		if (index.Compare(lpszURL) == 0) {
			TRACE (_T("Showing main window\n"));
			AfxGetMainWnd()->ShowWindow(SW_SHOW);
			AfxGetMainWnd()->UpdateWindow();
			m_bAppStarted = true;
		
			// it would be cleaner to kill this window 
			theApp.m_dLoading.ShowWindow(SW_HIDE); 
		}
	}	
}

// a timer polls the http interface for now 
// to check if its loaded - may be cancelled with cestron stuff 
void CMyHtmlView::OnTimer(UINT nIDEvent)
{
	if (nIDEvent == TIMER_LOADING) {
		KillTimer(TIMER_LOADING);
		OnHome(); 
		return;
	} 

	CHtmlView::OnTimer(nIDEvent);
}


// handle the http startup detection
LRESULT CMyHtmlView::OnStartHTTP(UINT wParam, LONG lParam)
{	
	OnHome(); 
	return 0; 
}


// url encode function from : http://www.codeproject.com/string/urlencode.asp
//

inline BYTE toHex(const BYTE &x)
{
	return x > 9 ? x + 55: x + 48;
}


CString URLEncode(CString sIn)
{
    CString sOut;
	
    const int nLen = sIn.GetLength() + 1;

    register LPBYTE pOutTmp = NULL;
    LPBYTE pOutBuf = NULL;
    register LPBYTE pInTmp = NULL;
    LPBYTE pInBuf =(LPBYTE)sIn.GetBuffer(nLen);
    BYTE b = 0;
	
    //alloc out buffer
    pOutBuf = (LPBYTE)sOut.GetBuffer(nLen  * 3 - 2);//new BYTE [nLen  * 3];

    if(pOutBuf)
    {
        pInTmp	= pInBuf;
	pOutTmp = pOutBuf;
		
	// do encoding
	while (*pInTmp)
	{
	    if(isalnum(*pInTmp))
	        *pOutTmp++ = *pInTmp;
	 
		// Sam - 29 Aug 2002 - changed it to %20 for slim 

		//   else
		//       if(isspace(*pInTmp))
		//	    *pOutTmp++ = '+';
		
		else
		{
		    *pOutTmp++ = '%';
		    *pOutTmp++ = toHex(*pInTmp>>4);
		    *pOutTmp++ = toHex(*pInTmp%16);
		}
	    pInTmp++;
	}
	*pOutTmp = '\0';
	//sOut=pOutBuf;
	//delete [] pOutBuf;
	sOut.ReleaseBuffer();
    }
    sIn.ReleaseBuffer();
    return sOut;
}



// ----------------------------------------------------------------
// globals - for getting a folder - maybe move to another file 
// ----------------------------------------------------------------

CString strTmpPath;

int CALLBACK BrowseCallbackProc(HWND hwnd, UINT uMsg, LPARAM lParam, LPARAM lpData)
{
	TCHAR szDir[MAX_PATH];
	switch(uMsg){
	case BFFM_INITIALIZED:
		if (lpData){
			strcpy(szDir, strTmpPath.GetBuffer(strTmpPath.GetLength()));
			SendMessage(hwnd,BFFM_SETSELECTION,TRUE,(LPARAM)szDir);
		}
		break;
	case BFFM_SELCHANGED: {
	   if (SHGetPathFromIDList((LPITEMIDLIST) lParam ,szDir)){
		  SendMessage(hwnd,BFFM_SETSTATUSTEXT,0,(LPARAM)szDir);
	   }
	   break;
	}
	default:
	   break;
	}
         
	return 0;
}

BOOL GetFolder(CString* strSelectedFolder,
				   const char* lpszTitle,
				   const HWND hwndOwner, 
				   const char* strRootFolder, 
				   const char* strStartFolder)
{
	char pszDisplayName[MAX_PATH];
	LPITEMIDLIST lpID;
	BROWSEINFOA bi;
	
	bi.hwndOwner = hwndOwner;
	if (strRootFolder == NULL){
		bi.pidlRoot = NULL;
	}else{
	   LPITEMIDLIST  pIdl = NULL;
	   IShellFolder* pDesktopFolder;
	   char          szPath[MAX_PATH];
	   OLECHAR       olePath[MAX_PATH];
	   ULONG         chEaten;
	   ULONG         dwAttributes;

	   strcpy(szPath, (LPCTSTR)strRootFolder);
	   if (SUCCEEDED(SHGetDesktopFolder(&pDesktopFolder)))
	   {
		   MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, szPath, -1, olePath, MAX_PATH);
		   pDesktopFolder->ParseDisplayName(NULL, NULL, olePath, &chEaten, &pIdl, &dwAttributes);
		   pDesktopFolder->Release();
	   }
	   bi.pidlRoot = pIdl;
	}
	bi.pszDisplayName = pszDisplayName;
	bi.lpszTitle = lpszTitle;
	bi.ulFlags = BIF_RETURNONLYFSDIRS | BIF_STATUSTEXT;
	bi.lpfn = BrowseCallbackProc;
	if (strStartFolder == NULL){
		bi.lParam = FALSE;
	}else{
		strTmpPath.Format("%s", strStartFolder);
		bi.lParam = TRUE;
	}
	bi.iImage = NULL;
	lpID = SHBrowseForFolderA(&bi);
	if (lpID != NULL){
		BOOL b = SHGetPathFromIDList(lpID, pszDisplayName);
		if (b == TRUE){
			strSelectedFolder->Format("%s",pszDisplayName);
			return TRUE;
		}
	}else{
		strSelectedFolder->Empty();
	}
	return FALSE;
}



