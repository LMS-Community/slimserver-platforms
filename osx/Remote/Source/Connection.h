/*
 *  Connection.h
 *  SliMP3
 *
 *  Created by Dave Camp on Sun Dec 15 2002.
 *  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
 *
 */

#include <Carbon/Carbon.h>

// --------------------------------------------------------------------------------

typedef enum
{
	kModePlay = 0,
	kModePause,
	kModeStop,
	kModeOff,
} PlayerMode;

// --------------------------------------------------------------------------------

class Connection
{
public:
						Connection(void);
	virtual				~Connection();

			Boolean		Connect(char* address, int port);
			void		Disconnect(void);
	
			Boolean		GetPower(Boolean &value);
			Boolean		SetPower(Boolean value);
			
			Boolean		GetVolume(int &value);
			Boolean		SetVolume(int value);
			
			Boolean		PreviousTrack(void);
			Boolean		NextTrack(void);
			
			Boolean		GetMode(PlayerMode &value);
			Boolean		SetMode(PlayerMode value);
			
protected:

	CFReadStreamRef		readStream;
	CFWriteStreamRef	writeStream;
	Boolean				connected;
	
	
			Boolean		Write(void* buffer, CFIndex length);
			Boolean		WriteInt(char* string, int value);
			Boolean		WriteString(char* string, char* value);
			
			Boolean		ReadInt(char* string, int &value);
			Boolean		ReadString(char* string, int maxLength);
			
			Boolean		QueryInt(char* command, char* query, int &value);
			Boolean		SetInt(char* command, char* query, int value);

			Boolean		QueryString(char* command, char* query, char* string, int maxLength);
			Boolean		SetString(char* command, char* query, char* string);
};
