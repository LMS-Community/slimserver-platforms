/* CTimeoutSocket class by Tim Kosse (Tim.Kosse@gmx.de)
Version 1.0 - 03/15/2001
This class is a CSocket derived class that checks for timeouts.
Normally, CSocket would just block if a connection times out 
and as a result, no data can be send or received.
This class provides two new function:
- BOOL HadTimeout()
  Checks if a timeout occurred in a previous call of Receive 
  or Send.
- void SetTimeoutLength(unsigned int length)
  Sets the timeout to the specified amount of time (in seconds)
  If you don't call this function, the timeout is set
  to 30 seconds.

Just call send and receive as normal. Both functions will
return an error if no data could be sent/received within the
timeout period instead of blocking forever.  A call of 
GetLastError would return WSAECDONNABORTED. 
This class is especially usefull if you use CSocketFile.
Read and ReadString of the attached CArchive objects won't 
block forever.  

You can download this class from http://codeguru.earthweb.com
This class is used within FileZilla, an opensource MFC FTP 
client. It can be found on 
http://www.sourceforge.com/projects/filezilla

Feel free to use and modify this class as needed, as long as 
this text remains unchanged within the modified source files.
*/

#include "stdafx.h"
#include "timeoutsocket.h"

CTimeoutSocket::CTimeoutSocket()
{
	m_timeoutlength=30000;
	m_HadTimeout=FALSE;
}

int CTimeoutSocket::Receive(void* lpBuf, int nBufLen, int nFlags) 
{
	m_nTimeOut=0; //Set the internal timeout of CSocket. Only important for the message queue
	DWORD dwStartTime = GetTickCount();

	if (m_pbBlocking != NULL)
	{
		WSASetLastError(WSAEINPROGRESS);
		return  FALSE;
	}
	int nResult;
	while ((nResult = CAsyncSocket::Receive(lpBuf, nBufLen, nFlags)) == SOCKET_ERROR)
	{
		if (GetLastError() == WSAEWOULDBLOCK)
		{
			if (!PumpMessages(FD_READ))
				return SOCKET_ERROR;
		}
		else
			return SOCKET_ERROR;
		//Calculate the difference
		
		// second line is to avoid potential crashing evry 49.7 days. 
		if (GetTickCount() - dwStartTime > m_timeoutlength ||
			GetTickCount() - dwStartTime < 0)				
		{
			m_HadTimeout=TRUE;
			SetLastError(WSAECONNABORTED);
			return SOCKET_ERROR;
		}
	}
	return nResult;
}

void CTimeoutSocket::SetTimeoutLength(unsigned int length)
{
	if (length)
		m_timeoutlength=length;
}

BOOL CTimeoutSocket::HadTimeout() const
{
	return m_HadTimeout;
}

int CTimeoutSocket::Send(const void* lpBuf, int nBufLen, int nFlags)
{
	if (m_pbBlocking != NULL)
	{
		WSASetLastError(WSAEINPROGRESS);
		return  FALSE;
	}
	
	int nLeft, nWritten;
	PBYTE pBuf = (PBYTE)lpBuf;
	nLeft = nBufLen;

	while (nLeft > 0)
	{
		nWritten = SendChunk(pBuf, nLeft, nFlags);
		if (nWritten == SOCKET_ERROR)
			return nWritten;

		nLeft -= nWritten;
		pBuf += nWritten;
	}
	return nBufLen - nLeft;
}

int CTimeoutSocket::SendChunk(const void* lpBuf, int nBufLen, int nFlags)
{
	m_nTimeOut=0; //Set the internal timeout of CSocket. Only important for the message queue
	DWORD dwStartTime = GetTickCount();
	int nResult;
	while ((nResult = CAsyncSocket::Send(lpBuf, nBufLen, nFlags)) == SOCKET_ERROR)
	{
		if (GetLastError() == WSAEWOULDBLOCK)
		{
			if (!PumpMessages(FD_WRITE))
				return SOCKET_ERROR;
		}
		else
			return SOCKET_ERROR;
		
		
		// second line is to avoid potential crashing evry 49.7 days. 
		if (GetTickCount() - dwStartTime > m_timeoutlength ||
			GetTickCount() - dwStartTime < 0)	
		{
			m_HadTimeout=TRUE;
			SetLastError(WSAECONNABORTED);
			return SOCKET_ERROR;
		}
	}
	return nResult;
}
