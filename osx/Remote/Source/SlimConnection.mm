//
//  SliMP3Connection.mm
//  SliMP3 Remote
//
//  Created by Dave Camp on Mon Dec 23 2002.
//  Copyright (c) 2002 David Camp Jr. All rights reserved.
//

/*
	Notes:
		The SliMP3Connection class is responsible for all communications with the SliMP3 server via the command line interface.
		
		The intended usage is for the application to create an instance of SliMP3Connection and call the connect method. Connect will start a new thread that performs all the network transactions. The caller is notified of progress and status changes via standard NSNotifications.

		The SliMP3Connection thread runs until a disconnect message is received. There is an timer task that periodically gets current status information from the server, and the caller is notified of changes when appropriate.
		
		 Requests from the caller to change server settings (e.g. setVolume) are not performed immediately. Instead, the request is converted into an internal form, and posted to a ThreadNotificationCenter. The connection thread observes these command notifications and executes them on it's thread, not the original caller's thread. This allows for completely asynchronous operation and minimal blocking of the main thread. Additionally, ThreadNotificationCenter currently guarantees that notifications are delivered at idle time, so they won't interrupt any run loop input sources currently executing (e.g. the timer task, or other pending commands).
	
	Future Improvements:
		The internal form that commands are converted to for processing is a bit limited (although all we need for now). This could be improved by using a more robust dictionary model.
		
		My method for parsing server responses is lame at best. I'm sure there must be a better way.
		
*/

#import "SlimConnection.h"
#import <unistd.h>

// --------------------------------------------------------------------------------

NSString *SliMP3ConnectionComplete = @"SliMP3ConnectionComplete";

NSString *SliMP3ConnectionFailed = @"SliMP3ConnectionFailed";

NSString *SliMP3ConnectionPlaylistDidChangeNotification = @"SliMP3ConnectionPlaylistDidChangeNotification";

NSString *SliMP3ConnectionSettingsDidChangeNotification = @"SliMP3ConnectionSettingsDidChangeNotification";

NSString *SliMP3ConnectionStatusNotification = @"SliMP3ConnectionStatusNotification";

// --------------------------------------------------------------------------------

const char *kPowerQuery =		"power ?\n";
const char* kPowerFormat =		"power %d\n";

const char *kSleepQuery =		"sleep ?\n";
const char* kSleepFormat =		"sleep %d\n";

const char* kVolumeQuery =		"mixer volume ?\n";
const char* kVolumeFormat = 	"mixer volume %d\n";

const char* kIndexQuery =		"playlist index ?\n";
const char* kIndexFormat = 		"playlist index %+d\n";
const char* kIndexAbsFormat = 	"playlist index %d\n";

const char* kModeQuery =		"mode ?\n";
const char* kModeFormat =		"mode %.10s\n";

const char* kPlaylistTracksQuery =	"playlist tracks ?\n";
const char* kPlaylistTracksFormat =	"playlist tracks %d\n";

const char* kShuffleQuery =		"playlist shuffle ?\n";
const char* kShuffleFormat =	"playlist shuffle %d\n";

const char* kRepeatQuery =		"playlist repeat ?\n";
const char* kRepeatFormat =		"playlist repeat %d\n";

const char*	kModePlayString =	"play";
const char*	kModePauseString =	"pause";
const char*	kModeStopString =	"stop";
const char*	kModeOffString =	"off";

const char*	kTimeQuery =		"time ?\n";
const char*	kTimeFormat =		"time %lf\n";

const char* kPlayerCountQuery =		"player count ?\n";
const char* kPlayerCountFormat =	"player count %d\n";

const char* kPlayerNameQuery =		"player name %d ?\n";
const char* kPlayerNameFormat =		"player name %s\n";

const char* kPlayerAddressQuery =	"player address %d ?\n";
const char* kPlayerAddressFormat =	"player address %s\n";

const char*	kPlaylistGenreQuery =		"playlist genre %d ?\n";
const char*	kPlaylistArtistQuery =		"playlist artist %d ?\n";
const char*	kPlaylistAlbumQuery =		"playlist album %d ?\n";
const char*	kPlaylistTitleQuery =		"playlist title %d ?\n";
const char*	kPlaylistDurationQuery =	"playlist duration %d ?\n";

// --------------------------------------------------------------------------------

@interface SliMP3Connection (PrivateMethods)

- (BOOL)writeString:(const char*)format value:(const char*)value;
- (BOOL)writeInt:(const char*)format value:(int)value;
- (NSString*)readString:(const char*)query;
- (BOOL)readInt:(const char*)format value:(int*)value;
- (BOOL)readDouble:(const char*)format value:(double*)value;
- (NSString*)queryString:(const char*)query;
- (BOOL)queryInt:(const char*)query format:(const char*)format value:(int*)value;
- (BOOL)queryDouble:(const char*)query format:(const char*)format value:(double*)value;
- (void)queryPlaylist;
- (void)postStatusText:(NSString*)string;
- (void)postConnectionFailedText:(NSString*)string;
- (void)pollPlayer:(id)sender;
- (void)postPlayerCommand:(const char*)format withInt:(int)value;
- (void)postPlayerCommand:(const char*)format withQuery:(const char*)query setting:(const char*)string;
- (void)processPlayerCommand:(NSNotification*)notification;
- (void)getPlayerAddresses;
- (void)doConnect:(id)object;

@end

// --------------------------------------------------------------------------------

#pragma mark -

@implementation SliMP3Connection

- (id)init
{
	self = [super init];
	mode = kModeOff;
	loopStopped = YES;
	keepRunning = YES;
	lastCommandPostedDate = [[NSDate date] retain];
	lock = [[NSLock alloc] init];
	
	// Stolen from MoreUnix.c from Apple
	{
		int err;
		struct sigaction signalState;
		err = sigaction(SIGPIPE, NULL, &signalState);
		if (err == 0)
		{
			signalState.sa_handler = SIG_IGN;
			err = sigaction(SIGPIPE, &signalState, NULL);
		}
	}
	return self;
}

// --------------------------------------------------------------------------------

- (void)dealloc
{
	[self disconnect];

	[playlist release];
	playlist = nil;
	
	[lastCommandPostedDate release];
	lastCommandPostedDate = nil;
	
	[playerList release];
	playerList = nil;
	
	[lock release];
	lock = nil;
}

#pragma mark -

// --------------------------------------------------------------------------------
// writeString
// Primitive method for sending a string value to the server

- (BOOL)writeString:(const char*)format value:(const char*)value
{
	BOOL	result = NO;
	if (connected)
	{
		char	command[1024];
	
		memset(command, 0, sizeof(command));
		sprintf(command, format, value);

		[stream writeData:[NSData dataWithBytesNoCopy:(void*) command length:strlen(command) freeWhenDone:NO]];
		result = YES;
	}
	return result;
}

// --------------------------------------------------------------------------------

- (BOOL)writeInt:(const char*)format value:(int)value
{
	BOOL	result = NO;
	if (connected)
	{
		char	command[1024];
	
		memset(command, 0, sizeof(command));
		sprintf(command, format, value);

		[stream writeData:[NSData dataWithBytesNoCopy:(void*) command length:strlen(command) freeWhenDone:NO]];
		result = YES;
	}
	return result;
}

#pragma mark -

// --------------------------------------------------------------------------------

- (NSString*)readString:(const char*)query
{
	NSString	*result = nil;
	
	if (connected)
	{
		NSData	*data = [stream availableData];
		if ([data length])
		{
			// The result string length is the query size minus 1
			int	answerLength = [data length] - (strlen(query) - 1);
			result = [NSString stringWithCString:((const char*)[data bytes]) + strlen(query) - 2 length:answerLength];

			result = [(NSString*) CFURLCreateStringByReplacingPercentEscapes(nil, (CFStringRef) result, CFSTR("")) autorelease];
		}
	}
	return result;
}

// --------------------------------------------------------------------------------
// readInt
// Primitive method for reading an int value from the server

- (BOOL)readInt:(const char*)format value:(int*)value
{
	BOOL	result = NO;
	
	*value = 0;
	if (connected)
	{
		NSData	*data = [stream availableData];
		if ([data length])
		{
			int	temp = 0;
			sscanf((const char*) [data bytes], format, &temp);
			*value = temp;
			result = YES;
		}
	}

	return result;
}

// --------------------------------------------------------------------------------
// readDouble
// Primitive method for reading a double value from the server

- (BOOL)readDouble:(const char*)format value:(double*)value
{
	BOOL	result = NO;
	
	*value = 0;
	if (connected)
	{
		NSData	*data = [stream availableData];
		if ([data length])
		{
			char	*buffer = new char[[data length] + 1];
			buffer[[data length]] = 0;
			[data getBytes:buffer];
			sscanf(buffer, format, value);
			result = YES;
		}
	}

	return result;
}

#pragma mark -

// --------------------------------------------------------------------------------
// queryString
// High level method for sending a query to the server and getting a string value back

- (NSString*)queryString:(const char*)query
{
	NSString	*result = nil;
	
	if (connected)
	{
		[stream writeData:[NSData dataWithBytesNoCopy:(void*) query length:strlen(query) freeWhenDone:NO]];
		
		result = [self readString:query];
	}
	return result;
}

// --------------------------------------------------------------------------------
// queryInt
// High level method for sending a query to the server and getting an int value back

- (BOOL)queryInt:(const char*)query format:(const char*)format value:(int*)value
{
	BOOL	result = NO;
	
	*value = 0;
	if (connected)
	{
		[stream writeData:[NSData dataWithBytesNoCopy:(void*) query length:strlen(query) freeWhenDone:NO]];
		
		result = [self readInt:format value:value];
	}

	return result;
}

// --------------------------------------------------------------------------------
// queryDouble
// High level method for sending a query to the server and getting a double value back

- (BOOL)queryDouble:(const char*)query format:(const char*)format value:(double*)value
{
	BOOL	result = NO;
	
	*value = 0;
	if (connected)
	{
		[stream writeData:[NSData dataWithBytesNoCopy:(void*) query length:strlen(query) freeWhenDone:NO]];
		
		result = [self readDouble:format value:value];
	}

	return result;
}

// --------------------------------------------------------------------------------
// queryPlaylist
// Get the current playlist contents from the server. This is an expensive operation
// and should only be done when needed.

- (void)queryPlaylist
{
	int	count = 0;

	[lock lock];
	{
		[playlist autorelease];
		playlist = [[NSMutableArray alloc] init];
	}
	[lock unlock];
	
	[self postStatusText:@"Retrieving playlist info"];

	if ([self queryInt:kPlaylistTracksQuery format:kPlaylistTracksFormat value:&count])
	{
		int	index;
		for (index = 0; index < count; index++)
		{
			NSMutableDictionary	*dict = [NSMutableDictionary dictionary];
			char	string[1024];
			
			sprintf(string, kPlaylistGenreQuery, index);
			[dict setObject:[self queryString:string] forKey:@"Genre"];

			sprintf(string, kPlaylistArtistQuery, index);
			[dict setObject:[self queryString:string] forKey:@"Artist"];

			sprintf(string, kPlaylistAlbumQuery, index);
			[dict setObject:[self queryString:string] forKey:@"Album"];

			sprintf(string, kPlaylistTitleQuery, index);
			[dict setObject:[self queryString:string] forKey:@"Title"];

			sprintf(string, kPlaylistDurationQuery, index);
			[dict setObject:[self queryString:string] forKey:@"Duration"];
			
			[lock lock];
			[playlist addObject:dict];
			[lock unlock];
			
			// Post an update every few tracks (makes UI smoother for long lists or slow connections)
			if ((index % 5) == 0)
			{
				[notificationCenter postNotificationName:SliMP3ConnectionPlaylistDidChangeNotification object:self];
			}
		}
		
	}
	
	[self postStatusText:@""];
}

#pragma mark -

// --------------------------------------------------------------------------------

- (void)postStatusText:(NSString*)string
{
	NSDictionary	*dict = [NSDictionary dictionaryWithObjectsAndKeys:string, @"StatusText", nil, nil];
	[notificationCenter postNotificationName:SliMP3ConnectionStatusNotification object:self userInfo:dict];
}

// --------------------------------------------------------------------------------

- (void)postConnectionFailedText:(NSString*)string
{
	NSDictionary	*dict = [NSDictionary dictionaryWithObjectsAndKeys:string, @"Text", nil, nil];
	[notificationCenter postNotificationName:SliMP3ConnectionFailed object:self userInfo:dict];
}

// --------------------------------------------------------------------------------

- (void)pollPlayer:(id)sender
{
	int			value = 0;
	BOOL		result = NO;
	NSString	*string = nil;
	BOOL		didChange = NO;
	double		tempDouble = 0.0;
	NSDate		*date = [NSDate date];
	
NS_DURING

	// Check the playlist track count. If it is different, the playlist changed...
	result = [self queryInt:kPlaylistTracksQuery format:kPlaylistTracksFormat value:&value];
	if (value != playlistCount)
	{
		playlistCount = value;
		[self queryPlaylist];
	}
	
	// Get the power state
	result = [self queryInt:kPowerQuery format:kPowerFormat value:&value];
	didChange |= (power != value);
	power = value;

	// Get the sleep state
	result = [self queryInt:kPowerQuery format:kSleepFormat value:&value];
	didChange |= (sleepTime != value);
	sleepTime = value;

	// Get the volume
	result = [self queryInt:kVolumeQuery format:kVolumeFormat value:&value];
	didChange |= (volume != value);
	volume = value;
	
	// Check shuffle
	result = [self queryInt:kShuffleQuery format:kShuffleFormat value:&value];
	didChange |= (shuffle != value);
	shuffle = value;
	
	// Check repeat
	result = [self queryInt:kRepeatQuery format:kRepeatFormat value:&value];
	didChange |= (repeat != (RepeatMode) value);
	repeat = (RepeatMode) value;
	
	// Get the mode
	PlayerMode	tempMode = kModeOff;
	string = [self queryString:kModeQuery];
	if ([string isEqualTo:@"play"])
		tempMode = kModePlay;
	else if ([string isEqualTo:@"pause"])
		tempMode = kModePause;
	else if ([string isEqualTo:@"stop"])
		tempMode = kModeStop;
	else if ([string isEqualTo:@"off"])
		tempMode = kModeOff;
	didChange |= (mode != tempMode);
	mode = tempMode;
	
	// Get the current track name
	string = [self queryString:"title ?\n"];
	if (![string isEqualTo:trackName])
	{
		[trackName release];
		trackName = [string retain];
		didChange = YES;
	}
	
	// Get the track number
	result = [self queryInt:kIndexQuery format:kIndexAbsFormat value:&value];
	didChange |= (track != value);
	track = value;
	
	// Check the elapsed time for the current track
	result = [self queryDouble:kTimeQuery format:kTimeFormat value:&tempDouble];
	didChange |= (elapsedTime != tempDouble);
	elapsedTime = tempDouble;

	// Post a notification if any of the settings changed
	if (didChange)
	{
		NSDictionary	*dict = [NSDictionary dictionaryWithObjectsAndKeys: date, @"Date", NULL, NULL];
		[notificationCenter postNotificationName:SliMP3ConnectionSettingsDidChangeNotification object:self userInfo:dict];
	}

NS_HANDLER
NS_ENDHANDLER

}

// --------------------------------------------------------------------------------

- (void)postPlayerCommand:(const char*)format withInt:(int)value
{
	[lastCommandPostedDate autorelease];
	lastCommandPostedDate = [[NSDate date] retain];
	
	NSDictionary	*dict = [NSDictionary dictionaryWithObjectsAndKeys: 
		[NSValue valueWithPointer:format], @"Format",
		[NSValue value:&value withObjCType:@encode(int)], @"Value",
		NULL, NULL];
	[commandCenter postNotificationName:@"processPlayerCommand" object:self userInfo:dict];
}

// --------------------------------------------------------------------------------

- (void)postPlayerCommand:(const char*)format withQuery:(const char*)query setting:(const char*)string
{
	[lastCommandPostedDate autorelease];
	lastCommandPostedDate = [[NSDate date] retain];
	
		NSDictionary	*dict = [NSDictionary dictionaryWithObjectsAndKeys: 
			[NSValue valueWithPointer:format], @"Format",
			[NSValue valueWithPointer:query], @"Query",
			[NSValue valueWithPointer:string], @"String",
			NULL, NULL];
	[commandCenter postNotificationName:@"processPlayerCommand" object:self userInfo:dict];
}

// --------------------------------------------------------------------------------

- (void)processPlayerCommand:(NSNotification*)notification
{
	NSDictionary	*dict = [notification userInfo];
	char			*format = (char*) [[dict objectForKey:@"Format"] pointerValue];
	char			*query = (char*) [[dict objectForKey:@"Query"] pointerValue];
	NSValue			*value = [dict objectForKey:@"Value"];
	char			*string = (char*) [[dict objectForKey:@"String"] pointerValue];
	
	if (value)
	{
		int	numberValue;
		[value getValue:&numberValue];
		if ([self writeInt:format value:numberValue])
		{
			int	temp;
			[self readInt:format value:&temp];
			if (temp != numberValue)
				Debug(NSLog(@"SliMP3Connection: Unable to set value"));
		}
	}
	else
	{
		if ([self writeString:format value:string])
		{
			NSString	*tempString = [self readString:query];
			NSString	*resultString = [NSString stringWithCString:string];
			if (![resultString isEqualTo:tempString])
				Debug(NSLog(@"SliMP3Connection: Unable to set string"));
		}
	}
}

// --------------------------------------------------------------------------------

- (void)getPlayerAddresses
{
	BOOL	result;
	int		playerCount = 0;
	
	playerList = [[NSMutableArray array] retain];
	result = [self queryInt:kPlayerCountQuery format:kPlayerCountFormat value:&playerCount];
	if (result)
	{
		int	index;
		for (index = 0; index < playerCount; index++)
		{
			NSMutableDictionary	*dict = [NSMutableDictionary dictionary];
			char	string[1024];
			
			sprintf(string, kPlayerNameQuery, index);
			[dict setObject:[self queryString:string] forKey:@"Name"];

			sprintf(string, kPlayerAddressQuery, index);
			[dict setObject:[self queryString:string] forKey:@"Address"];
			
			[playerList addObject:dict];
		}
	}
}

// --------------------------------------------------------------------------------

- (void)doConnect:(id)object
{
    NSAutoreleasePool	*pool = [[NSAutoreleasePool alloc] init];
	loopStopped = NO;
	{
		NSRunLoop	*runLoop = [NSRunLoop currentRunLoop];
		commandCenter = [[ThreadNotificationCenter alloc] init];

		[commandCenter addObserver:self selector:@selector(processPlayerCommand:) name:@"processPlayerCommand" object:self];
		
		struct sockaddr_in socketAddress;
		
		memset(&socketAddress, 0, sizeof(socketAddress));
		socketAddress.sin_family = AF_INET;
		inet_aton([serverAddress lossyCString], &socketAddress.sin_addr);
		socketAddress.sin_port = htons(serverPort);
	
		socketToRemoteServer = socket(AF_INET, SOCK_STREAM, 0);
		if (socketToRemoteServer > 0)
		{
			stream = [[NSFileHandle alloc] initWithFileDescriptor:socketToRemoteServer closeOnDealloc:YES];
	
			if (stream)
			{
				if (connect(socketToRemoteServer, (struct sockaddr*)&socketAddress, sizeof(socketAddress)) == 0)
				{
					connected = YES;
					Debug(NSLog(@"Connected"));
				}
				else
				{
					Debug(NSLog(@"Unable to connect"));
				}
			}
			else
			{
				Debug(NSLog(@"Unable to create streams"));
			}
		}
		else
		{
			Debug(NSLog(@"Unable to create socket"));
		}
		
		// Clear the status text
		[self postStatusText:@""];
		
		if (connected)
		{
			// Get the names and addresses of all the players on the server
			[self getPlayerAddresses];
			
			// Tell the world we have connected
			[notificationCenter postNotificationName:SliMP3ConnectionComplete object:self];
			
			// Start polling for changes
			statusTimer = [NSTimer scheduledTimerWithTimeInterval: 0.5
				target:self selector:@selector(pollPlayer:) userInfo:nil repeats:YES];
			
			// Run our runloop
			while (keepRunning)
			{
				[runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
			}

			// Clean up
			[statusTimer invalidate];
			statusTimer = nil;
			
			[stream release];
			stream = nil;
			
			if (socketToRemoteServer)
				close(socketToRemoteServer);
			socketToRemoteServer = nil;
		}
		else
		{
			[stream release];
			stream = nil;
			if (socketToRemoteServer)
				close(socketToRemoteServer);
			socketToRemoteServer = nil;
			[self postConnectionFailedText:@"Unable to connect to server."];
			Debug(NSLog(@"Unable to connect to server"));
		}
	}
	loopStopped = YES;
	[pool release];
}

#pragma mark -

// --------------------------------------------------------------------------------

- (void)connect:(NSString*)inAddress port:(int)inPort center:(ThreadNotificationCenter*)center
{
	serverAddress = [inAddress retain];
	serverPort = inPort;
	notificationCenter = [center retain];
	
	[NSThread detachNewThreadSelector:@selector(doConnect:) toTarget:self withObject:NULL];
}

// --------------------------------------------------------------------------------

- (void)disconnect
{
	keepRunning = NO;
	
	// Wait for the runloop to stop
	while (loopStopped == NO)
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.25]];
}

// --------------------------------------------------------------------------------

- (NSDate*)lastCommandDate
{
	return [[lastCommandPostedDate retain] autorelease];
}

#pragma mark -

// --------------------------------------------------------------------------------

- (BOOL)power
{
	return power;
}

// --------------------------------------------------------------------------------

- (int)sleep
{
	return sleepTime;
}

// --------------------------------------------------------------------------------

- (int)volume
{
	return volume;
}

// --------------------------------------------------------------------------------

- (BOOL)shuffle
{
	return shuffle;
}

// --------------------------------------------------------------------------------

- (RepeatMode)repeat
{
	return repeat;
}

// --------------------------------------------------------------------------------

- (PlayerMode)mode
{
	return mode;
}

// --------------------------------------------------------------------------------

- (NSArray*)playlist
{
	NSArray	*result = nil;

	[lock lock];
	if (playlist)
		result = [[playlist copy] autorelease];
	[lock unlock];
	
	return result;
}

// --------------------------------------------------------------------------------

- (NSString*)trackName
{
	NSString	*result = nil;

	[lock lock];
	result = [[trackName copy] autorelease];
	[lock unlock];
	
	if (!result)
		result = @"";
	return result;
}

// --------------------------------------------------------------------------------

- (double)elapsedTime
{
	return elapsedTime;
}

// --------------------------------------------------------------------------------

- (int)track
{
	return track;
}

#pragma mark -

// --------------------------------------------------------------------------------

- (void)setPower:(BOOL)value
{
	[self postPlayerCommand:kPowerFormat withInt:value];
}

// --------------------------------------------------------------------------------

- (void)setSleep:(int)value
{
	[self postPlayerCommand:kSleepFormat withInt:value];
}

// --------------------------------------------------------------------------------

- (void)setVolume:(int)value
{
	[self postPlayerCommand:kVolumeFormat withInt:value];
}

// --------------------------------------------------------------------------------

- (void)setShuffle:(BOOL)value
{
	[self postPlayerCommand:kShuffleFormat withInt:value];
}

// --------------------------------------------------------------------------------

- (void)setRepeat:(RepeatMode)value
{
	[self postPlayerCommand:kRepeatFormat withInt:(int) value];
}

// --------------------------------------------------------------------------------

- (void)nextTrack
{
	int	value = 1;
	[self postPlayerCommand:kIndexFormat withInt:value];
}

// --------------------------------------------------------------------------------

- (void)prevTrack
{
	int	value = -1;
	[self postPlayerCommand:kIndexFormat withInt:value];
}

// --------------------------------------------------------------------------------

- (void)playTrack:(int)index
{
	[self postPlayerCommand:kIndexAbsFormat withInt:index];
}

// --------------------------------------------------------------------------------

- (void)setMode:(PlayerMode)value
{
	const char	*setting = nil;
	
	switch(value)
	{
		case kModePlay:
			setting = kModePlayString;
			break;

		case kModePause:
			setting = kModePauseString;
			break;

		case kModeStop:
			setting = kModeStopString;
			break;

		case kModeOff:
			setting = kModeOffString;
			break;
	}

	if (setting)
		[self postPlayerCommand:kModeFormat withQuery:kModeQuery setting:setting];
}

// --------------------------------------------------------------------------------

- (void)setDisplayText:(NSString*)line1 line2:(NSString*)line2
{
	// Need to percent encode all non-alpha chars
	// Need to get the display time sent in
}

@end
