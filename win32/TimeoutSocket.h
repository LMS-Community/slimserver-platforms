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

class CTimeoutSocket : public CSocket
{
public:
	CTimeoutSocket();
	BOOL HadTimeout() const;
	void SetTimeoutLength(unsigned int length);
	virtual int Receive(void* lpBuf, int nBufLen, int nFlags = 0);
	virtual int Send(const void* lpBuf, int nBufLen, int nFlags);

protected:
	virtual int SendChunk(const void* lpBuf, int nBufLen, int nFlags);
	BOOL m_HadTimeout;
	unsigned int m_timeoutlength;
};
