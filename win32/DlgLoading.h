#pragma once

#define RGBBLACK    RGB(0,0,0)
#define RGBWHITE  RGB(255,255,255)


// CDlgLoading dialog

class CDlgLoading : public CDialog
{
	DECLARE_DYNAMIC(CDlgLoading)

public:
	CDlgLoading(CWnd* pParent = NULL);   // standard constructor
	virtual ~CDlgLoading();

// Dialog Data
	enum { IDD = IDD_DIALOG_LOADING };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

	DECLARE_MESSAGE_MAP()
public:
	virtual BOOL OnInitDialog();
	afx_msg HBRUSH OnCtlColor(CDC* pDC, CWnd* pWnd, UINT nCtlColor);
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	afx_msg void OnBnClickedButtonExit();
	afx_msg void OnStnClickedLoading();
};
