// MainFrm.cpp : implementation of the CMainFrame class

#include "stdafx.h"
#include "SlimServer.h"
#include "MainFrm.h"
#include "MyHtmlView.h"
#include "MyOutputView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CMainFrame



IMPLEMENT_DYNAMIC(CMainFrame, CMDIFrameWnd)



BEGIN_MESSAGE_MAP(CMainFrame, CMDIFrameWnd)

	ON_WM_CREATE()
	ON_WM_DESTROY()
	ON_MESSAGE(WM_USER_NOTIFYICON,OnHandleIconNotify)   
	ON_WM_SIZE()
	ON_COMMAND(ID_OPTIONS_HIDEWHENMINIMIZED, OnOptionsHideWhenMinimized)
	ON_WM_INITMENU()
	ON_WM_CLOSE()
	ON_COMMAND(ID_OPTIONS_CONFIRMONEXIT, OnOptionsConfirmonexit)
	ON_COMMAND(ID_OPTIONS_STOPSERVERONEXIT, OnOptionsStopserveronexit)
	ON_WM_SIZING()
	ON_UPDATE_COMMAND_UI(ID_OPTIONS_CONFIRMONEXIT, OnUpdateConfirmOnExit)
	ON_UPDATE_COMMAND_UI(ID_OPTIONS_STOPSERVERONEXIT, OnUpdateConfirmStopServerOnExit)

END_MESSAGE_MAP()


static UINT indicators[] =

{

	ID_SEPARATOR,           // status line indicator

	ID_INDICATOR_CAPS,

	ID_INDICATOR_NUM,

	ID_INDICATOR_SCRL,

};





// CMainFrame construction/destruction



CMainFrame::CMainFrame()

: m_bHideWhenMinimized(true), m_bConfirmOnExit(true), m_bStopServerOnExit(true)

{

	// load up hide when minimized from registry ... 
	m_bConfirmOnExit =  (theApp.GetProfileInt(REGISTRY_VERSION, REGISTRY_CONFIRM_ON_EXIT,TRUE)!=0); 
	m_bStopServerOnExit =  (theApp.GetProfileInt(REGISTRY_VERSION, REGISTRY_STOP_SERVER_ON_EXIT,TRUE)!=0); 
	m_bHideWhenMinimized = (theApp.GetProfileInt(REGISTRY_VERSION, REGISTRY_HIDE_WHEN_MINIMIZED,FALSE)!=0); 
	m_bAssociateMp3	= (theApp.GetProfileInt(REGISTRY_VERSION, REGISTRY_ASSOCIATE_MP3,FALSE)!=0); 
}



CMainFrame::~CMainFrame()

{

}





int CMainFrame::OnCreate(LPCREATESTRUCT lpCreateStruct)

{



	CImageList img;

	CString str;



	if (CMDIFrameWnd::OnCreate(lpCreateStruct) == -1)

		return -1;

	

	// check the hide when minimized option if needed 





	if (!m_wndReBar.Create(this))

	{

		TRACE0("Failed to create rebar\n");

		return -1;      // fail to create

	}

	if (1) {

		if (!m_wndToolBar.CreateEx(this))

		{

			TRACE0("Failed to create toolbar\n");

			return -1;      // fail to create

		}

		// set up toolbar properties

		m_wndToolBar.GetToolBarCtrl().SetButtonWidth(50, 150);

		m_wndToolBar.GetToolBarCtrl().SetExtendedStyle(TBSTYLE_EX_DRAWDDARROWS);



		img.Create(IDB_TOOLBARHOT, 22, 0, RGB(255, 0, 255));

		m_wndToolBar.GetToolBarCtrl().SetHotImageList(&img);

		img.Detach();

		img.Create(IDB_TOOLBARCOLD, 22, 0, RGB(255, 0, 255));

		m_wndToolBar.GetToolBarCtrl().SetImageList(&img);

		img.Detach();

		m_wndToolBar.ModifyStyle(0, TBSTYLE_FLAT | TBSTYLE_TRANSPARENT);

		m_wndToolBar.SetButtons(NULL, 5);



		// set up each toolbar button

		

		m_wndToolBar.SetButtonInfo(0, ID_GO_BACK, TBSTYLE_BUTTON, 0);

		str.LoadString(IDS_BACK);

		m_wndToolBar.SetButtonText(0, str);

		m_wndToolBar.SetButtonInfo(1, ID_GO_FORWARD, TBSTYLE_BUTTON, 1);
		str.LoadString(IDS_FORWARD);
		m_wndToolBar.SetButtonText(1, str);

		
		m_wndToolBar.SetButtonInfo(2, ID_VIEW_REFRESH, TBSTYLE_BUTTON, 3);
		str.LoadString(IDS_REFRESH);
		m_wndToolBar.SetButtonText(2, str);


		m_wndToolBar.SetButtonInfo(3, NULL, TBSTYLE_SEP, 0);


		m_wndToolBar.SetButtonInfo(4, ID_GO_START_PAGE, TBSTYLE_BUTTON, 4);
		str.LoadString(IDS_HOME);
		m_wndToolBar.SetButtonText(4, str);
		CRect rectToolBar;



		// set up toolbar button sizes

		m_wndToolBar.GetItemRect(0, &rectToolBar);
		m_wndToolBar.SetSizes(rectToolBar.Size(), CSize(30,20));

	}

	if (!m_wndStatusBar.Create(this) ||

		!m_wndStatusBar.SetIndicators(indicators,

		  sizeof(indicators)/sizeof(UINT)))

	{

		TRACE0("Failed to create status bar\n");

		return -1;      // fail to create

	}

	// we want the toolbar to be docable otherwise it looks shoddy

	m_wndToolBar.EnableDocking(CBRS_ALIGN_ANY);
	EnableDocking(CBRS_ALIGN_ANY);
	DockControlBar(&m_wndToolBar);

	// show icon in taskbar 

	HICON hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);

	///Fill up the NOTIFYICONDATA Structure

	NOTIFYICONDATA iconData;

	iconData.cbSize		= sizeof(NOTIFYICONDATA);

	iconData.hWnd		= GetSafeHwnd();  //window's handle
	iconData.uID			= 100 ;  //identifier
	iconData.uFlags		= NIF_MESSAGE|NIF_ICON|NIF_TIP; //flags
	iconData.uCallbackMessage	= WM_USER_NOTIFYICON; //notification handler
	iconData.hIcon		= hIcon;    //icon handle   
	CString strToolTip = _T("Slim Server");



	//Fill up tool tip

	LPCTSTR lpszToolTip = strToolTip.GetBuffer(strToolTip.GetLength());
	lstrcpyn(iconData.szTip,lpszToolTip,(int)strlen(lpszToolTip)+1);

												

	//Tell the shell what we intend doing

	//Add,Delete,Modify ---> NIM_ADD,NIM_DELETE, NIM_MODIFY in dwMsgType

	Shell_NotifyIcon(NIM_ADD, &iconData); 



	// cleanup 

	if (hIcon)

		DestroyIcon(hIcon);



	return 0;

}



BOOL CMainFrame::PreCreateWindow(CREATESTRUCT& cs)

{



	if( !CMDIFrameWnd::PreCreateWindow(cs) )

		return FALSE;

	// TODO: Modify the Window class or styles here by modifying

	//  the CREATESTRUCT cs

	



	return TRUE;

}





// CMainFrame diagnostics



#ifdef _DEBUG

void CMainFrame::AssertValid() const

{

	CMDIFrameWnd::AssertValid();

}



void CMainFrame::Dump(CDumpContext& dc) const

{

	CMDIFrameWnd::Dump(dc);

}



#endif //_DEBUG





// CMainFrame message handlers





void CMainFrame::OnDestroy()

{



	CMDIFrameWnd::OnDestroy();



	NOTIFYICONDATA iconData;

	iconData.cbSize		= sizeof(NOTIFYICONDATA);

	iconData.hWnd		= GetSafeHwnd();  //window's handle

	iconData.uID			= 100 ;  //identifier

	Shell_NotifyIcon(NIM_DELETE, &iconData); 



}



LRESULT CMainFrame::OnHandleIconNotify(UINT wParam, LONG lParam)

{

	

	UINT uID = (UINT) wParam;

	UINT uMouseMsg = (UINT) lParam;

	if (uMouseMsg == WM_LBUTTONDOWN || uMouseMsg == WM_RBUTTONDOWN)

	{ 

		ActivateFrame();

		BringWindowToTop();

		SetForegroundWindow();

	}

	return 0;

}



void CMainFrame::OnSize(UINT nType, int cx, int cy)

{

	CMDIFrameWnd::OnSize(nType, cx, cy);

	// disable navigation if appropriate
	CMDIChildWnd* pChild=(CMDIChildWnd* )GetActiveFrame();
	CView* pView= pChild->GetActiveView();

	if (pView) {
		if(pView->IsKindOf(RUNTIME_CLASS(CMyHtmlView))){
			CMyHtmlView* pHtmlView = reinterpret_cast<CMyHtmlView*> (pView);
			pHtmlView->RefreshPlayer(nType == SIZE_MINIMIZED);  
			
		} 

	} 
	 

	// hide on minimize test 
	if (nType == SIZE_MINIMIZED && m_bHideWhenMinimized) {
		ShowWindow(SW_HIDE);
	}   

}



void CMainFrame::OnOptionsHideWhenMinimized()

{

	m_bHideWhenMinimized = ! m_bHideWhenMinimized;
	theApp.WriteProfileInt(REGISTRY_VERSION, REGISTRY_HIDE_WHEN_MINIMIZED,(BOOL)m_bHideWhenMinimized); 
	UpdateOptionsMenu();

}


void CMainFrame::OnUpdateConfirmOnExit(CCmdUI* pCmdUI) 

{

	CString app = SLIM_APP_NAME;

	if (!CMyOutputView::DoneStarted()) {
		 pCmdUI->Enable(false); 

		 pCmdUI->SetCheck(false);

	} else {

		 pCmdUI->Enable(true); 

		 pCmdUI->SetCheck(m_bConfirmOnExit);

	}

}


void CMainFrame::OnUpdateConfirmStopServerOnExit(CCmdUI* pCmdUI) 

{

	CString app = SLIM_APP_NAME;

	if (!CMyOutputView::DoneStarted()) {
		 pCmdUI->Enable(false); 

		 pCmdUI->SetCheck(false);

	} else {

		 pCmdUI->Enable(true); 

		 pCmdUI->SetCheck(m_bStopServerOnExit);

	}

}
// Updates the check boxes on the options menu

// a bit wasteful but much cleaner 

void CMainFrame::UpdateOptionsMenu(void)

{

	CMenu* pMenu = GetMenu(); 
	pMenu->CheckMenuItem(ID_OPTIONS_HIDEWHENMINIMIZED,m_bHideWhenMinimized?MF_CHECKED:MF_UNCHECKED);
}



void CMainFrame::OnInitMenu(CMenu* pMenu)

{

	CMDIFrameWnd::OnInitMenu(pMenu);
		
	// update options menu 
	UpdateOptionsMenu(); 

}



// when the user attempts to close the app 

void CMainFrame::OnClose()

{
	CString app = SLIM_APP_NAME;
	if (m_bConfirmOnExit && CMyOutputView::GetRunningProcess(app)) {

		int boxResult = AfxMessageBox(_T("You are closing the Slim Server window.  Do you also want to stop the server?"), MB_YESNOCANCEL);
			
		if (boxResult == IDCANCEL) {
			return;
		} else if (boxResult == IDYES) {
			m_bStopServerOnExit = 1;
			theApp.WriteProfileInt(REGISTRY_VERSION, REGISTRY_STOP_SERVER_ON_EXIT,(BOOL)m_bStopServerOnExit); 
		} else {
			m_bStopServerOnExit = 0;
			theApp.WriteProfileInt(REGISTRY_VERSION, REGISTRY_STOP_SERVER_ON_EXIT,(BOOL)m_bStopServerOnExit); 
		}
	}

	CMDIFrameWnd::OnClose();
}



// when the option to confirm on exit is selected 

void CMainFrame::OnOptionsConfirmonexit()

{

	m_bConfirmOnExit = ! m_bConfirmOnExit;

	theApp.WriteProfileInt(REGISTRY_VERSION, REGISTRY_CONFIRM_ON_EXIT,(BOOL)m_bConfirmOnExit); 



	UpdateOptionsMenu();

}

void CMainFrame::OnOptionsStopserveronexit()

{

	m_bStopServerOnExit = ! m_bStopServerOnExit;

	theApp.WriteProfileInt(REGISTRY_VERSION, REGISTRY_STOP_SERVER_ON_EXIT,(BOOL)m_bStopServerOnExit); 



	UpdateOptionsMenu();

}



void CMainFrame::OnSizing(UINT fwSide, LPRECT pRect)

{

	CMDIFrameWnd::OnSizing(fwSide, pRect);



	// TODO: Add your message handler code here

}


void CMainFrame::OnOptionsUseslimservertoplaymp3files()
{
	m_bAssociateMp3 = ! m_bAssociateMp3;
	theApp.WriteProfileInt(REGISTRY_VERSION, REGISTRY_ASSOCIATE_MP3,(BOOL)m_bAssociateMp3); 
	UpdateOptionsMenu();

}
