// ControlSocket.cpp : implementation file
//

#include "stdafx.h"
#include "SlimServer.h"
#include "ControlSlim.h"
#include "TimeoutSocket.h"

BEGIN_MESSAGE_MAP(CControlSlim, CWnd)
END_MESSAGE_MAP()


// all events are set manually and unowned 

// CControlSlim
IMPLEMENT_DYNAMIC(CControlSlim, CWnd)
CControlSlim::CControlSlim() :
	m_eTerminate(FALSE,TRUE) , 
	m_eTestControl(FALSE,TRUE) , 
	m_eTestHTTP(FALSE,TRUE) 
{
	m_ptWorker = NULL; 
	m_iHttpPort = 9000;
}

CControlSlim::~CControlSlim()
{
	if (m_ptWorker) {

		// signal the shutting down of the thread 
		m_eTerminate.SetEvent(); 

		HANDLE hThread = m_ptWorker->m_hThread; 

		if (::WaitForSingleObject(hThread,5000) == WAIT_OBJECT_0) {
			// terminated cleanly 
		}  else {

			// messy way in case thread does not terminate 
			TerminateThread(hThread,0); 
		} 
	} 
}


// test http interface, will send a WM_USER_HTTP_STARTED once http is started 
void CControlSlim::TestHTTP(int port){
	
	m_mutex.Lock(); 
	m_iHttpPort = port;
	m_mutex.Unlock(); 

	if (!m_ptWorker) Start(); 
	m_eTestHTTP.SetEvent(); 
}  

// test the control protocol, will send a WM_USER_CONTROL_STARTED once its started 
void CControlSlim::TestControl() {
	
	if (!m_ptWorker) Start(); 
	m_eTestControl.SetEvent();
}  
	
// executes a command if possible - will add it to the string list 

void CControlSlim::ExecCommand(const CString & command)
{
	if (!m_ptWorker) Start(); 

	m_mutex.Lock(); 
	m_saQueue.Add(command);
	m_mutex.Unlock(); 
}

// add a command without executing it 
void CControlSlim::SyncAdd(const CString & command) 
{
	m_mutex.Lock();
	m_saQueue.Add(command);
	m_mutex.Unlock(); 
}  

// executes all commands in the queue 
// used in synchronous mode 
bool CControlSlim::SyncExec(int timeout) 
{

	bool rval;

	// exec queue in synchronous mode 
	// notice that the mutex will hold for quite a while ... 
	m_mutex.Lock();
	rval = ProcessControlCommands(&m_eTerminate ,m_saQueue,timeout);
	// should already be removed from queue 
	m_saQueue.RemoveAll();
	m_mutex.Unlock(); 

	return (rval); 
} 

// used to start up the socket server 
// handle to window that wants to be notified 
// defaults to this window 
bool CControlSlim::Start(HWND hwnd)
{
	if (hwnd == NULL) hwnd = m_hWnd;

	// kick off the worker thread 
	if (! m_ptWorker ) {

		THREADPARAMS * pParams; 
		pParams = new(THREADPARAMS); 
		
		pParams->pMutex = & m_mutex;
		pParams->peTerminate = & m_eTerminate; 
		pParams->peTestControl = & m_eTestControl; 
		pParams->peTestHTTP = & m_eTestHTTP; 
		pParams->psaQueue = & m_saQueue; 
		pParams->hwnd = hwnd;				// used when posting messages
		pParams->httpPort = (& m_iHttpPort); // for passing http port for testing 

		m_ptWorker = AfxBeginThread(ThreadFunc, pParams, 
				THREAD_PRIORITY_BELOW_NORMAL,0,CREATE_SUSPENDED);

		m_ptWorker->ResumeThread(); 
	}  

	return false;
}


UINT ThreadFunc(LPVOID pParams){
	
	THREADPARAMS * ptParams; 

	ptParams = (THREADPARAMS *) pParams; 


	CMutex *pMutex; 
	CStringArray *psaQueue;
	CEvent * peTerminate;
	CEvent * peTestHTTP;
	CEvent * peTestControl;
	int * piHttpPort; 

	HWND hwnd; 


	pMutex = ptParams->pMutex; 
	psaQueue = ptParams->psaQueue; 
	peTerminate = ptParams->peTerminate;
	peTestHTTP = ptParams->peTestHTTP;
	peTestControl = ptParams->peTestControl; 
	hwnd = ptParams->hwnd; 
	piHttpPort = ptParams->httpPort;

	delete ptParams; 
	
	// we need to do this or app will crash 
	AfxSocketInit(); 

	bool finished = false; 

	while (!finished) {
		
		// This duplicates the data so socket does not block while performing operations  
		CStringArray saQueueTemp;
		
		pMutex->Lock();
		saQueueTemp.Copy(*psaQueue); 
		psaQueue->RemoveAll(); 
		pMutex->Unlock(); 
		
		// process commands if we have to ... 
		if (saQueueTemp.GetSize() > 0) { 
			ProcessControlCommands(peTerminate, saQueueTemp); 	
		}

		// check our events 
		if (::WaitForSingleObject(peTestControl->m_hObject,0) == WAIT_OBJECT_0)
		{
			// signalled 
			peTestControl->ResetEvent();
			
			// process empty queue 
			if (ProcessControlCommands(peTerminate,saQueueTemp)){
				// signal success 
				SendMessage(hwnd,WM_USER_CONTROL_STARTED,0,0); 
			}
		} 
		
		if (::WaitForSingleObject(peTestHTTP->m_hObject,0) == WAIT_OBJECT_0)
		{
			int port;
			pMutex->Lock(); 
			port = *piHttpPort; 
			pMutex->Unlock();
				
			peTestHTTP->ResetEvent(); 
			
			// signal success 
			if (TestHTTP(peTerminate,port)) {
				SendMessage(hwnd,WM_USER_HTTP_STARTED,0,0); 
			} 
		}
		if (::WaitForSingleObject(peTerminate->m_hObject,0) == WAIT_OBJECT_0)
			finished = true; 

		Sleep(100); 
	}  

	return 0; 
} 


// test HTTP server - blocking function 
bool TestHTTP(CEvent *peTerminate, int port, int timeout) 
{

	CTimeoutSocket *pSocket; 
	bool success = false; 

	// create a cestron socket
	pSocket = new CTimeoutSocket(); 
	pSocket->Create(); 
	
	int tLeft = timeout;

	// try connecting - retry every 100 msecs 
	while (	!pSocket->Connect(_T("localhost"), port ) && 
			!(::WaitForSingleObject(peTerminate->m_hObject,0) == WAIT_OBJECT_0) &&
			tLeft > 0) {
		Sleep(100); 
		TRACE ("connect failed - %i!\n", GetLastError()); 
		tLeft -= 100; 
	}  

	
	// set timeout 
	pSocket->SetTimeoutLength(tLeft); 

	if (!(::WaitForSingleObject(peTerminate->m_hObject,0) == WAIT_OBJECT_0) && 
			tLeft >0) {
		
		const int BUFSIZE = 500; 
		char buffer[BUFSIZE]; 
		int l; 

		CString sBuf; 
		
		sBuf = _T("GET /home.html HTTP/1.0\n\n");  

		// write command to socket 
		pSocket->Send(sBuf.GetBuffer() ,sBuf.GetLength(), 0); 
		sBuf.ReleaseBuffer();
		TRACE("passed command: %s\n", sBuf);
					
		// waiting info 
		while ((l = pSocket->Receive(buffer,sizeof(buffer)-sizeof(char))) > 0)
		{
			buffer[l] = 0; 
			sBuf = buffer;
			TRACE("got reply: %s\n", sBuf);
			
			// maybe add something more sophisticated 
			success = true; 
		} 		
	}  
	
	// must close or app will crash 
	pSocket->ShutDown();
	pSocket->Close();
	delete pSocket;

	return success; 
}


// attempts to process the commands 
// true on success 
bool ProcessControlCommands(CEvent * peTerminate, CStringArray & saCommands, int timeout) 
{

	CTimeoutSocket *pSocket; 
	int i;
	bool success = false; 

	// create a cestron socket
	pSocket = new CTimeoutSocket(); 
	pSocket->Create(); 
 

	int tLeft = timeout; 
	if (timeout == 0) tLeft = 1; 

	// try connecting - retry every 100 msecs 
	while (!pSocket->Connect(_T("localhost"),9001) && 
		!(::WaitForSingleObject(peTerminate->m_hObject,0) == WAIT_OBJECT_0) && 
		tLeft > 0) {
		Sleep(100); 
		
		if (timeout > 0) tLeft -= 100; 

		TRACE ("connect failed - %i!\n", GetLastError()); 
	}  
	
	// set the timeout to the actual time left 
	pSocket->SetTimeoutLength(timeout==0?1000:tLeft);

	if (!(::WaitForSingleObject(peTerminate->m_hObject,0) == WAIT_OBJECT_0)) {
		
		const int BUFSIZE = 4000; 
		char buffer[BUFSIZE]; 
		int l; 

		CString sBuf; 

		// process the queue 
		if (saCommands.GetSize() > 0) {
			// got stuff in queue process it 
			for (i=0;i<saCommands.GetSize();i++) {
					
				saCommands[i] += _T("\n"); 

				// write command to socket 
				pSocket->Send(saCommands[i].GetBuffer() ,saCommands[i].GetLength(), 0); 
				saCommands[i].ReleaseBuffer();
				TRACE("passed command: %s\n", saCommands[i]);	

			} 

			// recieve all waiting info 
			while ((l = pSocket->Receive(buffer,sizeof(buffer)-sizeof(char))) > 0)
			{
				buffer[l] = 0; 
				sBuf = buffer;
				TRACE("got reply: %s\n", sBuf);

				success = true;
			}	
		} 
			
	}  
	
	// must close or app will crash 
	pSocket->ShutDown();

	pSocket->Close();
	delete pSocket;

	return success;
}

