// MyOutputView.cpp : implementation file

//



#include "stdafx.h"
#include "SlimServer.h"
#include "MyOutputView.h"
#include "DlgLoading.h"

// for process enumeration 
#include "ModuleInstance.h"


const int BUF_SIZE = 8192;

bool CMyOutputView::Started = 0;


// CMyOutputView

IMPLEMENT_DYNCREATE(CMyOutputView, CEditView)

CMyOutputView::CMyOutputView()

{

}



CMyOutputView::~CMyOutputView()

{

}



BEGIN_MESSAGE_MAP(CMyOutputView, CEditView)

	ON_WM_TIMER()

	ON_WM_DESTROY()

END_MESSAGE_MAP()





// CMyOutputView diagnostics



#ifdef _DEBUG

void CMyOutputView::AssertValid() const

{

	CEditView::AssertValid();

}



void CMyOutputView::Dump(CDumpContext& dc) const

{

	CEditView::Dump(dc);

}

#endif //_DEBUG





// CMyOutputView message handlers



void CMyOutputView::OnTimer(UINT nIDEvent)

{

	// Try to update the text on this view

	if (nIDEvent==TIMER_DEBUG) {

		// cool its our timer - check for anything new on stdout 

		

		DWORD	BytesLeftThisMessage = 0;
		DWORD	NumBytesRead;
		TCHAR	PipeData[BUF_SIZE]; 
		DWORD	TotalBytesAvailable = 0;
		BOOL	Success;

		// check if any new text is available 

		NumBytesRead = 0;

		Success = PeekNamedPipe
		( 

			PipeReadHandle,				// handle to pipe to copy from 

			PipeData,					// pointer to data buffer 

			1,							// size, in bytes, of data buffer 

			&NumBytesRead,				// pointer to number of bytes read 

			&TotalBytesAvailable,		// pointer to total number of bytes available

			&BytesLeftThisMessage		// pointer to unread bytes in this message 

		);





		if ( NumBytesRead )

		{

			Success = ReadFile

			(

				PipeReadHandle,		// handle to pipe to copy from 

				PipeData,			// address of buffer that receives data

				BUF_SIZE - 1,		// number of bytes to read

				&NumBytesRead,		// address of number of bytes read

				NULL				// address of structure for data for overlapped I/O

			);



			// more debugging needed ... 



			//------------------------------------------------------------------

			//	Zero-terminate the data.

			//------------------------------------------------------------------

			PipeData[NumBytesRead] = '\0';



			// append to debug window 

			CString str = PipeData;

			

			LogText(str); 

		}

	} 

	CEditView::OnTimer(nIDEvent);

}



void CMyOutputView::OnInitialUpdate()

{

	CEditView::OnInitialUpdate();



	// start the perl server ... 

	if (StartPerlServer()) {

		CDlgLoading dlg; 

		//dlg.DoModal(); 
		LogText(CString(_T("SlimServer has started!\n")));

		// go to the slim home page -- trying command line interface stuff now
		// AfxGetMainWnd()->SendMessage(WM_COMMAND, ID_GO_START_PAGE);
	}

	else {
		LogText(CString(_T("ERROR: SlimServer failed to start!\n")));
	} 


	// kickoff a timer to update the debug window  

	SetTimer(TIMER_DEBUG,500,NULL); 



}



void CMyOutputView::OnDestroy()

{

	CEditView::OnDestroy();



	// kill the timer used to update the debug window 

	KillTimer(TIMER_DEBUG); 

	if (theApp.GetProfileInt(REGISTRY_VERSION, REGISTRY_STOP_SERVER_ON_EXIT,TRUE)!=0) {
		StopPerlServer();
	}
}

bool CMyOutputView::DoneStarted(void) {
	return Started;
}

bool CMyOutputView::StopPerlServer(void) {
	BOOL Success = true;
	if (DoneStarted()) {
		// try to kill our slim process 
		if (!TerminateProcess (ProcessInfo.hProcess, 0)) {
			AfxMessageBox(_T("Warning:  Couldn't stop the SlimServer process."), MB_OK);
		}

		// cleanup - probably should put some debugging here ... 

		Success = CloseHandle(ProcessInfo.hThread);
		Success = CloseHandle(ProcessInfo.hProcess);
		Success = CloseHandle(PipeReadHandle);
		Success = CloseHandle(PipeWriteHandle);

	} else {
		// if we didn't start it, see if there's another one to kill,  kill, kill...
		CString app = SLIM_APP_NAME;
		DWORD dProcess = GetRunningProcess(app);
		if (dProcess) {
			HANDLE hProcess = OpenProcess(PROCESS_TERMINATE,FALSE,dProcess);

			if (hProcess) {
				if (!TerminateProcess(hProcess,0)) {
					AfxMessageBox(_T("Problem: Couldn't stop the SlimServer process. (2)"), MB_OK);
				}
				CloseHandle (hProcess); 
			} else {
				AfxMessageBox(_T("Problem: Couldn't find running server process to terminate."), MB_OK);
			}
		}
	}


	return (bool)Success;
}

DWORD CMyOutputView::GetRunningProcess(CString sName) {
		DWORD dProcess = 0; 

		CTaskManager           taskManager;
		CExeModuleInstance     *pProcess;
	//	CModuleInstance        *pModule;

		// Retrieves information about processes and modules.  
		// The taskManager dynamically decides whether to use ToolHelp library or PSAPI
		taskManager.Populate();

		// Enumerates all processes
		for (unsigned i = 0; i < taskManager.GetProcessCount(); i++)
		{
			CString s; 

			pProcess = taskManager.GetProcessByIndex(i);
			s = pProcess->Get_Name(); 

			if (s.GetLength() > sName.GetLength()) { 
				s = s.Right(sName.GetLength()); 
			}

			TRACE("%s\n",s);
			
			// do a case insensitive compare here because Win98 uppercases things...  sheesh...
			if (  s.CompareNoCase(sName) == 0) {
				dProcess = pProcess->Get_ProcessId();
				break;
			} 
		} // for
	return dProcess;
}

// starts up the perl server 

bool CMyOutputView::StartPerlServer(void)

{
	Started = false;
	CString app = SLIM_APP_NAME;
	CString svc = SLIM_SVC_NAME;

	// get out if the process is already running...
	if (GetRunningProcess(app) || GetRunningProcess(svc)) {
		return 1;
	}

	// cool no instances so launch new one 

	SECURITY_ATTRIBUTES		SecurityAttributes;

	STARTUPINFO				StartupInfo;

	BOOL					Success;



	//--------------------------------------------------------------------------

	//	Zero the structures.

	//--------------------------------------------------------------------------

	ZeroMemory( &StartupInfo,			sizeof( StartupInfo ));

	ZeroMemory( &ProcessInfo,			sizeof( ProcessInfo ));

	ZeroMemory( &SecurityAttributes,	sizeof( SecurityAttributes ));



	//--------------------------------------------------------------------------

	//	Create a pipe for the child's STDOUT.

	//--------------------------------------------------------------------------

	SecurityAttributes.nLength              = sizeof(SECURITY_ATTRIBUTES);

	SecurityAttributes.bInheritHandle       = TRUE;

	SecurityAttributes.lpSecurityDescriptor = NULL;



	Success = CreatePipe

	(

		&PipeReadHandle,		// address of variable for read handle

		&PipeWriteHandle,		// address of variable for write handle

		&SecurityAttributes,	// pointer to security attributes

		0						// number of bytes reserved for pipe (use default size)

	);



	if ( !Success )

	{

		return false;

	}	



	//--------------------------------------------------------------------------

	//	Set up members of STARTUPINFO structure.

	//--------------------------------------------------------------------------

	StartupInfo.cb           = sizeof(STARTUPINFO);
	StartupInfo.dwFlags      = STARTF_USESHOWWINDOW | STARTF_USESTDHANDLES;
	StartupInfo.wShowWindow  = SW_HIDE;
	StartupInfo.hStdOutput   = PipeWriteHandle;
	StartupInfo.hStdError    = PipeWriteHandle;



	
	CString s,d; 
	
	d = theApp.GetEXEPath();  
	d += _T("\\server\\");

	s = theApp.GetEXEPath();
	s += _T("\\server\\");
	s += SLIM_APP_NAME;
	s += _T(" --cliport 9090");



	//----------------------------------------------------------------------------

	//	Create the child process.

	//----------------------------------------------------------------------------

	Success = CreateProcess

	( 
		NULL,					// pointer to name of executable module
		LPTSTR(LPCSTR(s)),		// command line 
		NULL,					// pointer to process security attributes 
		NULL,					// pointer to thread security attributes (use primary thread security attributes)
		TRUE,					// inherit handles
		HIGH_PRIORITY_CLASS,	// creation flags
		NULL,					// pointer to new environment block (use parent's)
		LPTSTR(LPCSTR(d)),		// pointer to current directory name
		&StartupInfo,			// pointer to STARTUPINFO
		&ProcessInfo			// pointer to PROCESS_INFORMATION
	);                 

	DWORD err = GetLastError();

	if ( !Success )

	{

		return false;

	}

	
	Started = 1;
	return true;

}



// log a message to window

void CMyOutputView::LogText(const CString & msg)

{

	CString str;

	GetEditCtrl().GetWindowText(str);

	str += msg; 

	GetEditCtrl().SetWindowText(str);

}

