#pragma once

class CSlimPrefs
{
private: 
	CSlimPrefs(void);
	CMapStringToString m_options; 
public:
	CSlimPrefs(const CString & filename);
	~CSlimPrefs(void);
	int GetSlimHttpPort(void);
	// Returns Currnt Music Folder 
	const CString& GetMusicFolder(void);
	const CString& GetPlaylistFolder(void);
};
