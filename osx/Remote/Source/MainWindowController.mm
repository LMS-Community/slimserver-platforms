//
//  MainWindowController.mm
//  SliMP3 Remote
//
//  Created by Dave Camp on Sun Dec 22 2002.
//  Copyright (c) 2002 David Camp Jr. All rights reserved.
//

/*
	ToDo list:
	-	Sleep (need to prompt for sleep time)
	-	Text messages (need to also prompt for sleep time, percent encode strings)
		Grab current text from display and use on main window (fixed width font)
		Maybe put some of above items in a drawer
		Repeat all/one button
		Progress bar display (might not be needed if pulling display text from server)
		Brightness
		Dragging in tracks sends URL to server (only if server is local)
		Remote button window (something that has all of the buttons on the physical remote)
	
	Things I need a second player for (either directly needed, or related to the comm re-work needed for multi-player support).
		Multiple player support (and associated comm re-work)
		Multiple server support
		Rendezvous support (connection UI changes on hold until new comm code written)
		Prefs window (server address, other options) (connection UI changes on hold until new comm code written)
		
	Communications re-work (On hold until my second device arrives. I don't want to waste time re-writing code to support multiple players without actually having multiple players to work/test with)
	
		See if some of the heavier stuff (playlists) can be more efficiently obtained via HTML.
		Go from a request/answer system to completely independent I/O. Requests should be sent and not wait for an answer (from both external calls and polling timer). Stream should be switched to a mode that posts notifications when data arrives. All data processing should happen from notifications.
		Move playlist retrieval to a separate connection/thread. This will allow it to progress without blocking other requests (also allows app to take user input earlier). This can probably be most easily done by having a connection class and two sub-classes: a command processor and a playlist retriever.
*/


#import "MainWindowController.h"
#import "ConnectPanelController.h"
#import "DisplayTextController.h"

// --------------------------------------------------------------------------------

@interface MainWindowController (PrivateMethods)

- (NSString*)secondsString:(double)value;
- (void)setStatusText:(NSString*)string;

@end

@implementation MainWindowController (PrivateMethods)

// --------------------------------------------------------------------------------

- (NSString*)secondsString:(double)value
{
	NSString	*string = nil;
	int			minutes = 0;
	int			seconds = 0;
	
	if (value > 60)
	{
		minutes = (int) (value / 60.0);
		value -= (minutes * 60);
	}
	
	seconds = (int) value;
	
	string = [NSString stringWithFormat:@"%2d:%2.2d", minutes, seconds];
	
	return string;
}

// --------------------------------------------------------------------------------

- (void)setStatusText:(NSString*)string
{
	if ([string length] == 0)
		[spinner stopAnimation:self];
	
	[statusField setStringValue:string];
}

@end

// --------------------------------------------------------------------------------

#pragma mark -

@implementation MainWindowController

- (id)init
{
	return [self initWithServer:nil port:0];
}

// --------------------------------------------------------------------------------

- (id)initWithServer:(NSString*)address port:(int)port
{
	self = [super init];
	
	serverAddress = [address copy];
	serverPort = port;
	
	NSBundle	*mainBundle = [NSBundle mainBundle];
	
	connection = [[SliMP3Connection alloc] init];
	connectionNotifications = [[ThreadNotificationCenter alloc] init];
	
	playIcon = [[NSImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"Play" ofType:@"icns"]];
	pauseIcon = [[NSImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"Pause" ofType:@"icns"]];
	
	playSmallIcon = [[NSImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"Play small" ofType:@"icns"]];
	pauseSmallIcon = [[NSImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"Pause small" ofType:@"icns"]];
	speakerIcon = [[NSImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"speaker" ofType:@"tiff"]];
	
	NSAssert(playIcon != nil, @"missing play icon");
	NSAssert(pauseIcon != nil, @"missing pause icon");
	NSAssert(playSmallIcon != nil, @"missing play icon");
	NSAssert(pauseSmallIcon != nil, @"missing pause icon");
	NSAssert(speakerIcon != nil, @"missing speaker icon");
	
	mode = kModeStop;
	
	// Register for notifications
	[connectionNotifications addObserver:self selector:@selector(connectionDidConnect:) name:SliMP3ConnectionComplete object:connection];

	[connectionNotifications addObserver:self selector:@selector(connectionDidConnect:) name:SliMP3ConnectionFailed object:connection];

	[connectionNotifications addObserver:self selector:@selector(connectionPlaylistDidChange:) name:SliMP3ConnectionPlaylistDidChangeNotification object:connection];

	[connectionNotifications addObserver:self selector:@selector(connectionSettingsDidChange:) name:SliMP3ConnectionSettingsDidChangeNotification object:connection];

	[connectionNotifications addObserver:self selector:@selector(connectionStatusDidChange:) name:SliMP3ConnectionStatusNotification object:connection];

	[connectionNotifications addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:[self window]];
	
	// Connect
	if ([serverAddress length] && serverPort)
		[connection connect:serverAddress port:serverPort center:connectionNotifications];

	return self;
}

// --------------------------------------------------------------------------------

- (void)dealloc
{
	[statusTimer invalidate];
	statusTimer = nil;
	
	[playIcon release];
	playIcon = nil;
	
	[pauseIcon release];
	pauseIcon = nil;

	[playSmallIcon release];
	playSmallIcon = nil;
	
	[pauseSmallIcon release];
	pauseSmallIcon = nil;

	[connection release];
	connection = nil;
	
	[connectionNotifications release];
	connectionNotifications = nil;
	
	[serverAddress release];
	serverAddress = nil;
}

// --------------------------------------------------------------------------------

- (void)windowWillClose:(NSNotification*)notification
{
	if (!windowIsZooming)
		[connection disconnect];
}

// --------------------------------------------------------------------------------

- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem
{
	BOOL	result = YES;
	SEL		action = [menuItem action];
	
	if (action == @selector(play:) || 
		action == @selector(nextTrack:) ||
		action == @selector(previousTrack:) ||
		action == @selector(shuffle:) ||
		action == @selector(repeat:) ||
		action == @selector(repeatOne:) ||
		action == @selector(repeatAll:) ||
		action == @selector(volume:)
		)
	{
		result = powerOn;
	}
	
	if (action == @selector(power:))
	{
		[menuItem setState:powerOn ? NSOnState : NSOffState];
	}
	else if (action == @selector(sleep:))
	{
		[menuItem setState:([connection sleep] == 0) ? NSOnState : NSOffState];
	}
	else if (action == @selector(volume:))
	{
		[menuItem setState:([connection volume] == 0) ? NSOnState : NSOffState];
	}
	else if (action == @selector(shuffle:))
	{
		[menuItem setState:[shuffleButton intValue] ? NSOnState : NSOffState];
	}
	else if (action == @selector(repeat:))
	{
		[menuItem setState:[connection repeat] == kRepeatOff ? NSOnState : NSOffState];
	}
	else if (action == @selector(repeatOne:))
	{
		[menuItem setState:[connection repeat] == kRepeatOne ? NSOnState : NSOffState];
	}
	else if (action == @selector(repeatAll:))
	{
		[menuItem setState:[connection repeat] == kRepeatAll ? NSOnState : NSOffState];
	}
	else if (action == @selector(setDisplayText:))
	{
		result = YES;
	}
	return result;
}

// --------------------------------------------------------------------------------

- (void)awakeFromNib
{
	// Setup the track list
	if (tracksView)
	{
		[tracksView setDoubleAction:@selector(playTrack:)];
		[tracksView setAutoresizesAllColumnsToFit:YES];
	}
	
	// Setup the spinner. IB seems to not set the spinning style correctly...
	if (spinner)
	{
		[spinner setStyle:NSProgressIndicatorSpinningStyle];
		[spinner setDisplayedWhenStopped:NO];
		[spinner stopAnimation:self];
		[spinner setUsesThreadedAnimation:YES];
	}
	
	// Initialize  display fields
	[self setStatusText:@""];
	[trackField setStringValue:@""];
	[timeField setStringValue:@""];
	
	NSImageCell	*cell = [[[NSImageCell alloc] init] autorelease];

	[cell setImageFrameStyle:NSImageFrameNone];
	[cell setImageScaling:NSScaleNone];
	[cell setImageAlignment:NSImageAlignCenter];
	[[tracksView tableColumnWithIdentifier:@"Playing"] setDataCell:cell];
	
	// Show the window!
	[self showWindow:self];
	[[self window] makeKeyAndOrderFront:self];
	
// This needs to happen from a notification...
//	[self setStatusText:@"Connecting"];
//	[spinner startAnimation:self];
	
	[self connectionSettingsDidChange:NULL];
}

// --------------------------------------------------------------------------------

- (BOOL)windowShouldZoom:(NSWindow *)sender toFrame:(NSRect)newFrame
{
	windowIsSmall = !windowIsSmall;
	windowIsZooming = YES;
	
	[[self window] close];
	if ([NSBundle loadNibNamed:windowIsSmall ? @"SmallWindow" : @"LargeWindow" owner:self])
	{
		(void) [self window];
		[self connectionSettingsDidChange:NULL];
		[self showWindow:self];
		[[self window] makeKeyAndOrderFront:self];
	}
	else
	{
		Debug(NSLog(@"Unable to load nib"));
	}
	
	windowIsZooming = NO;
	return NO;
}

#pragma mark -

// --------------------------------------------------------------------------------

- (void)connectionDidConnect:(NSNotification*)notification
{
	if ([[notification name] isEqualTo:SliMP3ConnectionFailed])
	{
		NSRunAlertPanel(@"Unable to connect to server.", @"Make sure the server is setup correctly and try again.", nil, nil, nil);
		[NSApp terminate:self];
	}
	else
	{
		Debug(NSLog(@"connected"));
	}
}

// --------------------------------------------------------------------------------

- (void)connectionSettingsDidChange:(NSNotification*)notification
{
	NSDate	*date = [[notification userInfo] objectForKey:@"Date"];
	BOOL	updateSettings = NO;
	
	if (date)
	{
		// The update is timestamped. Make sure it's later than the last command sent
		if ([date compare:[connection lastCommandDate]] == NSOrderedDescending)
		{
			updateSettings = YES;
			Debug(NSLog(@"settingsDidChange: taking update"));
		}
		else
		{
			Debug(NSLog(@"settingsDidChange: skipping update"));
		}
	}
	else
	{
		// No date, forced update
		updateSettings = YES;
		Debug(NSLog(@"settingsDidChange: forced update"));
	}
		
	if (updateSettings)
	{
		int		value = 0;
	
		// Get the power state
		powerOn = [connection power];
		[powerButton setEnabled:YES];
		[powerButton setState:powerOn];
		
		// Get the volume
		[volumeSlider setIntValue:[connection volume]];
		[shuffleButton setIntValue:[connection shuffle]];
		[repeatButton setIntValue:[connection repeat]];
	
		// Get the current mode
		PlayerMode	tempMode = [connection mode];
		NSString	*string = @"";
		switch (tempMode)
		{
			case kModePlay:
				[playButton setImage:windowIsSmall ? pauseSmallIcon : pauseIcon];
				string = @"Playing";
				break;
	
			case kModePause:
				[playButton setImage:windowIsSmall ? playSmallIcon : playIcon];
				string = @"Paused";
				break;
	
			case kModeStop:
				[playButton setImage:windowIsSmall ? playSmallIcon : playIcon];
				string = @"Stopped";
				break;
	
			case kModeOff:
				[playButton setImage:windowIsSmall ? playSmallIcon : playIcon];
				string = @"Off";
				break;
		}
		[self setStatusText:string];
		mode = tempMode;
		
		// Enable/disable buttons
		[playButton setEnabled:powerOn];
		[previousButton setEnabled:powerOn];
		[nextButton setEnabled:powerOn];
		[volumeSlider setEnabled:powerOn];
		[shuffleButton setEnabled:powerOn];
		[repeatButton setEnabled:powerOn];
		
		// Update the track and time fields
		[trackField setStringValue:[connection trackName]];
		[timeField setStringValue:[NSString stringWithFormat:@"Elapsed Time: %@", [self secondsString:[connection elapsedTime]]]];
		
		// Update the current track
		value = [connection track];
		if (value != track)
		{
			track = value;
			[tracksView reloadData];
		}
	}
}

// --------------------------------------------------------------------------------

- (void)connectionPlaylistDidChange:(NSNotification*)notification
{
	Debug(NSLog(@"playlistDidChange"));
	[playlist release];
	playlist = [[connection playlist] retain];
	[tracksView reloadData];
}

// --------------------------------------------------------------------------------

- (void)connectionStatusDidChange:(NSNotification*)notification
{
	NSString	*string = [[notification userInfo] objectForKey:@"StatusText"];
	[self setStatusText:string];
	if ([string length])
		[spinner startAnimation:self];
}

#pragma mark -

// --------------------------------------------------------------------------------

- (IBAction)playTrack:(id)sender
{
	if (sender == tracksView)
	{
		[connection playTrack:[tracksView selectedRow]];
	}
}

// --------------------------------------------------------------------------------

- (IBAction)previousTrack:(id)sender
{
	[connection prevTrack];
}

// --------------------------------------------------------------------------------

- (IBAction)nextTrack:(id)sender
{
	[connection nextTrack];
}

// --------------------------------------------------------------------------------

- (IBAction)play:(id)sender
{
	if (mode == kModePlay)
		[connection setMode:kModePause];
	else
		[connection setMode:kModePlay];
}

// --------------------------------------------------------------------------------

- (IBAction)power:(id)sender
{
	[connection setPower:!powerOn];
}

// --------------------------------------------------------------------------------

- (IBAction)sleep:(id)sender
{
	
}

// --------------------------------------------------------------------------------

- (IBAction)volume:(id)sender
{
	if (sender == volumeSlider)
	{
		[connection setVolume:[sender intValue]];
	}
	else
	{
		if ([sender tag] == 0)
			[connection setVolume:[connection volume] + 5];
		else if ([sender tag] == 1)
			[connection setVolume:[connection volume] - 5];
		else if ([sender tag] == 2)
			[connection setVolume:0];
		[volumeSlider setIntValue:[connection volume]];
	}
}

// --------------------------------------------------------------------------------

- (IBAction)shuffle:(id)sender
{
	[connection setShuffle:![connection shuffle]];
}

// --------------------------------------------------------------------------------

- (IBAction)repeat:(id)sender
{
	RepeatMode	value = kRepeatOff;
	
	if (sender == repeatButton)
		value = ([sender intValue] == 0) ? kRepeatOff : kRepeatAll;
		
	[connection setRepeat:value];
}

// --------------------------------------------------------------------------------

- (IBAction)repeatOne:(id)sender
{
	[connection setRepeat:kRepeatOne];
}

// --------------------------------------------------------------------------------

- (IBAction)repeatAll:(id)sender
{
	[connection setRepeat:kRepeatAll];
}

// --------------------------------------------------------------------------------

- (IBAction)setDisplayText:(id)sender
{
	NSArray	*array = [DisplayTextController promptUser];
	if (array)
	{
		[connection setDisplayText:[array objectAtIndex:0] line2:[array objectAtIndex:1]];
	}
}

@end

// --------------------------------------------------------------------------------

#pragma mark -

@implementation MainWindowController(NSTableDataSource)

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
	int	count = 0;
	
	if (tableView == tracksView)
		count = [playlist count];
	
	return count;
}

// --------------------------------------------------------------------------------

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	NSString	*identifier = [tableColumn identifier];
	id	object = nil;

	if (tableView == tracksView)
	{
		object = [[playlist objectAtIndex:row] objectForKey:[tableColumn identifier]];

		if ([identifier isEqualTo:@"Duration"])
		{
			NSNumber	*number = (NSNumber*) object;
			object = [self secondsString:(double) [number doubleValue]];
		}
		else if ([identifier isEqualTo:@"Playing"])
		{
			if (row == track)
				object = speakerIcon;
		}
	}
	return object;
}
@end
