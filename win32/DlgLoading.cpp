// DlgLoading.cpp : implementation file
//

#include "stdafx.h"
#include "SlimServer.h"
#include "DlgLoading.h"


// CDlgLoading dialog

IMPLEMENT_DYNAMIC(CDlgLoading, CDialog)
CDlgLoading::CDlgLoading(CWnd* pParent /*=NULL*/)
	: CDialog(CDlgLoading::IDD, pParent)
{
}

CDlgLoading::~CDlgLoading()
{
}

void CDlgLoading::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
}


BEGIN_MESSAGE_MAP(CDlgLoading, CDialog)
	ON_WM_CTLCOLOR()
	ON_WM_ERASEBKGND()
	ON_BN_CLICKED(IDC_BUTTON_EXIT, OnBnClickedButtonExit)
	ON_STN_CLICKED(IDC_LOADING, OnStnClickedLoading)
END_MESSAGE_MAP()


// CDlgLoading message handlers

BOOL CDlgLoading::OnInitDialog()
{
	CDialog::OnInitDialog();

	return TRUE;  // return TRUE unless you set the focus to a control
	// EXCEPTION: OCX Property Pages should return FALSE
}

HBRUSH CDlgLoading::OnCtlColor(CDC* pDC, CWnd* pWnd, UINT nCtlColor)
{
	HBRUSH hbr = CDialog::OnCtlColor(pDC, pWnd, nCtlColor);
	
	pDC->SetBkColor(RGB(255,255,255)); 
	pDC->SetBkMode(TRANSPARENT);

	// TODO:  Change any attributes of the DC here
	if (pWnd->GetDlgCtrlID() == IDC_LOADING)
	{
		// bold the text
		// pDC->set
	}

	// TODO:  Return a different brush if the default is not desired
	return CreateSolidBrush(RGB(255,255,255));
;
}

BOOL CDlgLoading::OnEraseBkgnd(CDC* pDC)
{

	CRect rc;
	GetClientRect(rc);
	pDC->FillSolidRect(rc, RGB(255,255,255));
	return TRUE;


	//return CDialog::OnEraseBkgnd(pDC);
}

void CDlgLoading::OnBnClickedButtonExit()
{
	AfxGetMainWnd()->PostMessage(WM_CLOSE, 0, 0);
}

void CDlgLoading::OnStnClickedLoading()
{
	// TODO: Add your control notification handler code here
}
