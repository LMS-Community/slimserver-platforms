#pragma once




// CMyOutputView view



class CMyOutputView : public CEditView

{

	DECLARE_DYNCREATE(CMyOutputView)



protected:

	CMyOutputView();           // protected constructor used by dynamic creation

	virtual ~CMyOutputView();



public:

#ifdef _DEBUG

	virtual void AssertValid() const;

	virtual void Dump(CDumpContext& dc) const;

#endif



protected:

	DECLARE_MESSAGE_MAP()

public:

	afx_msg void OnTimer(UINT nIDEvent);

	virtual void OnInitialUpdate();

	afx_msg void OnDestroy();

	bool StopPerlServer(void);

	static DWORD GetRunningProcess(CString sName);

	static bool DoneStarted(void);

private:

	// starts up the perl server 

	bool StartPerlServer(void);

	static bool Started;

	// used for reading stdout and err

	HANDLE					PipeReadHandle;

	// used for writing to stout and err

	HANDLE					PipeWriteHandle;

	// process info for SlimServer

	PROCESS_INFORMATION		ProcessInfo;

public:

	// log a message to window

	void LogText(const CString & msg);

};





