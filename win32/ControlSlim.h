#pragma once

#include "afxcoll.h"
#include "afxmt.h"

UINT ThreadFunc(LPVOID);
// attempts to process the commands in thread 
bool ProcessControlCommands(CEvent *, CStringArray &, int = 0);
bool TestHTTP(CEvent *,  int port = 9000, int timeout = 60000); 

// CControlSlim command target

class CControlSlim : public CWnd
{
	DECLARE_DYNAMIC(CControlSlim)

public:
	CControlSlim();
	virtual ~CControlSlim();

	// executes a command if possibe - will add it to the string list 
	// optionally you may perform a command without creating a thread
	void ExecCommand(const CString & command);

	// test http interface, will send a WM_USER_HTTP_STARTED once http is started 
	void TestHTTP(int port); 

	// test the control protocol, will send a WM_USER_CONTROL_STARTED once its started 
	void TestControl(void); 
	
	// used to start up the socket server 
	bool Start(HWND = NULL);

	// used in sychronous mode 
	void SyncAdd(const CString & command);

	// used in sync mode 
	bool SyncExec(int timeout = 10000); 

	
private:
	// contains commands we want to send to the Server
	CStringArray m_saQueue;
	// mutex for queue access
	CMutex m_mutex;
	// worker thread
	CWinThread *m_ptWorker;
	// to terminate worker thread 
	CEvent m_eTerminate; 
	// to test underlying control protocol 
	CEvent m_eTestControl;
	// to test http protocol
	CEvent m_eTestHTTP;
	// used when testing http protocol 
	int m_iHttpPort; 
protected:
	DECLARE_MESSAGE_MAP()
};


typedef struct tagTHREADPARAMS {
	CMutex * pMutex; 
	HWND hwnd;  
	CStringArray * psaQueue;
	CEvent * peTerminate; 
	CEvent * peTestControl; 
	CEvent * peTestHTTP; 
	int * httpPort; 

} THREADPARAMS;
