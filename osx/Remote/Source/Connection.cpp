/*
 *  Connection.cpp
 *  SliMP3
 *
 *  Created by Dave Camp on Sun Dec 15 2002.
 *  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
 *
 */

#include "Connection.h"

// --------------------------------------------------------------------------------

#define kPowerStateQuery	"power ?\n"
#define kPowerState 		"power %d\n"

#define kVolumeStateQuery	"mixer volume ?\n"
#define kVolumeState 		"mixer volume %d\n"

#define kIndexQuery			"playlist index ?\n"
#define kIndexState 		"playlist index %+d\n"

#define kModeQuery			"mode ?\n"
#define kModeState 			"mode %s\n"

// --------------------------------------------------------------------------------

Connection::Connection(void)
{
	readStream = nil;
	writeStream = nil;
	connected = false;
}

// --------------------------------------------------------------------------------

Connection::~Connection()
{
	Disconnect();
}

// --------------------------------------------------------------------------------

Boolean Connection::Connect(char* address, int port)
{
	struct sockaddr_in socketAddress;
	
	memset(&socketAddress, 0, sizeof(socketAddress));
	socketAddress.sin_family = AF_INET;
	inet_aton(address, &socketAddress.sin_addr);
	socketAddress.sin_port = htons(port);

	CFDataRef	addr = nil;
	
	addr = CFDataCreate(kCFAllocatorDefault, (UInt8*) &socketAddress, sizeof(socketAddress));
	CFSocketSignature sig = { PF_INET, SOCK_STREAM, IPPROTO_TCP, addr };
	
	// Create the streams.
	CFStreamCreatePairWithPeerSocketSignature(kCFAllocatorDefault, &sig, &readStream, &writeStream);
	
    if (CFReadStreamOpen(readStream))
	{
		if (CFWriteStreamOpen(writeStream))
		{
			connected = true;
		}
		else
		{
			CFReadStreamClose(readStream);
			readStream = nil;
		}
	}
	return (connected);
}

// --------------------------------------------------------------------------------

void Connection::Disconnect(void)
{
	if (readStream)
		CFReadStreamClose(readStream);
	readStream = nil;

	if (writeStream)
		CFWriteStreamClose(writeStream);
	writeStream = nil;
}

#pragma mark -

// --------------------------------------------------------------------------------

Boolean	Connection::GetPower(Boolean &value)
{
	Boolean	result = false;
	int		temp = 0;
	
	result = QueryInt(kPowerState, kPowerStateQuery, temp);
	if (result)
		value = temp;

	return (result);
}

// --------------------------------------------------------------------------------

Boolean	Connection::SetPower(Boolean value)
{
	Boolean	result = false;
	
	result = SetInt(kPowerState, kPowerStateQuery, value);
	
	return (result);
}

// --------------------------------------------------------------------------------

Boolean	Connection::GetVolume(int &value)
{
	Boolean	result = false;
	int		temp = 0;
	
	result = QueryInt(kVolumeState, kVolumeStateQuery, temp);
	if (result)
		value = temp;

	return (result);
}

// --------------------------------------------------------------------------------

Boolean	Connection::SetVolume(int value)
{
	Boolean	result = false;
	
	result = SetInt(kVolumeState, kVolumeStateQuery, value);
	
	return (result);
}

// --------------------------------------------------------------------------------

Boolean	Connection::PreviousTrack(void)
{
	Boolean	result = false;
	
	result = SetInt(kIndexState, kIndexQuery, -1);
	
	return (result);
}

// --------------------------------------------------------------------------------

Boolean	Connection::NextTrack(void)
{
	Boolean	result = false;
	
	result = SetInt(kIndexState, kIndexQuery, 1);
	
	return (result);
}

// --------------------------------------------------------------------------------

Boolean	Connection::GetMode(PlayerMode &value)
{
	Boolean	result = false;
	char	string[1024];

	value = kModeStop;
	result = QueryString(kModeState, kModeQuery, string, sizeof(string));
	if (result)
	{
		if (strcmp("play", string) == 0)
			value = kModePlay;
		else if (strcmp("pause", string) == 0)
			value = kModePause;
		else if (strcmp("stop", string) == 0)
			value = kModeStop;
		else if (strcmp("off", string) == 0)
			value = kModeOff;
	}
	return (result);
}

// --------------------------------------------------------------------------------

Boolean	Connection::SetMode(PlayerMode value)
{
	Boolean	result = false;
	char	*string = nil;
	
	switch(value)
	{
		case kModePlay:
			string = "play";
			break;

		case kModePause:
			string = "pause";
			break;

		case kModeStop:
			string = "stop";
			break;

		case kModeOff:
			string = "off";
			break;
	}
	if (string)
		result = SetString(kModeState, kModeQuery, string);
	
	return (result);
}

#pragma  mark -

// --------------------------------------------------------------------------------

Boolean	Connection::Write(void* buffer, CFIndex length)
{
	Boolean	result = false;
	if (connected)
	{
		CFIndex bytesTransferred = 0;
	
		bytesTransferred = CFWriteStreamWrite(writeStream, (UInt8*) buffer, length);
		if (bytesTransferred == length)
			result = true;
	}
	return (result);
}

// --------------------------------------------------------------------------------

Boolean	Connection::WriteInt(char* string, int value)
{
	Boolean	result = false;

	if (connected)
	{
		char	command[1024];
		UInt32	length = 0;
	
		memset(command, 0, sizeof(command));
		sprintf(command, string, value);
		length = strlen(command);
		
		result = Write(command, length);
	}
	return (result);
}

// --------------------------------------------------------------------------------

Boolean	Connection::WriteString(char* string, char* value)
{
	Boolean	result = false;

	if (connected)
	{
		char	command[1024];
		UInt32	length = 0;
	
		memset(command, 0, sizeof(command));
		sprintf(command, string, value);
		length = strlen(command);
		
		result = Write(command, length);
	}
	return (result);
}

// --------------------------------------------------------------------------------

Boolean	Connection::ReadInt(char* string, int &value)
{
	Boolean	result = false;
	if (connected)
	{
		char	buffer[1024];
		CFIndex bytesTransferred = 0;
		
		value = 0;
	
		bytesTransferred = CFReadStreamRead(readStream, (UInt8*) buffer, sizeof(buffer));
		if (bytesTransferred)
		{
			sscanf(buffer, string, &value);
			result = true;
		}
	}
	return (result);
}

// --------------------------------------------------------------------------------

Boolean	Connection::ReadString(char* string, int maxLength)
{
	Boolean	result = false;

	memset(string, 0, maxLength);
	if (connected)
	{
		CFIndex bytesTransferred = 0;
		
		bytesTransferred = CFReadStreamRead(readStream, (UInt8*) string, maxLength);
		if (bytesTransferred)
			result = true;
	}
	return (result);
}

// --------------------------------------------------------------------------------

Boolean	Connection::QueryInt(char* command, char* query, int &value)
{
	Boolean	result = false;
	
	if (connected)
	{
		CFIndex bytesTransferred = 0;
		if (Write(query, strlen(query)))
		{
			char	buffer[1024];
			bytesTransferred = CFReadStreamRead(readStream, (UInt8*) buffer, sizeof(buffer));
			if (bytesTransferred)
			{
				int	temp = 0;
				sscanf(buffer, command, &temp);
				value = temp;
				result = true;
			}
		}
	}
	return (result);
}

// --------------------------------------------------------------------------------

Boolean	Connection::SetInt(char* command, char* query, int value)
{
	Boolean	result = false;
	
	if (connected)
	{
		if (WriteInt(command, value))
		{
			int	temp = 0;
			if (ReadInt(command, temp))
			{
				if (temp == value)
					result = true;
			}
		}
	}
	return (result);
}

// --------------------------------------------------------------------------------

Boolean	Connection::QueryString(char* command, char* query, char* string, int maxLength)
{
	Boolean	result = false;
	
	string[0] = 0;
	if (connected)
	{
		CFIndex bytesTransferred = 0;
		if (Write(query, strlen(query)))
		{
			char	buffer[1024];
			
			memset(buffer, 0, sizeof(buffer));
			bytesTransferred = CFReadStreamRead(readStream, (UInt8*) buffer, sizeof(buffer));
			if (bytesTransferred)
			{
				int	answerLength;
				
				// The result string length is the query size minus 1
				answerLength = strlen(buffer) - (strlen(query) - 1);
				if (answerLength > maxLength)
					answerLength = maxLength - 1;
				::BlockMoveData(buffer + strlen(query) - 2, string, answerLength);
				string[answerLength] = 0;
				result = true;
			}
		}
	}
	return (result);
}

// --------------------------------------------------------------------------------

Boolean	Connection::SetString(char* command, char* query, char* string)
{
	Boolean	result = false;
	
	if (connected)
	{
		if (WriteString(command, string))
		{
			char	buffer[1024];
			if (ReadString(buffer, sizeof(buffer)))
			{
				char	temp[1024];
				sscanf(buffer, command, &temp);

				if (strcmp(temp, string) == 0)
					result = true;
			}
		}
	}
	return (result);
}
