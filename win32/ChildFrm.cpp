// ChildFrm.cpp : implementation of the CChildFrame class

#include "stdafx.h"
#include "SlimServer.h"
#include "ChildFrm.h"
#include "SlimServerDoc.h"
#include "MyHtmlView.h" 
#include "MyOutputView.h"



#ifdef _DEBUG

#define new DEBUG_NEW

#endif





// CChildFrame



IMPLEMENT_DYNCREATE(CChildFrame, CMDIChildWnd)



BEGIN_MESSAGE_MAP(CChildFrame, CMDIChildWnd)

	ON_WM_SIZE()

	ON_WM_SIZING()

	ON_COMMAND(ID_VIEW_DEBUGWINDOW, OnViewDebugwindow)

END_MESSAGE_MAP()





// CChildFrame construction/destruction



CChildFrame::CChildFrame()

: bSplitterCreated(false)

, m_bViewDebugWindow(false)

{

	// TODO: add member initialization code here

}



CChildFrame::~CChildFrame()

{

}



// this function creates the panes for a static splitter window

BOOL CChildFrame::OnCreateClient( LPCREATESTRUCT lpcs, 

   CCreateContext* pContext)

{



   BOOL bCreateSpltr = m_wndSplitter.CreateStatic( this, 2, 1);

   // COneView and CAnotherView are user-defined views derived from CMDIView

   m_wndSplitter.CreateView(0,0,RUNTIME_CLASS(CMyHtmlView), CSize(0,0), 

      pContext);

   m_wndSplitter.CreateView(1,0,RUNTIME_CLASS(CMyOutputView), CSize(0,0), 

      pContext);

	

   bSplitterCreated = (bCreateSpltr!=0);



   return (bCreateSpltr);

}



BOOL CChildFrame::PreCreateWindow(CREATESTRUCT& cs)

{

	// TODO: Modify the Window class or styles here by modifying the CREATESTRUCT cs

	if( !CMDIChildWnd::PreCreateWindow(cs) )

		return FALSE;



	cs.style = WS_CHILD | WS_VISIBLE 

		| WS_THICKFRAME | WS_MAXIMIZE;



	return TRUE;

}





// CChildFrame diagnostics



#ifdef _DEBUG

void CChildFrame::AssertValid() const

{

	CMDIChildWnd::AssertValid();

}



void CChildFrame::Dump(CDumpContext& dc) const

{

	CMDIChildWnd::Dump(dc);

}



#endif //_DEBUG





// CChildFrame message handlers



void CChildFrame::OnSize(UINT nType, int cx, int cy)

{

	CMDIChildWnd::OnSize(nType, cx, cy);

	

	if (bSplitterCreated && cy > 80 && nType == SIZE_MAXIMIZED) {


		int s = m_bViewDebugWindow?80:0;



		m_wndSplitter.SetRowInfo(0,cy - s ,10);

		m_wndSplitter.SetRowInfo(1,s,10);

		m_wndSplitter.RecalcLayout();

	}

}




void CChildFrame::OnViewDebugwindow()

{

	m_bViewDebugWindow = ! m_bViewDebugWindow; 



	CFrameWnd *pFrame = GetParentFrame();



	CMenu* pMenu = pFrame->GetMenu(); 

	pMenu->CheckMenuItem(ID_VIEW_DEBUGWINDOW,m_bViewDebugWindow?MF_CHECKED:MF_UNCHECKED);


	CRect cRect;

	GetClientRect( &cRect );



	int s = m_bViewDebugWindow?80:0;



	m_wndSplitter.SetRowInfo(0,(cRect.bottom - cRect.top) - s ,10);

	m_wndSplitter.SetRowInfo(1,s,10);

	m_wndSplitter.RecalcLayout();

}



