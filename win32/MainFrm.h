// MainFrm.h : interface of the CMainFrame class
//


#pragma once

class CMainFrame : public CMDIFrameWnd

{

	DECLARE_DYNAMIC(CMainFrame)

public:

	CMainFrame();



// Attributes

public:



// Operations

public:



// Overrides

public:

	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);



// Implementation

public:

	virtual ~CMainFrame();

#ifdef _DEBUG

	virtual void AssertValid() const;

	virtual void Dump(CDumpContext& dc) const;

#endif



protected:  // control bar embedded members

	CStatusBar  m_wndStatusBar;

	CToolBar    m_wndToolBar;

	CReBar		m_wndReBar;



// Generated message map functions

protected:

	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);

	DECLARE_MESSAGE_MAP()

public:

	afx_msg void OnDestroy();

	afx_msg LRESULT OnHandleIconNotify(UINT wParam, LONG lParam);    

protected:



public:

	afx_msg void OnSize(UINT nType, int cx, int cy);

private:

	// Hide the Slim Server window when minimized
	bool m_bHideWhenMinimized;

	// Confirm on Exit 
	bool m_bConfirmOnExit;

	// Stop server on Exit 
	bool m_bStopServerOnExit;

	// Associate MP3s  
	bool m_bAssociateMp3;

public:

	afx_msg void OnOptionsHideWhenMinimized();

private:

	// Updates the check boxes on the options menu

	void UpdateOptionsMenu(void);
	void OnUpdateConfirmOnExit(CCmdUI* pCmdUI) ;

	void OnUpdateConfirmStopServerOnExit(CCmdUI* pCmdUI); 


public:

	afx_msg void OnInitMenu(CMenu* pMenu);
	afx_msg void OnClose();
	afx_msg void OnOptionsConfirmonexit();
	afx_msg void OnOptionsStopserveronexit();
	afx_msg void OnSizing(UINT fwSide, LPRECT pRect);

	afx_msg void OnOptionsUseslimservertoplaymp3files();
};





