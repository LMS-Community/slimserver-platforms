#pragma once

#include "ControlSlim.h"

// globals 

CString URLEncode(CString sIn);

BOOL GetFolder(CString* strSelectedFolder,
				   const char* lpszTitle,
				   const HWND hwndOwner, 
				   const char* strRootFolder, 
				   const char* strStartFolder); 

// CMyHtmlView html view 



class CMyHtmlView : public CHtmlView

{

	DECLARE_DYNCREATE(CMyHtmlView)


protected:

	CMyHtmlView();           // protected constructor used by dynamic creation
	virtual ~CMyHtmlView();

public:

#ifdef _DEBUG

	virtual void AssertValid() const;

	virtual void Dump(CDumpContext& dc) const;

#endif



protected:

	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support



	DECLARE_MESSAGE_MAP()

public:

	virtual void OnInitialUpdate();

	afx_msg void OnGoBack();
	afx_msg void OnGoForward();
	afx_msg void OnHome();
	afx_msg void OnRefresh();
	afx_msg void OnRescan();
	afx_msg void OnHelpUsingtheslimremote();
	afx_msg void OnHelpGettingstarted();
	afx_msg void OnHelpFAQ();
	afx_msg void OnHelpPlayersetup();
	afx_msg void OnHelpRemotecontrolreference();
	afx_msg void OnHelpTechnicalinformation();
	afx_msg LRESULT OnStartHTTP (UINT wParam, LONG lParam);    

	virtual void OnNavigateError(LPCTSTR lpszURL, LPCTSTR lpszFrame, DWORD dwError, BOOL *pbCancel);
	

private: 

	int m_iHttpPort;

	int m_iRetries;
	CControlSlim m_controlSocket; 

	// we disable navigation while this window is minimized to avoid constant web page refreshing 
	boolean m_bDisableNavigation; 

	// determines that the app has successfully started 
	boolean m_bAppStarted; 

	// full url till first / 
	inline CString GetHTTP_URL(void) {
		CString s;	
		s.Format(_T("http://localhost:%i"), m_iHttpPort); 
		return s;   	
	} 
public:


	afx_msg void OnOptionsSetmusicfolder();
	afx_msg void OnOptionsSetplaylistfolder();
	virtual void OnBeforeNavigate2(LPCTSTR lpszURL, DWORD nFlags, LPCTSTR lpszTargetFrameName, CByteArray& baPostedData, LPCTSTR lpszHeaders, BOOL* pbCancel);
	
	void RefreshPlayer(boolean bRefresh); 
	afx_msg void OnTimer(UINT nIDEvent);
};





