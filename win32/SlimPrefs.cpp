#include "StdAfx.h"
#include "slimprefs.h"


CSlimPrefs::CSlimPrefs(const CString & filename)
{

	CString strBuffer; 
	CString key,val; 
	int curPos; 

	CFileException e;
	try {
		// read the pref file 
		CStdioFile f; 
		
		if (! f.Open(filename, CFile::modeRead,&e))  return; 
		


		while (f.ReadString(strBuffer))
		{
			curPos = 0; 
			key = strBuffer.Tokenize(_T("="),curPos); 
			val = strBuffer.Mid(curPos); 

			m_options[(key.Trim())] = (val.Trim()); 

			TRACE("%s\n",strBuffer); 
		}

	}
	catch (CException *e) {
		TRACE ("Failed to open pref file!\n");
	}


	//CString s; 
	//POSITION pos = m_options.GetStartPosition();
	//while (pos != NULL) {
	//	CString strKey, strItem; 
	//	m_options.GetNextAssoc (pos, strKey, strItem);
	//	TRACE (_T("Key=%s; Item=%s;\n"),strKey,strItem);
	//} 


} 
CSlimPrefs::CSlimPrefs(void)
{
}

CSlimPrefs::~CSlimPrefs(void)
{
}

// Returns the http port
int CSlimPrefs::GetSlimHttpPort(void)
{

	CString s = m_options[_T("httpport")];	
	int p = atoi(LPCTSTR(s)); 
	p = (p==0?9000:p);

	return (p);  
}

// Returns Currnt Music Folder 
const CString& CSlimPrefs::GetMusicFolder(void)
{
	return (m_options[_T("audiodir")]);  
}

// Returns Currnt Play List Folder 
const CString& CSlimPrefs::GetPlaylistFolder(void)
{
	return (m_options[_T("playlistdir")]);  
}
