//
//  SliMP3Connection.h
//  SliMP3 Remote
//
//  Created by Dave Camp on Mon Dec 23 2002.
//  Copyright (c) 2002 David Camp Jr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThreadNotificationCenter.h"

// --------------------------------------------------------------------------------

typedef enum
{
	kModePlay = 0,
	kModePause,
	kModeStop,
	kModeOff,
} PlayerMode;

typedef enum
{
	kRepeatOff = 0,	// Values directly correspond to numbers returned by server...
	kRepeatOne,
	kRepeatAll,
} RepeatMode;

// --------------------------------------------------------------------------------

@interface SliMP3Connection : NSObject
{
	NSString		*serverAddress;
	int				serverPort;
	int				socketToRemoteServer;
	NSFileHandle	*stream;
	NSTimer			*statusTimer;
	BOOL			keepRunning;
	BOOL			loopStopped;
	
	BOOL			connected;
	BOOL			power;
	int				sleepTime;
	PlayerMode		mode;
	int				volume;
	int				playlistCount;
	BOOL			shuffle;
	RepeatMode		repeat;
	int				track;
	
	ThreadNotificationCenter	*notificationCenter;
	ThreadNotificationCenter	*commandCenter;

	NSMutableArray	*playerList;
	int				playerIndex;
	
	// Accessed via a lock
	NSLock			*lock;
	NSMutableArray	*playlist;
	NSString		*trackName;
	double			elapsedTime;
	NSDate			*lastCommandPostedDate;
}

- (id)init;
- (void)dealloc;

- (void)connect:(NSString*)inAddress port:(int)inPort center:(ThreadNotificationCenter*)center;
- (void)disconnect;
- (NSDate*)lastCommandDate;

- (BOOL)power;
- (int)sleep;
- (int)volume;
- (BOOL)shuffle;
- (RepeatMode)repeat;
- (PlayerMode)mode;
- (int)track;

- (void)setPower:(BOOL)value;
- (void)setSleep:(int)value;
- (void)setVolume:(int)value;
- (void)setShuffle:(BOOL)value;
- (void)setRepeat:(RepeatMode)value;
- (void)nextTrack;
- (void)prevTrack;
- (void)playTrack:(int)index;
- (void)setMode:(PlayerMode)value;
- (void)setDisplayText:(NSString*)line1 line2:(NSString*)line2;

- (NSArray*)playlist;
- (NSString*)trackName;
- (double)elapsedTime;

@end

// --------------------------------------------------------------------------------

extern NSString *SliMP3ConnectionComplete;
extern NSString *SliMP3ConnectionFailed;
extern NSString *SliMP3ConnectionPlaylistDidChangeNotification;
extern NSString *SliMP3ConnectionSettingsDidChangeNotification;
extern NSString *SliMP3ConnectionStatusNotification;


@interface NSObject(SliMP3ConnectionNotifications)

- (void)connectionDidConnect:(NSNotification*)notification;
- (void)connectionSettingsDidChange:(NSNotification*)notification;
- (void)connectionPlaylistDidChange:(NSNotification*)notification;
- (void)connectionStatusDidChange:(NSNotification*)notification;

@end